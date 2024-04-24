module ft8_modulator (
  input wire clk,
  input wire rst_n,
  input wire [7:0] ascii_in,
  input wire data_valid,
  output wire [2:0] symbol_out,
  output wire symbol_valid,
  output wire message_complete
);

  // Internal signals
  wire [86:0] packed_msg;
  wire packed_msg_valid;
  wire [173:0] codeword;
  wire codeword_valid;
  wire encoder_ready;
  wire mapper_ready;

  // Pipeline registers
  reg [86:0] packed_msg_reg;
  reg packed_msg_valid_reg;
  reg [173:0] codeword_reg;
  reg codeword_valid_reg;

  // Packed Message Encoder
  packed_message_encoder encoder (
    .clk(clk),
    .rst_n(rst_n),
    .ascii_in(ascii_in),
    .data_valid(data_valid),
    .packed_msg(packed_msg),
    .packed_msg_valid(packed_msg_valid),
    .ready(encoder_ready)
  );

  // Pipeline stage 1: Register packed message
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      packed_msg_reg <= 87'b0;
      packed_msg_valid_reg <= 1'b0;
    end else begin
      packed_msg_reg <= packed_msg;
      packed_msg_valid_reg <= packed_msg_valid;
    end
  end

  // LDPC Encoder
  ldpc_encoder ldpc (
    .clk(clk),
    .rst_n(rst_n),
    .packed_msg(packed_msg_reg),
    .packed_msg_valid(packed_msg_valid_reg),
    .codeword(codeword),
    .codeword_valid(codeword_valid)
  );

  // Pipeline stage 2: Register codeword
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      codeword_reg <= 174'b0;
      codeword_valid_reg <= 1'b0;
    end else begin
      codeword_reg <= codeword;
      codeword_valid_reg <= codeword_valid;
    end
  end

  // Symbol Mapper
  symbol_mapper mapper (
    .clk(clk),
    .rst_n(rst_n),
    .codeword(codeword_reg),
    .codeword_valid(codeword_valid_reg),
    .symbol_out(symbol_out),
    .symbol_valid(symbol_valid),
    .ready(mapper_ready),
    .message_complete(message_complete)
  );

  // Handshake logic
  assign encoder_ready = mapper_ready;

endmodule
