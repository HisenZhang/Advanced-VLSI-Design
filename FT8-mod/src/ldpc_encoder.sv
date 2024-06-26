module ldpc_encoder (
  input wire clk,
  input wire rst_n,
  input wire [86:0] packed_msg,
  input wire packed_msg_valid,
  output reg [173:0] codeword,
  output reg codeword_valid
);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      codeword <= 174'b0;
      codeword_valid <= 1'b0;
    end else begin
      if (packed_msg_valid) begin
        codeword <= ldpc_encode(packed_msg);
        codeword_valid <= 1'b1;
      end else begin
        codeword_valid <= 1'b0;
      end
    end
  end

  // LDPC encoding function
  function [173:0] ldpc_encode;
    input [86:0] packed_msg;

    reg [ 86:0] codeword_sys;
    reg [173:0] codeword;
    integer i, j;

    // Nm matrix
    localparam int Nm[87][7] = '{
        '{1, 30, 60, 89, 118, 147, 0},
        '{2, 31, 61, 90, 119, 147, 0},
        '{3, 32, 62, 91, 120, 148, 0},
        '{4, 33, 63, 92, 121, 149, 0},
        '{2, 34, 64, 93, 122, 150, 0},
        '{5, 33, 65, 94, 123, 148, 0},
        '{6, 34, 66, 95, 124, 151, 0},
        '{7, 35, 67, 96, 120, 152, 0},
        '{8, 36, 68, 97, 125, 153, 0},
        '{9, 37, 69, 98, 126, 152, 0},
        '{10, 38, 70, 99, 127, 154, 0},
        '{11, 39, 71, 100, 126, 155, 0},
        '{12, 40, 61, 101, 128, 145, 0},
        '{10, 33, 60, 95, 128, 156, 0},
        '{13, 41, 72, 97, 126, 157, 0},
        '{13, 42, 73, 90, 129, 156, 0},
        '{14, 39, 74, 99, 130, 158, 0},
        '{15, 43, 75, 102, 131, 159, 0},
        '{16, 43, 71, 103, 118, 160, 0},
        '{17, 44, 76, 98, 130, 156, 0},
        '{18, 45, 60, 96, 132, 161, 0},
        '{19, 46, 73, 83, 133, 162, 0},
        '{12, 38, 77, 102, 134, 163, 0},
        '{19, 47, 78, 104, 135, 147, 0},
        '{1, 32, 77, 105, 136, 164, 0},
        '{20, 48, 73, 106, 123, 163, 0},
        '{21, 41, 79, 107, 137, 165, 0},
        '{22, 42, 66, 108, 138, 152, 0},
        '{18, 42, 80, 109, 139, 154, 0},
        '{23, 49, 81, 110, 135, 166, 0},
        '{16, 50, 82, 91, 129, 158, 0},
        '{3, 48, 63, 107, 124, 167, 0},
        '{6, 51, 67, 111, 134, 155, 0},
        '{24, 35, 77, 100, 122, 162, 0},
        '{20, 45, 76, 112, 140, 157, 0},
        '{21, 36, 64, 92, 130, 159, 0},
        '{8, 52, 83, 111, 118, 166, 0},
        '{21, 53, 84, 113, 138, 168, 0},
        '{25, 51, 79, 89, 122, 158, 0},
        '{22, 44, 75, 107, 133, 155, 172},
        '{9, 54, 84, 90, 141, 169, 0},
        '{22, 54, 85, 110, 136, 161, 0},
        '{8, 37, 65, 102, 129, 170, 0},
        '{19, 39, 85, 114, 139, 150, 0},
        '{26, 55, 71, 93, 142, 167, 0},
        '{27, 56, 65, 96, 133, 160, 174},
        '{28, 31, 86, 100, 117, 171, 0},
        '{28, 52, 70, 104, 132, 144, 0},
        '{24, 57, 68, 95, 137, 142, 0},
        '{7, 30, 72, 110, 143, 151, 0},
        '{4, 51, 76, 115, 127, 168, 0},
        '{16, 45, 87, 114, 125, 172, 0},
        '{15, 30, 86, 115, 123, 150, 0},
        '{23, 46, 64, 91, 144, 173, 0},
        '{23, 35, 75, 113, 145, 153, 0},
        '{14, 41, 87, 108, 117, 149, 170},
        '{25, 40, 85, 94, 124, 159, 0},
        '{25, 58, 69, 116, 143, 174, 0},
        '{29, 43, 61, 116, 132, 162, 0},
        '{15, 58, 88, 112, 121, 164, 0},
        '{4, 59, 72, 114, 119, 163, 173},
        '{27, 47, 86, 98, 134, 153, 0},
        '{5, 44, 78, 109, 141, 0, 0},
        '{10, 46, 69, 103, 136, 165, 0},
        '{9, 50, 59, 93, 128, 164, 0},
        '{14, 57, 58, 109, 120, 166, 0},
        '{17, 55, 62, 116, 125, 154, 0},
        '{3, 54, 70, 101, 140, 170, 0},
        '{1, 36, 82, 108, 127, 174, 0},
        '{5, 53, 81, 105, 140, 0, 0},
        '{29, 53, 67, 99, 142, 173, 0},
        '{18, 49, 74, 97, 115, 167, 0},
        '{2, 57, 63, 103, 138, 157, 0},
        '{26, 38, 79, 112, 135, 171, 0},
        '{11, 52, 66, 88, 119, 148, 0},
        '{20, 40, 68, 117, 141, 160, 0},
        '{11, 48, 81, 89, 146, 169, 0},
        '{29, 47, 80, 92, 146, 172, 0},
        '{6, 32, 87, 104, 145, 169, 0},
        '{27, 34, 74, 106, 131, 165, 0},
        '{12, 56, 84, 88, 139, 0, 0},
        '{13, 56, 62, 111, 146, 171, 0},
        '{26, 37, 80, 105, 144, 151, 0},
        '{17, 31, 82, 113, 121, 161, 0},
        '{28, 49, 59, 94, 137, 0, 0},
        '{7, 55, 83, 101, 131, 168, 0},
        '{24, 50, 78, 106, 143, 149, 0}
    };
    localparam int colorder[173:0] = {
      0,
      1,
      2,
      3,
      30,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      32,
      12,
      40,
      13,
      14,
      15,
      16,
      17,
      18,
      37,
      45,
      29,
      19,
      20,
      21,
      41,
      22,
      42,
      31,
      33,
      34,
      44,
      35,
      47,
      51,
      50,
      43,
      36,
      52,
      63,
      46,
      25,
      55,
      27,
      24,
      23,
      53,
      39,
      49,
      59,
      38,
      48,
      61,
      60,
      57,
      28,
      62,
      56,
      58,
      65,
      66,
      26,
      70,
      64,
      69,
      68,
      67,
      74,
      71,
      54,
      76,
      72,
      75,
      78,
      77,
      80,
      79,
      73,
      83,
      84,
      81,
      82,
      85,
      86,
      87,
      88,
      89,
      90,
      91,
      92,
      93,
      94,
      95,
      96,
      97,
      98,
      99,
      100,
      101,
      102,
      103,
      104,
      105,
      106,
      107,
      108,
      109,
      110,
      111,
      112,
      113,
      114,
      115,
      116,
      117,
      118,
      119,
      120,
      121,
      122,
      123,
      124,
      125,
      126,
      127,
      128,
      129,
      130,
      131,
      132,
      133,
      134,
      135,
      136,
      137,
      138,
      139,
      140,
      141,
      142,
      143,
      144,
      145,
      146,
      147,
      148,
      149,
      150,
      151,
      152,
      153,
      154,
      155,
      156,
      157,
      158,
      159,
      160,
      161,
      162,
      163,
      164,
      165,
      166,
      167,
      168,
      169,
      170,
      171,
      172,
      173
    };

    // Initialize the codeword with the packed message
    codeword_sys = packed_msg;

    // Perform LDPC encoding using the generator matrix (Nm)
    for (i = 0; i < 87; i++) begin
      codeword[i] = codeword_sys[i];
    end

    for (i = 0; i < 87; i++) begin
      for (j = 0; j < 7; j++) begin
        codeword[87+Nm[i][j]-1] = codeword_sys[i] ^ codeword[87+Nm[i][j]-1];
      end
    end


    // Apply the column permutation to the codeword
    for (i = 0; i < 174; i++) begin
      codeword[i] = codeword_sys[colorder[i]];
    end

    return codeword;
  endfunction

endmodule
