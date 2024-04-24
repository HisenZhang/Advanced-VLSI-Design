module packed_message_encoder (
  input wire clk,
  input wire rst_n,
  input wire [7:0] ascii_in,
  input wire data_valid,
  output reg [86:0] packed_msg,
  output reg packed_msg_valid,
  output reg ready
);

  reg [71:0] message_buffer;
  reg [ 6:0] bit_counter;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      message_buffer <= 72'b0;
      bit_counter <= 7'b0;
      packed_msg <= 87'b0;
      packed_msg_valid <= 1'b0;
      ready <= 1'b1;
    end else begin
      if (data_valid && ready) begin
        if (bit_counter < 72) begin
          message_buffer <= {message_buffer[63:0], ascii_in};
          bit_counter <= bit_counter + 7'd8;
          ready <= 1'b0;
        end else begin
          packed_msg <= {message_buffer, 3'b000, crc_12(message_buffer)};
          packed_msg_valid <= 1'b1;
          message_buffer <= 72'b0;
          bit_counter <= 7'b0;
          ready <= 1'b1;
        end
      end else begin
        packed_msg_valid <= 1'b0;
        if (!data_valid) begin
          ready <= 1'b1;
        end
      end
    end
  end

  // CRC-12 calculation function
  function [11:0] crc_12;
    input [71:0] data;

    reg [11:0] crc;
    reg [71:0] temp;
    integer i, j;

    crc = 12'b0;
    temp = data;

    for (i = 0; i < 72; i++) begin
      if (temp[71] ^ crc[11]) begin
        crc = {crc[10:0], 1'b0} ^ 12'hC0F;
      end else begin
        crc = {crc[10:0], 1'b0};
      end
      temp = {temp[70:0], 1'b0};
    end

    return crc;
  endfunction

endmodule
