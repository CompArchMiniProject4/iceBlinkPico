`timescale 1ns/1ns
`include "dataPath.sv"

module dataPath_tb;

  logic clk, reset;

  // Control signals
  logic [3:0]  ALUControl;
  logic [1:0]  ResultSrc;
  logic        IRWrite, RegWrite;
  logic [1:0]  ALUSrcA, ALUSrcB;
  logic        AdrSrc, PCWrite;
  logic [2:0]  ImmSrc;

  // Inputs
  logic [31:0] ReadData;

  // Outputs
  logic        Zero, cout, overflow, sign;
  logic [31:0] Adr, WriteData, instr;

  // DUT
  dataPath dut (
    .clk(clk),
    .reset(reset),
    .ALUControl(ALUControl),
    .ResultSrc(ResultSrc),
    .IRWrite(IRWrite),
    .RegWrite(RegWrite),
    .ALUSrcA(ALUSrcA),
    .ALUSrcB(ALUSrcB),
    .AdrSrc(AdrSrc),
    .PCWrite(PCWrite),
    .ImmSrc(ImmSrc),
    .ReadData(ReadData),
    .memwrite(1'b0),
    .Zero(Zero),
    .cout(cout),
    .overflow(overflow),
    .sign(sign),
    .Adr(Adr),
    .WriteData(WriteData),
    .instr(instr)
  );

  // Clock generation
  always #5 clk = ~clk;

  initial begin
    $dumpfile("dataPath_tb.vcd");
    $dumpvars(0, dataPath_tb);

    clk = 0;
    reset = 0;

    // Synchronous reset
    @(negedge clk); reset = 1;
    @(negedge clk); reset = 0;

    $display("\n========== WRITE DATA FUNCTIONAL TEST ==========");

    // -------------------------------------
    // Step 1: Write 0x14E into register x5 using ADDI
    // ADDI x5, x0, 0x14E (334)
    // Encoding: imm[11:0]=0x14E, rs1=0, funct3=000, rd=5, opcode=0010011
    ReadData = 32'h014E0005 | 32'h00100113; // Correct ADDI encoding
    IRWrite  = 1;
    @(negedge clk); 
    IRWrite = 0;

    // Configure control signals for ADDI
    RegWrite   = 1;
    ResultSrc  = 2'b00;  // Result = ALUOut
    ImmSrc     = 3'b000; // I-type
    ALUSrcA    = 2'b10;  // Register A (rs1 = x0)
    ALUSrcB    = 2'b01;  // ImmExt
    ALUControl = 4'b0000; // ADD

    // Wait for write to complete
    @(negedge clk);
    RegWrite = 0;

    // -------------------------------------
    // Step 2: Read x5 via ADD instruction
    // ADD x0, x0, x5 (rs2 = 5)
    // Encoding: funct7=0000000, rs2=5, rs1=0, funct3=000, rd=0, opcode=0110011
    ReadData = 32'h00500033; // Correct ADD encoding
    IRWrite  = 1;
    @(negedge clk);
    IRWrite = 0;

    // Configure control signals for ADD
    ALUSrcA    = 2'b10;  // Register A
    ALUSrcB    = 2'b00;  // Register B
    ALUControl = 4'b0000; // ADD

    // Allow time for BReg to update
    @(negedge clk);

    // -------------------------------------
    // Step 3: Verify WriteData == 0x14E
    $display("WriteData observed: %h", WriteData);
    if (WriteData !== 32'h0000014E) begin
      $fatal(1, "ERROR: Expected 0x0000014E, got %h", WriteData);
    end else begin
      $display("SUCCESS: WriteData correct");
    end

    $display("Test completed.");
    $finish;
  end

endmodule