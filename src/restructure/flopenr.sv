module flop (input clk, reset, en,
    input [7:0] d, 
    output reg [7:0] q
    );

    always @(posedge clk) begin
        if (reset) q <= 0;
        else if (en) q <= d;
    end
endmodule