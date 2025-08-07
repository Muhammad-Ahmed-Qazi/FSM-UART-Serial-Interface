module baud_gen (
    input  logic clk,
    input  logic reset,
    output logic tick
);

    parameter BAUD_DIV = 5208;  // for 9600 baud with 50 MHz clk
    logic [$clog2(BAUD_DIV)-1:0] count;       // enough to count to 5208

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            tick  <= 0;
        end else if (count == BAUD_DIV - 1) begin
            count <= 0;
            tick  <= 1;
        end else begin
            count <= count + 1;
            tick  <= 0;
        end
    end

endmodule
