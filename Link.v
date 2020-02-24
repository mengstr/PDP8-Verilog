//
// Link.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
`default_nettype none

module Link (
input clk,
input CLEAR,
input L_ck,
input L_clear,        // Clear link
input L_compl,        // Complement link
input L_force,        // Update L to be FROM_ROTATER
input L_input,
output reg L,
output reg TO_ROTATER
);

reg lastCk=0;

always @(posedge clk) begin 
  if (CLEAR) L <= 0;
  else begin
    if (L_ck & ~lastCk) begin
      if (L_force==1) L <= L_input;
      else begin
        if (L_clear==1 && L_compl==0) L <= 0;
        if (L_clear==1 && L_compl==1) L <= 1;
        if (L_clear==0 && L_compl==1) L <= ~L;
      end
    end
  end
  TO_ROTATER <= (( L & ~L_clear ) ^ L_compl);
  lastCk <= L_ck;
end

endmodule
  