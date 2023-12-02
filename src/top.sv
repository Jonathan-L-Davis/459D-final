module top(
    input clk_100MH, input isMealy_main, 
    input rst, input ctrl_input_main, 
    output reg clock_led,
    input [1:0] SW_input_main, 
    output [3:0] Anode_Activate_main,
    output [6:0] LED_out_main    
);

module display(
    input clk_100MHz_disp, 
    input [3:0] digit3, 
    input [3:0] digit2, 
    input [3:0] digit1,
    input [3:0] digit0, 
    output reg [3:0] Anode_Activate_disp, 
    output reg [6:0] LED_out_disp
);

 gpiomem gpio (input .clk(), input .rw_select,
 input [8:0] address, input [7:0] data_in, 
 output [7:0] data_out,

 input [3:0] buttons,
 input [15:0] switches,
 output [15:0] leds,
 output [3:0] digit3, digit2, digit1, digit0    
 );


 core core0 (
    input bit .clk(), input bit .reset(),
    input bit .grant_given(), 
    output bit .grant_request(), output bit .rw(),
    input bit[7:0] .data_in(), output bit[7:0] .data_out(),
    output bit[9:0] .address()//upper bit is flag for gpio
    );

 core core1 (
    input bit .clk(), input bit .reset(),
    input bit .grant_given(), 
    output bit .grant_request(), output bit .rw(),
    input bit[7:0] .data_in(), output bit[7:0] .data_out(),
    output bit[9:0] .address()//upper bit is flag for gpio
    );

bus system_bus(
    input bit .clk(),
    input bit .reset(),
    //core 0 interface
    input bit .core0_request(),
    output bit .core0_grant(),
    input bit [7:0] .core0_data_in(),
    output bit [7:0] .core0_data_out(),
    input bit .core0_address(),
    
    //core 1 interface
    input bit .core1_request(),
    output bit .core1_grant(),
    input bit [7:0] .core1_data(),
    output bit [7:0] .core1_data_out(),
    input bit .core1_address(),
    
    //RAM interface
    output bit [8:0] .RAM_address(),
    output bit [7:0] .RAM_data_in(),
    input bit  [7:0] .RAM_data_out(),
    output bit .rw()
    //GPIO interface
    
);


endmodule