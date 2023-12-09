module top(
    //input clk_100MHz, 
    //input rst,
    output [3:0] Anode_Activate,
    output [6:0] LED_out,
    input [3:0] buttons,
    input [15:0] switches,
    output [15:0] leds       
);


bit clk_100MHz,rst;
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
reg grant_given_cpu1, grant_request_cpu1, rw_cpu1;
reg[7:0] data_in_cpu1, data_out_cpu1;
reg[8:0] address_cpu1;

display disp(
    .clk_100MHz_disp(clk_100MHz), 
    .digit3(digit3), 
    .digit2(digit2), 
    .digit1(digit1),
    .digit0(digit0), 
    .Anode_Activate_disp(Anode_Activate), 
    .LED_out_disp(LED_out)
);


gpiomem mem_gpio (.clk(clk_100MHz),.rw_select(rw_mem),
    .reset(rst),
    .address(address_mem), .data_in(data_in_mem), 
    .data_out(data_out_mem),
    .buttons(buttons),
    .switches(switches),
    .leds(leds),
    .digit3(digit3), .digit2(digit2), .digit1(digit1), .digit0(digit0)    
);


core core0 (
    .clk(clk_100MHz),.reset(rst),
    .grant_given(grant_given_cpu0), 
    .grant_request(grant_request_cpu0),
    .rw(rw_cpu0),
    .data_in(data_in_cpu0), 
    .data_out(data_out_cpu0),
    .address(address_cpu0)
    );


bit [31:0] IR;
bit [7:0] register[7:1];
assign register = core0.register_file.file;
assign IR = core0.IR;

core core1 (
    //.clk(clk_100MHz), .reset(rst),
    .grant_given(grant_given_cpu1), 
    .grant_request(grant_request_cpu1), 
    .rw(rw_cpu1),
    .data_in(data_in_cpu1),
    .data_out(data_out_cpu1),
    .address(address_cpu1)
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

bit [2:0] bus_state;

assign bus_state = system_bus.state;

    initial begin
    
    
        rst = 1;
        
        clk_100MHz = 0;
        #1ps;
        clk_100MHz = 1;
        #1ps;
        
        rst = 0;
        
        
        mem_gpio.RAM[504] = 4;
        mem_gpio.RAM[503] = 1;
        
        for(int i = 0; i < 4096; i++) begin
            clk_100MHz = 0;
            #1ps;
            clk_100MHz = 1;
            #1ps;
        end
        
    end

endmodule