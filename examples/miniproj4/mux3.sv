// 3-input multiplexer with parameterized width
// sel=00: out = in0
// sel=01: out = in1
// sel=10: out = in2
// sel=11: undefined (outputs zeros for safe synthesis)
module mux3 #(parameter WIDTH = 32) (
    input  logic [WIDTH-1:0] in0, in1, in2,  // Input channels
    input  logic [1:0]       sel,            // Selection signal
    output logic [WIDTH-1:0] out             // Selected output
);

    always_comb begin
        case (sel)
            2'b00:    out = in0;
            2'b01:    out = in1;
            2'b10:    out = in2;
            default:  out = '0;  // Safe default for synthesis
        endcase
    end

endmodule