module instruction_fetch (
    input  wire        CLK,
    input  wire        RESET,
    input  wire        stall,
    input  wire        jump,
    input  wire [31:0] jump_target,
    output reg  [31:0] IF_ID_PC,
    output reg  [31:0] IF_ID_IR
);
    reg [31:0] PC;
    wire [5:0] word_addr = PC[7:2];
    function [31:0] rom_lookup;
        input [5:0] addr;
        case (addr)
            6'd0: rom_lookup = {6'b110010, 5'd2,  5'd8,  5'd1, 5'b00000, 6'b000000};
            6'd1: rom_lookup = {6'b110010, 5'd4,  5'd9,  5'd3, 5'b00000, 6'b000000};
            6'd2: rom_lookup = {6'b000000, 5'd1,  5'd3,  5'd5, 5'b00000, 6'b101010};
            6'd3: rom_lookup = {6'b001101, 5'd5,  5'd6,  16'd200};
            6'd4: rom_lookup = {6'b111011, 5'd7,  5'd10, 5'd6, 5'b00000, 6'b000000};
            6'd5: rom_lookup = {6'b000010, 26'd7};
            6'd6: rom_lookup = {6'b110010, 5'd7,  5'd8,  5'd7, 5'b00000, 6'b000000};
            6'd7: rom_lookup = {6'b001111, 5'd0,  5'd6,  16'd128};
            default: rom_lookup = 32'b0;
        endcase
    endfunction

    wire [31:0] instr = rom_lookup(word_addr);

    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            PC       <= 32'b0;
            IF_ID_PC <= 32'b0;
            IF_ID_IR <= 32'b0;
        end else if (!stall) begin
            if (jump) begin
                PC       <= jump_target;
                IF_ID_IR <= 32'b0;        // flush
                IF_ID_PC <= PC + 32'd4;
            end else begin
                IF_ID_IR <= instr;
                IF_ID_PC <= PC + 32'd4;
                PC       <= PC + 32'd4;
            end
        end
    end

endmodule
    //  0: LSR R1, R2, R8
    //  1: LSR R3, R4, R9
    //  2: SLT R5, R1, R3
    //  3: ORI R6, R5, 200
    //  4: RSR R6, R7, R10
    //  5: j L1 (addr=7)
    //  6: LSR R7, R7, R8   flushed
    //  7: LUI R6, 128