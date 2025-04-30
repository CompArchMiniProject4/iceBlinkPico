module spi(
    input  logic clk,       // System clock
    input  logic sclk,      // SPI clock
    input  logic cs_n,      // Chip Select (active low)
    input  logic mosi,      // Master Out, Slave In
    output logic [17:0] data_out, // 16-bit divider_value + 2-bit waveform_select
    output logic data_ready
);

    logic [4:0] bit_cnt;       // up to 18 bits (needs 5 bits counter)
    logic [17:0] shift_reg;
    logic sclk_prev;

    always_ff @(posedge clk) begin
        sclk_prev <= sclk;
        data_ready <= 1'b0;

        if (!cs_n) begin
            if (sclk_prev == 0 && sclk == 1) begin // rising edge on sclk
                shift_reg <= {shift_reg[16:0], mosi};
                bit_cnt <= bit_cnt + 1;

                if (bit_cnt == 5'd17) begin
                    data_out <= {shift_reg[16:0], mosi};
                    data_ready <= 1'b1;
                    bit_cnt <= 0;
                end
            end
        end else begin
            bit_cnt <= 0;
        end
    end

endmodule
