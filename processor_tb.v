`timescale 1ns / 1ps
module processor_tb;
    reg CLK;
    reg RESET;
    processor DUT (
        .CLK(CLK),
        .RESET(RESET),
        .out_R6(out_R6),
        .out_R7(out_R7)
    );
    initial CLK = 0;
    always #5 CLK = ~CLK;
    initial begin
        RESET = 1;
        #20;
        RESET = 0;
    end
    
    wire [31:0] reg_R1 = DUT.RF.regs[1];  // registers
    wire [31:0] reg_R3 = DUT.RF.regs[3];
    wire [31:0] reg_R5 = DUT.RF.regs[5];
    wire [31:0] reg_R6 = DUT.RF.regs[6];
    wire [31:0] reg_R7 = DUT.RF.regs[7];
    wire [1:0] fwd_A = DUT.fw_ForwardA;  // forwarding
    wire [1:0] fwd_B = DUT.fw_ForwardB;
    wire jump_flush = DUT.ID_EX_Jump;
    wire [31:0] exmem_ALU = DUT.EX_MEM_ALUResult;
    wire [7:0] dmem_b0 = DUT.DMEM.DMEM_B0[0]; // data memory (word 0, big endian)
    wire [7:0] dmem_b1 = DUT.DMEM.DMEM_B1[0];
    wire [7:0] dmem_b2 = DUT.DMEM.DMEM_B2[0];
    wire [7:0] dmem_b3 = DUT.DMEM.DMEM_B3[0];
    reg [31:0] cyc;
    wire [31:0] out_R6;
wire [31:0] out_R7;
    always @(posedge CLK or posedge RESET) begin
        if (RESET) cyc <= 0;
        else cyc <= cyc + 1;
    end

    initial begin
        #300;
        $display("\nFinal values:");
        $display("R1 = %h", reg_R1);
        $display("R3 = %h", reg_R3);
        $display("R5 = %h", reg_R5);
        $display("R6 = %h", reg_R6);
        $display("R7 = %h", reg_R7);
        $display("\nData memory [0]: %h%h%h%h", dmem_b0, dmem_b1, dmem_b2, dmem_b3);

        $finish;
    end
endmodule