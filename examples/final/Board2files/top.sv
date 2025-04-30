module top (
    input logic clk,         // 12MHz from crystal
    output logic sclk,
    output logic mosi,
    output logic cs_n,
    input logic button       // use BOOT or other switch
);

    logic send = 0;
    logic [17:0] packet;
    logic busy;

    spi_master u_spi_master (
        .clk(clk),
        .send(send),
        .data_in(packet),
        .sclk(sclk),
        .mosi(mosi),
        .cs_n(cs_n),
        .busy(busy)
    );

    // simple controller: send waveform_select = 2'b01, divider = 250
    always_ff @(posedge clk) begin
        if (!busy && !button) begin
            packet <= {16'd250, 2'b01};  // Square wave
            send <= 1;
        end else begin
            send <= 0;
        end
    end

endmodule
