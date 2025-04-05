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

    logic [31:0] rf[31:0]; // 32 registers of 32 bits

    // Write on rising edge of clock
    always_ff @(posedge clk) begin
        if (we && rd != 5'd0) begin
            rf[rd] <= wd;
        end
    end

    // Read combinationally
    always_comb begin
        rd1 = (rs1 != 5'd0) ? rf[rs1] : 32'd0;
        rd2 = (rs2 != 5'd0) ? rf[rs2] : 32'd0;
    end

endmodule
