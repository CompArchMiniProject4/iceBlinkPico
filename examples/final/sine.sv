`include "spi.sv"
`include "memory.sv"
module top(
    input logic clk,
    input logic sclk,
    input logic cs_n,
    input logic mosi,
    output logic _9b, _6a, _4a, _2a, _0a, _5a, _3b, _49a, _45a, _48b
);

    logic [8:0] address = 9'd0;            // <-- FIX: Initialize to 0
    logic [9:0] sine_data;
    logic [9:0] output_data;
    
    logic [15:0] clk_divider = 16'd5;       // <-- FIX: Initialize to 5
    logic [15:0] divider_value = 16'd5;     // <-- FIX: Initialize to 5
    logic [1:0] waveform_select = 2'b00;    // <-- FIX: Initialize to 00

    logic [17:0] spi_data;
    logic spi_data_ready;

    // Precompute address slices
    logic address_bit8;
    logic [7:0] address_bits7_0;

    assign address_bit8 = address[8];
    assign address_bits7_0 = address[7:0];

    // Instantiate memory
    memory #(
        .INIT_FILE("sine.txt")
    ) u_memory (
        .clk(clk),
        .read_address(address),
        .read_data(sine_data)
    );

    // Instantiate SPI slave
    spi u_spi (
        .clk(clk),
        .sclk(sclk),
        .cs_n(cs_n),
        .mosi(mosi),
        .data_out(spi_data),
        .data_ready(spi_data_ready)
    );

    // Divider for stepping the address
    always_ff @(posedge clk) begin
        if (clk_divider == 0) begin
            clk_divider <= divider_value;
            if (address == 9'd511)  // optional: wrap-around at 511
                address <= 9'd0;
            else
                address <= address + 1;
        end else begin
            clk_divider <= clk_divider - 1;
        end
    end

    // Update divider value and waveform select from SPI
    always_ff @(posedge clk) begin
        if (spi_data_ready) begin
            divider_value <= spi_data[17:2];
            waveform_select <= spi_data[1:0];
        end
    end

    // Waveform generation
    logic [9:0] triangle_wave;
    logic [9:0] square_wave;

    always_comb begin
        if (address_bit8) begin
            triangle_wave = 10'd1023 - (address_bits7_0 << 2);
            square_wave = 10'd1023;
        end else begin
            triangle_wave = (address_bits7_0 << 2);
            square_wave = 10'd0;
        end

        case (waveform_select)
            2'b00: output_data = sine_data;
            2'b01: output_data = square_wave;
            2'b10: output_data = triangle_wave;
            default: output_data = 10'd0;
        endcase
    end

    // Output bit mapping
    assign _48b = output_data[9];
    assign _45a = output_data[8];
    assign _49a = output_data[7];
    assign _3b  = output_data[6];
    assign _5a  = output_data[5];
    assign _0a  = output_data[4];
    assign _2a  = output_data[3];
    assign _4a  = output_data[2];
    assign _6a  = output_data[1];
    assign _9b  = output_data[0];

endmodule
