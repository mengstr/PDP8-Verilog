`default_nettype none

module CLORIN (
  input [11:0] IN,
  input [7:0] CLR,
  input [11:0] DOR,
  input INV,
  output [11:0] OUT
);

  assign OUT=(CLR==8'b00000000) ?               //413
    INV ? (IN|DOR)^12'b111111111111 : (IN|DOR) :
    INV ? (   DOR)^12'b111111111111 : (   DOR) ;

  // wire [11:0] tmp=(CLR==8'b00000000) ? (IN|DOR):(DOR); //417
  // assign OUT=INV?tmp:tmp^12'b111111111111;

  // assign OUT= //420
  //   !INV ?
  //      (CLR!=8'b00000000) ? (DOR):(IN|DOR) :
  //     ((CLR!=8'b00000000) ? (DOR):(IN|DOR))^12'b111111111111 ;

  // assign OUT= //417
  //   INV ?
  //      (CLR==8'b00000000) ? (IN|DOR):(DOR) :
  //     ((CLR==8'b00000000) ? (IN|DOR):(DOR))^12'b111111111111 ;

  // always @* begin                              //420
  //   if (CLR==0) begin
  //     OUT=(IN | DOR) ^ {12{INV}};
  //   end else begin
  //     OUT=DOR ^ {12{INV}};
  //   end
  // end

endmodule



`ifdef TOP
module top(input CLK, inout P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23,P24,P25,P26,P27,P28,P29,P30,P31,P32,P33,P34,P35,P36,P37,P38,P39,P40,P41,P42,P43,P44,P45,P46,P47,P48,P49,P50,P51,P52,P53,P54,P55,P56,P57,P58,P59,P60,P61,P62,P63,P64,P65,P66);
  CLORIN dut(
    {P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11},
    {P12,P13,P14,P15,P16,P17,P18,P19},
    {P20,P21,P22,P23,P24,P25,P26,P27,P28,P29,P30,P31},
    {P32},
    {P33,P34,P35,P36,P37,P38,P39,P40,P41,P42,P43,P44}
  );
endmodule
`endif
