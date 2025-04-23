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
    logic [2:0]  funct3;

    // Main processor core
    rVMultiCycle rvMultiCycle (
        .clk(clk),
        .reset(reset),
        .ReadData(ReadData),     // From memory
        .Adr(DataAdr),           // To memory
        .MemWrite(MemWrite),     // To memory
        .WriteData(WriteData),   // To memory
        .funct3(funct3)          // From instruction [14:12]
    );

    // Memory subsystem with I/O mapping
    memory memory (
        .clk(clk),
        .write_mem(MemWrite),    // Controlled by FSM
        .funct3(funct3),         // For store size alignment
        .write_address(DataAdr),
        .write_data(WriteData),
        .read_address(DataAdr),
        .read_data(ReadData),
        .led(leds[0]),          // LED bit 0
        .red(leds[1]),          // LED bit 1
        .green(leds[2]),        // LED bit 2
        .blue(leds[3])          // LED bit 3
    );

    // PWM output expansion
    assign pwm_out = {leds, 28'd0};

endmodule