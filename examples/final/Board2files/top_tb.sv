`timescale 1ns/1ns

module top_tb;

    logic clk = 0;
    logic button = 1;
    logic sclk, mosi, cs_n;

    top dut (
        .clk(clk),
        .button(button),
        .sclk(sclk),
        .mosi(mosi),
        .cs_n(cs_n)
    );

    // Approximate 12 MHz clock
    always #42 clk = ~clk;

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        #1000;

        // Simulate button press to trigger SPI send
        button <= 0;
        #500;
        button <= 1;

        #5000;

        $finish;
    end

endmodule
