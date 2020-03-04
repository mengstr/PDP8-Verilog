//
// Skip.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
// Skip | 1 | 5 | 0 | 1
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

// assign OUT = ((((1'b1 ^ (AC!=0 | AC[11])) & SZASNA) | (AC[11] & SMASPA) | (LINK & SNLSZL)) ^ TSTINV);

wire ACa      = AC[0] | AC[1] |  AC[2] | AC[3];
wire ACb      = AC[4] | AC[5] |  AC[6] | AC[7];
wire ACc      = AC[8] | AC[9] | AC[10] | AC[11];
wire ACd      = ACa | ACb | ACc;
wire ACisZero = ~ACd;

wire zeroOK   = ACisZero & SZASNA;
wire negOK    = AC[11] & SMASPA;
wire linkOK   = LINK & SNLSZL;

wire skip     = zeroOK | negOK | linkOK;

assign OUT    = skip ^ TSTINV;

endmodule
