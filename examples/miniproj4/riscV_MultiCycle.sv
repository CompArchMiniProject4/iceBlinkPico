module riscV_MultiCycle (input logic clk, reset,
                         input logic [31:0] ReadData,
                         output logic [31:0] Adr,
                         output logic MemWrite,
                         output logic [31:0] WriteData);

  logic [1:0] ResultSrc, ImmSrc, ALUSrcB;
  logic adrSrc, alucontrol;
  logic irwrite, pcwrite;
  logic regwrite;
  logic [31:0] Instr;

  controller c(clk, reset, Instr[6:0], Instr[14:12], Instr[30], Zero, ImmSrc, ALUSrcA,
                ALUSrcB, ResultSrc, adrSrc, alucontrol, irwrite, pcwrite, regwrite, MemWrite);
  dataPath dp(clk, reset, ImmSrc, alucontrol, ResultSrc, irwrite, regwrite, ALUSrcA, ALUSrcB,
              adrSrc, pcwrite, ReadData, Zero, Adr, WriteData, Instr);

endmodule
