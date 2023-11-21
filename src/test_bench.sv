module test();
    
    bit clk;
    bit [7:0]result;
    core core_DUT(
        .clk(clk)
    );
    
    bit [5:0]func;
    bit [3:0]state;
    bit [5:0]op;
    bit [2:0]rs;
    bit [2:0]rt;
    bit [2:0]rd;
    bit [7:0]res;
    bit [7:0]d1;
    bit [7:0]d2;
    
    initial begin
        //for this test bench, we just drive the core 
        // and manually insert values into the right locations to make it compute
        clk = 0;
        core_DUT.state = 4;
        core_DUT.REG_DUT.file[1] = 5;
        core_DUT.REG_DUT.file[2] = 10;
        core_DUT.IR = 32'h00221820;//add : r3 = r1 + r2
        for( int i = 0; i < 10; i++ ) begin
            
        rs = core_DUT.rs;
        rt = core_DUT.rt;
        rd = core_DUT.rd;
        op = core_DUT.instr_opcode;
        func = core_DUT.instr_func;
        result = core_DUT.REG_DUT.file[3];
        state = core_DUT.state;
        res = core_DUT.alu_result;
        d1 = core_DUT.alu_data1;
        d2 = core_DUT.alu_data2;
        
        
            #1ps;
            clk = 1;
            #1ps;
            clk = 0;
        rs = core_DUT.rs;
        rt = core_DUT.rt;
        rd = core_DUT.rd;
        op = core_DUT.instr_opcode;
        func = core_DUT.instr_func;
        result = core_DUT.REG_DUT.file[3];
        state = core_DUT.state;
        res = core_DUT.alu_result;
        d1 = core_DUT.alu_data1;
        d2 = core_DUT.alu_data2;
        
        end
    end
    
    /*
    bit [7:0] data1,data2,result;
    bit [3:0] op;
    
    bit [7:0] data_rs,data_rt,data_rd;
    bit [4:0] rs,rt,rd;
    bit rw,clk;
    
    reg_file REG_DUT(
        .clk(clk),
        .rw(rw),
        .RS(rs), .RT(rt), .RD(rd),
        .RS_data(data_rs),
        .RT_data(data_rt),
        .RD_data(data_rd)
    );

    ALU ALU_DUT(
        .reg_1(data1),
        .reg_2(data2),
        .op(op),
        .out(result)
    );

    initial begin
        
        
        rw = 0;
        clk = 0;
        
        for( int i = 0; i < 8; i++ ) begin
            rd = i;
            rs = i;
            for( int j = 0; j < 256; j++ ) begin
                
                rw = 1;//write
                data_rd = j;
                clk = 1;
                #1ps;
                clk = 0;
                #1ps;//read data out
                clk = 1;
                rw = 0;
                #1ps;
                clk = 0;
                #1ps;
                if( ( i && data_rd != data_rs ) || ( !i && data_rs != 0 ) ) begin
                    $display("%d != %d, in register: %d",data_rd,data_rs,i);
                end
            end
        end
        
        for( int i = 0; i < 8; i++ ) begin
            rd = i;
            rt = i;
            for( int j = 0; j < 256; j++ ) begin
                
                rw = 1;//write
                data_rd = j;
                clk = 1;
                #1ps;
                clk = 0;
                #1ps;//read data out
                clk = 1;
                rw = 0;
                #1ps;
                clk = 0;
                #1ps;
                if( ( i && data_rd != data_rt ) || ( !i && data_rt != 0 ) ) begin
                    $display("%d != %d, in register: %d",data_rd,data_rt,i);
                end
            end
            
        end
        
        op = 0;// addition case
        for( int r1 = 0; r1 < 256; r1++ ) begin
            data1 = r1;
            for( int r2 = 0; r2 < 256; r2++ ) begin
                data2 = r2;
                
                #1ps;//small delay just to fit in sim window of 1 u-second
                if( data1 + data2 != result ) begin
                    $display("%d + %d != %d",data1,data2,result);
                    //more error logging here
                end
            end
        
        end
        op = 1;// subtraction case
        for( int r1 = 0; r1 < 256; r1++ ) begin
            data1 = r1;
            for( int r2 = 0; r2 < 256; r2++ ) begin
                data2 = r2;
                
                #1ps;//small delay just to fit in sim window of 1 u-second
                if( data1 - data2 != result ) begin
                    $display("%d - %d != %d",data1,data2,result);
                    //more error logging here
                end
            end
        
        end
        op = 2;// and case
        for( int r1 = 0; r1 < 256; r1++ ) begin
            data1 = r1;
            for( int r2 = 0; r2 < 256; r2++ ) begin
                data2 = r2;
                
                #1ps;//small delay just to fit in sim window of 1 u-second
                if( (data1 & data2) != result ) begin
                    $display("%d & %d != %d",data1,data2,result);
                    //more error logging here
                end
            end
        
        end
        op = 3;// or case
        for( int r1 = 0; r1 < 256; r1++ ) begin
            data1 = r1;
            for( int r2 = 0; r2 < 256; r2++ ) begin
                data2 = r2;
                
                #1ps;//small delay just to fit in sim window of 1 u-second
                if( (data1 | data2) != result ) begin
                    $display("%d | %d != %d",data1,data2,result);
                    //more error logging here
                end
            end
        
        end
        op = 4;// set less than case
        for( int r1 = 0; r1 < 256; r1++ ) begin
            data1 = r1;
            for( int r2 = 0; r2 < 256; r2++ ) begin
                data2 = r2;
                
                #1ps;//small delay just to fit in sim window of 1 u-second
                if( (data1 < data2) != result ) begin//should be signed
                    $display("%d < %d != %d",data1,data2,result);
                    //more error logging here
                end
            end
        
        end
        $finish;
        
    end
    //*/

endmodule