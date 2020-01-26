//
// PROGRAMCOUNTER.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module PROGRAMCOUNTER (
  input RESET,
  input [11:0] IN,
  input CK,
  input LD,
  input LATCH,
  output [11:0] PC,
  output [11:0] PCLAT
);

reg [11:0] thisPC=0;
reg [11:0] thisPCLAT=0;

assign PC=thisPC;
assign PCLAT=thisPCLAT;

always @(posedge CK or posedge RESET) begin 
  if (RESET) begin
    thisPC<=12'o0200;
  end else if (LD) begin
    thisPC<=IN;
  end else begin
    thisPC<=thisPC+1;
  end
end

always @(LATCH or thisPC) begin
  if (LATCH) thisPCLAT = thisPC;
end

endmodule
