module uart_tx (
    input  logic       clk,
    input  logic       tick,
    input  logic       start,
    input  logic [7:0] data_in,
    input  logic       reset,

    output logic       tx,
    output logic       busy,
    output logic       done
);

// Defining FSM register
typedef enum logic [1:0] {
	IDLE,
	START,
	SHIFT,
	CLEANUP
} state_t;
// state is the current state
// next_state is the next state in the FSM cycle
state_t state, next_state;

// Shift register of width 10 bits
logic [9:0] shift_reg;
// Bit count register of width 4 bits: counting from 0-9
logic [3:0] bit_count;

always_ff @(posedge clk) begin
    if (reset) begin
        state      <= IDLE;
		next_state <= IDLE;
        busy       <= 0;
        done       <= 0;
        tx         <= 1;
        shift_reg  <= 10'b0;
        bit_count  <= 0;
    end else begin
        state <= next_state;

        if (tick) begin
            case (state)
                IDLE: begin
                    done <= 0;
                    busy <= 0;
                    tx   <= 1; // IDLE line is HIGH
                    if (start) begin
                        shift_reg <= {1'b1, data_in, 1'b0};
                        bit_count <= 0;
                        next_state <= START;
                        busy <= 1;
                    end else begin
                        next_state <= IDLE;
                    end
                end

                START: begin
                    tx <= shift_reg[0];
                    shift_reg <= shift_reg >> 1;
                    bit_count <= bit_count + 1;
                    next_state <= SHIFT;
                end

                SHIFT: begin
                    tx <= shift_reg[0];
                    shift_reg <= shift_reg >> 1;
                    bit_count <= bit_count + 1;
                    if (bit_count == 9)
                        next_state <= CLEANUP;
                    else
                        next_state <= SHIFT;
                end

                CLEANUP: begin
                    done <= 1;
                    busy <= 0;
                    tx   <= 1;
                    next_state <= IDLE;
                end
            endcase
        end
    end
end

endmodule