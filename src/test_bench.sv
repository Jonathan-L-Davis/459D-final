module test();
    
    bit [7:0] data1,data2,result;
    bit [3:0] op;
    
    bit [7:0] reg_data_in,reg_data_out;
    bit [2:0] reg_addr;
    bit rw,clk;
    
    reg_file REG_DUT(
        .clk(clk),
        .rw(rw),
        .register(reg_addr),
        .data_in(reg_data_in),
        .data_out(reg_data_out)
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
        reg_addr = 0;
        reg_data_in = 0;
        reg_data_out = 0;
        
        for( int i = 0; i < 8; i++ ) begin
            reg_addr = i;
            for( int j = 0; j < 256; j++ ) begin
                
                rw = 1;//write
                reg_data_in = j;
                clk = 1;
                #1ps;
                clk = 0;
                #1ps;//read data out
                clk = 1;
                rw = 0;
                #1ps;
                clk = 0;
                #1ps;
                if( (i && reg_data_in != reg_data_out) || ( i==0 && reg_data_out != 0 ) ) begin
                    $display("%d != %d, in register: %d",reg_data_in,reg_data_out,i);
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


endmodule