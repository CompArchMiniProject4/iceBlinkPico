module rVMultiCycle (
  input  logic        clk, reset,
  input  logic [31:0] ReadData,
  output logic [31:0] Adr,
  output logic        MemWrite,
  output logic [31:0] WriteData
);

  // Declare missing signals for controller and dataPath
  logic [1:0] ALUSrcA, ALUSrcB, ResultSrc;
  logic [2:0] ImmSrc;
  logic [3:0] alucontrol;
  logic       adrSrc, irwrite, pcwrite, regwrite;
  logic       Zero, cout, overflow, sign;  // Added missing flags
  logic [31:0] Instr;

  // Corrected controller instantiation (now 19 ports)
  controller c(
    .clk(clk),
    .reset(reset),
    .op(Instr[6:0]),           // From dataPath's Instr output
    .funct3(Instr[14:12]),     // From dataPath's Instr output
    .funct7b5(Instr[30]),      // From dataPath's Instr output
    .zero(Zero),               // From dataPath
    .cout(cout),               // From dataPath (newly added)
    .overflow(overflow),       // From dataPath (newly added)
    .sign(sign),               // From dataPath (newly added)
    .immsrc(ImmSrc),
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

  // Corrected dataPath instantiation (now 19 ports)
  dataPath dp(
    .clk(clk),
    .reset(reset),
    .ImmSrc(ImmSrc),
    .ALUControl(alucontrol),
    .ResultSrc(ResultSrc),
    .IRWrite(irwrite),
    .RegWrite(regwrite),
    .ALUSrcA(ALUSrcA),
    .ALUSrcB(ALUSrcB),
    .AdrSrc(adrSrc),
    .PCWrite(pcwrite),
    .ReadData(ReadData),
    .Zero(Zero),               // To controller
    .cout(cout),               // To controller (newly added)
    .overflow(overflow),       // To controller (newly added)
    .sign(sign),               // To controller (newly added)
    .Adr(Adr),
    .WriteData(WriteData),
    .instr(Instr)              // Connects to controller's op/funct3/funct7b5
  );

endmodule
