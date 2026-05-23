module processor (
    input wire CLK,
    input wire RESET,
    output [31:0] out_R6,
    output [31:0] out_R7
);

// Pipeline registers IF/ID
reg [31:0] IF_ID_PC;
reg [31:0] IF_ID_IR;

// Pipeline registers ID/EX
reg [31:0] ID_EX_PC;
reg [31:0] ID_EX_ReadData1;
reg [31:0] ID_EX_ReadData2;
reg [31:0] ID_EX_SignImm;
reg [4:0]  ID_EX_RS;
reg [4:0]  ID_EX_RT;
reg [4:0]  ID_EX_RD;
reg [5:0]  ID_EX_Funct;
reg [5:0]  ID_EX_Opcode;
reg [31:0] ID_EX_JumpTarget;
reg        ID_EX_RegDst;
reg        ID_EX_ALUSrc;
reg        ID_EX_MemToReg;
reg        ID_EX_RegWrite;
reg        ID_EX_MemRead;
reg        ID_EX_MemWrite;
reg        ID_EX_Jump;
reg [1:0]  ID_EX_ALUOp;

// Pipeline registers EX/MEM
reg [31:0] EX_MEM_ALUResult;
reg [31:0] EX_MEM_WriteData;
reg [4:0]  EX_MEM_RD;
reg        EX_MEM_MemToReg;
reg        EX_MEM_RegWrite;
reg        EX_MEM_MemRead;
reg        EX_MEM_MemWrite;

// Pipeline registers MEM/WB
reg [31:0] MEM_WB_ReadData;
reg [31:0] MEM_WB_ALUResult;
reg [4:0]  MEM_WB_RD;
reg        MEM_WB_MemToReg;
reg        MEM_WB_RegWrite;

// IF stage outputs
wire [31:0] if_PC_out;
wire [31:0] if_IR_out;

