# 5-Stage Pipelined Processor

A 5-stage pipelined processor built in Verilog as part of my Computer Architecture course. It supports a small custom ISA and handles data hazards through forwarding without any stalls.

## What it does

The processor implements the classic IF, ID, EX, MEM, WB pipeline and supports 6 instructions:

- **LUI** - loads a 16-bit immediate into the upper half of a register
- **ORI** - bitwise OR of a register with a 16-bit immediate
- **SLT** - sets a register to 1 if one value is less than another, else 0
- **LSR** - left shifts a register by the value in another register
- **RSR** - right shifts a register by the value in another register
- **J** - unconditional jump

## Handling hazards

The main challenge in pipelined processors is that instructions depend on results from instructions that haven't finished yet. This design solves that using a forwarding unit, which routes results from later pipeline stages back to the ALU inputs, so no stalls are needed.

Jump instructions are handled by flushing the instruction immediately after the jump, resulting in a 1-cycle penalty.

## Project structure

- `instruction_fetch.v` - PC logic and instruction ROM
- `register_file.v` - 32 registers, write on posedge, read on negedge
- `alu.v` - handles all arithmetic and shift operations
- `alu_control.v` - decodes ALUOp + opcode/funct into ALU operation
- `control_unit.v` - generates control signals from opcode
- `forwarding_unit.v` - detects RAW hazards and selects the right data source
- `data_memory.v` - byte-addressable, big-endian, 256 bytes
- `processor.v` - ties everything together with all four pipeline registers
- `processor_tb.v` - testbench with clock, reset, and register/memory probes

## How to run

The project was built and simulated in Xilinx Vivado

## Results

The test program runs 8 instructions in 13 cycles (CPI = 1.625). The extra cycles come from the 4-stage pipeline fill and 1 jump flush. Forwarding kicks in correctly for the RAW hazards between I1/I2 and I3, and between I3 and I4.

The design was synthesised on an Artix-7 FPGA (xc7a200tfbg676-2) and used 1052 Slice LUTs and 1302 Slice Registers.
