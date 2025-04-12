
module top(input  logic        clk, reset, 
           output logic [31:0] WriteData, DataAdr, 
           output logic        MemWrite),
           output logic [3:0] leds,
           output logic [31:0] pwm_out;

logic [31:0] ReadData;

rVMultiCycle rvMultiCycle(clk, reset, ReadData, DataAdr, MemWrite, WriteData);
           mem mem(clk, MemWrite, DataAdr, WriteData, ReadData, leds, pwm_out);

 
endmodule
