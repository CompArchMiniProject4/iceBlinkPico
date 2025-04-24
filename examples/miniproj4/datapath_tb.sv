`timescale 1ns/1ns
`include "dataPath.sv"

module dataPath_tb;

  logic clk, reset;

  // ... (other declarations remain the same)

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
    // Correct ADDI encoding: 0x14E02813
    ReadData = 32'h14E02813;
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