//
// ClrOrInv.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module ClrOrInv (
  input [11:0] IN,
  input CLR,
  input [11:0] DOR,
  input INV,
  output [11:0] OUT
);

`ifdef HW
  // 898 44.92 MHz
  wire [11:0] stage1,stage2,stage3;
  assign stage1 = IN & {12{CLR}};
  assign stage2 = stage1 | DOR;
  assign stage3 = stage2 ^ {12{INV}};
  assign OUT    = stage3;
`else
  // 871 46.90 MHz
  assign OUT=(CLR==1'b0) ?
    INV ? (IN|DOR)^12'b111111111111 : (IN|DOR) :
    INV ? (   DOR)^12'b111111111111 : (   DOR) ;
`endif

endmodule
