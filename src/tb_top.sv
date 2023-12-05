
`timescale 1ns/1ps

typedef enum {RTYPE, ITYPE, JTYPE} form_e;
parameter ADDR_SPACE = 512;
class RandInstructions;
    rand form_e instruction_type;
    rand bit [31:0] instruction;
    rand bit [4:0] rs, rt, rd;
    rand bit [5:0] opcode, funct;
    rand bit[15:0] immediate_addr;
    rand bit [25:0] address;
    bit [4:0] shamt = 5'b00000;


    constraint c_operand{
        case (instruction_type)
            RTYPE: opcode == 6'b000000;
            ITYPE: opcode inside {[6'b000100, 6'b001000, 6'b100000, 6'b101000]};
            JTYPE: opcode == 6'b000010;
            default: opcode == 6'b000000;
        endcase
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
        immediate_addr inside {[4'h0000:4'hFFFF]};
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
            JTYPE: instruction == {opcode, rs, rt, rd, shamt, funct};
            default: instruction == {opcode, address};
        endcase;
    }

    
endclass

class RandTransactions;
    rand RandInstructions trans_array;

    function new();
            trans_array = new[ADDR_SPACE/4];
            foreach (trans_array[i]) begin
                trans_array[i] = new();
            end
        endfunction
endclass




module tb_top (); /* this is automatically generated */

    RandTransactions Transactions;
    int file;

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
            $fwrite(file, "%h\n", Transactions[7:0]);
            $fwrite(file, "%h\n", Transactions[15:8]);
            $fwrite(file, "%h\n", Transactions[23:16]); 
            $fwrite(file, "%h\n", Transactions[31:24]); 
        end

        // Close the file
        $fclose(file);
    end

    // (*NOTE*) replace reset, clock, others
    logic        clk_100MHz;
    logic        rst;
    logic  [3:0] Anode_Activate;
    logic  [6:0] LED_out;
    logic  [3:0] buttons;
    logic [15:0] switches;
    logic [15:0] leds;
    // clock
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

    task init();
        buttons    <= '0;
        switches   <= '0;
    endtask

    task drive(int iter);
        for(int it = 0; it < iter; it++) begin
            buttons    <= '0;
            switches   <= '0;
            @(posedge clk);
        end
    endtask

    initial begin
        // do something

        init();
        repeat(10)@(posedge clk);

        drive(20);

        repeat(10)@(posedge clk);
        $finish;
    end
    // dump wave
    initial begin
        $display("random seed : %0d", $unsigned($get_initial_random_seed()));
        if ( $test$plusargs("fsdb") ) begin
            $fsdbDumpfile("tb_top.fsdb");
            $fsdbDumpvars(0, "tb_top", "+mda", "+functions");
        end
    end
endmodule
