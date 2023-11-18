module core (
    input bit clk, input bit reset,
    input bit grant_given, 
    output bit grant_request, output bit rw,
    input bit[7:0] data_in, output bit[7:0] data_out,
    input bit[9:0] address
    );
    
    parameter o_ALU   =  0;
    parameter o_JMP   =  2;
    parameter o_JEQ   =  4;
    parameter o_ALUI  =  8;
    parameter o_LOAD  = 32;
    parameter o_STORE = 40;
    
    parameter f_ADD = 32;
    parameter f_SUB = 34;
    parameter f_AND = 36;
    parameter f_OR  = 37;
    parameter f_SLT = 42;
    
    //cpu internal state
    bit [3:0] state;
    
    bit [7:0] PC;
    bit [31:0] IR;
    
    bit [5:0] instr_opcode,instr_func;
    
    
    //ALU controls
    bit [7:0] alu_data1,alu_data2,alu_result;
    bit [3:0] alu_op;
    
    //register file controls
    bit [7:0] data_rs,data_rt,data_rd;
    bit [4:0] rs,rt,rd;
    bit reg_rw;
    
    reg_file REG_DUT(
        .clk(clk),
        .reset(reset)
        .rw(reg_rw),
        .RS(rs), .RT(rt), .RD(rd),
        .RS_data(data_rs),
        .RT_data(data_rt),
        .RD_data(data_rd)
    );
    
    ALU ALU_DUT(
        .reg_1(alu_data1),
        .reg_2(alu_data2),
        .op(alu_op),
        .out(alu_result)
    );
    
    always @ (posedge clk) begin
        
        if( reset ) begin
            
            //wipe core internal state
            state = 0;
            PC = 0;
            IR = 0;
            rw = 0;
            instr_opcode = 0;
            instr_func = 0;
            
            //set ALU controls to 0;
            alu_data1 = 0;
            alu_data2 = 0;
            alu_result = 0;
            alu_op = 0;
            
            //set register controls to 0;
            data_rs = 0;
            data_rt = 0;
            data_rd = 0;
            rs = 0;
            rt = 0;
            rd = 0;
            reg_rw = 0;
        end else begin
        
        /*
        * 
        * each step/state may take more than 1 clock cycle, 
        * each fetch step waits until the bus returns a grant_given == 1
        * 
        * 
        * 
        */
        
        case(state)
            0: begin//fetch - bigendian instructions
                if( grant_given == 0 ) begin
                    address <= '{1'b0,PC};
                    grant_request <= 1;
                end else begin
                    PC <= PC + 1;
                    grant_request = 0;
                    IR[31:24] <= data_in;
                    state <= 1;
                end
            end
            1: begin//fetch
                if( grant_given == 0 ) begin
                    address <= '{1'b0,PC};
                    grant_request <= 1;
                end else begin
                    PC <= PC + 1;
                    grant_request <= 0;
                    IR[23:16] <= data_in;
                    state <= 2;
                end
            end
            2: begin//fetch
                if( grant_given == 0 ) begin
                    address <= '{1'b0,PC};
                    grant_request <= 1;
                end else begin
                    PC <= PC + 1;
                    grant_request <= 0;
                    IR[15:8] <= data_in;
                    state <= 3;
                end
            end
            3: begin//fetch
                if( grant_given == 0 ) begin
                    address <= '{1'b0,PC};
                    grant_request <= 1;
                end else begin
                    PC <= PC + 1;
                    grant_request <= 0;
                    IR[7:0] <= data_in;
                    state <= 4;
                end
            end
            4: begin// decode
                instr_opcode <= IR[31:6];
                instr_func <= IR[5:0];
                
                case(instr_opcode)
                    0:
                    2:
                    4:
                    0:
                    8:
                    32:
                    40:
                endcase
                
            end
            5: begin// execute
            end
            default:state = 0;//reset if in unknown state
        endcase
        end
    end
    
endmodule