// ID instruction fields decoded from IF/ID register
wire [5:0]  id_Opcode     = IF_ID_IR[31:26];
wire [4:0]  id_RS         = IF_ID_IR[25:21];
wire [4:0]  id_RT         = IF_ID_IR[20:16];
wire [4:0]  id_RD         = IF_ID_IR[15:11];
wire [15:0] id_Imm        = IF_ID_IR[15:0];
wire [25:0] id_JAddr      = IF_ID_IR[25:0];
wire [5:0]  id_Funct      = IF_ID_IR[5:0];
wire [31:0] id_SignImm    = {{16{id_Imm[15]}}, id_Imm};
wire [31:0] id_JumpTarget = {IF_ID_PC[31:28], id_JAddr, 2'b00};

wire [31:0] id_ReadData1;
wire [31:0] id_ReadData2;

wire ctrl_RegDst, ctrl_ALUSrc, ctrl_MemToReg;
wire ctrl_RegWrite, ctrl_MemRead, ctrl_MemWrite;
wire ctrl_Branch, ctrl_Jump;
wire [1:0] ctrl_ALUOp;

wire [2:0] ex_ALUControl;

wire [1:0] fw_ForwardA;
wire [1:0] fw_ForwardB;

// EX stage
wire [4:0]  ex_WriteReg;    // rd or rt depending on RegDst
wire [31:0] ex_ALUIn1;      // forwarded rs
wire [31:0] ex_ALUIn2_reg;  // forwarded rt (before ALUSrc mux)
wire [31:0] ex_ALUIn2;      // final ALU B input
wire [31:0] ex_ALUResult;
wire        ex_Zero;

wire [31:0] wb_WriteData;   // WB mux output (ALU result or mem read)
wire [31:0] mem_ReadData;

// Sub-module instantiations
instruction_fetch IF_STAGE (
    .CLK         (CLK),
    .RESET       (RESET),
    .stall       (1'b0),
    .jump        (ID_EX_Jump),
    .jump_target (ID_EX_JumpTarget),
    .IF_ID_PC    (if_PC_out),
    .IF_ID_IR    (if_IR_out)
);

register_file RF (
    .CLK       (CLK),
    .RESET     (RESET),
    .ReadReg1  (id_RS),
    .ReadReg2  (id_RT),
    .ReadData1 (id_ReadData1),
    .ReadData2 (id_ReadData2),
    .WriteReg  (MEM_WB_RD),
    .WriteData (wb_WriteData),
    .RegWrite  (MEM_WB_RegWrite)
);

control_unit CTRL (
    .Opcode   (id_Opcode),
    .RegDst   (ctrl_RegDst),
    .ALUSrc   (ctrl_ALUSrc),
    .MemToReg (ctrl_MemToReg),
    .RegWrite (ctrl_RegWrite),
    .MemRead  (ctrl_MemRead),
    .MemWrite (ctrl_MemWrite),
    .Branch   (ctrl_Branch),
    .Jump     (ctrl_Jump),
    .ALUOp    (ctrl_ALUOp)
);

alu_control ALU_CTRL (
    .ALUOp      (ID_EX_ALUOp),
    .Funct      (ID_EX_Funct),
    .Opcode     (ID_EX_Opcode),
    .ALUControl (ex_ALUControl)
);

forwarding_unit FWD (
    .ID_EX_RS        (ID_EX_RS),
    .ID_EX_RT        (ID_EX_RT),
    .EX_MEM_RD       (EX_MEM_RD),
    .EX_MEM_RegWrite (EX_MEM_RegWrite),
    .MEM_WB_RD       (MEM_WB_RD),
    .MEM_WB_RegWrite (MEM_WB_RegWrite),
    .ForwardA        (fw_ForwardA),
    .ForwardB        (fw_ForwardB)
);

alu ALU (
    .A          (ex_ALUIn1),
    .B          (ex_ALUIn2),
    .ALUControl (ex_ALUControl),
    .ALUResult  (ex_ALUResult),
    .Zero       (ex_Zero)
);

data_memory DMEM (
    .CLK       (CLK),
    .RESET     (RESET),
    .Address   (EX_MEM_ALUResult),
    .WriteData (EX_MEM_WriteData),
    .MemWrite  (EX_MEM_MemWrite),
    .MemRead   (EX_MEM_MemRead),
    .ReadData  (mem_ReadData)
);

// Combinational datapath
assign ex_WriteReg = ID_EX_RegDst ? ID_EX_RD : ID_EX_RT;  // rd for R-type, rt for I-type

// pick most recent value for rs and rt
assign ex_ALUIn1 =
    (fw_ForwardA == 2'b10) ? EX_MEM_ALUResult :
    (fw_ForwardA == 2'b01) ? wb_WriteData      :
                             ID_EX_ReadData1;

assign ex_ALUIn2_reg =
    (fw_ForwardB == 2'b10) ? EX_MEM_ALUResult :
    (fw_ForwardB == 2'b01) ? wb_WriteData      :
                             ID_EX_ReadData2;

assign ex_ALUIn2 = ID_EX_ALUSrc ? ID_EX_SignImm : ex_ALUIn2_reg;  // immediate or register

assign wb_WriteData = MEM_WB_MemToReg ? MEM_WB_ReadData : MEM_WB_ALUResult;  // load or ALU result

// Pipeline register updates
always @(posedge CLK or posedge RESET) begin
    if (RESET) begin
        IF_ID_PC         <= 32'b0;
        IF_ID_IR         <= 32'b0;
        ID_EX_PC         <= 32'b0;
        ID_EX_ReadData1  <= 32'b0;
        ID_EX_ReadData2  <= 32'b0;
        ID_EX_SignImm    <= 32'b0;
        ID_EX_RS         <= 5'b0;
        ID_EX_RT         <= 5'b0;
        ID_EX_RD         <= 5'b0;
        ID_EX_Funct      <= 6'b0;
        ID_EX_Opcode     <= 6'b0;
        ID_EX_JumpTarget <= 32'b0;
        ID_EX_RegDst     <= 1'b0;
        ID_EX_ALUSrc     <= 1'b0;
        ID_EX_MemToReg   <= 1'b0;
        ID_EX_RegWrite   <= 1'b0;
        ID_EX_MemRead    <= 1'b0;
        ID_EX_MemWrite   <= 1'b0;
        ID_EX_Jump       <= 1'b0;
        ID_EX_ALUOp      <= 2'b0;
        EX_MEM_ALUResult <= 32'b0;
        EX_MEM_WriteData <= 32'b0;
        EX_MEM_RD        <= 5'b0;
        EX_MEM_MemToReg  <= 1'b0;
        EX_MEM_RegWrite  <= 1'b0;
        EX_MEM_MemRead   <= 1'b0;
        EX_MEM_MemWrite  <= 1'b0;
        MEM_WB_ReadData  <= 32'b0;
        MEM_WB_ALUResult <= 32'b0;
        MEM_WB_RD        <= 5'b0;
        MEM_WB_MemToReg  <= 1'b0;
        MEM_WB_RegWrite  <= 1'b0;

    end else begin

        // IF/ID flush to NOP if a jump is in EX
        IF_ID_PC <= if_PC_out;
        IF_ID_IR <= ID_EX_Jump ? 32'b0 : if_IR_out;

        // ID/EX data always flows through; control signals flushed on jump
        ID_EX_PC         <= IF_ID_PC;
        ID_EX_ReadData1  <= id_ReadData1;
        ID_EX_ReadData2  <= id_ReadData2;
        ID_EX_SignImm    <= id_SignImm;
        ID_EX_RS         <= id_RS;
        ID_EX_RT         <= id_RT;
        ID_EX_RD         <= id_RD;
        ID_EX_Funct      <= id_Funct;
        ID_EX_Opcode     <= id_Opcode;
        ID_EX_JumpTarget <= id_JumpTarget;

        if (ID_EX_Jump) begin
            // Insert NOP bubble and remove the instruction behind jump
            ID_EX_RegDst   <= 1'b0;
            ID_EX_ALUSrc   <= 1'b0;
            ID_EX_MemToReg <= 1'b0;
            ID_EX_RegWrite <= 1'b0;
            ID_EX_MemRead  <= 1'b0;
            ID_EX_MemWrite <= 1'b0;
            ID_EX_Jump     <= 1'b0;
            ID_EX_ALUOp    <= 2'b0;
        end else begin
            ID_EX_RegDst   <= ctrl_RegDst;
            ID_EX_ALUSrc   <= ctrl_ALUSrc;
            ID_EX_MemToReg <= ctrl_MemToReg;
            ID_EX_RegWrite <= ctrl_RegWrite;
            ID_EX_MemRead  <= ctrl_MemRead;
            ID_EX_MemWrite <= ctrl_MemWrite;
            ID_EX_Jump     <= ctrl_Jump;
            ID_EX_ALUOp    <= ctrl_ALUOp;
        end

        // EX/MEM
        EX_MEM_ALUResult <= ex_ALUResult;
        EX_MEM_WriteData <= ex_ALUIn2_reg;   // forwarded rt, needed for stores
        EX_MEM_RD        <= ex_WriteReg;
        EX_MEM_MemToReg  <= ID_EX_MemToReg;
        EX_MEM_RegWrite  <= ID_EX_RegWrite;
        EX_MEM_MemRead   <= ID_EX_MemRead;
        EX_MEM_MemWrite  <= ID_EX_MemWrite;

        // MEM/WB
        MEM_WB_ReadData  <= mem_ReadData;
        MEM_WB_ALUResult <= EX_MEM_ALUResult;
        MEM_WB_RD        <= EX_MEM_RD;
        MEM_WB_MemToReg  <= EX_MEM_MemToReg;
        MEM_WB_RegWrite  <= EX_MEM_RegWrite;

    end
end
assign out_R6 = RF.regs[6];
assign out_R7 = RF.regs[7];
endmodule
