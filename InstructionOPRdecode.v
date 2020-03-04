//
// OPRdecoder.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
// InstructionOPRdecode | 1 | 1 | 0 | 28
//

`default_nettype none

module InstructionOPRdecode  (
  input [8:0] IR,
  input OPR,
  output opr1,opr2,opr3,
  output oprIAC, oprX2, oprLEFT, oprRIGHT, oprCML, oprCMA, oprCLL,    // OPR 1
  output oprHLT, oprOSR, oprTSTINV, oprSNLSZL, oprSZASNA, oprSMASPA,  // OPR 2
  output oprMQL, oprSWP, oprMQA, oprSCA,                              // OPR 3 
  output oprSCL, oprMUY, oprDVI, oprNMI, oprSHL, oprASL, oprLSR,      // OPR 3
  output oprCLA                                                       // OPR 1,2,3
);

assign opr1 = OPR & ~IR[8];
assign opr2 = OPR &  IR[8] & ~IR[0];
assign opr3 = OPR &  IR[8] &  IR[0];

assign oprCLA = (opr1 | opr2 | opr3) & IR[7];

assign oprIAC  = opr1 & IR[0];
assign oprX2   = opr1 & IR[1];
assign oprLEFT = opr1 & IR[2];
assign oprRIGHT= opr1 & IR[3];
assign oprCML  = opr1 & IR[4];
assign oprCMA  = opr1 & IR[5];
assign oprCLL  = opr1 & IR[6];

assign oprHLT    = opr2 & IR[1];
assign oprOSR    = opr2 & IR[2];
assign oprTSTINV = opr2 & IR[3];
assign oprSNLSZL = opr2 & IR[4];
assign oprSZASNA = opr2 & IR[5];
assign oprSMASPA = opr2 & IR[6];

assign oprMQL = opr3 &  IR[4];
assign oprSWP = opr3 &  IR[4] & IR[6];
assign oprSCA = opr3 &  IR[5];
assign oprMQA = opr3 &  IR[6];
assign oprSCL = opr3 &  IR[1] & ~IR[2] & ~IR[3];  //1
assign oprMUY = opr3 & ~IR[1] &  IR[2] & ~IR[3];  //2
assign oprDVI = opr3 &  IR[1] &  IR[2] & ~IR[3];  //3
assign oprNMI = opr3 & ~IR[1] & ~IR[2] &  IR[3];  //4
assign oprSHL = opr3 &  IR[1] & ~IR[2] &  IR[3];  //5
assign oprASL = opr3 & ~IR[1] &  IR[2] &  IR[3];  //6
assign oprLSR = opr3 &  IR[1] &  IR[2] &  IR[3];  //7

endmodule
