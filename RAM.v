//
// RAM.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
`default_nettype none


module RAM(
  input clk,oe,we,
  input [11:0] addr, 
  input [11:0] dataI, 
  output [11:0] dataO
);

initial $readmemh("RAM.initial", mem);
reg [11:0] mem [0:4095];
reg [11:0] DO;

always @(negedge clk) begin
  if (we) mem[addr] <= dataI;
  if (oe) DO<=mem[addr];
end

assign dataO=oe ? DO : 12'bz;

endmodule

//
// for i in '0' '1' '2' '3' '4' '5' '6' '7' '8' '9' 'a' 'b' 'c' 'd' 'e' 'f'; do for j in '0' '1' '2' '3' '4' '5' '6' '7' '8' '9' 'a' 'b' 'c' 'd' 'e' 'f'; do for k in '0' '1' '2' '3' '4' '5' '6' '7' '8' '9' 'a' 'b' 'c' 'd' 'e' 'f'; do echo $i$j$k; done; done; done > RAM.initial
//
// ./tape2hexram.sh < ../bin/D0AB-InstTest-1.pt  > RAM.initial.Inst1
// ./tape2hexram.sh < ../bin/D0BB-InstTest-2.pt  > RAM.initial.Inst2
//