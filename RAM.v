`default_nettype none

//
// for i in '0' '1' '2' '3' '4' '5' '6' '7' '8' '9' 'a' 'b' 'c' 'd' 'e' 'f'; do for j in '0' '1' '2' '3' '4' '5' '6' '7' '8' '9' 'a' 'b' 'c' 'd' 'e' 'f'; do for k in '0' '1' '2' '3' '4' '5' '6' '7' '8' '9' 'a' 'b' 'c' 'd' 'e' 'f'; do echo $i$j$k; done; done; done > RAM.initial
//
// ./tape2hexram.sh < ../bin/D0AB-InstTest-1.pt  > RAM.initial.Inst1
// ./tape2hexram.sh < ../bin/D0BB-InstTest-2.pt  > RAM.initial.Inst2
//

module RAM(
  input clk,
  input oe,
  input we,
  input [11:0] addr, 
  input [11:0] dataI, 
  output [11:0] dataO
);

reg [11:0] mem [0:4095];
initial $readmemh("RAM.initial", mem);

always @* begin //@(posedge clk) begin
  if (we) mem[addr] = dataI;
end
assign dataO=oe ? mem[addr] : 12'bz;

endmodule
