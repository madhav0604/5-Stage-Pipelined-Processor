// 256-byte data memory (64 words), big-endian.
// Split into 4 byte-lane arrays so synthesis infers byte-enable BRAM cleanly.

module data_memory (
    input  wire        CLK,
    input  wire        RESET,
    input  wire [31:0] Address,
    input  wire [31:0] WriteData,
    input  wire        MemWrite,
    input  wire        MemRead,
    output reg  [31:0] ReadData
);

    reg [7:0] DMEM_B0 [0:63]; 
    reg [7:0] DMEM_B1 [0:63];
    reg [7:0] DMEM_B2 [0:63];
    reg [7:0] DMEM_B3 [0:63];

    wire [5:0] word_idx = Address[7:2];

    always @(posedge CLK) begin
        if (RESET) begin
            // Clear first 8 words explicitly; BRAM initialises the rest to 0 by default
            DMEM_B0[0] <= 8'b0; DMEM_B1[0] <= 8'b0; DMEM_B2[0] <= 8'b0; DMEM_B3[0] <= 8'b0;
            DMEM_B0[1] <= 8'b0; DMEM_B1[1] <= 8'b0; DMEM_B2[1] <= 8'b0; DMEM_B3[1] <= 8'b0;
            DMEM_B0[2] <= 8'b0; DMEM_B1[2] <= 8'b0; DMEM_B2[2] <= 8'b0; DMEM_B3[2] <= 8'b0;
            DMEM_B0[3] <= 8'b0; DMEM_B1[3] <= 8'b0; DMEM_B2[3] <= 8'b0; DMEM_B3[3] <= 8'b0;
            DMEM_B0[4] <= 8'b0; DMEM_B1[4] <= 8'b0; DMEM_B2[4] <= 8'b0; DMEM_B3[4] <= 8'b0;
            DMEM_B0[5] <= 8'b0; DMEM_B1[5] <= 8'b0; DMEM_B2[5] <= 8'b0; DMEM_B3[5] <= 8'b0;
            DMEM_B0[6] <= 8'b0; DMEM_B1[6] <= 8'b0; DMEM_B2[6] <= 8'b0; DMEM_B3[6] <= 8'b0;
            DMEM_B0[7] <= 8'b0; DMEM_B1[7] <= 8'b0; DMEM_B2[7] <= 8'b0; DMEM_B3[7] <= 8'b0;
        end else if (MemWrite) begin
            DMEM_B0[word_idx] <= WriteData[31:24];
            DMEM_B1[word_idx] <= WriteData[23:16];
            DMEM_B2[word_idx] <= WriteData[15:8];
            DMEM_B3[word_idx] <= WriteData[7:0];
        end
    end

    always @(posedge CLK) begin
        if (RESET)
            ReadData <= 32'b0;
        else if (MemRead)
            ReadData <= {DMEM_B0[word_idx], DMEM_B1[word_idx],
                         DMEM_B2[word_idx], DMEM_B3[word_idx]};
        else
            ReadData <= 32'b0;
    end

endmodule
