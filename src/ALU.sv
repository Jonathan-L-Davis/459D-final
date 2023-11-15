module smallALU( input bit [15:0] R[3:0], 
    input bit [1:0] select1_reg, input bit [1:0] select2_reg, 
    input bit sig, input bit op,
    output bit [7:0] out);

logic [15:0] selReg[1:0];
logic [15:0] midReg[1:0];


logic [7:0] add_result;
logic [7:0] sub_result;
logic [7:0] and_result;
logic [7:0]  or_result;
logic [7:0] slt_result;


assign selReg[0] = R[select1_reg];;
assign selReg[1] = R[select2_reg];

assign add_result = selReg[0]+selReg[1];
assign sub_result = selReg[0]-selReg[1];
assign  or_result = selReg[0]|selReg[1];
assign and_result = selReg[0]&selReg[1];
assign slt_result = selReg[0]<selReg[1];


always @* begin//used to update ALU flags, removed flags for now.
end

always @* begin/*
    if(op) begin
        if(sig) begin
          out1 = smul_result[15:0];
        out2 = smul_result[31:16];
        end else begin
          out1 = umul_result[15:0];
        out2 = umul_result[31:16];
        end
    end else begin
      if(sig) begin
          out1 = sadd_result[15:0];
      end else begin
        out1 = uadd_result[15:0];
      end
    end//*/
end



endmodule