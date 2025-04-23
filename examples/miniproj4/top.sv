`include "riscV_MultiCycle.sv"
`include "mem.sv"

module top (
    input  logic        clk, reset,
    output logic [31:0] WriteData,
    output logic [31:0] DataAdr,
    output logic        MemWrite,
    output logic [3:0]  leds,
    output logic [31:0] pwm_out
);

    logic [31:0] ReadData;
    logic [2:0]  funct3;  // Added funct3 signal

    rVMultiCycle rvMultiCycle (
        .clk(clk),
        .reset(reset),
        .ReadData(ReadData),
        .Adr(DataAdr),
        .MemWrite(MemWrite),
        .WriteData(WriteData)
    );

    memory memory (
        .clk(clk),
        .write_mem(MemWrite),
        .funct3(funct3),  // Now connected to processor's funct3
        .write_address(DataAdr),
        .write_data(WriteData),
        .read_address(DataAdr),
        .read_data(ReadData),
        .led(leds[0]),
        .red(leds[1]),
        .green(leds[2]),
        .blue(leds[3])
    );

    assign pwm_out = {leds, 28'd0};

endmodule