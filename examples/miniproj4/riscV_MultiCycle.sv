`include "controller.sv"
`include "dataPath.sv"

module rVMultiCycle (
  input  logic        clk, reset,
  input  logic [31:0] ReadData,
  output logic [31:0] Adr,
  output logic        MemWrite,
  output logic [31:0] WriteData,
  output logic [2:0]  funct3
);

  logic [1:0] ALUSrcA, ALUSrcB, ResultSrc;
  logic [2:0] ImmSrc;
  logic [3:0] alucontrol;
  logic       adrSrc, irwrite, pcwrite, regwrite;
  logic       Zero, cout, overflow, sign;
  logic [31:0] Instr;

  controller c(
    .clk(clk),
    .reset(reset),
    .op(Instr[6:0]),
    .funct3(Instr[14:12]),
    .funct7b5(Instr[30]),
    .zero(Zero),
    .cout(cout),
    .overflow(overflow),
    .sign(sign),
    .immsrc(ImmSrc),      // Now connected
    .alusrca(ALUSrcA),
    .alusrcb(ALUSrcB),
    .resultsrc(ResultSrc),
    .adrsrc(adrSrc),
    .alucontrol(alucontrol),
    .irwrite(irwrite),
    .pcwrite(pcwrite),
    .regwrite(regwrite),
    .memwrite(MemWrite)
  );

  dataPath dp(
    .clk(clk),
    .reset(reset),
    .ALUControl(alucontrol),
    .ResultSrc(ResultSrc),
    .IRWrite(irwrite),
    .RegWrite(regwrite),
    .ALUSrcA(ALUSrcA),
    .ALUSrcB(ALUSrcB),
    .ImmSrc(ImmSrc),      // Connected here
    .AdrSrc(adrSrc),
    .PCWrite(pcwrite),
    .ReadData(ReadData),
    .memwrite(MemWrite),  // Lowercase if required
    .Zero(Zero),
    .cout(cout),
    .overflow(overflow),
    .sign(sign),
    .Adr(Adr),
    .WriteData(WriteData),
    .instr(Instr)
  );

endmodule