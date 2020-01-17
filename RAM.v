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
reg [11:0] DO;

initial $readmemh("RAM.initial", mem);

always @(posedge clk) begin
  if (we) begin
    mem[addr] <= dataI;
//    $display("-- Wrote %04o to address %04o --",dataI, addr);
  end
  if (oe) DO<=mem[addr];
//  if (oe) dataO=mem[addr]; else dataO=12'bz;
end

assign dataO=oe ? DO : 12'bz;

endmodule
