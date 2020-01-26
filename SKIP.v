//
// SKIP.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module SKIP (
  input [11:0] AC,
  input LINK,
  input SZASNA,
  input SMASPA,
  input SNLSZL,
  input TSTINV,
  output OUT
);

assign OUT = ((((1'b1 ^ (AC!=0 | AC[11])) & SZASNA) | (AC[11] & SMASPA) | (LINK & SNLSZL)) ^ TSTINV);

endmodule
