//
// Skip.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module Skip (
  input [11:0] AC,
  input LINK,
  input SZASNA,
  input SMASPA,
  input SNLSZL,
  input TSTINV,
  output OUT
);

// TODO: Redo Skip with regular logic
assign OUT = ((((1'b1 ^ (AC!=0 | AC[11])) & SZASNA) | (AC[11] & SMASPA) | (LINK & SNLSZL)) ^ TSTINV);

endmodule
