module filter (
  input wire clk,                 // System clock
  input wire reset,               // Asynchronous reset
  input wire signed [15:0] data_in,  // 16-bit input data (Q15 format)
  output reg signed [34:0] data_out  // 35-bit output data (Q32 format)
);

  // Filter parameters
  parameter INPUT_WIDTH = 16;
  parameter INPUT_FRAC_WIDTH = 15;
  parameter COEFF_WIDTH = 16;
  parameter COEFF_FRAC_WIDTH = 15;
  parameter OUTPUT_WIDTH = 35;
  parameter OUTPUT_FRAC_WIDTH = 32;
  parameter NUM_TAPS = 101;
  parameter NUM_PARALLEL_PATHS = 3;

  // Derived parameters
  parameter NUM_TAPS_PER_PATH = NUM_TAPS / NUM_PARALLEL_PATHS;
  parameter PATH_WIDTH = INPUT_WIDTH + COEFF_WIDTH;

  // Coefficients (Q15 format)
  parameter signed [COEFF_WIDTH-1:0] COEFFS[NUM_TAPS-1:0] = {
    -16'sd7,
    -16'sd24,
    -16'sd61,
    -16'sd123,
    -16'sd214,
    -16'sd327,
    -16'sd446,
    -16'sd539,
    -16'sd568,
    -16'sd493,
    -16'sd287,
    16'sd58,
    16'sd512,
    16'sd1017,
    16'sd1485,
    16'sd1820,
    16'sd1943,
    16'sd1813,
    16'sd1445,
    16'sd916,
    16'sd343,
    -16'sd140,
    -16'sd419,
    -16'sd436,
    -16'sd210,
    16'sd170,
    16'sd567,
    16'sd837,
    16'sd878,
    16'sd664,
    16'sd258,
    -16'sd206,
    -16'sd567,
    -16'sd691,
    -16'sd522,
    -16'sd108,
    16'sd408,
    16'sd833,
    16'sd984,
    16'sd763,
    16'sd201,
    -16'sd537,
    -16'sd1186,
    -16'sd1461,
    -16'sd1143,
    -16'sd156,
    16'sd1387,
    16'sd3210,
    16'sd4925,
    16'sd6149,
    16'sd6590,
    16'sd6149,
    16'sd4925,
    16'sd3210,
    16'sd1387,
    -16'sd156,
    -16'sd1143,
    -16'sd1461,
    -16'sd1186,
    -16'sd537,
    16'sd201,
    16'sd763,
    16'sd984,
    16'sd833,
    16'sd408,
    -16'sd108,
    -16'sd522,
    -16'sd691,
    -16'sd567,
    -16'sd206,
    16'sd258,
    16'sd664,
    16'sd878,
    16'sd837,
    16'sd567,
    16'sd170,
    -16'sd210,
    -16'sd436,
    -16'sd419,
    -16'sd140,
    16'sd343,
    16'sd916,
    16'sd1445,
    16'sd1813,
    16'sd1943,
    16'sd1820,
    16'sd1485,
    16'sd1017,
    16'sd512,
    16'sd58,
    -16'sd287,
    -16'sd493,
    -16'sd568,
    -16'sd539,
    -16'sd446,
    -16'sd327,
    -16'sd214,
    -16'sd123,
    -16'sd61,
    -16'sd24,
    -16'sd7
  };

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
          .coefficient(COEFFS[i*NUM_TAPS_PER_PATH+j]),
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
