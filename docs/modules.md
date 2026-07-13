# Module reference

## uart_tx.sv (`uart_tx`)

Purpose: Serial transmitter FSM that shifts out one 8-bit byte as start, data, and stop bits on `tx`.

### Ports

| Signal | Direction | Width | Description |
| --- | --- | --- | --- |
| `clk` | input | 1 | System clock. |
| `tick` | input | 1 | Baud tick enable from `baud_gen`. |
| `start` | input | 1 | Starts a transmit frame when sampled high in `IDLE`. |
| `data_in` | input | 8 | Payload byte loaded into transmit shift register. |
| `reset` | input | 1 | Active-high reset. |
| `tx` | output | 1 | Serial output line. |
| `busy` | output | 1 | High during active transmit sequence. |
| `done` | output | 1 | Pulsed high in `CLEANUP` after frame completion. |

### FSM

| State | Transition condition | Next state |
| --- | --- | --- |
| `IDLE` | `tick && start` | `START` |
| `IDLE` | `tick && !start` | `IDLE` |
| `START` | `tick` | `SHIFT` |
| `SHIFT` | `tick && (bit_count == 9)` | `CLEANUP` |
| `SHIFT` | `tick && (bit_count != 9)` | `SHIFT` |
| `CLEANUP` | `tick` | `IDLE` |

### Parameters

| Parameter | Default | Meaning |
| --- | --- | --- |
| None | N/A | Module has no parameter declarations. |

## uart_rx.sv (`uart_rx`)

Purpose: Serial receiver FSM that detects a start condition, shifts in 8 bits, and asserts `data_ready`.

### Ports

| Signal | Direction | Width | Description |
| --- | --- | --- | --- |
| `clk` | input | 1 | System clock. |
| `reset` | input | 1 | Active-high reset. |
| `tick` | input | 1 | Baud tick enable from `baud_gen`. |
| `rx` | input | 1 | Serial input line. |
| `data_out` | output | 8 | Last received byte from `shift_reg`. |
| `data_ready` | output | 1 | High in `CLEANUP` when `data_out` is updated. |
| `busy` | output | 1 | High while receiver is in active acquisition. |

### FSM

| State | Transition condition | Next state |
| --- | --- | --- |
| `IDLE` | `tick && (rx == 0)` | `RECEIVING` |
| `IDLE` | `tick && (rx != 0)` | `IDLE` |
| `RECEIVING` | `tick && (sample_count == 0) && (bit_count == 7)` | `CLEANUP` |
| `RECEIVING` | `tick && (sample_count == 0) && (bit_count != 7)` | `RECEIVING` |
| `RECEIVING` | `tick && (sample_count != 0)` | `RECEIVING` |
| `CLEANUP` | `tick` | `IDLE` |

### Parameters

| Parameter | Default | Meaning |
| --- | --- | --- |
| None | N/A | Module has no parameter declarations. |

## baud_gen.sv (`baud_gen`)

Purpose: Clock divider that raises `tick` for one `clk` cycle every `BAUD_DIV` cycles.

### Ports

| Signal | Direction | Width | Description |
| --- | --- | --- | --- |
| `clk` | input | 1 | System clock. |
| `reset` | input | 1 | Active-high reset (asynchronous in sensitivity list). |
| `tick` | output | 1 | One-cycle pulse when internal `count` reaches `BAUD_DIV - 1`. |

### FSM

Not applicable. This module uses a counter, not an explicit state machine.

### Parameters

| Parameter | Default | Meaning |
| --- | --- | --- |
| `BAUD_DIV` | `5208` | Number of `clk` cycles per generated baud tick. |

## uart_top.sv (`uart_top`)

Purpose: Top-level integration that connects `baud_gen`, `uart_rx`, and `uart_tx` into a loopback datapath.

### Ports

| Signal | Direction | Width | Description |
| --- | --- | --- | --- |
| `clk` | input | 1 | Board/system clock input. |
| `raw_reset` | input | 1 | External reset input; inverted internally. |
| `rx` | input | 1 | UART serial input. |
| `tx` | output | 1 | UART serial output. |

### FSM

Not applicable. `uart_top` has control logic for `start` generation but no enum-based FSM.

### Parameters

| Parameter | Default | Meaning |
| --- | --- | --- |
| None | N/A | Module has no parameter declarations. |
