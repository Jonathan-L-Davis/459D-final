module ALU( 
    input bit [7:0] reg_1, input bit [7:0] reg_2,// input data
    input bit [3:0] alucont,// function
    output bit [7:0] out,
    output bit zero_flag);// output data

    logic [15:0] selReg[1:0];
    logic [15:0] midReg[1:0];


    logic [7:0] add_result;
    logic [7:0] sub_result;
    logic [7:0] and_result;
    logic [7:0]  or_result;
    logic [7:0] xor_result;
    logic [7:0] slt_result;


    assign selReg[0] = reg_1;
    assign selReg[1] = reg_2;

    assign and_result = selReg[0]&selReg[1];
    assign  or_result = selReg[0]|selReg[1];
    assign add_result = selReg[0]+selReg[1];
    assign xor_result = selReg[0]^selReg[1];
    assign sub_result = selReg[0]-selReg[1];
    assign slt_result = selReg[0]<selReg[1];

    always @(*) begin//used to update ALU flags, removed flags for now.
    end

    always @(*) begin//*
        case(alucont)
        3'b000: out <= and_result;
        3'b001: out <=  or_result;
        3'b010: out <= add_result;
        3'b101: out <= xor_result;
        3'b110: out <= sub_result;
        3'b111: out <= slt_result;
        endcase//*/
        assign zero_flag = (out==0)? 1:0;
    end

endmodule