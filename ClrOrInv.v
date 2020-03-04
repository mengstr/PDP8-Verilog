//
// ClrOrInv.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
// ClrOrInv | 2 | 2 | 1 | 0
//

`default_nettype none

module ClrOrInv (
  input [11:0] IN,
  input CLR,
  input [11:0] DOR,
  input INV,
  output [11:0] OUT
);

wire nCLR          = ~CLR;
wire [11:0] stage1 = IN & {12{nCLR}};
wire [11:0] stage2 = stage1 | DOR;
wire [11:0] stage3 = stage2 ^ {12{INV}};
assign OUT         = stage3;

endmodule
