module ft8_modulator_tb;

  // Parameters
  localparam CLK_PERIOD = 10;  // Clock period in nanoseconds

  // Inputs
  reg clk;
  reg rst_n;
  reg [7:0] ascii_in;
  reg data_valid;

  // Outputs
  wire [2:0] symbol_out;
  wire symbol_valid;
  wire message_complete;

  // Instantiate the FT8 modulator
  ft8_modulator dut (
    .clk(clk),
    .rst_n(rst_n),
    .ascii_in(ascii_in),
    .data_valid(data_valid),
    .symbol_out(symbol_out),
    .symbol_valid(symbol_valid),
    .message_complete(message_complete)
  );

  // Clock generation
  always begin
    clk = 1'b0;
    #(CLK_PERIOD / 2);
    clk = 1'b1;
    #(CLK_PERIOD / 2);
  end

  // Test case inputs
  reg [8*100-1:0] test_cases[0:6];

  initial begin
    // Initialize test cases
    test_cases[0] = "CQ KI7PO DN06";
    test_cases[1] = "KI7PO IZ1M JN35";
    test_cases[2] = "IZ1M KI7PO -10";
    test_cases[3] = "KI7PO IZ1M R-12";
    test_cases[4] = "IZ1M KI7PO RRR";
    test_cases[5] = "KI7PO IZ1M 73";
    test_cases[6] = "IZ1M KI7PO 73";

    // Initialize inputs
    rst_n = 1'b0;
    ascii_in = 8'b0;
    data_valid = 1'b0;

    // Reset the modulator
    #(CLK_PERIOD * 2);
    rst_n = 1'b1;

    // Apply test cases
    for (integer i = 0; i < 7; i++) begin
      automatic reg [8*100-1:0] current_test_case = test_cases[i];
      automatic integer length = $size(current_test_case) / 8;

      // Send characters of the current test case
      for (integer j = 0; j < length; j++) begin
        @(posedge clk);
        ascii_in = current_test_case[j*8+:8];
        data_valid = 1'b1;
        @(posedge clk);
        data_valid = 1'b0;
        wait (dut.encoder.ready);
      end

      // Wait for the modulator to finish processing the current test case
      wait (message_complete);
    end

    // End the simulation
    #(CLK_PERIOD * 10);
    $finish;
  end

  // Timeout
  initial begin
    #1_000_000;  // Adjust the timeout value as needed
    $display("Timeout reached. Simulation terminated.");
    $finish;
  end

  // Dump waveforms
  initial begin
    $dumpfile("ft8_modulator.vcd");
    $dumpvars(0, ft8_modulator_tb);
  end

endmodule
