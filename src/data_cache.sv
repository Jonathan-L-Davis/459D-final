module data_cache(
    input clk,
    input reset,
    input [8:0] address,
    input [7:0] data_in,
    input rw,
    output reg grant_given_core,
    input grant_request_core,

    output reg [8:0] data_out,
    output reg hit, 

    output reg grant_request_bus,
    input grant_given_bus,
    input ext_mem_data_out,
    output reg ext_mem_data_in,
    output reg [8:0] ext_mem_addr,
    output reg ext_mem_rw
);

    parameter CACHE_SIZE = 32;
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
            grant_request_bus <= 0;
            ext_mem_rw <= 0; //read initially

        end else begin
            // Calculate index and tag
            if(grant_request_core) begin
                int index = address % CACHE_SIZE;
                int tag = address / CACHE_SIZE;

                // check for hit
                if (tags[index] == tag) begin
                    hit <= 1;
                    if (rw) begin
                        // Write
                        cache_mem[index] <= data_in;
                        // Write-through
                        grant_request_bus <= 1;
                        ext_mem_addr <= address;
                        ext_mem_data_in <= data_in;
                        ext_mem_rw <= 1;
                        grant_given_core <= grant_given_bus;
                    end else begin
                        // Read
                        data_out <= cache_mem[index];
                        grant_given_core <= 1;
                    end
                end else begin
                    hit <= 0;
                    //miss
                    grant_request_bus <= 1;
                    ext_mem_addr <= address;
                    if (rw) begin
                        //write
                        cache_mem[index] <= data_in;
                        // Write-through
                        ext_mem_data_in <= data_in;
                        ext_mem_rw <= 1;
                    end else begin
                        //read
                        ext_mem_rw <= 0;
                        if(grant_given_bus) begin
                            cache_mem[index] <=  ext_mem_data_out;
                            data_out <= ext_mem_data_out;
                        end
                    end
                    grant_given_core <= grant_given_bus;
                end
            end
        end
    end
endmodule