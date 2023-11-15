module smallALU( input bit [15:0] R[3:0], input bit [1:0] select1_reg, input bit [1:0] select2_reg, input bit sig, input bit op,  
    output bit [15:0] out1, output bit [15:0] out2, output bit add_result_flags);

logic [15:0] selReg[1:0];
logic [15:0] midReg[1:0];


logic [16:0] uadd_result;
logic [31:0] umul_result;
logic signed [15:0] sadd_result;
logic signed [31:0] smul_result;


assign selReg[0] = R[select1_reg];;
assign selReg[1] = R[select2_reg];

assign uadd_result = selReg[0]+selReg[1];
assign umul_result = selReg[0]*selReg[1];
assign sadd_result = $signed(selReg[0])+$signed(selReg[1]);
assign smul_result = $signed(selReg[0])*$signed(selReg[1]);

always @* begin
  if(sig) begin
    add_result_flags = (selReg[0][15]==selReg[1][15])&(selReg[0][15]!=sadd_result[15]);
  end else begin
    add_result_flags = uadd_result[16];
  end

end

always @* begin
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
    end
end



endmodule