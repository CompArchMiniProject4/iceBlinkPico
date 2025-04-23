module register_file (
    input  logic        clk,     // Clock
    input  logic        we,      // Write enable
    input  logic [4:0]  rs1,     // Read address 1
    input  logic [4:0]  rs2,     // Read address 2
    input  logic [4:0]  rd,      // Write address
    input  logic [31:0] wd,      // Write data
    output logic [31:0] rd1,     // Read data 1
    output logic [31:0] rd2      // Read data 2
);

    logic [31:0] rf[31:0];  // 32x32 register array

    // Synchronous write
    always_ff @(posedge clk) begin
        if (we && rd != 5'd0)
            rf[rd] <= wd;  // Register x0 is hardwired to 0
    end

    // Asynchronous read
    always_comb begin
        rd1 = (rs1 != 5'd0) ? rf[rs1] : 32'd0;
        rd2 = (rs2 != 5'd0) ? rf[rs2] : 32'd0;
    end

endmodule
