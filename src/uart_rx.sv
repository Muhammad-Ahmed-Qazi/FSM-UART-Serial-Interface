module uart_rx (
    input  logic       clk,
    input  logic       reset,
    input  logic       tick,
    input  logic       rx,

    output logic [7:0] data_out,
    output logic       data_ready,
    output logic       busy
);

typedef enum logic [1:0] {
    IDLE,
    RECEIVING,
    CLEANUP
} state_t;
state_t state, next_state;

logic [7:0] shift_reg;  // Shift register for 10 bits (1 start, 8 data, 1 stop)
logic [3:0] bit_count;  // Bit count register
logic [3:0] sample_count; // Sample counter for detecting ticks

always_ff @(posedge clk) begin
    if (reset) begin
        state      <= IDLE;
        next_state <= IDLE;
        data_out   <= 8'b0;
        data_ready <= 0;
        busy       <= 0;
        bit_count    <= 0;
        shift_reg  <= 8'b0;
    end else begin
        state <= next_state;

        if (tick) begin
            case (state)
                IDLE: begin
                    data_ready <= 0;
                    busy       <= 0;

                    if (rx == 0) begin  // Detected falling edge of start bit
                        busy         <= 1;
                        bit_count    <= 0;
                        sample_count <= 0;
                        next_state   <= RECEIVING;
                    end else begin
                        next_state <= IDLE;
                    end
                end

                RECEIVING: begin
                    if (tick) begin
                        sample_count <= sample_count + 1;

                        if (sample_count == 0) begin
                            // Center of bit reached, time to sample
                            shift_reg <= {rx, shift_reg[7:1]};  // LSB first
                            bit_count  <= bit_count + 1;
                            sample_count <= 0;

                            if (bit_count == 7) begin  // All 8 bits received
                                next_state <= CLEANUP;
                            end else begin
                                next_state <= RECEIVING;
                            end
                        end else begin
                            next_state <= RECEIVING;  // keep waiting
                        end
                    end
                end

                CLEANUP: begin
                    // data_out <= {
                    //     shift_reg[0], shift_reg[1], shift_reg[2], shift_reg[3],
                    //     shift_reg[4], shift_reg[5], shift_reg[6], shift_reg[7]
                    // };
                    data_out <= shift_reg;
                    data_ready <= 1;
                    next_state <= IDLE;
                end
            endcase
        end
    end
end


endmodule