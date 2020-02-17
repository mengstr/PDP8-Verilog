//
// InstructionIOTdecode.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module InstructionIOTdecode (
  input [11:0] IR,
  input IOT,
  input ckFetch,
  input ck3,
  output IOT600x ,
  output IOT601x ,
  output IOT602x ,
  output IOT603x ,
  output IOT604x ,
  output IOT605x ,
  output IOT606x ,
  output IOT607x ,
  output IOT62x0 ,
  output IOT62x1 ,
  output IOT62x2 ,
  output IOT62x3 ,
  output IOT62x4 ,
  output IOT62x5 ,
  output IOT62x6 ,
  output IOT62x7 ,
  output DONE
);

wire s0;
wire s1;
wire s2;
wire s3;
wire s4;
wire s5;
wire s6;
wire s7;
wire s8;
wire s9;
assign DONE = (ck3 & IOT);
assign s6 = ~ IR[8];
assign s5 = ~ IR[7];
assign s4 = ~ IR[6];
assign s3 = ~ IR[5];
assign s2 = ~ IR[4];
assign s1 = ~ IR[3];
assign s9 = ~ IR[2];
assign s8 = ~ IR[1];
assign s7 = ~ IR[0];
assign s0 = ~ ckFetch;
assign IOT600x  = (s0 & IOT & s1 & s2 & s3 & s4 & s5 & s6);
assign IOT601x  = (s0 & IOT & IR[3] & s2 & s3 & s4 & s5 & s6);
assign IOT602x  = (s0 & IOT & s1 & IR[4] & s3 & s4 & s5 & s6);
assign IOT603x  = (s0 & IOT & IR[3] & IR[4] & s3 & s4 & s5 & s6);
assign IOT604x  = (s0 & IOT & s1 & s2 & IR[5] & s4 & s5 & s6);
assign IOT605x  = (s0 & IOT & IR[3] & s2 & IR[5] & s4 & s5 & s6);
assign IOT606x  = (s0 & IOT & s1 & IR[4] & IR[5] & s4 & s5 & s6);
assign IOT607x  = (s0 & IOT & IR[3] & IR[4] & IR[5] & s4 & s5 & s6);
assign IOT62x0  = (s0 & IOT & s7 & s8 & s9 & s4 & IR[7] & s6);
assign IOT62x1  = (s0 & IOT & IR[0] & s8 & s9 & s4 & IR[7] & s6);
assign IOT62x2  = (s0 & IOT & s7 & IR[1] & s9 & s4 & IR[7] & s6);
assign IOT62x3  = (s0 & IOT & IR[0] & IR[1] & s9 & s4 & IR[7] & s6);
assign IOT62x4  = (s0 & IOT & s7 & s8 & IR[2] & s4 & IR[7] & s6);
assign IOT62x5  = (s0 & IOT & IR[0] & s8 & IR[2] & s4 & IR[7] & s6);
assign IOT62x6  = (s0 & IOT & s7 & IR[1] & IR[2] & s4 & IR[7] & s6);
assign IOT62x7  = (s0 & IOT & IR[0] & IR[1] & IR[2] & s4 & IR[7] & s6);

endmodule
