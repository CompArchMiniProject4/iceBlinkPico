`timescale 10ns/10ns

module sine_tb;

    logic clk = 0;
    logic sclk = 0;
    logic cs_n = 1;
    logic mosi;

    logic _9b, _6a, _4a, _2a, _0a, _5a, _3b, _49a, _45a, _48b;

    // Instantiate top DUT
    top dut (
        .clk(clk),
        .sclk(sclk),
        .cs_n(cs_n),
        .mosi(mosi),
        ._9b(_9b),
        ._6a(_6a),
        ._4a(_4a),
        ._2a(_2a),
        ._0a(_0a),
        ._5a(_5a),
        ._3b(_3b),
        ._49a(_49a),
        ._45a(_45a),
        ._48b(_48b)
    );

    initial begin
        $dumpfile("sine.vcd");
        $dumpvars(0, sine_tb);

        // Wait a little before sending SPI
        #1000;

        // SPI send: Divider 500, waveform select 10 (triangle wave)
        spi_send(16'd500, 2'b10);

        #5000;

        // SPI send: Divider 1000, waveform select 00 (sine wave)
        spi_send(16'd1000, 2'b00);

        #5000;

        // SPI send: Divider 250, waveform select 01 (square wave)
        spi_send(16'd250, 2'b01);

        #30000;;

        $finish;
    end

    // Clock generation
    always #4 clk = ~clk;    // 125MHz
    always #10 sclk = ~sclk; // SPI clock slower

    task spi_send(input logic [15:0] divider, input logic [1:0] wform);
        logic [17:0] packet;
        integer i;
        begin
            packet = {divider, wform};
            cs_n = 0;
            for (i = 17; i >= 0; i = i - 1) begin
                mosi = packet[i];
                @(posedge sclk);
            end
            cs_n = 1;
            // small gap between transactions
            repeat (5) @(posedge clk);
        end
    endtask

endmodule
