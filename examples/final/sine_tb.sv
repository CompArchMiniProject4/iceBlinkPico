`timescale 10ns/10ns
`include "sine.sv"

module sine_tb;

    logic clk = 0;
    logic _9b, _6a, _4a, _2a, _0a, _5a, _3b, _49a, _45a, _48b;

    top u0 (
        .clk    (clk), 
        ._9b    (_9b), 
        ._6a    (_6a), 
        ._4a    (_4a), 
        ._2a    (_2a), 
        ._0a    (_0a), 
        ._5a    (_5a), 
        ._3b    (_3b), 
        ._49a   (_49a), 
        ._45a   (_45a), 
        ._48b   (_48b)
    );

    initial begin
        $dumpfile("sine.vcd");
        $dumpvars(0, sine_tb);

        // Debugging: Monitor values every cycle
        $monitor("Time: %0t | _9b: %b _6a: %b _4a: %b _2a: %b _0a: %b _5a: %b _3b: %b _49a: %b _45a: %b _48b: %b", 
                  $time, _9b, _6a, _4a, _2a, _0a, _5a, _3b, _49a, _45a, _48b);

        #10000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end

endmodule





