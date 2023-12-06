`timescale 1ns/1ps

module bus_tb();
    
    bit clk,reset;
    //core 0 interface
    bit core0_request;
    bit core0_rw;
    bit core0_grant;
    bit [7:0] core0_data_in;
    bit [7:0] core0_data_out;
    bit [7:0] core0_address;
    
    //core 1 interface
    bit core1_request;
    bit core1_rw;
    bit core1_grant;
    bit [7:0] core1_data_in;
    bit [7:0] core1_data_out;
    bit [7:0] core1_address;
    
    //RAM interface
    bit [8:0] RAM_address;
    bit [7:0] RAM_data_in;
    bit [7:0] RAM_data_out;
    bit rw;
    
    bit [1:0] state;
    
    bus bussy(
        
        .clk(clk),
        .reset(reset),
        
        //core 0 interface
        .core0_request(core0_request),
        .core0_rw(core0_rw),
        .core0_grant(core0_grant),
        .core0_data_in(core0_data_in),
        .core0_data_out(core0_data_out),
        .core0_address(core0_address),
        
        //core 1 interface
        .core1_request(core1_request),
        .core1_rw(core1_rw),
        .core1_grant(core1_grant),
        .core1_data_in(core1_data_in),
        .core1_data_out(core1_data_out),
        .core1_address(core1_address),
        
        //RAM interface
        .RAM_address(RAM_address),
        .RAM_data_in(RAM_data_in),
        .RAM_data_out(RAM_data_out),
        .rw(rw)
    );
    
    initial begin
        
        // reset bus to start in an known state
        reset = 0;
        clk = 0;
        #1ps clk = 1;
        #1ps clk = 0;
        reset = 1;
        #1ps clk = 1;
        #1ps clk = 0;
        reset = 0;
        #1ps clk = 1;
        #1ps clk = 0;
        
        /*  Test Bench,
        *   
        *   test data reading
        *       cpu requests grant
        *       bus waits until it is done processing current events
        *       bus sends read request to RAM
        *       bus pushes request back to Core, sets success flag
        *           things to check
        *           
        *           bus
        *           
        */
        
        core0_request = 1;
        core0_address = 5;
        core0_rw = 1;
        RAM_data_out = 8'hFF;
        
        state = bussy.state;
        
        #1ps clk = 1;
        #1ps clk = 0;
        state = bussy.state;
        #1ps clk = 1;
        #1ps clk = 0;
        state = bussy.state;
        #1ps clk = 1;
        #1ps clk = 0;
        state = bussy.state;
        #1ps clk = 1;
        #1ps clk = 0;
        state = bussy.state;
        #1ps clk = 1;
        #1ps clk = 0;
        state = bussy.state;
        #1ps clk = 1;
        #1ps clk = 0;
        state = bussy.state;
        
        
        
        
        
        
        
        
        
        
        
    end
    
endmodule