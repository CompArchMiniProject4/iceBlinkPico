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

  initial begin 
    clk = 0;
    reset = 1;
    #20 reset = 0;
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #2000000  // 2 million time units = 2ms simulation
    if(!error_flag) begin
      $display("Simulation succeeded: No errors detected");
      $display("Final LED state: %b", leds);
    end
    $finish;
  end

  always #5 clk = ~clk;  // 10ns period (100 MHz)

  always @(negedge clk) begin
    if(MemWrite) begin
      if(DataAdr === 252) begin
        if(WriteData === 0) begin
          $display("ERROR: Test failed at time %0t", $time);
          error_flag = 1;
        end
        else begin
          $display("Unexpected write to address 252: %h", WriteData);
          error_flag = 1;
        end
        $finish;
      end
    end
  end

endmodule