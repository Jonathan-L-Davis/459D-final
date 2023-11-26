module bus(
    input bit clk,
    input bit reset,
    //core 0 interface
    input bit core0_request,
    output bit core0_grant,
    input bit [7:0] core0_data_in,
    output bit [7:0] core0_data_out,
    input bit core0_address,
    
    //core 1 interface
    input bit core1_request,
    output bit core1_grant,
    input bit [7:0] core1_data,
    output bit [7:0] core1_data_out,
    input bit core1_address,
    
    //RAM interface
    output bit [8:0] RAM_address,
    output bit [7:0] RAM_data_in,
    input bit  [7:0] RAM_data_out,
    output bit rw
    //GPIO interface
    
);
    
    bit [1:0] in_progress;
    
    always @ ( posedge clk ) begin
        if( reset ) begin
            //reset important control signals, ignore rest
           core0_grant <= 0;
           core1_grant <= 0;
           rw <= 0;
        end else if( core0_request && !in_progress[1] && !in_progress[0]) begin
            // if nothing is in progress, start a request from 0, otherwise ignore and continue
            //will change drastically
        end
    end
endmodule