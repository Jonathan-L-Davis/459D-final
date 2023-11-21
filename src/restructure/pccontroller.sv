module pccontroller(input clk, 
    zeroflag, pcwritecond, 
    pcwrite, 
    output reg pcen
    );

    always @(*) begin
        pcen = ((zeroflag && pcwritecond) || pcwrite) ? 1:0;
    end
endmodule