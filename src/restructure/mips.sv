module mips(input bit clk, input bit reset,
    input bit grant_given, 
    output bit grant_request, output bit rw,
    input bit[7:0] data_in, output bit[7:0] data_out,
    output bit[8:0] address//upper bit is flag for gpio
    );

    wire [5:0] op;
    wire zero_flag, pcen, pcwritecond, pcwrite;
    reg memread, memwrite, alusrca, memtoreg, iord;
    reg regwrite, regdst;
    reg [1:0] pcsource, alusrcb, aluop;
    reg [3:0] irwrite

    reg [7:0] MemData, alu_a, alu_b, reg_data1, reg_data2, a_reg, b_reg;
    reg [7:0] pc_reg, pc_new_reg;
    controller controller_inst(.clk(clk), .reset(reset), .op(op), 
        .zero(zero_flag), .memread(memread), .memwrite(memwrite),
        .alusrca(alusrca), .memtoreg(memtoreg), .iord(iord),
        .pcen(pcen), .regwrite(regwrite), .regdst(regdst), 
        .pcsource(pcsource), .alusrcb(alusrcb), .aluop(aluop)
        .irwrite(irwrite));

    alucontrol alucontrol_inst(.aluop(aluop), 
        .funct(funct), .alucont(alucont));

    pccontroller pccontroller_inst(.clk(clk), .zeroflag(zeroflag), 
        .pcwritecond(pcwritecond), .pcwrite(pcwrite), .pcen(pcen));
    
    flop a_register(.clk(clk),.d(), .q(a_reg));
    flop b_register(.clk(clk),.d(), .q(b_reg));
    flopenr pc_register(.clk  (clk), .reset(reset), .d(pc_new_reg), .q(pc_reg), .en(pcen))

    mux2_1_8bit alu_src_a_mux(.select(alusrca), .out(alu_a), .a(pc_reg), .b(a_reg))
    
    mux2_1_8bit mem_addr_mux(.select(memread), .out(MemData), .a(), .b());

    ALU alu_inst (.reg_1(reg_1));
    module ALU( 
    input bit [7:0] reg_1, input bit [7:0] reg_2,// input data
    input bit [3:0] alucont,// function
    output bit [7:0] out,
    output bit zero_flag);// output data

endmodule