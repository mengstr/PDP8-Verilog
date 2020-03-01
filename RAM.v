//
// RAM.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
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

// reg startFix=0;
reg [11:0] mem [0:4095];
reg [11:0] DO;

always @(posedge clk) begin
// always @(negedge clk) begin
  // if (~clk & ~startFix) DO<=mem[addr];
  // startFix<=1;
  if (we) mem[addr] <= dataI;
  if (oe) DO<=mem[addr];
end

assign dataO=oe ? DO : 12'b0;

endmodule
