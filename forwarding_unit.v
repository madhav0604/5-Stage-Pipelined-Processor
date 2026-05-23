// ForwardA/B encoding: 00=regfile, 10=EX/MEM (closer), 01=MEM/WB (farther)
// EX hazard takes priority over MEM hazard.

module forwarding_unit (
    input  wire [4:0] ID_EX_RS,
    input  wire [4:0] ID_EX_RT,
    input  wire [4:0] EX_MEM_RD,
    input  wire       EX_MEM_RegWrite,
    input  wire [4:0] MEM_WB_RD,
    input  wire       MEM_WB_RegWrite,
    output reg  [1:0] ForwardA,
    output reg  [1:0] ForwardB
);

    always @(*) begin
        if (EX_MEM_RegWrite && (EX_MEM_RD != 5'b0) && (EX_MEM_RD == ID_EX_RS))
            ForwardA = 2'b10;
        else if (MEM_WB_RegWrite && (MEM_WB_RD != 5'b0) && (MEM_WB_RD == ID_EX_RS))
            ForwardA = 2'b01;
        else
            ForwardA = 2'b00;

        if (EX_MEM_RegWrite && (EX_MEM_RD != 5'b0) && (EX_MEM_RD == ID_EX_RT))
            ForwardB = 2'b10;
        else if (MEM_WB_RegWrite && (MEM_WB_RD != 5'b0) && (MEM_WB_RD == ID_EX_RT))
            ForwardB = 2'b01;
        else
            ForwardB = 2'b00;
    end

endmodule
