module instrDec (
    input  logic [6:0] op,
    output logic [2:0] immsrc
);

    // Immediate type encoding:
    // 3'b000 → I-type (12-bit)
    // 3'b001 → S-type (12-bit)
    // 3'b010 → B-type (13-bit)
    // 3'b011 → J-type (21-bit)
    // 3'b100 → U-type (32-bit)

    always_comb begin
        case(op)
            // R-type (no immediate needed)
            7'b0110011: immsrc = 3'bxxx;  // Don't care

            // I-type instructions
            7'b0010011: immsrc = 3'b000;  // ALU immediate
            7'b0000011: immsrc = 3'b000;  // Load
            7'b1100111: immsrc = 3'b000;  // JALR

            // S-type
            7'b0100011: immsrc = 3'b001;  // Store

            // B-type
            7'b1100011: immsrc = 3'b010;  // Branch

            // J-type
            7'b1101111: immsrc = 3'b011;  // JAL

            // U-type
            7'b0010111: immsrc = 3'b100;  // AUIPC
            7'b0110111: immsrc = 3'b100;  // LUI

            default:     immsrc = 3'bxxx;  // Undefined/unsupported
        endcase
    end

endmodule