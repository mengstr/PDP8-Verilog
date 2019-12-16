`default_nettype none

module PROGRAMCOUNTER (
  input [11:0] IN,
  input CLR,
  input LD,
  input CLK,
  input LATCH1,
  input LATCH2,
  output reg [11:0] PC,
  output reg [11:0] PCLAT
);

// reg [11:0] PC;
// reg [11:0] PCLAT;

always @(posedge CLK or posedge CLR) begin
  if (CLR) begin
    PC<=12'o0200;
  end else if (LD) begin
    PC<=IN;
  end else begin
    PC<=PC+1;
  end
end

  always @(LATCH1 or LATCH2 or PC) begin
    if (LATCH1 || LATCH2) PCLAT = PC;
  end

endmodule


