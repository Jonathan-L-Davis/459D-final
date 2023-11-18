module reg_file (
    input clk, input rw, input reset, 
    input [2:0] RS, RT, RD,
    input [7:0] RD_data, 
    output reg [7:0] RS_data, RT_data);
    
    reg [7:0] file [7:1];
    
    always @(posedge clk)begin
        
        if( RD ) && rw))begin
            file[RD] <= RD_data;
        end else begin
            
            if( RS )begin
                RS_data <= file[RS];
            end else begin
                RS_data <= 0;
            end
            
            if( RT )begin
                RT_data <= file[RT];
            end else begin
                RT_data <= 0;
            end
            
        end
    
        if(reset) begin
            for( int i = 1; i < 8; i++ )
                file[i] = 0;
            RS_data = 0;
            RD_data = 0;
        end
    end
    
endmodule