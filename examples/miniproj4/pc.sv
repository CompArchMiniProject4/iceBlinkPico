module pc (
    input  logic        clk,
    input  logic        reset,
    input  logic        pc_en,       // Enable PC update
    input  logic [31:0] pc_next,     // Next PC (for branch/jump)
    input  logic        pc_src,      // 0: PC + 4, 1: pc_next
    output logic [31:0] pc_out
);

    logic [31:0] pc_reg;

    always_ff @(posedge clk) begin
        if (reset) begin
            pc_reg <= 32'h00000000;
        end else if (pc_en) begin
            if (pc_src == 1'b0) begin
                pc_reg <= pc_reg + 4; // Default increment: next instruction
            end else begin
                pc_reg <= pc_next;    // For branch/jump instructions
            end
        end
    end

    assign pc_out = pc_reg;

endmodule