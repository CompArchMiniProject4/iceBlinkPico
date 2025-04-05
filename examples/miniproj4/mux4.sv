module mux4(
    input  logic [31:0] a,   
    input  logic [31:0] b,   
    input  logic [31:0] c,   
    input  logic [31:0] d,   
    input  logic [1:0]  sel, 
    output logic [31:0] out
);
    always_comb begin
        case (sel)
            2'b00: out = a;
            2'b01: out = b;
            2'b10: out = c;
            2'b11: out = d;
        endcase
    end
endmodule
