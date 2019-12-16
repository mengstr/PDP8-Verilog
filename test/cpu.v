
`default_nettype none

module top(input SYSCLK, inout P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23,P24,P25,P26,P27,P28,P29,P30,P31,P32,P33,P34,P35,P36,P37,P38,P39,P40,P41,P42,P43,P44,P45,P46,P47,P48,P49,P50,P51,P52,P53,P54,P55,P56,P57,P58,P59,P60,P61,P62,P63,P64,P65,P66);
  CPU dut(
    .SYSCLK(SYSCLK),
    .pBusPC({P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11}),
    .pBusData({P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23})
  );
endmodule



module CPU(
  input SYSCLK,
  output [11:0] pBusPC,
  output [11:0] pBusData
);

  // The main buses
  wire [11:0] busReg;
  wire [11:0] busIR;
  wire [11:0] busData;
  wire [11:0] busRamD;
  wire [11:0] busRamA;
  wire [11:0] busPC;
  wire [11:0] busLatPC;
  wire [11:0] busPCin;

  assign pBusPC=busPC;
  assign pBusData=busData;

  PROGRAMCOUNTER thePC(
    .IN(12'b0),
    .CLR(1'b0),
    .LD(1'b0),
    .CLK(SYSCLK),
    .LATCH1(1'b0),
    .LATCH2(1'b0),
    .PC(busPC),
    .PCLAT(busLatPC)
  );

  RAM theRAM(
    .clk(SYSCLK),
    .oe(1'b1),
    .we(1'b0),
    .addr(busPC), 
    .dataI(12'b0), 
    .dataO(busData)
  );

endmodule



module RAM (
  input clk,
  input oe,
  input we,
  input [11:0] addr, 
  input [11:0] dataI, 
  output [11:0] dataO
);

  reg [11:0] mem [0:4095];
  
  initial $readmemh("RAM.initial", mem);
  
//  assign dataO=oe?mem[addr]:12'bz;

  always @(posedge clk) begin
    if (we) mem[addr] <= dataI;
//    dataO <= mem[addr];
    dataO=oe?mem[addr]:12'bz;
  end

endmodule




module PROGRAMCOUNTER (
  input [11:0] IN,
  input CLR,
  input LD,
  input CLK,
  input LATCH1,
  input LATCH2,
  output [11:0] PC,
  output [11:0] PCLAT
);

  reg [11:0] PC=0;
  reg [11:0] PCLAT=0;

  always @(posedge CLK or posedge CLR) begin
    if (CLR) begin
      PC<=0;
    end else if (LD) begin
      PC<=IN;
    end else begin
      PC<=PC+1;
    end
  end

  always @(LATCH1 or LATCH2 or PC) begin
    if (LATCH1 || LATCH2) PCLAT = PC;
  end

endmodule
