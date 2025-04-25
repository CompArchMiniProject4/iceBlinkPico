module flopenr #(parameter WIDTH = 8) (
    input  logic             clk,   // Clock input
    input  logic             reset, // Asynchronous reset (active-high)
    input  logic             en,    // Enable input (active-high)
    input  logic [WIDTH-1:0] d,     // Data input
    output logic [WIDTH-1:0] q      // Data output
);

    always_ff @(posedge clk, posedge reset) begin
        if (reset)  q <= '0;         // Async reset to all zeros
        else if (en) q <= d;         // Update on enable
        // No else: retains value when not enabled
    end

endmodule
