`timescale 1ns/1ps

module core_tb();
    
    bit clk,reset;
    bit grant_given, grant_request;
    bit rw;
    bit [7:0] data_in, data_out;
    bit [8:0] addr;
    
    core DUT(
    .clk(clk),
    .reset(reset),
    .grant_given(grant_given), 
    .grant_request(grant_request),
    .rw(rw),
    .data_in(data_in),
    .data_out(data_out),
    .address(addr)
    );
    
    bit reg_rw;
    bit [3:0] state;
    bit [31:0] IR;
    bit [5:0] instr_opcode;
    initial begin
        reset = 1;
        #1ps clk = 0;
        #1ps clk = 1;
        
        #1ps clk = 0;
        reset = 0;
        #1ps clk = 1;
        
        DUT.IR = 32'h80000000;//lb into register 0, should do nothing
        DUT.state = 4;// first decode/execute step
        //DUT.register_file.reg_file[1];
        state = DUT.state;
        IR = DUT.IR;
        reg_rw = DUT.reg_rw;
        instr_opcode = DUT.IR[31:26];
        #1ps clk = 0;
        #1ps clk = 1;
        
        //grant_given = 1;
        data_in = 8'h55;
        state = DUT.state;
        IR = DUT.IR;
        reg_rw = DUT.reg_rw;
        instr_opcode = DUT.IR[31:26];
        
        #1ps clk = 0;
        #1ps clk = 1;
        state = DUT.state;
        IR = DUT.IR;
        reg_rw = DUT.reg_rw;
        instr_opcode = DUT.IR[31:26];
        
        #1ps clk = 0;
        #1ps clk = 1;
        state = DUT.state;
        IR = DUT.IR;
        reg_rw = DUT.reg_rw;
        instr_opcode = DUT.IR[31:26];
        
        #1ps clk = 0;
        #1ps clk = 1;
        state = DUT.state;
        IR = DUT.IR;
        reg_rw = DUT.reg_rw;
        instr_opcode = DUT.IR[31:26];
        
        #1ps clk = 0;
        #1ps clk = 1;
        state = DUT.state;
        IR = DUT.IR;
        reg_rw = DUT.reg_rw;
        instr_opcode = DUT.IR[31:26];
        
        #1ps clk = 0;
        #1ps clk = 1;
        state = DUT.state;
        IR = DUT.IR;
        reg_rw = DUT.reg_rw;
        instr_opcode = DUT.IR[31:26];
        
        
        
    end
    
endmodule