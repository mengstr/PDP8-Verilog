//
// InstructionIOTaddr.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
// InstructionIOTaddr | ? | ? | ? | ?
//

`default_nettype none

module InstructionIOTaddr  (
  input [8:3] IR,
  input IOT,
  output IOT00,
  output IOT03,
  output IOT04
);

assign IOT00 = IOT & (IR==6'o00);
assign IOT03 = IOT & (IR==6'o03);
assign IOT04 = IOT & (IR==6'o04);

endmodule
