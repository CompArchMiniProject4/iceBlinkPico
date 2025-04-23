// 4-input multiplexer with parameterized width
// sel=00: out = in0
// sel=01: out = in1
// sel=10: out = in2
// sel=11: out = in3
module mux4 #(parameter WIDTH = 32) (
    input  logic [WIDTH-1:0] in0, in1, in2, in3,  // Input channels
    input  logic [1:0]       sel,                 // Selection signal
    output logic [WIDTH-1:0] out                  // Selected output
);

    always_comb begin
        case (sel)
            2'b00:    out = in0;
            2'b01:    out = in1;
            2'b10:    out = in2;
            2'b11:    out = in3;
            default:  out = 'x;  // X-propagation for simulation debugging
        endcase
    end

endmodule

