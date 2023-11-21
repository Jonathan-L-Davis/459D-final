module flop (input clk, rw,
    input [7:0] data_in, input [3:0] ir_write,
    output reg [5:0] opcode, 
    output reg [4:0] RS, RT, 
    output reg [15:0] immediate
    );
    bit [31:0] instruction;
    always @(posedge clk) begin
        if (rw == 0) //when reading
            case(ir_write)
                4'b0001:
                    instruction[7:0] = data_in;
                4'b0010:
                    instruction[15:8] = data_in;
                4'b0100:
                    instruction[23:16] = data_in;
                4'b1000:
                    instruction[31:24] = data_in;
            endcase
    end
    always @(*) begin
        opcode <= instruction[31:26];
        RS <= instruction[25:21];
        RT <= instruction[20:16];
        immediate <= instruction[15:0];
    end
endmodule