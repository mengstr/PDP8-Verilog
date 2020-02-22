//
// IRdecode.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module IRdecode (
  input [11:0]PCLATCHED,
  input [11:0]IR,
  output PPIND ,
  output IND,
  output DIR,
  output MP,
  output AAND,
  output TAD,
  output ISZ,
  output DCA,
  output JMS,
  output JMP,
  output IOT,
  output OPR
);


//
//   ICESTORM_LC:   876/ 1280    68%
// Timing estimate: 21.25 ns (47.07 MHz)
//
// assign AAND  = IR[11:9]==3'd0;
// assign TAD   = IR[11:9]==3'd1;
// assign ISZ   = IR[11:9]==3'd2;
// assign DCA   = IR[11:9]==3'd3;
// assign JMS   = IR[11:9]==3'd4;
// assign JMP   = IR[11:9]==3'd5;
// assign IOT   = IR[11:9]==3'd6;
// assign OPR   = IR[11:9]==3'd7;


//
//    ICESTORM_LC:   854/ 1280    66%
//   Timing estimate: 19.95 ns (50.13 MHz)
//  
wire [2:0] IRinst = IR[11:9];
assign AAND  = IRinst==3'd0;
assign TAD   = IRinst==3'd1;
assign ISZ   = IRinst==3'd2;
assign DCA   = IRinst==3'd3;
assign JMS   = IRinst==3'd4;
assign JMP   = IRinst==3'd5;
assign IOT   = IRinst==3'd6;
assign OPR   = IRinst==3'd7;


// 11 10  9 . 8  7  6 . 5  4  3 . 2  1  0
// ---------------------------------------
//  0  0  0 . 0  0  0 . 0  0  1 . x  x  x   0010 - 0017
//
//  0  0  0 . x  x  x . x  x  x . x  x  x   AND
//  0  0  1 . x  x  x . x  x  x . x  x  x   TAD
//  0  1  0 . x  x  x . x  x  x . x  x  x   ISZ
//  0  1  1 . x  x  x . x  x  x . x  x  x   DCA
//  1  0  0 . x  x  x . x  x  x . x  x  x   JMS
//  1  0  1 . x  x  x . x  x  x . x  x  x   JMP
//  1  1  0 . x  x  x . x  x  x . x  x  x   IOT
//  1  1  1 . x  x  x . x  x  x . x  x  x   OPR
//
//  x  x  x . x  0  x . x  x  x . x  x  x   Access Zero Page
//  x  x  x . x  1  x . x  x  x . x  x  x   Access Current Page
//
//  x  x  x . 0  x  x . x  x  x . x  x  x   Direct addressing
//  x  x  x . 1  x  x . x  x  x . x  x  x   Indirect addressing
//

// wire isPP1   = ~(PCLATCHED[11] | PCLATCHED[10] | PCLATCHED[9] | PCLATCHED[8] | PCLATCHED[7]);
// wire isPP2   = ~(IR[6] | ~IR[5] | IR[4] | ~IR[3]);
// wire isPP    = (isPP1 | ~MP) & isPP2; 

wire isPP1 = ~PCLATCHED[11] & ~PCLATCHED[10] & ~PCLATCHED[9] & ~PCLATCHED[8] & ~PCLATCHED[7];
wire isPP2 = ~IR[6] & ~IR[5] & ~IR[4] & IR[3];
wire isPP = (isPP1 | ~MP) & isPP2;

wire normalInstruction = ~IOT & ~OPR;
assign IND   = normalInstruction &  IR[8] & ~isPP;
assign PPIND = normalInstruction &  IR[8] &  isPP;
assign DIR   = normalInstruction & ~IR[8];
assign MP    = normalInstruction &  IR[7];

endmodule
