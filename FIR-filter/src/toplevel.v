module pipelined_parallel_fir_filter (
    input wire clk,                 // System clock
    input wire reset,               // Asynchronous reset
    input wire signed [15:0] data_in,  // 16-bit input data
    output reg signed [34:0] data_out  // 35-bit output data to accommodate for growth
);

// Filter parameters
parameter INPUT_WIDTH = 16;
parameter COEFF_WIDTH = 16;
parameter ACCUM_WIDTH = 35;
parameter NUM_TAPS = 100;
parameter NUM_PARALLEL_PATHS = 3;

// Derived parameters
parameter NUM_TAPS_PER_PATH = NUM_TAPS / NUM_PARALLEL_PATHS;
parameter PATH_WIDTH = INPUT_WIDTH + COEFF_WIDTH;

// Coefficients (placeholder values)
parameter signed [COEFF_WIDTH-1:0] COEFFS[NUM_TAPS-1:0] = '{ /* Coefficients */ };

// Input sample distribution
reg [1:0] sample_counter = 0;
reg signed [INPUT_WIDTH-1:0] path_data[NUM_PARALLEL_PATHS-1:0];

// MAC units for each parallel path
wire signed [PATH_WIDTH-1:0] mac_outputs[NUM_PARALLEL_PATHS-1:0];

genvar i, j;
generate
    for (i = 0; i < NUM_PARALLEL_PATHS; i = i + 1) begin : mac_units
        for (j = 0; j < NUM_TAPS_PER_PATH; j = j + 1) begin : taps
            fixed_point_mac #(
                .INPUT_WIDTH(INPUT_WIDTH),
                .COEFF_WIDTH(COEFF_WIDTH),
                .ACCUM_WIDTH(PATH_WIDTH)
            ) mac (
                .clk(clk),
                .reset(reset),
                .sample(path_data[i]),
                .coefficient(COEFFS[i * NUM_TAPS_PER_PATH + j]),
                .accumulator(mac_outputs[i])
            );
        end
    end
endgenerate

// Combine outputs from the MAC units
always @(posedge clk) begin
    if (reset) begin
        data_out <= 0;
        sample_counter <= 0;
    end else begin
        if (sample_counter == NUM_PARALLEL_PATHS - 1) begin
            // Combine the results on the last parallel path
            data_out <= mac_outputs[0] + mac_outputs[1] + mac_outputs[2];
        end
        sample_counter <= sample_counter + 1;
    end
end

// Distribute the input samples to the parallel paths
always @(posedge clk) begin
    if (reset) begin
        path_data[0] <= 0;
        path_data[1] <= 0;
        path_data[2] <= 0;
    end else if (sample_counter == 0) begin
        path_data[0] <= data_in;
    end else if (sample_counter == 1) begin
        path_data[1] <= data_in;
    end else if (sample_counter == 2) begin
        path_data[2] <= data_in;
    end
end

endmodule
