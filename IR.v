//
// IR.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
`default_nettype none


module IR(
  input CLK,
  input RESET,
  input ckFetch,
  input irqOverride,
  input [11:0] busData,
  output reg [11:0] busIR
);

reg lastCkFetch=0;

always @(posedge CLK) begin
  if (RESET) begin 
    lastCkFetch<=0;
    busIR<=0;
  end else begin
    if (ckFetch & !lastCkFetch) busIR <= irqOverride ? 12'o4000 : busData;
  end
  lastCkFetch<=ckFetch;
end

endmodule

