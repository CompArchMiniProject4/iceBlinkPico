module controller (
    input  logic        clk,
    input  logic        reset,
    input  logic [6:0]  opcode,     // From instruction[6:0]
    output logic        pc_en,
    output logic        pc_src,
    output logic        ir_en,
    output logic        regfile_we,
    output logic [1:0]  alu_src_a,
    output logic [1:0]  alu_src_b,
    output logic [2:0]  alu_op,
    output logic        mem_read,
    output logic        mem_write,
    output logic        mem_to_reg
);

    typedef enum logic [2:0] {
        FETCH,
        DECODE,
        EXECUTE,
        MEM_ACCESS,
        WRITEBACK,
        BRANCH
    } state_t;

    state_t state, next_state;

    // FSM state transition
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= FETCH;
        else
            state <= next_state;
    end

    // FSM next-state logic + control signals
    always_comb begin
        // Default all control signals to 0
        pc_en      = 0;
        pc_src     = 0;
        ir_en      = 0;
        regfile_we = 0;
        alu_src_a  = 2'b00;
        alu_src_b  = 2'b00;
        alu_op     = 3'b000;
        mem_read   = 0;
        mem_write  = 0;
        mem_to_reg = 0;
        next_state = state;

        case (state)
            FETCH: begin
                mem_read = 1;
                ir_en    = 1;
                pc_en    = 1;
                pc_src   = 0; // PC + 4
                next_state = DECODE;
            end

            DECODE: begin
                // Extract opcode and decide instruction type
                case (opcode)
                    7'b0110011: next_state = EXECUTE;    // R-type
                    7'b0010011: next_state = EXECUTE;    // I-type (ALU)
                    7'b0000011: next_state = EXECUTE;    // Load
                    7'b0100011: next_state = EXECUTE;    // Store
                    7'b1100011: next_state = BRANCH;     // Branch
                    7'b1101111: next_state = EXECUTE;    // JAL
                    default:    next_state = FETCH;      // Unknown, skip
                endcase
            end

            EXECUTE: begin
                // Set ALU inputs based on instruction type
                // (Example shown for R-type and I-type)
                alu_src_a = 2'b01; // Register rs1
                alu_src_b = (opcode == 7'b0010011) ? 2'b10 : 2'b01; // imm or rs2
                alu_op    = /* logic to decode funct3/funct7 */ 3'b010; // Example: ADD
                if (opcode == 7'b0000011 || opcode == 7'b0100011)
                    next_state = MEM_ACCESS;
                else
                    next_state = WRITEBACK;
            end

            MEM_ACCESS: begin
                if (opcode == 7'b0000011) begin // Load
                    mem_read = 1;
                    next_state = WRITEBACK;
                end else begin // Store
                    mem_write = 1;
                    next_state = FETCH;
                end
            end

            WRITEBACK: begin
                regfile_we = 1;
                mem_to_reg = (opcode == 7'b0000011); // If load, take data from memory
                next_state = FETCH;
            end

            BRANCH: begin
                alu_src_a = 2'b01; // rs1
                alu_src_b = 2'b01; // rs2
                alu_op    = 3'b001; // SUB for comparison
                // (Assume branch decision is made outside and result sent here)
                if (/* branch_taken */) begin
                    pc_en  = 1;
                    pc_src = 1; // jump to branch target
                end else begin
                    pc_en  = 1;
                    pc_src = 0; // PC + 4
                end
                next_state = FETCH;
            end
        endcase
    end

endmodule
