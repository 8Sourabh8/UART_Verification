# UART Verification (UVM)

UVM testbench for a UART with a 16-deep transmit FIFO and a programmable baud rate.
The DUT runs in loopback: a byte written on `data_in` goes into the FIFO, the
transmitter sends it serially (start bit, 8 data bits LSB first, stop bit), the
receiver picks it up and puts it on `data_out` with a one-clock `rx_done` pulse.

## Design under test (`rtl/`)

| Block | Job |
|---|---|
| `baud_generator.v` | divides the clock by the 16-bit divisor `{DM, DL}` |
| `uart_fifo.v` | 16 x 8 transmit FIFO; `busy` = FIFO full |
| `uart_cont.v` | reads the FIFO and starts each transmission |
| `transmitter.v` / `receiver.v` | serial TX and RX with oversampling |

Registers are loaded through `reg_load`: `01` = divisor low byte, `10` = divisor high byte, `11` = oversampling value.

## Testbench

```
test ── env ─┬─ source agent (active): sequencer → driver → DUT inputs, monitor → src_ap
             ├─ destination agent (passive): monitor on data_out / rx_done → dst_ap
             └─ scoreboard: analysis FIFOs from both monitors
```

- **Driver** resets the DUT, programs the divisor and oversampling, then writes bytes, waiting while `busy` (FIFO full) is high.
- **Source monitor** captures every byte accepted into the UART.
- **Destination monitor** captures `data_out` in the clock where `rx_done` is high.
- **Scoreboard** checks that every byte comes out unchanged and in order, counts matches and mismatches, and in `check_phase` reports bytes that were sent but never received (or received but never sent). A covergroup tracks the data patterns that were transferred (all zeros, all ones, 0x55, 0xAA, single LSB, single MSB, low and high ranges).

## Tests (`test/uart_test_lib.sv`)

| Test | Stimulus |
|---|---|
| `uart_base_test` | one random byte |
| `uart_random_test` | 20 random bytes back to back (fills the FIFO, exercises `busy`) |
| `uart_corner_test` | 00, FF, 55, AA, 01, 80, then 10 random bytes |
| `uart_long_test` | 64 random bytes (FIFO fills and drains four times) |

Each test waits until the scoreboard has received every byte, with a timeout so a lost byte fails the test instead of hanging it.

## Running

```
cd sim
make run_test      # uart_base_test   (VCS by default; set SIMULATOR = Questa in the Makefile for Questa)
make run_test1     # uart_random_test
make run_test2     # uart_corner_test
make run_test3     # uart_long_test
make regress       # all tests + merged coverage
```

Tools: SystemVerilog, UVM, Synopsys VCS / Siemens QuestaSim.
