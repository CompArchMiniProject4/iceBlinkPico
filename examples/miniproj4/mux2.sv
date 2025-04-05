module mux2_32 (
    input  logic [31:0] a,   
    input  logic [31:0] b,   
    input  logic        sel, // control signal
    output logic [31:0] out
);
    assign out = sel ? b : a;
endmodule
