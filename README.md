# MIPS32 Pipelined Processor

A 32-bit MIPS processor implemented in **VHDL** and organized as a five-stage pipeline. The project includes instruction fetch, instruction decode, execution, memory access, and write-back logic, along with a Vivado test environment for observing internal processor values.

The design targets an Artix-7 FPGA device and includes a board-oriented interface for displaying selected signals on switches, LEDs, and a seven-segment display.

## Table of Contents

- [Overview](#overview)
- [Processor Pipeline](#processor-pipeline)
- [Instruction Set](#instruction-set)
- [Main Components](#main-components)
- [Hardware Interface](#hardware-interface)
- [Technology and Target](#technology-and-target)
- [Getting Started](#getting-started)
- [Simulation and Testing](#simulation-and-testing)
- [Project Structure](#project-structure)
- [Project Notes](#project-notes)
- [Learning Objectives](#learning-objectives)

## Overview

This project implements a pipelined MIPS32 processor using modular VHDL components. Pipeline registers carry instructions, data, and control signals between stages so that multiple instructions can be processed at different stages of execution.

The top-level test environment connects the processor components and exposes selected internal values through the FPGA interface. Switches choose which value is shown on the seven-segment display, while LEDs show processor control signals.

## Processor Pipeline

The design is divided into five stages:

| Stage | Name | Responsibility |
|---|---|---|
| IF | Instruction Fetch | Reads the current instruction and updates the program counter. |
| ID | Instruction Decode | Decodes instruction fields, reads register values, and prepares immediate data. |
| EX | Execute | Performs ALU operations and calculates branch addresses. |
| MEM | Memory Access | Reads from or writes to the data memory. |
| WB | Write Back | Selects the value written back to the register file. |

A simplified view of the data flow is:

```mermaid
flowchart LR
    IF["IF: Instruction Fetch"] --> ID["ID: Decode"]
    ID --> EX["EX: Execute"]
    EX --> MEM["MEM: Memory Access"]
    MEM --> WB["WB: Write Back"]
    WB --> ID
```

Pipeline registers hold the values and control signals passed between stages. The design also includes control logic for branches and jumps.

## Instruction Set

The control unit contains decode cases for the following instruction groups:

| Category | Instructions |
|---|---|
| R-type arithmetic and logic | `ADD`, `SUB`, `SLL`, `SRL`, `AND`, `OR`, `XOR`, `SLT` |
| Immediate operations | `ADDI`, `ANDI`, `ORI` |
| Memory operations | `LW`, `SW` |
| Branches | `BEQ`, `BNE` |
| Jump | `J` |

The execute unit contains the corresponding ALU control logic, including addition, subtraction, bitwise operations, shifts, and set-on-less-than.

## Main Components

| File | Responsibility |
|---|---|
| `IFetch.vhd` | Instruction fetch, program counter updates, and branch or jump selection. |
| `ID.vhd` | Register file access and instruction-field extraction. |
| `EX.vhd` | ALU control and execution, zero detection, and branch-address calculation. |
| `MEM.vhd` | Data memory read and write operations. |
| `UC.vhd` | Generates control signals from the instruction opcode. |
| `MPG.vhd` | Conditions a push-button input for use as a control signal. |
| `SSD.vhd` | Multiplexes and drives the seven-segment display. |
| `test_env_pipeline.vhd` | Connects the processor modules and maps internal values to board inputs and outputs. |

## Hardware Interface

The `test_env_pipeline` top-level module exposes these ports:

| Signal | Direction | Purpose |
|---|---|---|
| `sw(15 downto 0)` | Input | Includes the selector used to choose an internal processor value. |
| `bt(1 downto 0)` | Input | Push-button inputs for control and reset. |
| `clk` | Input | FPGA clock. |
| `cat(6 downto 0)` | Output | Seven-segment display segment control. |
| `an(7 downto 0)` | Output | Seven-segment display digit selection. |
| `led(15 downto 0)` | Output | Displays processor control signals. |

The selector `sw(7 downto 5)` chooses which internal 32-bit value is sent to the seven-segment display:

| Selector | Displayed value |
|---|---|
| `000` | Instruction in the IF/ID stage |
| `001` | Program counter value in the IF/ID stage |
| `010` | First register value in the ID/EX stage |
| `011` | Second register value in the ID/EX stage |
| `100` | Extended immediate in the ID/EX stage |
| `101` | ALU result in the EX/MEM stage |
| `110` | Data read from memory in the MEM/WB stage |
| `111` | Write-back value |

The lower LEDs expose register destination, immediate extension, ALU source, branch, jump, memory write, memory-to-register, and register write control signals.

## Technology and Target

- **Hardware description language:** VHDL
- **FPGA design suite:** Xilinx Vivado
- **Vivado project version:** 2022.2
- **Target device:** `xc7a100tcsg324-1`
- **Board constraints referenced by the project:** Nexys A7

## Getting Started

### Prerequisites

- Xilinx Vivado 2022.2 or a compatible Vivado version
- A Nexys A7 board for hardware implementation
- A supported Artix-7 device for synthesis and implementation

### Clone the repository

```bash
git clone https://github.com/stefaniaelena20/MIPS-PIPELINE.git
cd MIPS-PIPELINE
```

### Open the Vivado project

1. Launch Vivado.
2. Select **Open Project**.
3. Open `pipeline.xpr`.
4. Check that the VHDL sources are listed under **Design Sources**.
5. Confirm that the project top module is `test_env_pipeline`.
6. Run **Behavioral Simulation** to inspect the design, or run synthesis and implementation for the target FPGA.

## Simulation and Testing

The Vivado project identifies `test_env_pipeline` as the design top module. The repository includes the processor VHDL modules and the top-level test environment, along with design documentation and diagrams.

For hardware testing, program the FPGA and use the switches and buttons to control the interface. Change `sw(7 downto 5)` to display different internal pipeline values. Use the LEDs to inspect the active control signals.

The repository does not include a separate self-checking VHDL testbench. Simulation results should therefore be inspected through Vivado’s waveform viewer or the configured hardware interface.

## Project Structure

```text
MIPS-PIPELINE/
├── EX.vhd
├── ID.vhd
├── IFetch.vhd
├── MEM.vhd
├── MPG.vhd
├── SSD.vhd
├── UC.vhd
├── test_env_pipeline.vhd
├── pipeline.xpr
├── pipeline.lpr
├── test_env_pipeline.dcp
├── DiagramaPipelineMIPS32.xlsx
├── RegistreMIPS32Pipeline.docx
└── Czebey Stefania_documentatie.docx
```

## Project Notes

- The Vivado project file contains local path references for source and constraint files. If Vivado reports missing files after cloning, add the VHDL sources to the project and provide a valid XDC constraints file for the target board.
- The target part is specified as `xc7a100tcsg324-1`; the project also references a Nexys A7 constraint file.
- The repository includes both VHDL source files and a compiled design checkpoint. The VHDL files are the editable hardware description.
- Instruction support should be verified in simulation, especially when modifying the control unit or ALU logic.

## Learning Objectives

This project demonstrates:

- Designing a processor datapath in VHDL.
- Organizing a processor into pipeline stages.
- Passing data and control signals through pipeline registers.
- Implementing an ALU and register file.
- Decoding MIPS instruction opcodes.
- Handling branch and jump control flow.
- Integrating FPGA inputs and outputs.
- Using Vivado for simulation and FPGA development.

## Author

**Stefania Elena**
