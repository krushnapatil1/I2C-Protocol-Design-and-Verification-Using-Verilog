# I2C-Protocol-Design-and-Verification-Using-Verilog
# I2C Protocol Design and Verification using Verilog

## 📌 Project Overview

This project implements the **Inter-Integrated Circuit (I2C) communication protocol** using Verilog HDL. It focuses on designing and verifying communication between an I2C Master and an I2C Slave.

The master initiates communication, transmits the slave address and data, and checks the acknowledgment (ACK) response from the slave. The design is verified using a testbench to simulate a successful data transfer.

## 🎯 Objectives

- Understand the working principle of the I2C communication protocol.
- Design an I2C Master using Verilog HDL.
- Design an I2C Slave using Verilog HDL.
- Implement serial data communication using SDA and SCL lines.
- Verify master-slave communication using a testbench.
- Observe and analyze simulation waveforms.

## ⚙️ Features

- I2C Master and Slave design.
- Serial communication using SDA (Serial Data) and SCL (Serial Clock).
- 7-bit slave addressing.
- 8-bit data transmission.
- Start and Stop condition generation.
- ACK response handling.
- Combined testbench for master-slave verification.
- Simulation of a successful data transfer.

## 🧠 I2C Protocol Basics

I2C is a synchronous, serial communication protocol that uses two signal lines:

| Signal | Description |
|---|---|
| SDA | Serial Data Line |
| SCL | Serial Clock Line |

### Basic Communication Sequence

1. The master generates a START condition.
2. The master transmits the 7-bit slave address and the R/W bit.
3. The addressed slave responds with an acknowledgment (ACK).
4. The master transmits 8-bit data.
5. The slave acknowledges the received data.
6. The master generates a STOP condition to end communication.

## 🏗️ Project Modules

### 1. I2C Master
- Initiates communication.
- Generates the START and STOP conditions.
- Sends the slave address and data.
- Handles acknowledgment checking.
- Provides status signals such as `busy`, `done`, and `ack_error`.

### 2. I2C Slave
- Detects the master's START condition.
- Receives and checks the slave address.
- Receives transmitted data.
- Generates ACK when appropriate.
- Supports communication with the master.

### 3. Combined Testbench
- Generates the clock and reset signals.
- Starts an I2C transaction.
- Connects the master and slave through the SDA and SCL lines.
- Tests a successful data transfer.
- Monitors transaction status and simulation waveforms.

## 🛠️ Tools and Technologies

- **HDL:** Verilog
- **Simulation:** Icarus Verilog
- **Waveform Viewer:** GTKWave
- **Code Editor:** Visual Studio Code
- **Version Control:** Git and GitHub

## ▶️ How to Run the Simulation

### Step 1: Clone the Repository

```bash
git clone <YOUR_REPOSITORY_URL>
cd <YOUR_PROJECT_FOLDER>
```

Replace the placeholders with your actual GitHub repository URL and folder name.

### Step 2: Compile the Design

Run the following command from the project directory:

```bash
iverilog -g2012 -o i2c_sim <MASTER_FILE> <SLAVE_FILE> <TESTBENCH_FILE>
```

Replace the filenames with the actual names of your Verilog source files.

### Step 3: Run the Simulation

```bash
vvp i2c_sim
```

### Step 4: View the Waveforms

If the testbench generates a VCD waveform file, open it using:

```bash
gtkwave <WAVEFORM_FILE>.vcd
```

Inspect SDA, SCL, reset, start, busy, done, and acknowledgment signals as applicable to your implementation.

## 🧪 Verification

The combined testbench is intended to verify:

- Reset operation.
- START and STOP conditions.
- Slave address transmission.
- ACK response.
- 8-bit data transmission.
- Successful completion of a transaction.
- Correct status-signal behavior.

**Expected result:** A successful transaction should show the master transmitting the address and data, the slave acknowledging the appropriate phases, and the transaction completing without an acknowledgment error.

Actual results should be confirmed using the simulation output and waveforms.

## 📚 Learning Outcomes

Through this project, I practiced:

- RTL design using Verilog HDL.
- Finite State Machine (FSM) implementation.
- Serial communication protocols.
- Master-slave communication.
- Testbench development and functional verification.
- Simulation debugging and waveform analysis.

## 🚀 Future Improvements

- Support read transactions from slave to master.
- Add repeated START condition support.
- Support configurable clock frequency.
- Test invalid addresses and missing ACK responses.
- Extend verification to cover additional protocol corner cases.

## 👨‍💻 Author

**Krushna Patil**

Aspiring Design Verification Engineer | VLSI Enthusiast

GitHub: [krushnapatil1](https://github.com/krushnapatil1)

---

*This project is developed for learning and demonstrating I2C protocol design and functional verification using Verilog HDL.*
