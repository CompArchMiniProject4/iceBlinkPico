`timescale 1ns/1ns
`include "top.sv"

module tb();
  logic clk; 
  logic reset;
  logic [31:0] WriteData, DataAdr;  
  logic MemWrite;
  logic [3:0] leds;
  logic [31:0] pwm_out;
  logic error_flag = 0;

  top dut(
    .clk(clk),
    .reset(reset),
    .WriteData(WriteData),
    .DataAdr(DataAdr),
    .MemWrite(MemWrite),
    .leds(leds),
    .pwm_out(pwm_out)
  );

  // Clock generation: 10ns period (100 MHz)
  always #5 clk = ~clk;

  // Reset pulse logic for synchronous reset
  initial begin 
    clk = 0;
    reset = 0;
    #2;               // Let clock settle
    @(negedge clk);   // Sync to clock edge
    reset = 1;        // Synchronous reset assertion
    @(negedge clk);   // Hold for 1 cycle
    reset = 0;        // Deassert reset
  end

  // Simulation control
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);

    #2000000; // 2ms simulation

    if (!error_flag) begin
      $display("Simulation succeeded: No errors detected");
      $display("Final LED state: %b", leds);
    end

    $finish;
  end

  // Simple monitor for expected memory writes
  always @(negedge clk) begin
    if (MemWrite) begin
      if (DataAdr === 32'd252) begin
        if (WriteData === 32'd0) begin
          $display("ERROR: Invalid zero write at %0t", $time);
          error_flag = 1;
        end else begin
          $display("Unexpected write to address 252: %h at %0t", WriteData, $time);
          error_flag = 1;
        end
        $finish;
      end
    end
  end

endmodule
