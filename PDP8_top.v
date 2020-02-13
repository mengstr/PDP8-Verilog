//
// PDP8_top.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
`default_nettype none

module PDP8_top(
  input EXTCLK,
  input nBUT1, nBUT2,
  output reg LED1, LED2,
  input RxD, 
  output TxD,
  output GREEN1, GREEN2,
  output RED1, RED2,
  output YELLOW1, YELLOW2,
  output PLED1, PLED2, PLED3, PLED4, PLED5, PLED6,
  input SW1, SW2, SW3
);

reg [15:0] xtalDivider;
always @(posedge EXTCLK) xtalDivider<=xtalDivider+1;

wire REFRESHCLK = xtalDivider[10]; // 100M/2048 = 48.82 KHz
wire CLK        = xtalDivider[$clog2(`EXTCLK_DIV)-1]; 

PDP8 cpu(
  .CLK(CLK),
  .sw_RESET(~nBUT2),
  .sw_CLEAR(~nBUT2),
  .sw_RUN(~nBUT1), 
  .sw_HALT(0),
  .rx(RxD), .tx(TxD),
  .LED1(LED1), .LED2(LED2),
  .REFRESHCLK(REFRESHCLK),
  .GREEN1(GREEN1), .GREEN2(GREEN2),
  .RED1(RED1), .RED2(RED2),
  .YELLOW1(YELLOW1), .YELLOW2(YELLOW2),
  .PLED1(PLED1), .PLED2(PLED2), .PLED3(PLED3), .PLED4(PLED4), .PLED5(PLED5), .PLED6(PLED6),
  .SW1(SW1), .SW2(SW2), .SW3(SW3) 
  );




endmodule


