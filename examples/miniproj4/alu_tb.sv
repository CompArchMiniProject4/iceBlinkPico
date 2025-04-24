`timescale 1ns/1ns
`include "alu.sv"

module alu_tb;

  logic [31:0] src1, src2;
  logic [3:0]  aluc;
  logic [31:0] out;
  logic        zero, cout, overflow, sign;

  alu dut (
    .src1(src1),
    .src2(src2),
    .aluc(aluc),
    .out(out),
    .zero(zero),
    .cout(cout),
    .overflow(overflow),
    .sign(sign)
  );

  // Helper task for checking output
  task automatic check(string name, logic [31:0] expected);
    if (out !== expected) begin
      $display("FAIL: %s | src1=%0d, src2=%0d => out=%h (expected %h)", name, src1, src2, out, expected);
      $fatal;
    end else begin
      $display("PASS: %s | out=%h", name, out);
    end
  endtask

  initial begin
    $display("\n===== ALU Test Start =====");
    $dumpfile("alu_tb.vcd");
    $dumpvars(0, alu_tb);

    // ADD: 15 + 10 = 25
    src1 = 32'd15; src2 = 32'd10; aluc = 4'b0000; #1;
    check("ADD", 32'd25);

    // SUB: 20 - 10 = 10
    src1 = 32'd20; src2 = 32'd10; aluc = 4'b0001; #1;
    check("SUB", 32'd10);

    // AND
    src1 = 32'hFF00FF00; src2 = 32'h0F0F0F0F; aluc = 4'b0010; #1;
    check("AND", 32'h0F000F00);

    // OR
    src1 = 32'hFF00FF00; src2 = 32'h0F0F0F0F; aluc = 4'b0011; #1;
    check("OR", 32'hFF0FFF0F);

    // XOR
    src1 = 32'hFFFF0000; src2 = 32'h00FFFF00; aluc = 4'b0100; #1;
    check("XOR", 32'hFF00FF00);

    // SLT (signed): -5 < 2 => 1
    src1 = -5; src2 = 2; aluc = 4'b0101; #1;
    check("SLT", 32'd1);

    // SLTU (unsigned): 5 < 2 => 0
    src1 = 5; src2 = 2; aluc = 4'b0110; #1;
    check("SLTU", 32'd0);

    // SLL (shift left logical): 1 << 3 = 8
    src1 = 32'd1; src2 = 32'd3; aluc = 4'b0111; #1;
    check("SLL", 32'd8);

    // SRL (shift right logical): 0x80000000 >> 2 = 0x20000000
    src1 = 32'h80000000; src2 = 32'd2; aluc = 4'b1000; #1;
    check("SRL", 32'h20000000);

    // SRA (arithmetic shift): -4 >>> 1 = -2
    src1 = -4; src2 = 32'd1; aluc = 4'b1001; #1;
    check("SRA", -2);

    $display("🎉 All ALU tests passed!");
    $finish;
  end

endmodule
