module alu (
    input logic [31:0] src1, src2, // 32-bit source operands
    input  logic [3:0] aluc,       // ALU control signal
    output logic [31:0] out,       // ALU result
    output logic zero,             // Zero flag (1 if out == 0)
    output logic cout,             // Carry-out flag
    output logic overflow,         // Overflow flag
    output logic sign              // Sign bit of the result
);

always_comb begin
    case (aluc)
        4'b0000: begin
            {cout, out} = {1'b0, src1} + {1'b0, src2}; // ADD
        end
        4'b0001: begin
            {cout, out} = {1'b0, src1} - {1'b0, src2}; // SUB
        end
        4'b0010: begin
            out = src1 & src2; // AND
            cout = 0;
        end
        4'b0011: begin
            out = src1 | src2; // OR
            cout = 0;
        end
        4'b0100: begin
            out = src1 ^ src2; // XOR
            cout = 0;
        end
        4'b0101: begin
            out = src1 << src2[4:0]; // SLL
            cout = 0;
        end
        4'b0110: begin
            out = src1 >> src2[4:0]; // SRL
            cout = 0;
        end
        4'b0111: begin
            out = $signed(src1) >>> $unsigned(src2[4:0]); // SRA 
            cout = 0;
        end
        4'b1000: begin
            out = ($signed(src1) < $signed(src2)) ? 1 : 0; // SLT
            cout = 0;
        end
        4'b1001: begin
            out = ($unsigned(src1) < $unsigned(src2)) ? 1 : 0; // SLTU 
            cout = 0;
        end
        default: begin
            out = 0;
            cout = 0;
        end
    endcase

    // Compute Flags
    zero = (out == 0) ? 1'b1 : 1'b0;
    sign = out[31];
    overflow = ((src1[31] == src2[31]) && (src1[31] != out[31])) 
                && (aluc == 4'b0000 || aluc == 4'b0001); 
end

endmodule