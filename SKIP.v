`default_nettype none

module SKIP (
  input [11:0] AC,
  input LINK,
  input SZASNA,
  input SMASPA,
  input SNLSZL,
  input TSTINV,
  input SK1,
  input SK2,
  input SK3,
  output reg OUT
);

  always @* begin
    if (
      (TSTINV==0 && (AC==0 && SZASNA) || (AC[11]==1 && SMASPA) || (LINK && SNLSZL) )
      ||
      (TSTINV==1 && (AC!=0 && SZASNA) || (AC[11]!=1 && SMASPA) || (!LINK && SNLSZL) )
      ||
      (SK1 || SK2 || SK3) 
    ) begin
        OUT=1;
      end else begin
        OUT=0;
      end
  end

endmodule



`ifdef TOP
module top(input CLK, inout P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23,P24,P25,P26,P27,P28,P29,P30,P31,P32,P33,P34,P35,P36,P37,P38,P39,P40,P41,P42,P43,P44,P45,P46,P47,P48,P49,P50,P51,P52,P53,P54,P55,P56,P57,P58,P59,P60,P61,P62,P63,P64,P65,P66);
  SKIP dut(
    {P0,P1,P2,P3, P4,P5,P6,P7, P8,P9,P10,P11},
    P12,
    P13,
    P14,
    P15,
    P16,
    P17,
    P18,
    P19,
    P20
  );
endmodule
`endif
