module aluDec (
    input  logic [1:0]  aluop,
    input  logic        op5, funct7b5,
    input  logic [2:0]  funct3,
    output logic [3:0]  alucontrol
);

    always_comb begin
        case(aluop)
            2'b00: alucontrol = 4'b0000;  // ADD (for loads/stores/ADDI)
            2'b01: alucontrol = 4'b0001;  // SUB (for branches)
            2'b10: begin                  // R-type/I-type operations
                case (funct3)
                    3'b000:  // ADD/SUB
                        alucontrol = ({op5, funct7b5} == 2'b11) ? 4'b0001 : 4'b0000;
                    3'b001:  // SLL
                        alucontrol = 4'b0111;
                    3'b010:  // SLT
                        alucontrol = 4'b0101;
                    3'b011:  // SLTU
                        alucontrol = 4'b0110;
                    3'b100:  // XOR
                        alucontrol = 4'b0100;
                    3'b101:  // SRL/SRA
                        alucontrol = funct7b5 ? 4'b1001 : 4'b1000;
                    3'b110:  // OR
                        alucontrol = 4'b0011;
                    3'b111:  // AND
                        alucontrol = 4'b0010;
                    default: 
                        alucontrol = 4'bxxxx;  // Undefined
                endcase
            end
            default: 
                alucontrol = 4'bxxxx;  // Undefined ALU operation
        endcase
    end

endmodule
