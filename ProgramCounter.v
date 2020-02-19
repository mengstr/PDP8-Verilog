//
// ProgramCounter.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module ProgramCounter (
  input CLK,
  input RESET,
  input [11:0] IN,
  input CK,
  input LD,
  input LATCH,
  input FETCH,
  output [11:0] PC,
  output [11:0] PCLAT
);

reg [11:0] thisPC=0;
reg [11:0] thisPCLAT=0;
reg prevLD=0;
reg prevFetch=0;

assign PC=thisPC;
assign PCLAT=thisPCLAT;

always @(posedge CLK) begin 
  if (RESET) begin
    thisPC<=12'o0200;
    thisPCLAT<=12'o0200;
    prevLD<=0;
    prevFetch<=0;
  end else if (LD && !prevLD) begin
    thisPC<=IN;
  end else if (FETCH & !prevFetch) begin
    thisPCLAT<=thisPC;
    thisPC<=thisPC+1;
  end else if (CK & !prevFetch) begin
    thisPC<=thisPC+1;
    if (LATCH) thisPCLAT<=thisPC;
  end

  prevLD<=LD;
  prevFetch<=FETCH;
end


endmodule
