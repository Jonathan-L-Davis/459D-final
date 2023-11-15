module test();
    
    bit [7:0] data1,data2,result;
    bit [3:0] op = 0;

    ALU ALU_DUT(
        .reg_1(data1),
        .reg_2(data2),
        .op(op),
        .out(result)
    );

    initial begin
        
        //$display("%d");
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
        $finish;
        
    end


endmodule