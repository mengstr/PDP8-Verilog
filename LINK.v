//
// LINK.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
`default_nettype none

module LINK (
input SYSCLK,
input RESET,
input CLEAR,
input LINK_CK,
input CLL,        // Clear link
input CML,        // Complement link
input SET,        // Update L to be FROM_ROTATER
input FROM_ROTATER,
output reg L,
output TO_ROTATER
);

always @(posedge LINK_CK or posedge CLEAR) begin 
/* verilator lint_off SYNCASYNCNET */
  // FIXME
  if (CLEAR) L<=0;
/* verilator lint_on SYNCASYNCNET */
  else begin
    if (SET==1) L<=FROM_ROTATER;
    else begin
      if (CLL==1 && CML==0) L<=0;
      if (CLL==1 && CML==1) L<=1;
      if (CLL==0 && CML==1) L<=~L;
    end
  end
end

// assign TO_ROTATER=L;
assign TO_ROTATER=((L&(~CLL))^CML);

endmodule
  