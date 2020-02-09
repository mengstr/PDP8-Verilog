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

reg [2:0] fakepll;
always @(posedge EXTCLK) fakepll<=fakepll+1;
//wire SYSCLK=fakepll[2]; // 100/4=25 MHz
wire SYSCLK=fakepll[2]; // 100/8=12.5 MHz

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
  .GREEN1(GREEN1), .GREEN2(GREEN2),
  .RED1(RED1), .RED2(RED2),
  .YELLOW1(YELLOW1), .YELLOW2(YELLOW2),
  .PLED1(PLED1), .PLED2(PLED2), .PLED3(PLED3), .PLED4(PLED4), .PLED5(PLED5), .PLED6(PLED6)
  );




endmodule


