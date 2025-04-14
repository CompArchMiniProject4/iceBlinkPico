module tb();

  logic clk; 
  logic reset;
  logic [31:0] WriteData, DataAdr;  
  logic MemWrite;
  logic [3:0] leds;
  logic [31:0] pwm_out;

  // Instantiate 'top' with all 7 ports
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
    reset <= 1; # 22; reset <= 0;
  end

  always begin 
    clk <= 1; # 5; clk <= 0; # 5;
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
