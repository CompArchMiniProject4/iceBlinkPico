module fsm (
    input  logic        clk, reset,
    input  logic [6:0]  op,
    output logic        branch, pcupdate, regwrite, memwrite, irwrite,
    output logic [1:0]  resultsrc, alusrcb, alusrca,
    output logic [1:0]  adrsrc,  // Changed from 1-bit to 2-bit
    output logic [1:0]  aluop
);

    // State definitions remain the same
    localparam S0  = 4'd0,
               S1  = 4'd1,
               S2  = 4'd2,
               S3  = 4'd3,
               S4  = 4'd4,
               S5  = 4'd5,
               S6  = 4'd6,
               S7  = 4'd7,
               S8  = 4'd8,
               S9  = 4'd9,
               S10 = 4'd10,
               S11 = 4'd11,
               S12 = 4'd12,
               S13 = 4'd13,
               S14 = 4'd14;

    logic [3:0] state, nextstate;
    wire op5 = op[5];

    // State register remains the same
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= S0;
        else
            state <= nextstate;
    end

    // Next state logic remains the same
    always_comb begin
        nextstate = S13;  // Default to error state
        case (state)
            S0:  nextstate = S1;
            S1: begin
                case (op)
                    7'b0110011: nextstate = S6;
                    7'b0010011: nextstate = S8;
                    7'b0000011: nextstate = S2;
                    7'b0100011: nextstate = S2;
                    7'b1100111: nextstate = S14;
                    7'b1100011: nextstate = S10;
                    7'b1101111: nextstate = S9;
                    7'b0010111: nextstate = S11;
                    7'b0110111: nextstate = S12;
                    default:    nextstate = S13;
                endcase
            end
            S2: nextstate = (op5 == 1'b0) ? S3 : S5;
            S3: nextstate = S4;
            S4: nextstate = S0;
            S5: nextstate = S0;
            S6: nextstate = S7;
            S7: nextstate = S0;
            S8: nextstate = S7;
            S9: nextstate = S7;
            S10: nextstate = S0;
            S11: nextstate = S7;
            S12: nextstate = S7;
            S14: nextstate = S7;
            S13: nextstate = S13;
            default: nextstate = S13;
        endcase
    end

    always_comb begin
        // Defaults
        branch     = 1'b0;
        pcupdate   = 1'b0;
        regwrite   = 1'b0;
        memwrite   = 1'b0;
        irwrite    = 1'b0;
        resultsrc  = 2'b00;
        alusrcb    = 2'b00;
        alusrca    = 2'b00;
        adrsrc     = 2'b00;  // Default to PC (instruction fetch)
        aluop      = 2'b00;

        case (state)
            S0: begin
                pcupdate  = 1'b1;
                irwrite   = 1'b1;
                resultsrc = 2'b10;
                alusrcb   = 2'b10;  // PC+4 calculation
                alusrca   = 2'b00;  // Use PC
                adrsrc    = 2'b00;  // Address from PC (instruction fetch)
                aluop     = 2'b00;  // ADD
            end
            S1: begin
                alusrcb = 2'b01;  // Register B
                alusrca = 2'b01;  // Register A
                adrsrc  = 2'b00;  // PC
                aluop   = 2'b00;  // ADD
            end
            S2: begin
                alusrcb = 2'b01;  // Immediate for address calculation
                alusrca = 2'b10;  // Base address from register
                adrsrc  = 2'b00;  // PC
                aluop   = 2'b00;  // ADD
            end
            S3: begin
                adrsrc = 2'b01;  // Use ALU result (load address)
            end
            S4: begin
                regwrite  = 1'b1;
                resultsrc = 2'b01;  
                adrsrc    = 2'b01;  // Use ALU result
            end
            S5: begin
                memwrite = 1'b1;
                adrsrc   = 2'b01;  // Use ALU result
            end
            S6: begin
                alusrca = 2'b10;  // Register A
                adrsrc  = 2'b00;  // PC (not used here, but default)
                aluop   = 2'b10;  // R-type operation
            end
            S7: begin
                regwrite = 1'b1;
                adrsrc   = 2'b00;  // Back to PC
            end
            S8: begin
                alusrca = 2'b10;  // Register A
                alusrcb = 2'b01;  // Immediate
                adrsrc  = 2'b00;  // PC
                aluop   = 2'b10;  // I-type operation
            end
            S9: begin
                pcupdate  = 1'b1;
                alusrca   = 2'b00;  // PC
                alusrcb   = 2'b01;  // Immediate (offset)
                adrsrc    = 2'b00;  // PC (for jump target calculation)
                aluop     = 2'b00;  // ADD
                resultsrc = 2'b10;  // PC+4
            end
            S10: begin
                branch   = 1'b1;
                alusrca  = 2'b10;  // Register A
                alusrcb  = 2'b01;  // Register B
                adrsrc   = 2'b00;  // PC
                aluop    = 2'b01;  // SUB for comparison
            end
            S11: begin
                alusrca = 2'b01;  // Not used (AUIPC)
                alusrcb = 2'b01;  // Immediate
                adrsrc  = 2'b00;  // PC
                aluop   = 2'b00;  // ADD
            end
            S12: begin
                resultsrc = 2'b11;  // LUI result
                adrsrc    = 2'b00;  // PC
            end
            S14: begin
                pcupdate  = 1'b1;
                alusrca   = 2'b10;  // Register A (JALR)
                alusrcb   = 2'b01;  // Immediate
                adrsrc    = 2'b00;  // PC 
                aluop     = 2'b00;  // ADD
                resultsrc = 2'b10;  // PC+4
            end
        endcase
    end
    
    always @(posedge clk) begin  // Not recommended for production code
        if (state == S3 || state == S5) begin
            $display("[%t] STATE=%d, adrsrc=%b", $time, state, adrsrc);
        end
    end

endmodule
