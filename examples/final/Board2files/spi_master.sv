module spi_master (
    input  logic clk,
    input  logic send,
    input  logic [17:0] data_in,
    output logic sclk,
    output logic mosi,
    output logic cs_n,
    output logic busy
);

    typedef enum logic [1:0] {
        IDLE, ASSERT_CS, TRANSFER, DONE
    } state_t;

    state_t state = IDLE;
    logic [4:0] bit_cnt = 0;
    logic [17:0] shift_reg = 0;
    logic [7:0] clk_div = 0;

    assign sclk = clk_div[5];
    assign busy = (state != IDLE);

    always_ff @(posedge clk) begin
        clk_div <= clk_div + 1;

        case (state)
            IDLE: begin
                cs_n <= 1;
                mosi <= 0;
                if (send) begin
                    shift_reg <= data_in;
                    bit_cnt <= 18;
                    state <= ASSERT_CS;
                end
            end

            ASSERT_CS: begin
                cs_n <= 0;
                if (clk_div == 0)
                    state <= TRANSFER;
            end

            TRANSFER: begin
                if (clk_div[5:0] == 6'b111111) begin
                    mosi <= shift_reg[17];
                    shift_reg <= {shift_reg[16:0], 1'b0};
                    bit_cnt <= bit_cnt - 1;
                    if (bit_cnt == 1)
                        state <= DONE;
                end
            end

            DONE: begin
                cs_n <= 1;
                if (clk_div == 0)
                    state <= IDLE;
            end
        endcase
    end

endmodule
