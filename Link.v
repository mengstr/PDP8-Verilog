//
// Link.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
`default_nettype none

module Link (
input CLK,
input RESET,
input CLEAR,
input LINK_CK,
input CLL,        // Clear link
input CML,        // Complement link
input SET,        // Update L to be FROM_ROTATER
input FROM_ROTATER,
output reg L,
output reg TO_ROTATER
);

//FIXME should be clocked with CLK not LINK_CK
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

// assign TO_ROTATER=((L&(~CLL))^CML);
wire TO_ROTATER_=((L&(~CLL))^CML);
always @(posedge LINK_CK) begin
  TO_ROTATER<=TO_ROTATER_;
end

endmodule
  