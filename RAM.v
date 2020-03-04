//
// RAM.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
// RAM | 2 | 3 | 1 | 0
//

`default_nettype none

module RAM(
  input clk,
  input oe,
  input we,
  input [11:0] addr, 
  input [11:0] dataI, 
  output [11:0] dataO
);

initial $readmemh("initialRAM.hex", mem);

reg [11:0] mem [0:4095];
reg [11:0] DO;

always @(posedge clk) begin
  if (we) mem[addr] <= dataI;
  if (oe) DO<=mem[addr];
end

assign dataO=oe ? DO : 12'b0;

endmodule
