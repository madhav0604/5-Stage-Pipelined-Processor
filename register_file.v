module register_file (
    input  wire        CLK,
    input  wire        RESET,
    input  wire [4:0]  ReadReg1,
    input  wire [4:0]  ReadReg2,
    output reg  [31:0] ReadData1,
    output reg  [31:0] ReadData2,
    input  wire [4:0]  WriteReg,
    input  wire [31:0] WriteData,
    input  wire        RegWrite
);

    reg [31:0] regs [0:31];

    always @(posedge CLK) begin
        if (RESET) begin
            regs[0]  <= 32'b0; regs[1]  <= 32'b0;
            regs[2]  <= 32'b0; regs[3]  <= 32'b0;
            regs[4]  <= 32'b0; regs[5]  <= 32'b0;
            regs[6]  <= 32'b0; regs[7]  <= 32'b0;
            regs[8]  <= 32'b0; regs[9]  <= 32'b0;
            regs[10] <= 32'b0; regs[11] <= 32'b0;
            regs[12] <= 32'b0; regs[13] <= 32'b0;
            regs[14] <= 32'b0; regs[15] <= 32'b0;
            regs[16] <= 32'b0; regs[17] <= 32'b0;
            regs[18] <= 32'b0; regs[19] <= 32'b0;
            regs[20] <= 32'b0; regs[21] <= 32'b0;
            regs[22] <= 32'b0; regs[23] <= 32'b0;
            regs[24] <= 32'b0; regs[25] <= 32'b0;
            regs[26] <= 32'b0; regs[27] <= 32'b0;
            regs[28] <= 32'b0; regs[29] <= 32'b0;
            regs[30] <= 32'b0; regs[31] <= 32'b0;
        end else begin
            if (RegWrite && (WriteReg != 5'b00000))  
                regs[WriteReg] <= WriteData;
        end
    end

    always @(negedge CLK) begin
        if (RESET) begin
            ReadData1 <= 32'b0;
            ReadData2 <= 32'b0;
        end else begin
            ReadData1 <= (ReadReg1 == 5'b0) ? 32'b0 : regs[ReadReg1];
            ReadData2 <= (ReadReg2 == 5'b0) ? 32'b0 : regs[ReadReg2];
        end
    end
endmodule