//
// Link.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
// Link | 0 | 14 | 0 | 2
//

`default_nettype none

module Link (
input clk,
input reset,
input ck,
input clear1,        // Clear link
input clear2,        // Clear link
input compl1,        // Complement link
input compl2,        // Complement link
input compl3,        // Complement link
input compl4,        // Complement link
input compl5,        // Complement link
input compl6,        // Complement link
input force1,        // Update L to be FROM_ROTATER
input force2,        // Update L to be FROM_ROTATER
input L_input,
output reg L,
output reg TO_ROTATER
);

reg lastCk=0;

wire compl=(((compl1 ^ (compl2 & compl3)) | (compl4 & compl5)) | compl6); 


always @(posedge clk) begin 
  if (reset) L <= 0;
  else begin
    if (ck & ~lastCk) begin
      if ((force1|force2)==1) L <= L_input;
      else begin
        if ((clear1|clear2)==1 && compl==0) L <= 0;
        if ((clear1|clear2)==1 && compl==1) L <= 1;
        if ((clear1|clear2)==0 && compl==1) L <= ~L;
      end
    end
  end
  TO_ROTATER <= (( L & ~(clear1|clear2) ) ^ compl);
  lastCk <= ck;
end

endmodule
  