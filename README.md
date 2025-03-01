# MIPS32 Pipeline Processor
A VHDL implementation of a pipelined MIPS32 processor designed for the Nexys A7 FPGA board.

## Overview

This project implements a 5-stage pipelined MIPS32 processor using VHDL. The pipeline architecture improves performance by allowing multiple instructions to be processed simultaneously across different stages. The design includes hazard detection and mitigation through strategic NOOP insertions.

## Architecture

The processor is implemented with the classic 5-stage RISC pipeline:

1. **Instruction Fetch (IF)**: Retrieves instructions from instruction memory
2. **Instruction Decode (ID)**: Decodes instructions and reads register values
3. **Execute (EX)**: Performs ALU operations and calculates branch addresses
4. **Memory Access (MEM)**: Performs memory read/write operations
5. **Write-Back (WB)**: Writes results back to registers

### Pipeline Registers

The pipeline uses four register sets to hold intermediate data between stages:
- **IF/ID**: Holds instruction and PC+4 value
- **ID/EX**: Holds control signals, register values, immediate value, and other instruction-specific data
- **EX/MEM**: Holds ALU results, branch address, and control signals for memory operations
- **MEM/WB**: Holds memory data, ALU results, and write-back control signals

## Supported Instructions

The processor supports a subset of the MIPS instruction set:
- **R-Type Instructions**: ADD, SLT, SLL
- **I-Type Instructions**: ADDI, LW, SW, BEQ
- **J-Type Instructions**: J (Jump)

## Test Program

The current implementation includes a test program that determines whether an array is sorted in ascending order. The program:
1. Loads array starting address and length from memory
2. Iterates through array elements
3. Compares adjacent elements
4. Sets result to 1 (true) if sorted, 0 (false) otherwise

### Memory Configuration

- Address 0: Starting address of the array (0x0000000C in the example)
- Address 4: Length of the array (10 in the example)
- Address 8: Result (1 if sorted, 0 otherwise)
- Address 12+: Array elements (in the example: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

## Implementation Details

### Hardware Components

- **Control Unit (UC)**: Generates control signals based on instruction opcode
- **Register File**: 32 general-purpose registers
- **ALU**: Supports basic arithmetic and logical operations
- **Instruction Memory**: ROM with the program instructions
- **Data Memory**: RAM for program data

### User Interface Components

- **Monopulse Generator (MPG)**: Debounces button inputs
- **Seven-Segment Display (SSD)**: Displays processor state information

## Files Description

- **test_env.vhd**: Top-level entity connecting all components
- **IFetch.vhd**: Instruction fetch stage implementation
- **ID.vhd**: Instruction decode stage implementation
- **EX.vhd**: Execute stage implementation
- **MEM.vhd**: Memory access stage implementation
- **UC.vhd**: Main control unit
- **MPG.vhd**: Monopulse generator for button debouncing
- **SSD.vhd**: Seven-segment display controller
- **NexysA7_test_env.xdc**: Constraint file for Nexys A7 FPGA

## Usage

1. Load the project into Vivado
2. Generate bitstream
3. Program the Nexys A7 FPGA
4. Use buttons to control execution:
   - BTN0: Step through program execution (enable signal)
   - BTN1: Reset processor
5. Use switches SW[7:5] to select display information:
   - 000: Current instruction
   - 001: PC+4 value
   - 010-111: Various pipeline register values

## Hazard Handling

The implementation includes strategic NOOP insertions to avoid data hazards:
- After load instructions to avoid load-use hazards
- After branch instructions to avoid branch hazards
- After jump instructions to ensure proper execution flow

## Future Improvements

- Implementation of data forwarding to reduce pipeline stalls
- Addition of branch prediction to improve performance
- Support for more MIPS instructions
- Implementation of exception handling
