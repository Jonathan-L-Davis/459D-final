module mips(input bit clk, input bit reset,
    input bit grant_given, 
    output bit grant_request, output bit rw,
    input bit[7:0] data_in, output bit[7:0] data_out,
    output bit[8:0] address//upper bit is flag for gpio
    );

wire [5:0] op;


endmodule