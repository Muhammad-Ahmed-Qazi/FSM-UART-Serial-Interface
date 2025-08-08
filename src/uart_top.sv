// module uart_top (
//     input  logic        clk,         // 50 MHz DE1-SoC clock
//     input  logic        reset,
//     input  logic        rx,          // Serial input from UART cable
//     input  logic        start,       // Manual trigger to send data
//     input  logic [7:0]  data_in,     // Data to transmit

//     output logic        tx,          // Serial output to UART cable
//     output logic [7:0]  data_out,    // Received data
//     output logic        data_ready   // High when byte received
// );

//     logic tick;
//     logic done, tx_busy, rx_busy;

//     // Baud rate generator
//     baud_gen #(
//         .BAUD_DIV(10)  // Example: 50_000_000 / 9600
//     ) baud_inst (
//         .clk(clk),
//         .reset(reset),
//         .tick(tick)
//     );

//     // UART Transmitter
//     uart_tx tx_inst (
//         .clk(clk),
//         .reset(reset),
//         .tick(tick),
//         .start(start),
//         .data_in(data_in),
//         .tx(tx),
//         .done(done),
//         .busy(tx_busy)
//     );

//     // UART Receiver
//     uart_rx rx_inst (
//         .clk(clk),
//         .reset(reset),
//         .tick(tick),
//         .rx(rx),
//         .data_out(data_out),
//         .data_ready(data_ready),
//         .busy(rx_busy)
//     );

// endmodule

module uart_top (
    input  logic        clk,      // 50 MHz clock from FPGA board
    input  logic        raw_reset,    // Active-high reset
    input  logic        rx,       // Serial data input from laptop
    output logic        tx       // Serial data output to laptop
);

    // Internal signals
    logic        tick;
    logic        reset;
    logic [7:0]  data_out;
    logic        data_ready;
    logic        tx_done;
    logic        tx_busy;
    logic        start;
    logic [7:0]  data_in;

    // Connect received data to transmitter input (loopback)
    assign data_in = data_out;

    // Reset logic: active-high reset
    assign reset = ~raw_reset;

    // Generate 'start' signal when data is ready and TX is not busy
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            start <= 0;
        else if (data_ready && !tx_busy)
            start <= 1;
        else
            start <= 0;
    end

    // BAUD Generator (set for 9600 baud @ 50 MHz system clock)
    baud_gen #(.BAUD_DIV(5208)) baud_inst (
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    // UART Transmitter
    uart_tx tx_inst (
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .start(start),
        .data_in(data_in),
        .tx(tx),
        .done(tx_done),
        .busy(tx_busy)
    );

    // UART Receiver
    uart_rx rx_inst (
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .rx(rx),
        .data_out(data_out),
        .data_ready(data_ready),
        .busy()
    );

endmodule