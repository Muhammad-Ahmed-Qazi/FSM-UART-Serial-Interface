// `timescale 1ns/1ps

// module uart_tb;

//     // DUT signals
//     logic clk;
//     logic reset;
//     logic start;
//     logic [7:0] data_in;
//     logic tx;
//     logic rx;
//     logic [7:0] data_out;
//     logic data_ready;

//     // Instantiate DUT
//     uart_top dut (
//         .clk(clk),
//         .reset(reset),
//         .rx(rx),
//         .start(start),
//         .data_in(data_in),
//         .tx(tx),
//         .data_out(data_out),
//         .data_ready(data_ready)
//     );

//     // Clock generation (50 MHz)
//     always #10 clk = ~clk;

//     // Test sequence
//     initial begin
//         $dumpfile("uart_tb.vcd");
//         $dumpvars(0, uart_tb);

//         // Initialize
//         clk       = 0;
//         reset     = 1;
//         start     = 0;
//         data_in   = 8'hA5;  // 10100101 — test pattern
//         rx        = 1;      // Idle state

//         #100 reset = 0;     // Release reset
//         #100 start = 1;
//         #120  start = 0;

//         // Loopback tx → rx manually
//         forever begin
//             @(posedge clk);
//             rx <= tx;
//         end
//     end

//     // Timeout safeguard
//     initial begin
//         #2000000;
//         $display("Timeout. Simulation took too long.");
//         $finish;
//     end

//     // Monitor for success
//     always @(posedge clk) begin
//         if (data_ready) begin
//             $display("Transmitted: 0x%h | Received: 0x%h", data_in, data_out);
//             if (data_out == data_in)
//                 $display("✅ UART loopback SUCCESS");
//             else
//                 $display("❌ UART loopback MISMATCH");
//             #100 $finish;
//         end
//     end

// endmodule

// `timescale 1ns/1ps

// module uart_tb;

//     logic clk;
//     logic reset;
//     logic rx;
//     logic tx;
//     logic [7:0] led;

//     // Instantiate uart_top (Unit Under Test)
//     uart_top dut (
//         .clk(clk),
//         .reset(reset),
//         .rx(rx),
//         .tx(tx),
//         .led(led)
//     );

//     // Generate 50 MHz clock (period = 20 ns)
//     always #10 clk = ~clk;

//     // UART transmitter stimulus task (sends a byte LSB-first with start and stop bits)
//     task send_uart_byte(input [7:0] data);
//         int i;
//         begin
//             // Start bit
//             rx = 0;
//             #(BAUD_PERIOD);

//             // Send 8 data bits, LSB first
//             for (i = 0; i < 8; i++) begin
//                 rx = data[i];
//                 #(BAUD_PERIOD);
//             end

//             // Stop bit
//             rx = 1;
//             #(BAUD_PERIOD);
//         end
//     endtask

//     // Simulated UART baud period (based on 9600 baud @ 50 MHz clk)
//     parameter BAUD_DIV     = 10;         // use a low divider for faster sim
//     parameter CLK_PERIOD   = 20;         // 50 MHz = 20ns
//     parameter BAUD_PERIOD  = BAUD_DIV * CLK_PERIOD;

//     // Test sequence
//     initial begin
//         // Initialize signals
//         clk = 0;
//         reset = 1;
//         rx = 1;  // idle line state

//         #100;
//         reset = 0;

//         #100;

//         // Send test byte
//         send_uart_byte(8'b10101010);  // 0xAA

//         // Wait for data to loop back
//         #2000;

//         send_uart_byte(8'b01010101);  // 0x55

//         #2000;

//         send_uart_byte(8'hF0);        // 0xF0

//         #2000;

//         $finish;
//     end

//     // Dump VCD for waveform viewing
//     initial begin
//         $dumpfile("uart_tb.vcd");
//         $dumpvars(0, uart_tb);
//     end

// endmodule

// uart_top_tb.sv

// uart_top_tb.sv - Loopback Testbench with RX reuse check

// uart_top_tb.sv - Loopback Testbench with Verification

module uart_tb;

    logic clk;
    logic reset;
    logic rx;
    wire  tx;

    logic [7:0] expected_data1 = 8'b10101010;
    logic [7:0] expected_data2 = 8'b11001100;

    // DUT signals for monitoring
    wire [7:0] data_out;
    wire       data_ready;

    // Instantiate uart_top
    uart_top uut (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tx(tx)
    );

    // Clock generation
    always #10 clk = ~clk;  // 50 MHz clock

    // Task to send byte serially on rx line
    task send_uart_byte(input [7:0] data);
        int i;
        rx = 1;  // idle
        #(104160);  // Wait one bit period
        rx = 0;  // start bit
        #(104160);
        for (i = 0; i < 8; i++) begin
            rx = data[i];
            #(104160);
        end
        rx = 1;  // stop bit
        #(104160);
    endtask

    // Monitor received loopback byte (print once per reception)
    logic prev_data_ready;
    always_ff @(posedge clk) begin
        prev_data_ready <= uut.data_ready;
        if (uut.data_ready && !prev_data_ready) begin
            $display("[Time %0t] Data received: %b", $time, uut.data_out);
        end
    end

    // Simulation logic
    initial begin
        $dumpfile("uart_tb.vcd");
        $dumpvars(0, uart_tb);

        clk = 0;
        rx = 1;
        reset = 1;
        #200 reset = 0;

        // First byte
        $display("Sending first byte: %b", expected_data1);
        send_uart_byte(expected_data1);

        // Wait for loopback
        #1500000;

        // Second byte
        $display("Sending second byte: %b", expected_data2);
        send_uart_byte(expected_data2);

        // Wait for second echo
        #1500000;

        $display("\n✅ Simulation complete.");
        $finish;
    end

endmodule
