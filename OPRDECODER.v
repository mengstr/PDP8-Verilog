`default_nettype none

//  ICESTORM_LC:   424/ 1280    33%  With separate CLAs
//  ICESTORM_LC:   453/ 1280    35% Merged CLAs
//  ICESTORM_LC:   424/ 1280    33% Fixed meerged CLAs
//ICESTORM_LC:   453/ 1280    35%

module OPRDECODER  (
  input [11:0] IR,
  input OPR,
  output opr1,opr2,opr3,
  output oprIAC, oprX2, oprLEFT, oprRIGHT, oprCML, oprCMA, oprCLL, // OPR 1
  output oprHLT, oprOSR, oprTSTINV, oprSNLSZL, oprSZASNA, oprSMASPA,  // OPR 2
  output oprMQL, oprSWP, oprMQA, oprSCA,  // OPR 3 
  output oprSCL, oprMUY, oprDVI, oprNMI, oprSHL, oprASL, oprLSR, // OPR 3
  output oprCLA // OPR 1,2,3
);
  wire s0,s1,s2,s3,s4;

  assign s0 = ~ IR[8];
  assign s1 = ~ IR[0];
  assign s2 = ~ IR[1];
  assign s3 = ~ IR[2];
  assign s4 = ~ IR[3];

 assign opr1 = (s0 & OPR);
 assign opr2 = (s1 & IR[8] & OPR);
 assign opr3 = (IR[0] & IR[8] & OPR);

  assign oprMQL = (IR[0] & IR[4] & IR[8] & OPR);
  assign oprSWP = (IR[0] & IR[4] & IR[6] & IR[8] & OPR);
  assign oprMQA = (IR[0] & IR[6] & IR[8] & OPR);
  assign oprSCA = (IR[0] & IR[5] & IR[8] & OPR);
  assign oprLSR = (IR[0] & IR[1] & IR[2] & IR[3] & IR[8] & OPR);
  assign oprIAC = (IR[0] & s0 & OPR);
  assign oprX2 = (IR[1] & s0 & OPR);
  assign oprLEFT = (IR[2] & s0 & OPR);
  assign oprRIGHT = (IR[3] & s0 & OPR);
  assign oprCML = (IR[4] & s0 & OPR);
  assign oprCMA = (IR[5] & s0 & OPR);
  assign oprCLL = (IR[6] & s0 & OPR);
  assign oprHLT = (s1 & IR[1] & IR[8] & OPR);
  assign oprOSR = (s1 & IR[2] & IR[8] & OPR);
  assign oprTSTINV = (s1 & IR[3] & IR[8] & OPR);
  assign oprSNLSZL = (s1 & IR[4] & IR[8] & OPR);
  assign oprSZASNA = (s1 & IR[5] & IR[8] & OPR);
  assign oprSMASPA = (s1 & IR[6] & IR[8] & OPR);
  assign oprASL = (IR[0] & s2 & IR[2] & IR[3] & IR[8] & OPR);
  assign oprSHL = (IR[0] & IR[1] & s3 & IR[3] & IR[8] & OPR);
  assign oprNMI = (IR[0] & s2 & s3 & IR[3] & IR[8] & OPR);
  assign oprDVI = (IR[0] & IR[1] & IR[2] & s4 & IR[8] & OPR);
  assign oprMUY = (IR[0] & s2 & IR[2] & s4 & IR[8] & OPR);
  assign oprSCL = (IR[0] & IR[1] & s3 & s4 & IR[8] & OPR);

  assign oprCLA = ((IR[0] & IR[7] & OPR) | (~ IR[1] & IR[7] & OPR) | (IR[7] & ~ IR[8] & OPR));


endmodule


//(IR7 & (~ IR8) & OPR) | ((~ IR1) & IR7 & IR8 & OPR) | (IR0 & IR7 & IR8 & OPR)


`ifdef TOP
module top(input CLK, inout P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23,P24,P25,P26,P27,P28,P29,P30,P31,P32,P33,P34,P35,P36,P37,P38,P39,P40,P41,P42,P43,P44,P45,P46,P47,P48,P49,P50,P51,P52,P53,P54,P55,P56,P57,P58,P59,P60,P61,P62,P63,P64,P65,P66);
  OPRDECODER dut(
    {P0,P1,P2,P3, P4,P5,P6,P7, P8,P9,P10,P11},
    P12, 
    P13, P14, P15, P16, P17, P18, P19, P20, P21, P22, P23, 
    P24, P25, P26, P27, P28, P29, P30, P31, P32, P33, P34, 
    P35, P36, P37, P38, P39, P40, P41, P42, P43, P44, P45
  );
endmodule
`endif
