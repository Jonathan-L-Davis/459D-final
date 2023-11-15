module reg_file (input clk, input rw, input [2:0] register,input [7:0] data_in, output reg [7:0] data_out);
    
    reg [7:0] file [7:0];
    
    always @ (posedge clk) begin
        if( register == 0 ) begin
            case(rw)
                0:data_out <= 0;
                1:;
            endcase
        end else begin
            case(rw)
                0://read
                data_out <= file[register];
                1://write
                file[register] <= data_in;
            endcase
        end
    end
    
endmodule