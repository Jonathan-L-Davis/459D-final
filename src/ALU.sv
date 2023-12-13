module ALU( 
    input bit [7:0] reg_1, input bit [7:0] reg_2,// input data
    input bit [3:0]op,// function
    output bit [7:0] out);// output data

logic [15:0] selReg[1:0];
logic [15:0] midReg[1:0];


logic [7:0] res[15:0];

assign selReg[0] = reg_1;
assign selReg[1] = reg_2;

assign res[0] = selReg[0]+selReg[1];
assign res[1] = selReg[0]-selReg[1];
assign res[2] = selReg[0]&selReg[1];
assign res[3] = selReg[0]|selReg[1];
assign res[4] = selReg[0]<selReg[1];
assign res[5] = selReg[0]^selReg[1];
assign res[6] = selReg[0]<<selReg[1][2:0];
assign res[7] = selReg[0]>>selReg[1][2:0];
assign res[8] = 0;
assign res[9] = 0;
assign res[10] = 0;
assign res[11] = 0;
assign res[12] = 0;
assign res[13] = 0;
assign res[14] = 0;
assign res[15] = 0;

assign out = res[op];


endmodule