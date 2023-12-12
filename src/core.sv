module core
    #(
        parameter pc_start = 0
    )
    (
    input bit clk, input bit reset,
    input bit grant_given, 
    output bit grant_request, output bit rw,
    input bit[7:0] data_in, output bit[7:0] data_out,
    output bit [8:0] address//upper bit is flag for gpio
    );
    
    localparam o_ALU   =  0;
    localparam o_JMP   =  2;
    localparam o_JEQ   =  4;
    localparam o_ALUI  =  8;
    localparam o_LOAD  = 32;
    localparam o_STORE = 40;
    
    localparam f_ADD = 32;
    localparam f_SUB = 34;
    localparam f_AND = 36;
    localparam f_OR  = 37;
    localparam f_XOR = 38;
    localparam f_SLT = 42;
    
    //cpu internal state
    bit [3:0] state;
    
    bit [7:0] PC;
    bit [31:0] IR;
    
    //instruction formats
    //added these variables to parse instruction
    
    //ALU controls
    bit [7:0] alu_data1,alu_data2,alu_result;
    bit [3:0] alu_op;// 0 for add, 1 for sub, 2 for and, 3 for or, 4 for slt
    
    //register file controls
    bit [7:0] data_rs,data_rt,data_rd;
    bit [2:0] rs,rt,rd;
    bit reg_rw;
    
    reg_file register_file(
        .clk(clk),
        .reset(reset),
        .rw(reg_rw),
        .RS(rs), .RT(rt), .RD(rd),
        .RS_data(data_rs),
        .RT_data(data_rt),
        .RD_data(data_rd)
    );
    
    ALU alu(
        .reg_1(alu_data1),
        .reg_2(alu_data2),
        .op(alu_op),
        .out(alu_result)
    );
    
    assign instr_op = IR[31:26];

    always @ (posedge clk) begin
        
        if( reset ) begin
            
            //wipe core internal state
            state = 0;
            PC = pc_start;
            IR = 0;
            rw = 0;
            
            //set ALU controls to 0;
            alu_data1 = 0;
            alu_data2 = 0;
            //alu_result = 0;
            alu_op = 0;
            
            //set register controls to 0;
            //data_rs = 0;
            //data_rt = 0;
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
                reg_rw <= 0;//reset reg_write
                rw <= 0;
                if( grant_given == 0 ) begin
                    address <= {1'b0,PC};
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
                    address <= {1'b0,PC};
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
                    address <= {1'b0,PC};
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
                    address <= {1'b0,PC};
                    grant_request <= 1;
                end else begin
                    PC <= PC + 1;
                    grant_request <= 0;
                    IR[7:0] <= data_in;
                    state <= 4;
                end
            end
            4: begin// decode/execute
                case(IR[31:26])
                    //changed logic for alu and register io based on instruction.
                    o_ALU: begin
                        
                        rw <= 0;
                        rs <= IR[23:21];
                        rt <= IR[18:16];
                        rd <= IR[13:11];
                        case(IR[5:0])//set operation and wait until execute cycle to grab the result
                            f_ADD: begin
                                alu_op <= 0;
                            end
                            f_SUB: begin
                                alu_op <= 1;
                            end
                            f_AND: begin
                                alu_op <= 2;
                            end
                            f_OR: begin
                                alu_op <= 3;
                            end
                            f_SLT: begin
                                alu_op <= 4;
                            end
                            f_XOR: begin
                                alu_op <= 5;
                            end
                        endcase
                        state <= 5;
                    end
                    2: begin
                        PC <= IR[7:0];
                        state <= 0;
                    end
                    o_JEQ: begin
                        //need to add logic somewhere for comparison. 
                        rs <= IR[23:21];
                        rt <= IR[18:16];
                        rd <= 0;
                        alu_op = 5;//xor, if 0 they are equal
                        state <= 5;
                        alu_data1 <= data_rs;
                        alu_data2 <= data_rt;
                    end
                    o_ALUI: begin// add immmedidate
                        rs <= IR[23:21];
                        rt <= IR[18:16];
                        rd <= IR[13:11];
                        alu_data1 <= data_rs;
                        alu_data2 <= IR[7:0];
                        state <= 5;
                    end
                    o_LOAD: begin
                        data_rd <= data_rd;       ///////                 
                        if( grant_given == 0 ) begin
                            address <= {1'b0,IR[8:0]};
                            grant_request <= 1;
                            rw <= 0;
                        end else begin
                            reg_rw = 1;
                            grant_request = 0;
                            data_rd <= data_in;//gets set on next clock cycle
                            rd <= IR[18:16];
                            state <= 0;
                        end
                    end
                    o_STORE: begin
                            address <= {1'b0,IR[8:0]};
                            state <= 5;
                    end
                endcase
            end
            5: begin// execute, not all instructions hit this point
                case(IR[31:26])
                    o_ALU:begin
                        alu_data1 <= data_rs;
                        alu_data2 <= data_rt;
                        state <= 6;
                    end
                    o_JEQ:begin
                        alu_data1 <= data_rs;
                        alu_data2 <= data_rt;
                        state <= 6;
                    end
                    o_ALUI: begin
                        alu_data1 <= data_rs;
                        alu_data2 <= IR[7:0];
                        state <= 6;
                    end
                    o_STORE: begin//at least 2 cycles here
                        if( grant_given == 0 ) begin
                            grant_request <= 1;
                            rw <= 1;
                            data_out <= data_rt;
                        end else begin
                            grant_request <= 0;
                            state <= 0;
                        end
                    end
                endcase
            end
            6: begin// execute, not all instructions hit this point
                case(IR[31:26])
                    o_ALU: begin 
                        data_rd <= alu_result;
                        reg_rw <= 1;
                        state <= 0;
                    end
                    o_ALUI: begin
                        rd <= rt;
                        data_rd <= alu_result;
                        reg_rw <= 1;
                        state <= 0;
                    end
                    o_JEQ: begin
                        if( alu_result == 0 )
                            PC <= PC + (IR[7:0]) - 4;
                        state <= 0;
                    end
                endcase
            end
            default: begin
                state = 0;//reset if in unknown state
                PC = 0;//start at address 0
            end
        endcase
        end
    end
    
endmodule