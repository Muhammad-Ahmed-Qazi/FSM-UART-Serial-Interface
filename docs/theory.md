# UART framing and timing notes

## 8N1 framing in this RTL

The transmit path in `uart_tx` loads:

```text
shift_reg <= {1'b1, data_in, 1'b0}
```

This creates a 10-bit frame:

| Bit order on `tx` | Meaning |
| --- | --- |
| First bit | Start bit (`0`) |
| Next 8 bits | `data_in[0]` to `data_in[7]` (LSB first due to right shift) |
| Last bit | Stop bit (`1`) |

`uart_tx` outputs `shift_reg[0]` on each `tick` and shifts right every symbol interval.

## Mid-bit sampling rationale

UART receivers commonly sample near the center of each bit period to reduce edge timing error and tolerate
small baud mismatch between sender and receiver.

In `uart_rx`, the intent is represented by `sample_count` and the comment `Center of bit reached, time to
sample`. Current sampling condition in RTL is:

```text
if (sample_count == 0) begin
    shift_reg <= {rx, shift_reg[7:1]};
```

With the current logic, `sample_count` is reset to `0` in the same branch where sampling occurs. The design
therefore samples on baud `tick` events according to this condition. Any additional sub-bit timing scheme is
TBD in the present RTL.

## Baud tick generation

`baud_gen` divides `clk` by parameter `BAUD_DIV`:

| Signal | Role |
| --- | --- |
| `count` | Increments each `clk` cycle. |
| `tick` | Pulses high for one cycle when `count == BAUD_DIV - 1`. |

At reset, `count` and `tick` are cleared. In `uart_top`, `baud_gen` is instantiated with
`.BAUD_DIV(5208)`, matching a nominal 9600-bps symbol tick for a 50 MHz clock.

## Loopback path in `uart_top`

The receive-to-transmit data path is direct:

| Path element | RTL signal relationship |
| --- | --- |
| Receive data handoff | `assign data_in = data_out;` |
| Transmit trigger | `start` is pulsed when `data_ready && !tx_busy` |
| Output path | `uart_tx.tx` drives top-level `tx` |

Operationally, bytes arriving on `rx` are decoded by `uart_rx` into `data_out`; when `data_ready` is
asserted and transmitter is idle, `start` initiates retransmission of the same byte through `uart_tx`.
