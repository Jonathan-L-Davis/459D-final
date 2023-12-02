
`timescale 1ns/1ps
module tb_top (); /* this is automatically generated */

    // clock
    logic clk;
    initial begin
        clk = '0;
        forever #(0.5) clk = ~clk;
    end

    // synchronous reset
    logic srstb;
    initial begin
        srstb <= '0;
        repeat(10)@(posedge clk);
        srstb <= '1;
    end

    // (*NOTE*) replace reset, clock, others
    logic        clk_100MHz;
    logic        rst;
    logic  [1:0] SW_input_main;
    logic  [3:0] Anode_Activate;
    logic  [6:0] LED_out;
    logic  [3:0] buttons;
    logic [15:0] switches;
    logic [15:0] leds;

    top inst_top
        (
            .clk_100MHz     (clk_100MHz),
            .rst            (rst),
            .SW_input_main  (SW_input_main),
            .Anode_Activate (Anode_Activate),
            .LED_out        (LED_out),
            .buttons        (buttons),
            .switches       (switches),
            .leds           (leds)
        );

    task init();
        clk_100MHz    <= '0;
        rst           <= '0;
        SW_input_main <= '0;
        buttons       <= '0;
        switches      <= '0;
    endtask

    task drive(int iter);
        for(int it = 0; it < iter; it++) begin
            clk_100MHz    <= '0;
            rst           <= '0;
            SW_input_main <= '0;
            buttons       <= '0;
            switches      <= '0;
            @(posedge clk);
        end
    endtask

    initial begin
        // do something

        init();
        repeat(10)@(posedge clk);

        drive(20);

        repeat(10)@(posedge clk);
        $finish;
    end
    // dump wave
    initial begin
        $display("random seed : %0d", $unsigned($get_initial_random_seed()));
        if ( $test$plusargs("fsdb") ) begin
            $fsdbDumpfile("tb_top.fsdb");
            $fsdbDumpvars(0, "tb_top", "+mda", "+functions");
        end
    end
endmodule
