//
// ADDAND.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module ADDAND (
  input [11:0] A,
  input [11:0] B,
  input CI,
  input OE_ADD,
  input OE_AND,
  output [11:0] S,
  output CO
);

wire [12:0] sum;

assign sum = A + B + {12'b0, CI};
assign S =  OE_ADD ? sum[11:0] : OE_AND ? A & B : 12'b0;
assign CO = OE_ADD ? sum[12] : 1'b0;

endmodule
