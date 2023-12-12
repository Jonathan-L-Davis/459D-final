module gpiomem (input clk, input reset, input rw_select,
 input [8:0] address, input [7:0] data_in, 
 output reg [7:0] data_out,

 input [3:0] buttons,
 input [15:0] switches,
 output reg [15:0] leds,
 output reg [3:0] digit3, digit2, digit1, digit0    
 );
    reg [7:0] RAM[511:0];

    //buttons,//503{3:0}
    //switches//504-505
    //leds,   //506-507
    //digit3, //511
    //digit2, //510
    //digit1, //509
    //digit0 //508

    //read only
    //503, 504, 505, 

    always @(posedge clk) begin
    assign data_out = RAM[address];
    if( reset )begin
        $readmemh("fib_test.dat", RAM);
    end else begin
        if(rw_select == 1) begin // Write operation
            if((address != 503)||(address != 504)||(address != 505)) begin
                RAM[address] <= data_in;
            end
        end else begin
            //data_out <= RAM[address];
        end
        
        //*

        //buttons,//503{4:0}
        RAM[503] <= {4'b0000, buttons};

        //switches//505-504
        RAM[504] <= switches[7:0];
        RAM[505] <= switches[15:8];

        //leds,   //506-507
        leds <= {RAM[507], RAM[506]};
        //*/
        
        digit3 <= RAM[511];
        digit2 <= RAM[510];
        digit1 <= RAM[509];
        digit0 <= RAM[508];
    end
    end
    
    
endmodule