
module top(input  logic        clk, reset, 
           output logic [31:0] WriteData, DataAdr, 
           output logic        MemWrite);

logic [31:0] ReadData;

rVMultiCycle rvMultiCycle(clk, reset, ReadData, DataAdr, MemWrite, WriteData);
mem mem(clk, MemWrite, DataAdr, WriteData, ReadData);

 
endmodule