
`timescale 1ns/1ps

typedef enum {RTYPE, ITYPE, JTYPE} type_e;
parameter ADDR_SPACE = 512;
class RandInstructions;
    rand type_e instruction_type;
    rand bit [31:0] instruction;
    rand bit [4:0] rs, rt, rd;
    rand bit [5:0] opcode, funct;
    rand bit[15:0] immediate_addr;
    rand bit [25:0] address;
    bit [4:0] shamt = 5'b00000;
    int instruction_number;
    rand bit is_store_instruction;


    //distribution of the instruction types
    constraint c_instruction_type {
        instruction_type dist { 
            RTYPE := 5,
            ITYPE := 3,   // ITYPE has a 30% chance
            JTYPE := 2 
        };
    }

    //distribution of store instructions based on if it is itype
    constraint c_itype_store {
        if (instruction_type == ITYPE) {
            is_store_instruction dist {1'b1 :/ 4, 1'b0 :/ 6}; // Store instruction 40%, , others are 60%
        }
    }

    constraint c_operand{
            if(instruction_type == RTYPE) opcode == 6'b000000;
            else if(instruction_type == ITYPE){
             if(is_store_instruction){
                    opcode = 6'b101000;  
                } else {
                    opcode inside {[6'b000100, 6'b001000, 6'b100000]};
                }
            }        
            else if(instruction_type == JTYPE) opcode == 6'b000010;
            else{ opcode == 6'b000000;}
    }

    constraint c_function{
        if (instruction_type == RTYPE){
            funct inside {[6'b100000, 6'b100010, 6'b100100, 6'b100101, 6'b101010]};
        }else{
            funct == 6'b100000;
        }
    }
    constraint c_rsrt{
        case (instruction_type)
            RTYPE: {rs, rt, rd} inside {[5'b00000:5'b11111]};
            ITYPE: {rs, rt} inside {[5'b00000:5'b11111]};
            default: {rs, rt, rd} inside {[5'b00000:5'b11111]};
        endcase
    }

    constraint c_immediate{
        if (instruction_type == ITYPE){
            if((instruction_number >=0 || instruction_number <=31) && is_store_instruction){
                immediate_addr inside {[4'h0000:4'h007C], [4'h00FC:4'hFFFF]};
            }else if((instruction_number >=32 || instruction_number <=63) && is_store_instruction){
                immediate_addr inside {[4'h0080:4'hFFFF]};
            }else{
                immediate_addr inside {[4'h0000:4'hFFFF]};
            }
        }else{
            immediate_addr == 4'h0000;
        }
    }

    constraint c_address{
        if (instruction_type == JTYPE){
            address inside {[26'b00_0000_0000_0000_0000_0000_0000:26'b11_1111_1111_1111_1111_1111_1111]};
        }else{
            immediate_addr == 26'b00_0000_0000_0000_0000_0000_0000;
        }
    }

    constraint c_instruction{
        case (instruction_type)
            RTYPE: instruction == {opcode, rs, rt, rd, shamt, funct};
            ITYPE: instruction == {opcode, rs, rt, immediate_addr};
            JTYPE: instruction == {opcode, address};
            default: instruction == {opcode, address};
        endcase;
    }

endclass

class RandTransactions;
    rand RandInstructions trans_array;

    function new();
            trans_array = new[ADDR_SPACE/4]; //128 instructions, 512 lines of data
            foreach (trans_array[i]) begin
                trans_array[i] = new();
            end
        endfunction
endclass


module tb_top (); /* this is automatically generated */

    RandTransactions Transactions;
    int file;
    // (*NOTE*) replace reset, clock, others
    logic        clk_100MHz;
    logic        rst;
    logic  [3:0] Anode_Activate;
    logic  [6:0] LED_out;
    logic  [3:0] buttons;
    logic [15:0] switches;
    logic [15:0] leds;
    // clock


//generate random instructions and write them to memory in big endian format
    initial begin
        file = $fopen("testbenchmem.dat", "w");

        if (file == 0) begin
            $display("Error: File could not be opened.");
            $finish;
        end

        Transactions = new();
        assert(Transactions.randomize()) else $fatal("Randomization failed");
        foreach(Transactions[i])begin
            $fwrite(file, "%h\n", Transactions[31:24]); 
            $fwrite(file, "%h\n", Transactions[23:16]);
            $fwrite(file, "%h\n", Transactions[15:8]);
            $fwrite(file, "%h\n", Transactions[7:0]);            
        end
        // Close the file
        $fclose(file);
    end

    
    initial begin
        clk_100MHz = '0;
        forever #(0.5) clk_100MHz = ~clk_100MHz;
    end

    // synchronous reset
    logic srstb;
    initial begin
        rst <= '1;
        repeat(10)@(posedge clk);
        rst <= '0;
    end

    

    top inst_top
        (
            .clk_100MHz     (clk_100MHz),
            .rst            (rst),
            .Anode_Activate (Anode_Activate),
            .LED_out        (LED_out),
            .buttons        (buttons),
            .switches       (switches),
            .leds           (leds)
        );



    bit [31:0] last_inst_core0, last_inst_core1, curr_inst_core0, curr_inst_core1;
    covergroup instruction_transitions(input int core_id)
        option.per_instance = 1;

        inst_reg_opcodes:
        coverpoint (core_id == 0 ? inst_top.core0.IR : inst_top.core1.IR) {
        //coverpoint current_inst {
            wildcard add = {32'b000000????????????????????100000};
            wildcard sub = {32'b000000????????????????????100010};
            wildcard and_instr = {32'b000000????????????????????100100};
            wildcard or_instr = {32'b000000????????????????????100101};
            wildcard slt = {32'b000000????????????????????101010};

            wildcard addi = {32'b001000????????????????????????????};
            wildcard beq = {32'b000100????????????????????????????};
            wildcard lb = {32'b100000????????????????????????????};
            wildcard sb = {32'b101000????????????????????????????};

            wildcard j = {32'b000010??????????????????????????????};
        }

        cross_inst:
             cross (core_id == 0 ? last_inst_core0 : last_inst_core1), (core_id == 0 ? curr_inst_core0 : curr_inst_core1);

    endgroup : instruction_transitions

    instruction_transitions core0_instr_cov = new(0);
    instruction_transitions core1_instr_cov = new(1);
    always @(posedge clk_100MHz) begin
        if (inst_top.core0.state == 4) begin
            curr_inst_core0 = inst_top.core0.IR;
            core0_instr_cov.sample(inst_top.core0.IR);
            last_inst_core0 = inst_top.core0.IR;
        end
        if (inst_top.core1.state == 4) begin
            curr_inst_core1 = inst_top.core1.IR;
            core1_instr_cov.sample(inst_top.core1.IR);
            last_inst_core1 = inst_top.core1.IR; 
        end
    end




    // task init();
    //     buttons    <= '0;
    //     switches   <= '0;
    // endtask

    // task drive(int iter);
    //     for(int it = 0; it < iter; it++) begin
    //         buttons    <= '0;
    //         switches   <= '0;
    //         @(posedge clk);
    //     end
    // endtask

    

    // initial begin
    //     // do something

    //     init();
    //     repeat(10)@(posedge clk);

    //     drive(20);

    //     repeat(10)@(posedge clk);
    //     $finish;
    // end
    // // dump wave
    // initial begin
    //     $display("random seed : %0d", $unsigned($get_initial_random_seed()));
    //     if ( $test$plusargs("fsdb") ) begin
    //         $fsdbDumpfile("tb_top.fsdb");
    //         $fsdbDumpvars(0, "tb_top", "+mda", "+functions");
    //     end
    // end
endmodule
