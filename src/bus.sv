module bus(
    input bit clk,
    input bit reset,
    
    //core 0 interface
    input bit core0_request,
    input bit core0_rw,
    output bit core0_grant,
    input bit [7:0] core0_data_in,
    output bit [7:0] core0_data_out,
    input bit [8:0] core0_address,
    
    //core 1 interface
    input bit core1_request,
    input bit core1_rw,
    output bit core1_grant,
    input bit [7:0] core1_data_in,
    output bit [7:0] core1_data_out,
    input bit [8:0] core1_address,
    
    //RAM interface
    output bit [8:0] RAM_address,
    output bit [7:0] RAM_data_in,
    input bit  [7:0] RAM_data_out,
    output bit rw
    
);
    
    bit [1:0] in_progress;
    bit [1:0] grant_given;
    bit [1:0] grant_request;
    bit [1:0] grant_request_type;
    bit patron;
    
    bit [8:0] addr [1:0];
    bit [7:0] data_in [1:0];
    bit [7:0] data_out [1:0];
    
    parameter wait_state = 0;
    parameter write_state = 1;
    parameter read_request_state = 2;
    parameter read_deliver_state = 3;
    bit [1:0] state;
    
    always @ ( posedge clk ) begin
        if( reset ) begin
            //reset important control signals, ignore rest
            core0_grant <= 0;
            core1_grant <= 0;
            rw <= 0;
            patron <= 0;
        end else begin
            case(state)
            wait_state: begin
                if( grant_request[~patron] ) begin//give priority to least recent core
                    patron <= ~patron;
                    case(grant_request_type[~patron])
                        0: state <= write_state;
                        1: state <= read_request_state;
                    endcase
                end else if(grant_request[patron]) begin
                    case(grant_request_type[patron])
                        0: state <= write_state;
                        1: state <= read_request_state;
                    endcase
                end
            end
            write_state: begin
                RAM_data_in <= data_in[patron];
                RAM_address <= addr[patron];
                rw <= 1;
                state <= wait_state;
            end
            read_request_state: begin
                RAM_address <= addr[patron];
                rw <= 0;
                state <= read_deliver_state;
            end
            read_deliver_state: begin
                data_out[patron] <= RAM_data_out;
                state <= wait_state;
            end
            endcase
        end
    end
    
    assign core0_data_out = data_out[0];
    assign core1_data_out = data_out[1];
    assign data_in[0] = core0_data_in;
    assign data_in[1] = core1_data_in;
    assign addr[0] = core0_address;
    assign addr[1] = core1_address;
    assign grant_request[0] = core0_request;
    assign grant_request[1] = core1_request;
    assign grant_request_type[0] = core0_rw;
    assign grant_request_type[1] = core1_rw;
    
    
endmodule