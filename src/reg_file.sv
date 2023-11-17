module reg_file (
    input clk, input rw, 
    input [4:0] RS, RT, RD,
    input [7:0] data_to_write, 
    output reg [7:0] RS_data, RT_data);
    
    reg [7:0] file [16:1];

    always(@posedge clk)begin
        if((( !(RD==0) || !(RD > 16)) && rw))begin
            file[RD] <= data_to_write;
        end else if (!rw) begin
            if((( !(RS==0) || !(RS > 16))))begin
                RS_data <= file[RS];
            end else begin
                RS_data <= 0;
            end

            if((( !(RT==0) || !(RT > 16))))begin
                RT_data <= file[RT];
            end else begin
                RT_data <= 0;
            end
        end
    end
    
    
    //assign RS_data = (( !(RS==0) || !(RS > 16)) && !rw) ? file[RS]: 0;
    //assign RT_data = (( !(RT==0) || !(RT > 16)) && !rw) ? file[RT]: 0;
    //assign file[RD] = (( !(RD==0) || !(RD > 16)) && rw) ? data_to_write: 0;
    
endmodule