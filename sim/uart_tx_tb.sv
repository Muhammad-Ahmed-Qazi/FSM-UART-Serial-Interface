module uart_tx_tb;

    logic clk;
    logic reset;
    logic start;
    logic [7:0] data_in;
    logic tx;       // output of TX
    logic busy;
    logic done;
    logic tick;

    logic rx;       // input to RX (we'll connect it to tx)
    logic [7:0] data_out;
    logic data_ready;
    logic rx_busy;

    // Baud Generator
    baud_gen #(.BAUD_DIV(10)) baud_inst (
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
        .busy(busy),
        .done(done)
    );

    // UART Receiver
    uart_rx rx_inst (
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .rx(rx),
        .data_out(data_out),
        .data_ready(data_ready),
        .busy(rx_busy)
    );

    // Clock Generation
    always #5 clk = ~clk;  // 100 MHz clock

    // Connect tx → rx line
    assign rx = tx;

    // Test Sequence
    initial begin
        clk     = 0;
        reset   = 1;
        start   = 0;
        data_in = 8'b10101011;  // Example data to send

        #10 reset = 0;

        #50 start = 1;
        #60 start = 0;

        wait (done);
        wait (data_ready);

        $display("Time %0t: RECEIVER GOT DATA: %b", $time, data_out);

        #50 $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, uart_tx_tb);
    end

    initial begin
        #100000 $finish;
    end

endmodule
