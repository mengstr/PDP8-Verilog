//
// CLORIN.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module CLORIN (
  input [11:0] IN,
  input CLR,
  input [11:0] DOR,
  input INV,
  output [11:0] OUT
);

assign OUT=(CLR==1'b0) ?
  INV ? (IN|DOR)^12'b111111111111 : (IN|DOR) :
  INV ? (   DOR)^12'b111111111111 : (   DOR) ;

endmodule
