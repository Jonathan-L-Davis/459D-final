module data_cache(
    input clk,
    input reset,
    input [8:0] address,
    input [7:0] data_in,
    input rw,
    output reg [31:0] data_out,
    output reg hit
);

    parameter CACHE_SIZE = 128;
    parameter WORD_SIZE = 8;
    reg [WORD_SIZE-1:0] cache_mem [0:CACHE_SIZE-1];

    // direct mapped
    reg [7:0] tags [0:CACHE_SIZE-1];

    
    always @(posedge clk) begin
        if (reset) begin
            // Initialize cache
            for (int i = 0; i < CACHE_SIZE; i = i + 1) begin
                cache_mem[i] <= 0;
                tags[i] <= 0;
            end
        end else begin
            // Calculate index and tag
            int index = address % CACHE_SIZE;
            int tag = address / CACHE_SIZE;

            // check for hit
            if (tags[index] == tag) begin
                hit <= 1;
                if (rw) begin
                    // Write
                    cache_mem[index] <= data_in;
                end else begin
                    // Read
                    data_out <= cache_mem[index];
                end
            end else begin
                hit <= 0;
                //miss
            end
        end
    end

endmodule