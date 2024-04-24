module symbol_mapper (
  input wire clk,
  input wire rst_n,
  input wire [173:0] codeword,
  input wire codeword_valid,
  output reg [2:0] symbol_out,
  output reg symbol_valid,
  output reg ready,
  output reg message_complete
);

  localparam int Costas_Symbols[7] = '{2, 5, 6, 0, 4, 1, 3};

  reg [6:0] symbol_counter;
  reg [173:0] codeword_reg;
  reg processing;
  reg symbols_ready;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      symbol_out <= 3'b0;
      symbol_valid <= 1'b0;
      symbol_counter <= 7'b0;
      ready <= 1'b1;
      message_complete <= 1'b0;
      codeword_reg <= 174'b0;
      processing <= 1'b0;
      symbols_ready <= 1'b0;
    end else begin
      if (codeword_valid && !processing) begin
        codeword_reg <= codeword;
        symbol_counter <= 7'b0;
        ready <= 1'b0;
        processing <= 1'b1;
        symbols_ready <= 1'b0;
      end

      if (processing) begin
        if (symbol_counter < 79) begin
          if ((symbol_counter < 7) || (symbol_counter >= 36 && symbol_counter < 43) || (symbol_counter >= 72)) begin
            symbol_out <= Costas_Symbols[symbol_counter%7];
          end else begin
            symbol_out <= codeword_reg[(symbol_counter-7)*3+:3];
          end
          symbol_valid <= 1'b1;
          symbol_counter <= symbol_counter + 7'b1;
          message_complete <= 1'b1;
        end else begin
          symbol_valid <= 1'b0;
          symbols_ready <= 1'b1;
          processing <= 1'b0;
        end
      end

      if (symbols_ready) begin
        ready <= 1'b1;
        message_complete <= 1'b0;
        symbols_ready <= 1'b0;
      end
    end
  end

endmodule
