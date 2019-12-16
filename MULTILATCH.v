`default_nettype none

//
// 12 bit asynch clear register with 2 outputs having separate enables
//

module MULTILATCH (
    input [11:0] in,
    input clear,latch,
    input oe1,oe2,
    output [11:0] out1, out2
);

    reg [11:0] data;
    assign out1=oe1?data:12'bz;
    assign out2=oe2?data:12'bz;

    always @(posedge latch or posedge clear) begin
        if (clear) begin
            data<=0;
        end else begin 
            data<=in;
        end
    end
endmodule



`ifdef TOP
module top(input CLK, inout P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23,P24,P25,P26,P27,P28,P29,P30,P31,P32,P33,P34,P35,P36,P37,P38,P39,P40,P41,P42,P43,P44,P45,P46,P47,P48,P49,P50,P51,P52,P53,P54,P55,P56,P57,P58,P59,P60,P61,P62,P63,P64,P65,P66);
  MULTILATCH dut(
    {P0,P1,P2,P3, P4,P5,P6,P7, P8,P9,P10,P11},
    P12,P13,
    P14,P15,
    {P16,P17,P18,P19, P20,P21,P22,P23, P24,P25,P26,P27},
    {P28,P29,P30,P31, P32,P33,P34,P35, P36,P37,P38,P39}
  );
endmodule
`endif
