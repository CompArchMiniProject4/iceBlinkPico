`ifndef BRANCH_DEC_SV
`define BRANCH_DEC_SV

module branchDec (
    input  logic [2:0] funct3,  // From instruction[14:12]
    input  logic       branch,  // From main control unit
    output logic       beq, bne, blt, bge, bltu, bgeu
);

    always_comb begin
        // Default all outputs to 0
        {beq, bne, blt, bge, bltu, bgeu} = 6'b000000;
        
        if (branch) begin
            case (funct3)
                3'b000:  beq  = 1'b1;  // Branch Equal
                3'b001:  bne  = 1'b1;  // Branch Not Equal
                3'b100:  blt  = 1'b1;  // Branch Less Than (signed)
                3'b101:  bge  = 1'b1;  // Branch Greater/Equal (signed)
                3'b110:  bltu = 1'b1;  // Branch Less Than (unsigned)
                3'b111:  bgeu = 1'b1;  // Branch Greater/Equal (unsigned)
                default: ;            // No branch for invalid funct3
            endcase
        end
    end

endmodule
`endif