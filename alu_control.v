module alu_control (
    input  wire [1:0] ALUOp,
    input  wire [5:0] Funct,
    input  wire [5:0] Opcode,
    output reg  [2:0] ALUControl
);

    always @(*) begin
        case (ALUOp)
            2'b01: ALUControl = 3'b000; // ORI
            2'b10: ALUControl = 3'b001; // LUI
            2'b11: ALUControl = 3'b101;
            2'b00: begin             
                if      (Opcode == 6'b110010) ALUControl = 3'b011; // LSR
                else if (Opcode == 6'b111011) ALUControl = 3'b100; // RSR
                else if (Funct  == 6'b101010) ALUControl = 3'b010; // SLT
                else                          ALUControl = 3'b000;
            end
            default: ALUControl = 3'b000;
        endcase
    end

endmodule
