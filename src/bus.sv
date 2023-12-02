module bus(
    input bit clk,
    input bit reset,
    //core 0 interface
    input bit core0_request,
    output bit core0_grant,
    input bit [7:0] core0_data_in,
    output bit [7:0] core0_data_out,
    input bit [9:0] core0_address,
    input bit core0_rw,
    
    //core 1 interface
    input bit core1_request,
    output bit core1_grant,
    input bit [7:0] core1_data,
    output bit [7:0] core1_data_out,
    input bit [9:0] core1_address,
    input bit core1_rw,
    
    //RAM interface
    output bit [8:0] RAM_address,
    output bit [7:0] RAM_data_in,
    input bit  [7:0] RAM_data_out,
    output bit rw_RAM
    
);
    
    bit [1:0] in_progress;
    bit [1:0] grant_given;
    bit [1:0] grant_request;
    bit [1:0] grant_request_type;
    bit patron;
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
        end else if( core0_request && !in_progress[1] && !in_progress[0]) begin
            case(state)
            wait_state: begin
                if( grant_request[~patron] ) begin//give priority to least recent core
                    patron <= ~patron;
                    case(core)
                        0: state <= write_state;
                        1: state <= read_request_state;
                    endcase
                end else if(grant_request[patron]) begin
                    case(core)
                        0: state <= write_state;
                        1: state <= read_request_state;
                    endcase
                end
                if( req[patron] ) begin
                    state <= req_type[patron]+1;
                end else if( req[~patron] )
                    
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
                data_out <= RAM_data_out;
                state <= wait_state;
            end
            endcase
        end
    end
    
    
    
endmodule