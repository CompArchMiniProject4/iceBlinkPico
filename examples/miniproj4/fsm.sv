module fsm (
    input  logic        clk, rst,
    input  logic [6:0]  op,
    output logic        branch, pcupdate, regwrite, memwrite, irwrite,
    output logic [1:0]  resultsrc, alusrcb, alusrca,
    output logic        adrsrc,
    output logic [1:0]  aluop
);

    typedef enum logic [3:0] {
        s0, s1, s2, s3, s4, s5, s6, s7,
        s8, s9, s10, s11, s12, s13
    } statetype;

    statetype state, nextstate;

    logic op5, op6;
    assign op5 = op[5];
    assign op6 = op[6];

    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            state <= s0;
        else
            state <= nextstate;
    end

    always_comb begin
        case (state)
            s0: nextstate = s1;
            s1: case (op)
                7'b0110011: nextstate = s6;
                7'b0010011: nextstate = s8;
                7'b0000011,
                7'b0100011,
                7'b1100111: nextstate = s2;
                7'b1100011: nextstate = s10;
                7'b1101111: nextstate = s9;
                7'b0010111: nextstate = s11;
                7'b0110111: nextstate = s12;
                default:    nextstate = s13;
            endcase
            s2: nextstate = statetype'(op5 ? (op6 ? s9 : s5) : s3);
            s3: nextstate = s4;
            s4, s5, s7, s0, s10, s12: nextstate = s0;
            s6, s8, s9, s11: nextstate = s7;
            s13: nextstate = s13;
        endcase
    end

    always_comb begin
        branch    = 0;
        pcupdate  = 0;
        regwrite  = 0;
        memwrite  = 0;
        irwrite   = 0;
        resultsrc = 2'b00;
        alusrcb   = 2'b00;
        alusrca   = 2'b00;
        adrsrc    = 0;
        aluop     = 2'b00;

        case (state)
            s0: begin pcupdate = 1; irwrite = 1; resultsrc = 2'b10; alusrcb = 2'b10; end
            s1: begin alusrcb = 2'b01; alusrca = 2'b01; end
            s2: begin alusrcb = 2'b01; alusrca = 2'b10; end
            s3: begin adrsrc = 1; end
            s4: begin regwrite = 1; resultsrc = 2'b01; end
            s5: begin memwrite = 1; adrsrc = 1; end
            s6: begin alusrca = 2'b10; aluop = 2'b10; end
            s7: begin regwrite = 1; end
            s8: begin alusrcb = 2'b01; alusrca = 2'b10; aluop = 2'b10; end
            s9: begin pcupdate = 1; alusrcb = 2'b10; alusrca = 2'b01; end
            s10: begin branch = 1; alusrca = 2'b10; aluop = 2'b01; end
            s11: begin alusrcb = 2'b01; alusrca = 2'b01; end
            s12: begin regwrite = 1; resultsrc = 2'b11; end
            default: /* s13 */ begin end
        endcase
    end

endmodule
