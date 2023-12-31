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
    rand bit is_beq_instruction;


    //distribution of the instruction types
    constraint c_instruction_type {
        instruction_type dist { 
            RTYPE := 5,
            ITYPE := 5,   // ITYPE has a 50% chance
            JTYPE := 0 
        };
    }

    //distribution of store instructions based on if it is itype
    constraint c_itype_store {
        if (instruction_type == ITYPE) {
            is_store_instruction dist {1'b1 :/ 25, 1'b0 :/ 75}; // store 25%, , others are 75%
        }
    }

    constraint c_itype_beq {
        if (instruction_type == ITYPE) {
            is_beq_instruction dist {1'b1 :/ 0, 1'b0 :/ 10}; // beq 0%, , others are 100%
        }
    }


    //set operand based nn instruction, if I type, 3 opcodes possible
    constraint c_operand {
        if (instruction_type == RTYPE) {
            opcode == 6'b000000;
        } else if (instruction_type == ITYPE) {
            if (is_store_instruction) {
                opcode == 6'b101000;
            } else if (is_beq_instruction){
                opcode == 6'b000100;
            } else{
                (opcode == 6'b001000) || (opcode == 6'b100000);
            }
        } else if (instruction_type == JTYPE) {
            opcode == 6'b000010;
        } else {
            opcode == 6'b000000;
        }
    }

    //set function based on instruction, RTYPE
    constraint c_function{
        if (instruction_type == RTYPE){
           (funct == 6'b100000) || (funct == 6'b100010) || (funct == 6'b100100) || (funct == 6'b100101) || (funct == 6'b101010);
        }else{
            funct == 6'b100000;
        }
    }

     //set rs, rt, rd based on instruction type
    constraint c_rsrt{
            if(instruction_type == RTYPE){ 
                rs inside {[5'b00000:5'b00111]};
                rt inside {[5'b00000:5'b00111]};
                rd inside {[5'b00000:5'b00111]};
            }else if(instruction_type == ITYPE){ 
                rs inside {[5'b00000:5'b00111]};
                rt inside {[5'b00000:5'b00111]};
            }else{ 
                rs inside {[5'b00000:5'b00111]};
                rt inside {[5'b00000:5'b00111]};
                rd inside {[5'b00000:5'b00111]};
            }
    }

    //set immediate address based on instruction type
    constraint c_immediate{
        if (instruction_type == ITYPE){
            if((instruction_number >=0 || instruction_number <=31) && is_store_instruction){
                immediate_addr inside {[16'h0000:16'h01FF]};
            }
        }else{
            immediate_addr == 16'h0000;
        }
    }

    //set jump address based on instruction type
    constraint c_address{
        if (instruction_type == JTYPE){
            address inside {[26'b00_0000_0000_0000_0000_0000_0000:26'b00_0000_00000_0000_0001_1111_1111]};
        }else{
            immediate_addr == 26'b00_0000_0000_0000_0000_0000_0000;
        }
    }

    //combine all based on instruction type
    constraint c_instruction{
       if(instruction_type == RTYPE){ instruction == {opcode, rs, rt, rd, shamt, funct};
       }else if(instruction_type == ITYPE){ instruction == {opcode, rs, rt, immediate_addr};
        }else if(instruction_type == JTYPE){ instruction == {opcode, address};
        }else{instruction == {opcode, address};}
    }

endclass

//class to store randomized instrucitons
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
        //open the data file, randomize, and store random instructions. 
        Transactions = new();

        file = $fopen("testbench.dat", "w");

        if (file == 0) begin
            $display("Error: File could not be opened.");
            $finish;
        end
        $display("randomizing");
        assert(Transactions.randomize()) else $fatal("Randomization failed");
        $display("randomized");
        foreach (Transactions.trans_array[i]) begin
            $display("wrote instruction %d", i);  
            $fwrite(file, "%h\n", Transactions.trans_array[i].instruction[31:24]); 
            $fwrite(file, "%h\n", Transactions.trans_array[i].instruction[23:16]);
            $fwrite(file, "%h\n", Transactions.trans_array[i].instruction[15:8]);
            $fwrite(file, "%h\n", Transactions.trans_array[i].instruction[7:0]);            
        end
        // Close the file
        $fclose(file);


        //start clock and reset
        clk_100MHz <= '0;
        forever #(1) clk_100MHz <= ~clk_100MHz;

        rst <= '1;
        repeat(2)@(posedge clk_100MHz);
        rst <= '0;
        $display("it done been randomized");

    end

    
    
    int counterMax = 1_000_000;
    int loopMax = 5;

    int counter = 0;
    int iteration = 0;
    int loops = 0;
    
    always @(posedge  clk_100MHz) begin

        //after so many clock cycles, rerandomize and reset the core with new instructions. 
         counter = counter + 1;
         if(counter == counterMax) begin
            iteration = 1;
            loops = loops + 1;
            $display("loops: %d", loops);
            counter = 0;
        end else begin
            iteration = 0;
        end

        if(loops >= loopMax) begin
            $finish;
        end

        if (iteration) begin
           
            file = $fopen("testbench.dat", "w");

            if (file == 0) begin
                $display("Error: File could not be opened.");
                $finish;
            end
            assert(Transactions.randomize()) else $fatal("Randomization failed");
            $display("randomized");
            foreach (Transactions.trans_array[i]) begin
                $display("wrote instruction %d", i);  
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
            $display("it done been randomized");
        end
    end


    //module declarations
    //memory/gpio
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

    //single core
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


    //system bus
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


    //whenever reset, read in the memory. 
    always @(posedge rst) begin
        $display("file rewritten");
        $readmemh("testbench.dat", mem_gpio.RAM);
    end


        //code coverage for instruction opcodes. Cross coverage to ensure all combinations are met. 
        bit [31:0] last_inst, curr_inst; // New variables

        covergroup opcodes;
            coverpoint curr_inst {
            //coverpoint current_inst {
                wildcard bins add = {32'b000000????????????????????100000};
                wildcard bins sub = {32'b000000????????????????????100010};
                wildcard bins and_instr = {32'b000000????????????????????100100};
                wildcard bins or_instr = {32'b000000????????????????????100101};
                wildcard bins slt = {32'b000000????????????????????101010};

                wildcard bins addi = {32'b001000??????????????????????????};
                wildcard bins beq = {32'b000100??????????????????????????};
                wildcard bins lb = {32'b100000??????????????????????????};
                wildcard bins sb = {32'b101000??????????????????????????};

                wildcard bins j = {32'b000010??????????????????????????};
            }

            coverpoint last_inst; 
            coverpoint curr_inst; 

            cross last_inst, curr_inst; // Updated cross
        endgroup

    opcodes core0_cov = new;
    initial begin
        core0_cov.start();
    end

    //take samples on the decode cycles of the core, when IR is stable. 
    always @(posedge clk_100MHz) begin
        if (core0.state == 4) begin
            curr_inst = core0.IR;
            core0_cov.sample();
            //$display("sample");
            $display("%t: Covergroup total coverage is %f", $time, core0_cov.get_coverage());
            last_inst = core0.IR;
        end
    end

endmodule
