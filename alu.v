module alu (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [2:0]  ALUControl,
    output reg  [31:0] ALUResult,
    output wire        Zero
);

    assign Zero = (ALUResult == 32'b0);

    always @(*) begin
        case (ALUControl)
            3'b000: ALUResult = A | B;
            3'b001: ALUResult = {B[15:0], 16'b0};
            3'b010: ALUResult = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            3'b011: ALUResult = A << B[4:0];
            3'b100: ALUResult = A >> B[4:0];
            3'b101: ALUResult = 32'b0;
            default: ALUResult = 32'b0;
        endcase
    end

endmodule
