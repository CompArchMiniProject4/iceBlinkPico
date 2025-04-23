module extend (
    input  logic [31:7] instr,
    input  logic [2:0]  ImmSrc,
    output logic [31:0] imm_out
);

    logic [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;

    // Pre-decode all possible immediates
    assign imm_i = {{20{instr[31]}}, instr[31:20]};                                                  // I-type
    assign imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};                                     // S-type
    assign imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};          // B-type
    assign imm_u = {instr[31:12], 12'b0};                                                            // U-type
    assign imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};        // J-type

    // Use case statement to select which immediate
    always_comb begin
        case (ImmSrc)
            3'b000: imm_out = imm_i;
            3'b001: imm_out = imm_s;
            3'b010: imm_out = imm_b;
            3'b011: imm_out = imm_u;
            3'b100: imm_out = imm_j;
            default: imm_out = 32'd0;
        endcase
    end

endmodule

