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

    logic [32:0] tmp;
    logic [4:0]  shamt;

    assign shamt = src2[4:0];  // ONLY allowed here as continuous assign

    always @(*) begin
        out = 32'd0;
        tmp = 33'd0;
        cout = 1'b0;
        overflow = 1'b0;

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

            4'b0010: out = src1 & src2;  // AND
            4'b0011: out = src1 | src2;  // OR
            4'b0100: out = src1 ^ src2;  // XOR
            4'b0101: out = $signed(src1) < $signed(src2) ? 32'd1 : 32'd0;  // SLT
            4'b0110: out = (src1 < src2) ? 32'd1 : 32'd0;  // SLTU
            4'b0111: out = src1 << shamt; // SLL
            4'b1000: out = src1 >> shamt; // SRL
            4'b1001: out = $signed(src1) >>> shamt; // SRA
            default: out = 32'd0;
        endcase

        zero = (out == 32'd0);
        sign = out[31];
    end

endmodule
