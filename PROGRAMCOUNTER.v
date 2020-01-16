`default_nettype none

module PROGRAMCOUNTER (
  input [11:0] IN,
  input CLR,
  input LD,
  input CLK,
  input LATCH1,
  input LATCH2,
  output [11:0] PC,
  output [11:0] PCLAT
);

reg [11:0] thisPC=0;
reg [11:0] thisPCLAT=0;

assign PC=thisPC;
assign PCLAT=thisPCLAT;

//always @(posedge CLK) begin // or posedge CLR) begin //FIX1
always @(posedge CLK or posedge CLR) begin 
  if (CLR) begin
    thisPC<=12'o0200;
  end else if (LD) begin
    thisPC<=IN;
  end else begin
    thisPC<=thisPC+1;
  end
end

  always @(LATCH1 or LATCH2 or thisPC) begin
    if (LATCH1 || LATCH2) thisPCLAT = thisPC;
  end

endmodule


