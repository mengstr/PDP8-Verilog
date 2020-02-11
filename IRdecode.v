//
// IRdecode.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module IRdecode (
  input RESET,
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

assign AAND = !RESET & IR[11:9]==3'd0;
assign TAD  = !RESET & IR[11:9]==3'd1;
assign ISZ  = !RESET & IR[11:9]==3'd2;
assign DCA  = !RESET & IR[11:9]==3'd3;
assign JMS  = !RESET & IR[11:9]==3'd4;
assign JMP  = !RESET & IR[11:9]==3'd5;
assign IOT  = !RESET & IR[11:9]==3'd6;
assign OPR  = !RESET & IR[11:9]==3'd7;

wire isPP1 = ~PCLATCHED[11] & ~PCLATCHED[10] & ~PCLATCHED[9] & ~PCLATCHED[8] & ~PCLATCHED[7];
wire isPP2 = ~IR[6] & ~IR[5] & ~IR[4] & IR[3];
wire isPP = (isPP1 | ~MP) & isPP2; 

assign PPIND = !RESET & ~IOT & ~OPR & IR[8] &  isPP;
assign IND   = !RESET & ~IOT & ~OPR & IR[8] & ~isPP;
assign DIR   = !RESET & ~IR[8];
assign MP    = !RESET &  IR[7];

endmodule
