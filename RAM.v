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

initial $readmemh("initialRAM.hex", mem);
reg [11:0] mem [0:4095];
reg [11:0] DO;

always @(negedge clk) begin
  if (we) mem[addr] <= dataI;
//  if (we & addr>=12'o2170 & addr<=12'o2177) $display("Writing %o to address %o",dataI, addr);
  if (oe) DO<=mem[addr];
end

assign dataO=oe ? DO : 12'bz;

endmodule
