// for initial datapath file

module flopr #(parameter WIDTH = 8) (
    input  logic             clk,    // Clock input
    input  logic             reset,  // Asynchronous reset (active-high)
    input  logic [WIDTH-1:0] d,      // Data input
    output logic [WIDTH-1:0] q       // Data output
);

    always_ff @(posedge clk, posedge reset) begin
        if (reset)  q <= '0;    // Clear all bits on reset
        else        q <= d;     // Update on every clock edge
    end

endmodule

