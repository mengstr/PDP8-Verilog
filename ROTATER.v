//
// ROATAER.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module ROTATER (
  input [2:0] OP,
  input [11:0] AI,
  input LI,
  input OE,
  output [11:0] AO,
  output LO
);

  reg [11:0] Areg;
  reg Lreg;

  always @* begin
  case({OP[2],OP[1],OP[0]})
    3'b001: begin // Swap
              Areg={AI[5:0],AI[11:6]};
              Lreg=LI;
            end
    3'b010: begin // Shift left 1 step
              Areg={AI[10:0],LI};
              Lreg=AI[11];
              end
    3'b011: begin // Shift left 2 steps
              Areg={AI[9:0],LI,AI[11]};
              Lreg=AI[10];
              end
    3'b100: begin // Shift right 1 step
              Areg={LI,AI[11:1]};
              Lreg=AI[0];
              end
    3'b101: begin // Shift right 2 steps
              Areg={AI[0],LI,AI[11:2]};
              Lreg=AI[1];
              end
    default: begin
                Areg=AI;
                Lreg=LI;
              end
    endcase
  end

  assign AO=OE ? Areg : 12'bzzzzzzzzzzzz;
  assign LO=Lreg;

endmodule



`ifdef TOP
module top(input SYSCLK, inout P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23,P24,P25,P26,P27,P28,P29,P30,P31,P32,P33,P34,P35,P36,P37,P38,P39,P40,P41,P42,P43,P44,P45,P46,P47,P48,P49,P50,P51,P52,P53,P54,P55,P56,P57,P58,P59,P60,P61,P62,P63,P64,P65,P66);
  ROTATER dut(
    {P0,P1,P2},
    {P3,P4,P5,P6, P7,P8,P9,P10, P11,P12,P13,P14},
    P15,
    P16,
    {P17,P18,P19,P20, P21,P22,P23,P24, P25,P26,P27,P28},
    P29
  );
endmodule
`endif
