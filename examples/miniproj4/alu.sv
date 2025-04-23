module alu (
    input  logic [31:0] src1,
    input  logic [31:0] src2,
    input  logic [3:0]  aluc,
    output logic [31:0] out,
    output logic        zero,
    output logic        cout,
    output logic        overflow,
    output logic        sign
);

    logic [32:0] tmp;       // Extended for carry out
    logic [4:0]  shamt;     // Shift amount

    // Move the part-select outside the always block
    assign shamt = src2[4:0];

    // Use traditional always block for better Icarus Verilog support
    always @* begin
        // Default assignments
        out      = 32'd0;
        tmp      = 33'd0;
        cout     = 1'b0;
        overflow = 1'b0;
        zero     = 1'b0;
        sign     = 1'b0;

        case (aluc)
            4'b0000: begin // ADD
                tmp = {1'b0, src1} + {1'b0, src2};
                out = tmp[31:0];
                cout = tmp[32];
                overflow = (src1[31] == src2[31]) && (out[31] != src1[31]);
            end

            4'b0001: begin // SUB
                tmp = {1'b0, src1} - {1'b0, src2};
                out = tmp[31:0];
                cout = tmp[32];
                overflow = (src1[31] != src2[31]) && (out[31] != src1[31]);
            end

            4'b0010: out = src1 & src2;  // Bitwise AND
            4'b0011: out = src1 | src2;  // Bitwise OR
            4'b0100: out = src1 ^ src2;  // Bitwise XOR
            4'b0101: out = $signed(src1) < $signed(src2) ? 32'd1 : 32'd0;  // SLT (signed)
            4'b0110: out = src1 < src2 ? 32'd1 : 32'd0;                    // SLTU (unsigned)
            4'b0111: out = src1 << shamt;  // SLL
            4'b1000: out = src1 >> shamt;  // SRL
            4'b1001: out = $signed(src1) >>> shamt;  // SRA
            default: out = 32'd0;         // Default to 0
        endcase

        // Flags
        zero = (out == 32'd0);
        sign = out[31];
    end

endmodule
