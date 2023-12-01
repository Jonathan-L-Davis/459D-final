module memory (input clk, input rw_select,
 input [8:0] address, input [7:0] data_in, 
 output [7:0] data_out
 );
    reg [7:0] RAM[511:0];

    always @(posedge clk) begin
        if(rw_select == 1) begin // Write operation
            RAM[address] <= data_in;
        end else begin
            data_out <= RAM[address];
        end
    end

    initial begin
        $readmemh("mem_test.dat", RAM);
    end
endmodule