module register_file (
    input  logic        clk,
    input  logic        we,
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic [31:0] wd,
    output logic [31:0] rd1,
    output logic [31:0] rd2
);

    logic [31:0] rf[31:0];
    logic [31:0] rd1_reg, rd2_reg;

    // Synchronous write
    always_ff @(posedge clk) begin
        if (we && rd != 5'd0)
            rf[rd] <= wd;
        // Synchronous read
        rd1_reg <= (rs1 != 5'd0) ? rf[rs1] : 32'd0;
        rd2_reg <= (rs2 != 5'd0) ? rf[rs2] : 32'd0;
    end

    assign rd1 = rd1_reg;
    assign rd2 = rd2_reg;

endmodule