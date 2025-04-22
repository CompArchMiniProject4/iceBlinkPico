`timescale 10ns/10ns
`include "top.sv"

module tb();
  logic clk; 
  logic reset;
  logic [31:0] WriteData, DataAdr;  
  logic MemWrite;
  logic [3:0] leds;
  logic [31:0] pwm_out;

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
    $dumpvars(0, dut);
    #1000000
    $finish;
  end

  always begin 
    #4
    clk = ~clk;
  end

  always @(negedge clk) begin
    if(MemWrite) begin 
      if(DataAdr == 252 & WriteData == 32'h00001000) begin
        $display("Simulation succeeded"); 
        $stop;
      end else begin 
        $display("Simulation failed"); 
        $stop;
      end
    end
  end

endmodule
