//
// IR.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
`default_nettype none


module IR(
  input SYSCLK,
  input RESET,
  input ckFetch,
  input [11:0] busData,
  output reg [11:0] busIR
);

reg lastCkFetch=0;

always @(posedge SYSCLK) begin
  if (RESET) begin 
    lastCkFetch<=0;
    busIR<=0;
  end else begin
    if (ckFetch & !lastCkFetch) busIR<=busData;
  end
  lastCkFetch<=ckFetch;
end

endmodule

