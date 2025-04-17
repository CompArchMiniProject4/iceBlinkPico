module alu (
    input  logic [31:0] src1, src2,
    input  logic [3:0]  aluc,
    output logic [31:0] out,
    output logic        zero, cout, overflow, sign
);

    logic [4:0] shamt;
    assign shamt = src2[4:0];

    always_comb begin
        case (aluc)
            4'b0000: {cout, out} = {1'b0, src1} + {1'b0, src2};
            4'b0001: {cout, out} = {1'b0, src1} - {1'b0, src2};
            4'b0010: begin out = src1 & src2; cout = 0; end
            4'b0011: begin out = src1 | src2; cout = 0; end
            4'b0100: begin out = src1 ^ src2; cout = 0; end
            4'b0101: begin out = src1 << shamt; cout = 0; end
            4'b0110: begin out = src1 >> shamt; cout = 0; end
            4'b0111: begin out = $signed(src1) >>> shamt; cout = 0; end
            4'b1000: begin out = ($signed(src1) < $signed(src2)) ? 1 : 0; cout = 0; end
            4'b1001: begin out = ($unsigned(src1) < $unsigned(src2)) ? 1 : 0; cout = 0; end
            default: begin out = 0; cout = 0; end
        endcase

        zero = (out == 0);
        sign = out[31];
        overflow = ((src1[31] == src2[31]) && (src1[31] != out[31])) &&
                   (aluc == 4'b0000 || aluc == 4'b0001);
    end

endmodule
