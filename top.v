`default_nettype none

module top(
  input EXTCLK,
  input nBUT1, nBUT2,
  output reg LED1, LED2,
  input RxD, 
  output TxD,
  output GREEN1, GREEN2,
  output RED1, RED2,
  output YELLOW1, YELLOW2,
  output PLED1, PLED2, PLED3, PLED4, PLED5, PLED6,
  input P62,P63,P64
);

reg [15:0] xtalDivider;
always @(posedge EXTCLK) xtalDivider<=xtalDivider+1;

wire REFRESHCLK=xtalDivider[10]; // 100/2024  = 48.82 KHz

`ifdef CLK_50M
wire SYSCLK=xtalDivider[0];  // 100/2     = 50 MHz
`elsif CLK_25M
wire SYSCLK=xtalDivider[1];  // 100/4     = 25 MHz
`elsif CLK_12M
wire SYSCLK=xtalDivider[2];  // 100/8     = 12.5 MHz
`elsif CLK_6M
wire SYSCLK=xtalDivider[3];  // 100/16    = 6.25 MHz
`elsif CLK_3M
wire SYSCLK=xtalDivider[4];  // 100/32    = 3.12 MHz
`elsif CLK_1M
wire SYSCLK=xtalDivider[5];  // 100/64    = 1.56 MHz
`elsif CLK_800K
wire SYSCLK=xtalDivider[6];  // 100/128   = 781.25 KHz
`elsif CLK_400K
wire SYSCLK=xtalDivider[7];  // 100/256   = 390.62 KHz
`elsif CLK_200K
wire SYSCLK=xtalDivider[8];  // 100/512   = 195.31 KHz
`elsif CLK_100K
wire SYSCLK=xtalDivider[9];  // 100/1024  = 97.65 KHz
`elsif CLK_50K
wire SYSCLK=xtalDivider[10]; // 100/2024  = 48.82 KHz
`elsif CLK_24K
wire SYSCLK=xtalDivider[11]; // 100/4096  = 24.41 KHz
`elsif CLK_12K
wire SYSCLK=xtalDivider[12]; // 100/8192  = 12.20 KHz
`elsif CLK_6K
wire SYSCLK=xtalDivider[13]; // 100/16384 = 6.10 KHz
`elsif CLK_3K
wire SYSCLK=xtalDivider[14]; // 100/32768 = 3.05 KHz
`elsif CLK_1K
wire SYSCLK=xtalDivider[15]; // 100/65536 = 1.52 KHz
`endif

CPU dut(
  .SYSCLK(SYSCLK),
  .sw_RESET(~nBUT2),
  .sw_CLEAR(~nBUT2),
  .sw_RUN(~nBUT1), 
  .sw_HALT(0),
  // .pBusPC({P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11}),
  // .pBusData({P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23}),
  // .pInstAND(P24), .pInstTAD(P25), .pInstISZ(P26), .pInstDCA(P27), .pInstJMS(P28), .pInstJMP(P29), .pInstIOT(P30), .pInstOPR(P31),
  .rx(RxD), .tx(TxD),
  .LED1(LED1), .LED2(LED2),
  .REFRESHCLK(REFRESHCLK),
  .GREEN1(GREEN1), .GREEN2(GREEN2),
  .RED1(RED1), .RED2(RED2),
  .YELLOW1(YELLOW1), .YELLOW2(YELLOW2),
  .PLED1(PLED1), .PLED2(PLED2), .PLED3(PLED3), .PLED4(PLED4), .PLED5(PLED5), .PLED6(PLED6)
  );




endmodule


