module control_unit (
    input  wire [5:0] Opcode,
    output reg        RegDst,
    output reg        ALUSrc,
    output reg        MemToReg,
    output reg        RegWrite,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        Branch,
    output reg        Jump,
    output reg  [1:0] ALUOp
);

    always @(*) begin

        RegDst   = 1'b0;
        ALUSrc   = 1'b0;
        MemToReg = 1'b0;
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        Branch   = 1'b0;
        Jump     = 1'b0;
        ALUOp    = 2'b00;

        case (Opcode)
            6'b001111: begin // LUI
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
            end
            6'b001101: begin // ORI
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b01;
            end
            6'b000000: begin // SLT (funct=101010)
                RegDst   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b00;
            end
            6'b110010: begin // LSR
                RegDst   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b00;
            end
            6'b111011: begin // RSR
                RegDst   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b00;
            end
            6'b000010: begin // J
                Jump     = 1'b1;
                ALUOp    = 2'b11;
            end
            default: ; // NOP
        endcase
    end

endmodule
