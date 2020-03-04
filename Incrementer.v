//
// Incrementer.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
// Incrementer | 1 | 2 | 1 | 1
//

`default_nettype none

module Incrementer (
  input [11:0] IN,
  input INC,
  input OE,
  output [11:0] OUT,
  output C
);

assign OUT=(OE==1 ? IN+{11'b0,INC} : 12'b0);
assign C=(INC==1 && IN==4095);

endmodule
