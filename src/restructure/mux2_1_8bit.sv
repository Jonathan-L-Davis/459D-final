module mux2_1_8bit(
input select,
input [8:0] a, b, output out [8:0]
);
    assign out =  select ? a : b;
    
endmodule

