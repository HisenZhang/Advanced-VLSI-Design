module fixed_point_mac #(
    parameter INPUT_WIDTH = 16,      // Bit width of the input
    parameter COEFF_WIDTH = 16,      // Bit width of the coefficients
    parameter ACCUM_WIDTH = 35       // Bit width of the accumulator
)(
    input wire clk,                  // Clock signal
    input wire reset,                // Asynchronous reset
    input wire signed [INPUT_WIDTH-1:0] sample,     // Input sample
    input wire signed [COEFF_WIDTH-1:0] coefficient, // Filter coefficient
    output reg signed [ACCUM_WIDTH-1:0] accumulator // Accumulated output
);

// Internal signal for the multiplication result
wire signed [INPUT_WIDTH+COEFF_WIDTH-1:0] mult_result;

// Perform the multiplication
assign mult_result = sample * coefficient;

// Perform the accumulation with pipelining
always @(posedge clk or posedge reset) begin
    if (reset) begin
        accumulator <= 0;
    end else begin
        // Add the multiplication result to the accumulator
        accumulator <= accumulator + mult_result;
    end
end

endmodule
