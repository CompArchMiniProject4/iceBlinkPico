module dataPath (
    input logic clk, reset,
    input logic [2:0] ImmSrc, 
    input logic [3:0] ALUControl, 
    input logic [1:0] ResultSrc, 
    input logic IRWrite,
    input logic RegWrite,
    input logic [1:0] ALUSrcA, ALUSrcB, 
    input logic AdrSrc, 
    input logic PCWrite,  
    input logic [31:0] ReadData,
    input logic memwrite,  
    output logic Zero, cout, overflow, sign, 
    output logic [31:0] Adr, 
    output logic [31:0] WriteData,
    output logic [31:0] instr
);

logic [31:0] Result , ALUOut, ALUResult;
logic [31:0] RD1, RD2, A , SrcA, SrcB, Data;
logic [31:0] ImmExt;
logic [31:0] PC, OldPC;
logic [31:0] aligned_address;

// PC register
flopenr #(32) pcFlop(clk, reset, PCWrite, Result, PC);

// Register file
register_file rf(clk, RegWrite, instr[19:15], instr[24:20], instr[11:7], Result, RD1, RD2); 
extend ext(instr[31:7], ImmSrc, ImmExt);
flopr #(32) regF( clk, reset, RD1, A);
flopr #(32) regF_2( clk, reset, RD2, WriteData);

// ALU path
mux3 #(32) srcAmux(PC, OldPC, A, ALUSrcA, SrcA);
mux3 #(32) srcBmux(WriteData, ImmExt, 32'd4, ALUSrcB, SrcB);
alu alu(SrcA, SrcB, ALUControl, ALUResult, Zero, cout, overflow, sign);
flopr #(32) aluReg (clk, reset, ALUResult, ALUOut);
mux4 #(32) resultMux(ALUOut, Data, ALUResult, ImmExt, ResultSrc, Result);

// Memory path
mux2 #(32) adrMux (
    .a(PC),
    .b(Result),
    .sel(AdrSrc),
    .out(Adr)
);
flopenr #(32) memFlop1(clk, reset, IRWrite, PC, OldPC); 
flopenr #(32) memFlop2(clk, reset, IRWrite, ReadData, instr);
flopr #(32) memDataFlop(clk, reset, ReadData, Data);

// Aligned memory address
assign aligned_address = 
        (memwrite && instr[14:12] == 3'b010) ? {ALUOut[31:2], 2'b00} :  
        (memwrite && instr[14:12] == 3'b001) ? {ALUOut[31:1], 1'b0} : 
        ALUOut;

// Removed: assign aluout = aligned_address;

endmodule
