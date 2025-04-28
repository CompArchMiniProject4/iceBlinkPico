`include "flopenr.sv"
`include "flopr.sv"
`include "mux2.sv"
`include "mux3.sv"
`include "mux4.sv"
`include "alu.sv"
`include "imm_gen.sv"
`include "reg.sv"

module dataPath (
    input  logic        clk, reset,
    input  logic [3:0]  ALUControl,
    input  logic [1:0]  ResultSrc,
    input  logic        IRWrite,
    input  logic        RegWrite,
    input  logic [1:0]  ALUSrcA, ALUSrcB,
    input  logic [1:0]  AdrSrc,
    input  logic        PCWrite,
    input  logic [2:0]  ImmSrc,
    input  logic [31:0] ReadData,
    input  logic        memwrite,
    output logic        Zero, cout, overflow, sign,
    output logic [31:0] Adr,
    output logic [31:0] WriteData,
    output logic [31:0] instr
);

    // Internal wires/regs
    logic [31:0] Result, ALUOut, ALUResult;
    logic [31:0] RD1, RD2, A, SrcA, SrcB, Data;
    logic [31:0] ImmExt;
    logic [31:0] PC, OldPC;
    logic [31:0] aligned_address;
    logic [2:0]  funct3; // <-- Used instead of instr[14:12]
    logic [31:0] mem_address;

    // Extract instr[14:12] safely outside procedural block
    assign funct3 = instr[14:12];

    // PC register
    flopenr #(32) pcFlop(clk, reset, PCWrite, Result, PC);

    // Register file
    register_file rf (
        .clk(clk),
        .we(RegWrite),
        .rs1(instr[19:15]),
        .rs2(instr[24:20]),
        .rd(instr[11:7]),
        .wd(Result),
        .rd1(RD1),
        .rd2(RD2)
    );

    // Immediate extension
    extend ext (
        .instr(instr[31:7]),
        .ImmSrc(ImmSrc),
        .imm_out(ImmExt)
    );

    // Operand registers
    flopr #(32) AReg(clk, reset, RD1, A);
    flopr #(32) BReg(clk, reset, RD2, WriteData);

    // ALU operand selection
    mux3 #(32) srcAmux (
        .in0(PC),
        .in1(OldPC),
        .in2(A),
        .sel(ALUSrcA),
        .out(SrcA)
    );

    mux3 #(32) srcBmux (
        .in0(WriteData),
        .in1(ImmExt),
        .in2(32'd4),
        .sel(ALUSrcB),
        .out(SrcB)
    );

    // ALU
    alu alu (
        .src1(SrcA),
        .src2(SrcB),
        .aluc(ALUControl),
        .out(ALUResult),
        .zero(Zero),
        .cout(cout),
        .overflow(overflow),
        .sign(sign)
    );

    // ALU output register
    flopr #(32) aluReg(clk, reset, ALUResult, ALUOut);

    // Result selection
    mux4 #(32) resultMux (
        .in0(ALUOut),
        .in1(Data),
        .in2(ImmExt),
        .in3(32'h0),
        .sel(ResultSrc),
        .out(Result)
    );

    always_comb begin
        case (AdrSrc)
            2'b00: Adr = PC;            // Fetch stage (PC → instruction read)
            2'b01: Adr = ALUResult;     // Memory access (ALUResult → data read/write)
            default: Adr = PC;          
        endcase
    end

    // IR and PC history registers
    flopenr #(32) oldPcReg(clk, reset, IRWrite, PC, OldPC);
    flopenr #(32) instrReg(clk, reset, IRWrite, ReadData, instr);
    flopr   #(32) dataReg(clk, reset, ReadData, Data);

    // Aligned address logic — now uses funct3 instead of instr[14:12]
    always @* begin
        case (funct3)
            3'b000: aligned_address = ALUOut;                        // SB
            3'b001: aligned_address = {ALUOut[31:1], 1'b0};          // SH
            3'b010: aligned_address = {ALUOut[31:2], 2'b00};         // SW
            default: aligned_address = ALUOut;
        endcase
    end

endmodule
