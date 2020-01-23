`default_nettype none

module IRDECODER  (
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

  wire isPP1 = ~PCLATCHED[11] & ~PCLATCHED[10] & ~PCLATCHED[9] & ~PCLATCHED[8] & ~PCLATCHED[7];
  wire isPP2 = ~IR[6] & ~IR[5] & ~IR[4] & IR[3];
  wire isPP = (isPP1 | ~MP) & isPP2;

  assign PPIND =  IR[8] &  isPP;
  assign IND   =  IR[8] & ~isPP;
  assign DIR   = ~IR[8];
  assign MP    =  IR[7];

  assign AAND = IR[11:9]==3'd0;
  assign TAD  = IR[11:9]==3'd1;
  assign ISZ  = IR[11:9]==3'd2;
  assign DCA  = IR[11:9]==3'd3;
  assign JMS  = IR[11:9]==3'd4;
  assign JMP  = IR[11:9]==3'd5;
  assign IOT  = IR[11:9]==3'd6;
  assign OPR  = IR[11:9]==3'd7;

endmodule
