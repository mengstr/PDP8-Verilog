//
// MultiLatch.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

//
// 12 bit asynch clear register with 2 outputs having separate enables
//

module MultiLatch (
  input RESET,
  input CLK, 
  input [11:0] in,
  input hold,
  input latch,
  input oe1,oe2,
  output [11:0] out1, out2
);

reg [11:0] data=0;
reg [11:0] holdreg=0;

always @(posedge CLK) begin
  if (RESET) begin
    holdreg<=0;
    data<=0;
  end else begin
    if (!hold) holdreg<=in;
    if (latch) data<=holdreg;
  end
end

assign out1=oe1 ? data : 12'b0;
assign out2=oe2 ? data : 12'b0;

endmodule
