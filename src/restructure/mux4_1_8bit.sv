module mux2_1_8bit(
input [1:0] select,
input [8:0] a, b, c, d, output out [8:0]
);
    assign out =  select[1] ? (select[0] ? d : c) : (select[1] ? b : a);
    
endmodule

