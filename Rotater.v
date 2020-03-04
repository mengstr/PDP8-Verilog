//
// Rotater.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
// Rotater | 1 | 5 | 1 | 1
//

`default_nettype none

module Rotater (
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

assign AO=OE ? Areg : 12'b0;
assign LO=Lreg;

endmodule
