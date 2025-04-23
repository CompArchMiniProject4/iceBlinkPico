`include "fsm.sv"
`include "aluDec.sv"
`include "branchDec.sv"

module controller(
    input  logic       clk, reset,
    input  logic [6:0] op,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    input  logic       zero, cout, overflow, sign,
    output logic [2:0] immsrc,
    output logic [1:0] alusrca, alusrcb,
    output logic [1:0] resultsrc,
    output logic       adrsrc,
    output logic [3:0] alucontrol,
    output logic       irwrite, pcwrite,
    output logic       regwrite, memwrite
);

    logic beq, bne, blt, bge, bltu, bgeu;
    logic branch, pcupdate;
    logic [1:0] aluop;

    // Main Finite State Machine
    fsm MainFSM(
        .clk(clk),
        .reset(reset),
        .op(op),
        .branch(branch),
        .pcupdate(pcupdate),
        .regwrite(regwrite),
        .memwrite(memwrite),
        .irwrite(irwrite),
        .resultsrc(resultsrc),
        .alusrcb(alusrcb),
        .alusrca(alusrca),
        .adrsrc(adrsrc),
        .aluop(aluop)
    );

    // ALU Control Decoder
    aluDec AluDecoder(
        .aluop(aluop),
        .op5(op[5]),        // Instruction bit 5 for R-type/I-type distinction
        .funct7b5(funct7b5), // Instruction bit 30
        .funct3(funct3),
        .alucontrol(alucontrol)
    );

    // Branch Type Decoder
    branchDec BranchDecoder(
        .funct3(funct3),  // Now connected
        .branch(branch),
        .beq(beq),
        .bne(bne),
        .blt(blt),
        .bge(bge),
        .bltu(bltu),
        .bgeu(bgeu)
    );

    // PC Write Control Logic
    assign pcwrite = (beq & zero) |           // BEQ
                    (bne & ~zero) |          // BNE
                    (blt & (sign != overflow)) |  // BLT (signed)
                    (bge & (sign == overflow)) |  // BGE (signed)
                    (bltu & ~cout) |         // BLTU (unsigned)
                    (bgeu & cout) |          // BGEU (unsigned)
                    pcupdate;                // Normal PC update

endmodule