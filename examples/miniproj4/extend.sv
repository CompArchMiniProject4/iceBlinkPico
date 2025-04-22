module extend (
    input logic [31:0] instr,
    input logic [2:0] ImmSrc,
    output logic [31:0] ImmExt
);

    // Intermediate immediate values
    logic [31:0] imm_I, imm_S, imm_B, imm_J, imm_U;

    assign imm_I = {{20{instr[31]}}, instr[31:20]};
    assign imm_S = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    assign imm_B = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
    assign imm_J = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
    assign imm_U = {instr[31:12], 12'b0};

    always_comb begin
        case (ImmSrc)
            3'b000: ImmExt = imm_I;
            3'b001: ImmExt = imm_S;
            3'b010: ImmExt = imm_B;
            3'b011: ImmExt = imm_J;
            3'b100: ImmExt = imm_U;
            default: ImmExt = 32'bx;
        endcase
    end

endmodule
