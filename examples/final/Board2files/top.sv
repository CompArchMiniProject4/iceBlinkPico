`include "spi_master.sv"

module top (
    input  logic clk,         // 12 MHz input clock
    output logic sclk,
    output logic mosi,
    output logic cs_n,
    input  logic button       // active-low button
);

    logic send, busy;
    logic [17:0] packet;
    logic [1:0] waveform_select = 2'b00;
    logic [15:0] divider = 16'd5;  // Adjust for desired waveform speed

    // Temporary value for next waveform
    logic [1:0] next_waveform;

    // SPI Master instance
    spi_master u_spi_master (
        .clk(clk),
        .send(send),
        .data_in(packet),
        .sclk(sclk),
        .mosi(mosi),
        .cs_n(cs_n),
        .busy(busy)
    );

    // ==== Button debounce and rising edge detection ====
    logic button_sync_0, button_sync_1;
    logic button_debounced;
    logic [19:0] debounce_counter = 0;

    always_ff @(posedge clk) begin
        button_sync_0 <= button;
        button_sync_1 <= button_sync_0;
    end

    always_ff @(posedge clk) begin
        if (button_sync_1 == 0) begin
            if (debounce_counter < 20'd500_000)
                debounce_counter <= debounce_counter + 1;
        end else begin
            debounce_counter <= 0;
        end
        button_debounced <= (debounce_counter == 20'd500_000);
    end

    // Edge detection
    logic button_debounced_prev;
    logic rising_edge;

    always_ff @(posedge clk) begin
        button_debounced_prev <= button_debounced;
        rising_edge <= (button_debounced && !button_debounced_prev);
    end

    // ==== Waveform selector and SPI send control ====
    logic send_request;

    always_ff @(posedge clk) begin
        if (rising_edge)
            send_request <= 1;
        else if (send)
            send_request <= 0;

        send <= (!busy && send_request);

        if (!busy && send_request) begin
            next_waveform = waveform_select + 1;
            waveform_select <= next_waveform;
            packet <= {divider, next_waveform};
        end
    end

endmodule
