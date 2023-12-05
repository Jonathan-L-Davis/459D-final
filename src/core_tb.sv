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
    
    initial begin
        reset = 1;
        #1ps clk = 0;
        #1ps clk = 1;
        reset = 0;
        #1ps clk = 0;
        #1ps clk = 1;
        
        
        DUT.IR = 32'h00000000;
        DUT.state = 4;// first decode/execute step
        
        #1ps clk = 0;
        #1ps clk = 1;
        
        #1ps clk = 0;
        #1ps clk = 1;
        
        #1ps clk = 0;
        #1ps clk = 1;
        
        #1ps clk = 0;
        #1ps clk = 1;
        
        #1ps clk = 0;
        #1ps clk = 1;
        
        #1ps clk = 0;
        #1ps clk = 1;
        
        
        
    end
    
endmodule