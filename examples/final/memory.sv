module memory #(
    parameter INIT_FILE = ""
)(
    input logic clk,
    input logic [8:0] read_address,
    output logic [9:0] read_data
);

    logic [8:0] quarter_cycle_memory [0:127]; // 9-bit amplitude (0-511)

    initial if (INIT_FILE) begin
        $readmemh(INIT_FILE, quarter_cycle_memory);
    end

    always_ff @(posedge clk) begin
        case (read_address[8:7])
            // Q1: 0-π/2 -> 512 to 1023 (512 + amplitude)
            2'b00: read_data <= 10'd512 + {1'b0, quarter_cycle_memory[read_address[6:0]]};
            
            // Q2: π/2-π -> 1023 to 512 (512 + mirrored amplitude)
            2'b01: read_data <= 10'd512 + {1'b0, quarter_cycle_memory[127 - read_address[6:0]]};
            
            // Q3: π-3π/2 -> 512 to 1 (512 - amplitude)
            2'b10: read_data <= 10'd512 - {1'b0, quarter_cycle_memory[read_address[6:0]]};
            
            // Q4: 3π/2-2π -> 1 to 512 (512 - mirrored amplitude)
            2'b11: read_data <= 10'd512 - {1'b0, quarter_cycle_memory[127 - read_address[6:0]]};
        endcase
    end

endmodule

