module controller(input clk, reset,
input [5:0] op, input zero,
output reg memread, memwrite, alusrca, memtoreg, iord,
output pcen,
output reg regwrite, regdst,
output reg [1:0] pcsource, alusrcb, aluop,
output reg [3:0] irwrite);

//states
parameter FETCH1 = 4'b0001;
parameter FETCH2 = 4'b0010;
parameter FETCH3 = 4'b0011; 
parameter FETCH4 = 4'b0100;
parameter DECODE = 4'b0101; 
parameter MEMADR = 4'b0110;
parameter LBRD = 4'b0111;
parameter LBWR = 4'b1000;
parameter SBWR = 4'b1001;
parameter RTYPEEX = 4'b1010;
parameter RTYPEWR = 4'b1011;
parameter BEQEX = 4'b1100;
parameter JEX = 4'b1101;
parameter ADDIWR = 4'b1110;

//opcodes
    parameter LB = 6'b100000;
    parameter SB = 6'b101000;
    parameter RTYPE = 6'b000000;
    parameter BEQ = 6'b000100;
    parameter J = 6'b000010;
    parameter ADDI = 6'b001000;

//local vars
reg [3:0] state, nextstate;
reg pcwrite, pcwritecond;

    always @(posedge clk) begin
        if(reset) begin
            state <= FETCH1;
        end else begin
            state <= nextstate;
        end
    end

    always @(*) begin
        case(state)
            FETCH1:
                nextstate <= FETCH1;
            FETCH2:
                nextstate <= FETCH1;
            FETCH3:
                nextstate <= FETCH1;
            FETCH4:
                nextstate <= FETCH1;
            DECODE:
                case(op)
                    LB:
                        nextstate <= MEMADR;
                    SB:
                        nextstate <= MEMADR;
                    RTYPE:
                        nextstate <= RTYPEEX;
                    BEQ:
                        nextstate <= BEQEX;
                    J:
                        nextstate <= JEX;
                    ADDI:
                        nextstate <= MEMADR;
                    default:
                        nextstate <= FETCH1;
                  endcase
            MEMADR:
                case(op)
                    LB:
                        nextstate <= LBRD;
                    SB:
                        nextstate <= SBWR;
                    ADDI:
                        nextstate <= ADDIWR;
                    default:
                        nextstate <= FETCH1;
                endcase
            LBRD:
                nextstate <= LBWR;
            LBWR:
                nextstate <= FETCH1;
            SBWR:
                nextstate <= FETCH1;
            RTYPEEX:
                nextstate <= RTYPEWR;
            RTYPEWR:
                nextstate <= FETCH1;
            BEQEX:
                nextstate <= FETCH1;
            JEX:
                nextstate <= FETCH1;
            ADDIWR:
                nextstate <= FETCH1;
            default: 
                nextstate <= FETCH1;
        endcase // state
    end



    always @(*) begin
        if(reset) begin
            irwrite <= 4'b0000;
            pcwrite <= 0; pcwritecond <= 0;
            regwrite <= 0; regdst <= 0;
            memread <= 0; memwrite <= 0;
            alusrca <= 0; alusrcb <= 2'b00;
            aluop <= 2'b00; pcsource <= 2'b00;
            iord <= 0; memtoreg <= 0;
        end else begin
            case(state)
                FETCH1:
                    begin
                        memread <= 1;
                        irwrite <= 4'b1000;
                        alusrca <= 0;
                        alusrcb <= 2'b01;
                        pcwrite <= 1;
                    end
                FETCH2:
                    begin
                        memread <= 1;
                        irwrite <= 4'b0100;
                        alusrca <= 0;
                        alusrcb <= 2'b01;
                        pcwrite <= 1;
                    end
                FETCH3:
                    begin
                        memread <= 1;
                        irwrite <= 4'b0010;
                        alusrca <= 0;
                        alusrcb <= 2'b01;
                        pcwrite <= 1;
                    end
                FETCH4:
                    begin
                        memread <= 1;
                        irwrite <= 4'b0001;
                        alusrca <= 0;
                        alusrcb <= 2'b01;
                        pcwrite <= 1;
                    end
                DECODE:
                    alusrcb <= 2'b11;
                MEMADR:
                    case(op)
                        LB:
                        SB:
                        ADDI:
                        default:
                    endcase
                LBRD:
                LBWR:
                SBWR:
                RTYPEEX:
                RTYPEWR:
                BEQEX:
                JEX:
                ADDIWR:
                    
                default: 
                   
            endcase // state
        end
    end
endmodule : controller
