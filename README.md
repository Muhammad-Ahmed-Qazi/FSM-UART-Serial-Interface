# ⚡ FPGA UART Serial Interface

A **Verilog-based UART loopback** for the **Terasic Cyclone V GX Starter Kit** FPGA.  
Incoming serial data is echoed back to the sender, providing instant feedback via USB-UART.

---

## 📜 Overview

This project features a **pure hardware UART loopback**—no CPU or firmware required.

> **Use cases:**
> - ✅ UART interface testing
> - ✅ FPGA I/O debugging
> - ✅ Serial protocol learning

**Specs:**
- **Baud rate:** `9600` (8N1)
- **Clock:** `50 MHz`
- **Modules:** `baud_gen`, `uart_rx`, `uart_tx`, `uart_top`

---

## 📂 Directory Layout

```
src/
├── uart_top.v      # Main loopback module
├── uart_tx.v       # Transmitter
├── uart_rx.v       # Receiver
├── baud_gen.v      # Baud generator
sim/
├── uart_tb.sv      # Testbench
├── uart_tx_tb.sv   # TX testbench
optimisation/
├── uart_top.sdc    # Timing constraints
fpga/
└── uart.qsf        # Quartus project file
```

---

## 🔧 Prerequisites

- **Board:** Terasic Cyclone V GX Starter Kit (or 50 MHz FPGA)
- **Software:** Intel Quartus Prime
- **Terminal:** PuTTY, Minicom, Tera Term, etc.
- **Cable:** USB-to-UART

---

## 🚀 Getting Started

1. **Build & Flash**
    - Import RTL files into Quartus
    - Compile and program via USB-Blaster

2. **Connect Terminal**
    ```bash
    minicom -D /dev/ttyUSB0 -b 9600
    ```
    *(Update device path as needed)*

3. **Echo Test**
    - Type in the terminal
    - FPGA echoes input instantly

---

### 🛠 Tweaks

**Baud Rate:**  
Edit `BAUD_DIV` in `baud_gen.v`:

```verilog
BAUD_DIV = CLOCK_FREQ / BAUD_RATE
```

For 9600 baud @ 50 MHz:

```verilog
BAUD_DIV = 50_000_000 / 9600 ≈ 5208
```

**Startup Message:**  
Add an FSM in `uart_tx` to send a banner on reset.

---

📜 License: MIT — free for use, modification, and distribution.
