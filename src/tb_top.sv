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
            is_store_instruction dist {1'b1 :/ 4, 1'b0 :/ 6}; // store 40%, , others are 60%
        }
    }

    constraint c_operand {
        if (instruction_type == RTYPE) {
            opcode == 6'b000000;
        } else if (instruction_type == ITYPE) {
            if (is_store_instruction) {
                opcode == 6'b101000;
            } else {
                (opcode == 6'b000100) || (opcode == 6'b001000) || (opcode == 6'b100000);
            }
        } else if (instruction_type == JTYPE) {
            opcode == 6'b000010;
        } else {
            opcode == 6'b000000;
        }
    }


    constraint c_function{
        if (instruction_type == RTYPE){
           (funct == 6'b100000) || (funct == 6'b100010) || (funct == 6'b100100) || (funct == 6'b100101) || (funct == 6'b101010);
        }else{
            funct == 6'b100000;
        }
    }

    constraint c_rsrt{
            if(instruction_type == RTYPE){ 
                rs inside {[5'b00000:5'b11111]};
                rt inside {[5'b00000:5'b11111]};
                rd inside {[5'b00000:5'b11111]};
            }else if(instruction_type == ITYPE){ 
                rs inside {[5'b00000:5'b11111]};
                rt inside {[5'b00000:5'b11111]};
            }else{ 
                rs inside {[5'b00000:5'b11111]};
                rt inside {[5'b00000:5'b11111]};
                rd inside {[5'b00000:5'b11111]};
            }
    }

    constraint c_immediate{
        if (instruction_type == ITYPE){
            if((instruction_number >=0 || instruction_number <=31) && is_store_instruction){
                immediate_addr inside {[16'h0000:16'hFFFF]};
            }
        }else{
            immediate_addr == 16'h0000;
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
       if(instruction_type == RTYPE){ instruction == {opcode, rs, rt, rd, shamt, funct};
       }else if(instruction_type == ITYPE){ instruction == {opcode, rs, rt, immediate_addr};
        }else if(instruction_type == JTYPE){ instruction == {opcode, address};
        }else{instruction == {opcode, address};}
    }

endclass

class RandTransactions;
    rand RandInstructions trans_array[];

    function new();
            trans_array = new[ADDR_SPACE/4]; //128 instructions, 512 lines of data
            foreach (trans_array[i]) begin
                trans_array[i] = new();
            end
    endfunction
endclass


module tb_top (); 
    RandTransactions Transactions;
    int file;
    reg        clk_100MHz;
    reg        rst;
    logic  [3:0] Anode_Activate;
    logic  [6:0] LED_out;
    reg  [3:0] buttons = 0;
    reg [15:0] switches = 0;
    logic [15:0] leds;

    //vars for disp
    reg [3:0] digit3, digit2, digit1, digit0;

    //vars for gpiomem
    reg [7:0] data_out_mem, data_in_mem;
    reg [8:0] address_mem;
    reg rw_mem;

    //vars for core0
    reg grant_given_cpu0, grant_request_cpu0, rw_cpu0;
    reg[7:0] data_in_cpu0, data_out_cpu0;
    reg[8:0] address_cpu0;

    //vars for core1
    reg grant_given_cpu1;
    reg grant_request_cpu1 = 0;
    reg rw_cpu1;
    reg[7:0] data_in_cpu1, data_out_cpu1;
    reg[8:0] address_cpu1;




    initial begin
        clk_100MHz <= '0;
        forever #(1) clk_100MHz <= ~clk_100MHz;
    end

    int counter = 0;
    int iteration = 0;
    int loops;
    int counterMax = 1_000;
    int loopMax = 5;
    always @(posedge  clk_100MHz) begin
         counter = counter + 1;
         if(counter == counterMax) begin
            iteration = 1;
            loops = loops + 1;
            $display("loops: %d", loops);
            counter = 0;
        end else begin
            iteration = 0;
        end

        if (iteration) begin
            file = $fopen("testbench.dat", "w");

            if (file == 0) begin
                $display("Error: File could not be opened.");
                $finish;
            end

            Transactions = new();
            assert(Transactions.randomize()) else $fatal("Randomization failed");
            foreach (Transactions.trans_array[i]) begin  
                $fwrite(file, "%h\n", Transactions.trans_array[i].instruction[31:24]); 
                $fwrite(file, "%h\n", Transactions.trans_array[i].instruction[23:16]);
                $fwrite(file, "%h\n", Transactions.trans_array[i].instruction[15:8]);
                $fwrite(file, "%h\n", Transactions.trans_array[i].instruction[7:0]);            
            end
            // Close the file
            $fclose(file);

            rst <= '1;
            repeat(2)@(posedge clk_100MHz);
            rst <= '0;
            iteration = 0;
            $display("reset");
        end

        if(loops >= loopMax) begin
            $finish;
        end
    end

    gpiomem mem_gpio (
        .clk(clk_100MHz),
        .rw_select(rw_mem),
        .reset(rst),
        .address(address_mem), .data_in(data_in_mem), 
        .data_out(data_out_mem),
        .buttons(buttons),
        .switches(switches),
        .leds(leds),
        .digit3(digit3), .digit2(digit2), .digit1(digit1), .digit0(digit0)    
    );


    core #(.pc_start(0)) core0 (
        .clk(clk_100MHz),
        .reset(rst),
        .grant_given(grant_given_cpu0), 
        .grant_request(grant_request_cpu0),
        .rw(rw_cpu0),
        .data_in(data_in_cpu0), 
        .data_out(data_out_cpu0),
        .address(address_cpu0)
        );

    bus system_bus(
        .clk(clk_100MHz),
        .reset(rst),

        .core0_request(grant_request_cpu0),
        .core0_grant(grant_given_cpu0),
        .core0_data_in(data_out_cpu0),
        .core0_data_out(data_in_cpu0),
        .core0_address(address_cpu0),
        .core0_rw(rw_cpu0),
        
        .core1_request(grant_request_cpu1),
        .core1_grant(grant_given_cpu1),
        .core1_data_in(data_out_cpu1),
        .core1_data_out(data_in_cpu1),
        .core1_address(address_cpu1),
        .core1_rw(rw_cpu1),
        
        .RAM_address(address_mem),
        .RAM_data_in(data_in_mem),
        .RAM_data_out(data_out_mem),
        .rw(rw_mem)    
    );

    always @(posedge rst) begin
        $display("file rewritten");
        $readmemh("testbench.dat", mem_gpio.RAM);
    end


    class instruction_transitions;
        bit [31:0] last_inst, curr_inst; // New variables

        covergroup opcodes;
            inst_reg_opcodes: coverpoint core0.IR {
            //coverpoint current_inst {
                bins add = {32'b000000????????????????????100000};
                bins sub = {32'b000000????????????????????100010};
                bins and_instr = {32'b000000????????????????????100100};
                bins or_instr = {32'b000000????????????????????100101};
                bins slt = {32'b000000????????????????????101010};

                bins addi = {32'b001000??????????????????????????};
                bins beq = {32'b000100??????????????????????????};
                bins lb = {32'b100000??????????????????????????};
                bins sb = {32'b101000??????????????????????????};

                bins j = {32'b000010??????????????????????????};
            }

            last_inst_cp: coverpoint last_inst; 
            curr_inst_cp: coverpoint curr_inst; 

            cross_inst: cross last_inst_cp, curr_inst_cp; // Updated cross
        endgroup

        function sample();
            opcodes.sample();
        endfunction
    endclass

    instruction_transitions core0_instr_cov = new();

    always @(posedge clk_100MHz) begin
        if (core0.state == 4) begin
            core0_instr_cov.curr_inst = core0.IR;
            core0_instr_cov.sample();
            $display("sample");
            core0_instr_cov.last_inst = core0.IR;
        end
    end

endmodule
