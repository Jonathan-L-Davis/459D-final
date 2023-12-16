module display(
    input clk_100MHz_disp, 
    input [3:0] digit3, 
    input [3:0] digit2, 
    input [3:0] digit1,
    input [3:0] digit0, 
    output reg [3:0] Anode_Activate_disp, 
    output reg [6:0] LED_out_disp
);

    reg [19:0] refresh_counter;
    reg prev_isMealy_disp;

    initial begin
        //initially refresh counter is zero
        prev_isMealy_disp = 1'b0;
            refresh_counter = 20'b00000000000000000000;
            Anode_Activate_disp = 4'b0000;
            LED_out_disp = 7'b0000001;
    end
    
    always @(posedge clk_100MHz_disp)
    begin
            //increase counter
            refresh_counter = refresh_counter + 1;

            //~100 times per second, change digit
            case (refresh_counter[19:18]) 
                2'b00: begin
                    Anode_Activate_disp = 4'b0111; 
                        case (digit3)
                        4'b0000: LED_out_disp = 7'b0000001; // "0"     
                        4'b0001: LED_out_disp = 7'b1001111; // "1" 
                        4'b0010: LED_out_disp = 7'b0010010; // "2" 
                        4'b0011: LED_out_disp = 7'b0000110; // "3" 
                        4'b0100: LED_out_disp = 7'b1001100; // "4" 
                        4'b0101: LED_out_disp = 7'b0100100; // "5" 
                        4'b0110: LED_out_disp = 7'b0100000; // "6" 
                        4'b0111: LED_out_disp = 7'b0001111; // "7" 
                        4'b1000: LED_out_disp = 7'b0000000; // "8"     
                        4'b1001: LED_out_disp = 7'b0000100; // "9" 
                        4'b1010: LED_out_disp = 7'b0001000; // "A" 
                        4'b1011: LED_out_disp = 7'b1100000; // "B" 
                        4'b1100: LED_out_disp = 7'b0110001; // "C" 
                        4'b1101: LED_out_disp = 7'b1000010; // "D" 
                        4'b1110: LED_out_disp = 7'b0110000; // "E" 
                        4'b1111: LED_out_disp = 7'b0111000; // "F"
                        default: LED_out_disp = 7'b0000001; // "0"
                    endcase
                end
                2'b01: begin
                    Anode_Activate_disp = 4'b1011; 
                        case (digit2)
                        4'b0000: LED_out_disp = 7'b0000001; // "0"     
                        4'b0001: LED_out_disp = 7'b1001111; // "1" 
                        4'b0010: LED_out_disp = 7'b0010010; // "2" 
                        4'b0011: LED_out_disp = 7'b0000110; // "3" 
                        4'b0100: LED_out_disp = 7'b1001100; // "4" 
                        4'b0101: LED_out_disp = 7'b0100100; // "5" 
                        4'b0110: LED_out_disp = 7'b0100000; // "6" 
                        4'b0111: LED_out_disp = 7'b0001111; // "7" 
                        4'b1000: LED_out_disp = 7'b0000000; // "8"     
                        4'b1001: LED_out_disp = 7'b0000100; // "9" 
                        4'b1010: LED_out_disp = 7'b0001000; // "A" 
                        4'b1011: LED_out_disp = 7'b1100000; // "B" 
                        4'b1100: LED_out_disp = 7'b0110001; // "C" 
                        4'b1101: LED_out_disp = 7'b1000010; // "D" 
                        4'b1110: LED_out_disp = 7'b0110000; // "E" 
                        4'b1111: LED_out_disp = 7'b0111000; // "F"
                        default: LED_out_disp = 7'b0000001; // "0"
                    endcase
                end
                2'b10: begin
                    Anode_Activate_disp = 4'b1101; 
                        case (digit1)
                        4'b0000: LED_out_disp = 7'b0000001; // "0"     
                        4'b0001: LED_out_disp = 7'b1001111; // "1" 
                        4'b0010: LED_out_disp = 7'b0010010; // "2" 
                        4'b0011: LED_out_disp = 7'b0000110; // "3" 
                        4'b0100: LED_out_disp = 7'b1001100; // "4" 
                        4'b0101: LED_out_disp = 7'b0100100; // "5" 
                        4'b0110: LED_out_disp = 7'b0100000; // "6" 
                        4'b0111: LED_out_disp = 7'b0001111; // "7" 
                        4'b1000: LED_out_disp = 7'b0000000; // "8"     
                        4'b1001: LED_out_disp = 7'b0000100; // "9" 
                        4'b1010: LED_out_disp = 7'b0001000; // "A" 
                        4'b1011: LED_out_disp = 7'b1100000; // "B" 
                        4'b1100: LED_out_disp = 7'b0110001; // "C" 
                        4'b1101: LED_out_disp = 7'b1000010; // "D" 
                        4'b1110: LED_out_disp = 7'b0110000; // "E" 
                        4'b1111: LED_out_disp = 7'b0111000; // "F"
                        default: LED_out_disp = 7'b0000001; // "0"
                    endcase
                end
                2'b11: begin
                    Anode_Activate_disp = 4'b1110; 
                    case (digit0)
                        4'b0000: LED_out_disp = 7'b0000001; // "0"     
                        4'b0001: LED_out_disp = 7'b1001111; // "1" 
                        4'b0010: LED_out_disp = 7'b0010010; // "2" 
                        4'b0011: LED_out_disp = 7'b0000110; // "3" 
                        4'b0100: LED_out_disp = 7'b1001100; // "4" 
                        4'b0101: LED_out_disp = 7'b0100100; // "5" 
                        4'b0110: LED_out_disp = 7'b0100000; // "6" 
                        4'b0111: LED_out_disp = 7'b0001111; // "7" 
                        4'b1000: LED_out_disp = 7'b0000000; // "8"     
                        4'b1001: LED_out_disp = 7'b0000100; // "9" 
                        4'b1010: LED_out_disp = 7'b0001000; // "A" 
                        4'b1011: LED_out_disp = 7'b1100000; // "B" 
                        4'b1100: LED_out_disp = 7'b0110001; // "C" 
                        4'b1101: LED_out_disp = 7'b1000010; // "D" 
                        4'b1110: LED_out_disp = 7'b0110000; // "E" 
                        4'b1111: LED_out_disp = 7'b0111000; // "F"
                        default: LED_out_disp = 7'b0000001; // "0"
                    endcase
                end
            endcase
    end 
endmodule
