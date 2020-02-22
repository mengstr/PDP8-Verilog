//
// Link.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
`default_nettype none

module Link (
input clk,
input reset,
input CLEAR,
input LINK_CK,
input CLL,        // Clear link
input CML,        // Complement link
input SET,        // Update L to be FROM_ROTATER
input FROM_ROTATER,
output reg L,
output reg TO_ROTATER
);

reg lastLinkck=0;

always @(posedge clk) begin 
  if (CLEAR) L<=0;
  else begin
    if (LINK_CK & ~lastLinkck) begin
      if (SET==1) L<=FROM_ROTATER;
      else begin
        if (CLL==1 && CML==0) L<=0;
        if (CLL==1 && CML==1) L<=1;
        if (CLL==0 && CML==1) L<=~L;
      end
    end
  end
  TO_ROTATER<=((L&(~CLL))^CML);
  lastLinkck<=LINK_CK;
end



endmodule
  