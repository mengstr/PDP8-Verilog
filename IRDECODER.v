`default_nettype none

module IRDECODER  (
  input [11:0]PCLATCHED,
  input [11:0]IR,
  output PPIND ,
  output IND,
  output DIR,
  output MP,
  output AAND ,
  output TAD,
  output ISZ,
  output DCA,
  output JMS,
  output JMP,
  output IOT,
  output OPR
);

  wire s0,s1,s2;
  wire or789;
  assign or789=PCLATCHED[7] | PCLATCHED[8] | PCLATCHED[9];
  assign OPR = (IR[10] & IR[11] & IR[9]);
  assign s1 = ~ IR[11];
  assign s0 = ~ IR[10];
  assign s2 = ~ IR[9];
  assign PPIND  = ((s0 & IR[3] & ~ IR[4] & ~ IR[5] & ~ IR[6] & IR[8] & ~ PCLATCHED[10] & ~ PCLATCHED[11] & ~ or789) | (s0 & IR[3] & ~ IR[4] & ~ IR[5] & ~ IR[6] & ~ IR[7] & IR[8]) | (s1 & IR[3] & ~ IR[4] & ~ IR[5] & ~ IR[6] & IR[8] & ~ PCLATCHED[10] & ~ PCLATCHED[11] & ~ or789) | (s1 & IR[3] & ~ IR[4] & ~ IR[5] & ~ IR[6] & ~ IR[7] & IR[8]));
  assign IND = ((s0 & IR[7] & IR[8] & or789) | (s0 & IR[7] & IR[8] & PCLATCHED[10]) | (s0 & IR[7] & IR[8] & PCLATCHED[11]) | (s0 & ~ IR[3] & IR[8]) | (s0 & IR[4] & IR[8]) | (s0 & IR[5] & IR[8]) | (s0 & IR[6] & IR[8]) | (s1 & IR[7] & IR[8] & or789) | (s1 & IR[7] & IR[8] & PCLATCHED[10]) | (s1 & IR[7] & IR[8] & PCLATCHED[11]) | (s1 & ~ IR[3] & IR[8]) | (s1 & IR[4] & IR[8]) | (s1 & IR[5] & IR[8]) | (s1 & IR[6] & IR[8]));
  assign DIR = ((s0 & ~ IR[8]) | (s1 & ~ IR[8]));
  assign MP = ((s0 & IR[7]) | (s1 & IR[7]));
  assign AAND  = (s0 & s1 & s2);
  assign TAD = (s0 & s1 & IR[9]);
  assign ISZ = (IR[10] & s1 & s2);
  assign DCA = (IR[10] & s1 & IR[9]);
  assign JMS = (s0 & IR[11] & s2);
  assign JMP = (s0 & IR[11] & IR[9]);
  assign IOT = (IR[10] & IR[11] & s2);
endmodule



