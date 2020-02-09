//
// uart.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
`default_nettype none

module UART (
  input SYSCLK,
  input RESET,
  input [7:0] txData, // data to be transmitted serially onto tx
  input txStb,        // positive going strobe for the txData - 1 SYSCLK
  output tx,          // serial output stream in 8N1 format with high idle
  output txRdy,       // high when the uart is ready to accept new data
  input rx,
  output [7:0] rxData,
  input rxAck,
  output rxRdy
);

//
// ....----------+       +     +     +     +     +     +     +     +     +      +----------....
//          idle | start | lsb | bit | bit | bit | bit | bit | bit | msb | stop | idle
//               +-------+     +     +     +     +     +     +     +     +------+
//

parameter XTAL              = 12_500_000;
// parameter BAUD           = 6_250_000;  // 60
// parameter BAUD           = 3686400;    // 62
// parameter BAUD           = 1843200;    // 65
// parameter BAUD           = 921600;     // 66
// parameter BAUD           = 460800;     // 68
// parameter BAUD           = 230400;     // 69
// parameter BAUD           = 115200;     // 70
// parameter BAUD           = 76800;      // 72
// parameter BAUD           = 19200;      // 74
parameter BAUD           = 9600;       // 76
// parameter BAUD           = 4800;       // 77
// parameter BAUD           = 2400;       // 78
// parameter BAUD           = 1200;       // 80
// parameter BAUD           = 600;        // 81
// parameter BAUD           = 300;        // 82
// parameter BAUD           = 150;        // 84
// parameter BAUD           = 110;        // 84
// parameter BAUD           = 75;         // 85
parameter BAUDDIVIDER8X     = XTAL/(BAUD*8);
parameter BAUDDIVIDER_WIDTH = $clog2(BAUDDIVIDER8X);

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ BAUDRATE DIVIDER █ ▇ ▆ ▅ ▄ ▂ ▁
//

// Divide the SYSCLK down to the 8x baud rate as well as the real baudrate.
// The 8x baud is used to time the midpoint of the samples in the RX handling.

reg [BAUDDIVIDER_WIDTH-1:0] baud8x=0; 
reg baudTick8x=0;
reg [2:0] baudCnt=0;  // Counter to divide the 8xbaud clock to the real baudrate
reg baudTick=0;       // Strobes at baudrate speed - 1 SYSCLK

always @(posedge SYSCLK) begin
  if (RESET) begin
  end
end

always @(posedge SYSCLK) begin
  baud8x <= baud8x + 1;
  if ({32'b0,baud8x}==BAUDDIVIDER8X-1) begin 
    baud8x <= 0;
    baudTick8x <= 1;
  end 
  if (baudTick8x) begin 
    baudTick8x <= 0;
    baudCnt<=baudCnt+1;
    if (baudCnt==0) baudTick<=1;
  end
  if (baudTick) baudTick <= 0;
end

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ UART RECEIVE █ ▇ ▆ ▅ ▄ ▂ ▁
//

//
//
//

reg [3:0] rxCnt=0;
reg [8:0] rxBuf=0;
reg [3:0] nextMiddle=0;
reg rxReady=0;
reg ping=0;

always @(posedge SYSCLK) begin
  if (rxAck) rxReady<=0;
  if (baudTick8x) begin
    if (rxCnt==0) begin
      if (~rx) begin
        // Detected the startbit
        nextMiddle <= 10;
        rxCnt <= rxCnt + 1;
        rxBuf <= 0;
        ping<=1;
        rxReady <= 0;
      end
    end else if (nextMiddle!=0) begin
      nextMiddle <= nextMiddle-1;
    end else begin
      ping<=1;
      rxBuf <= rxBuf >> 1;
      rxBuf[8] <= rx;
      rxCnt <= rxCnt+1;
      nextMiddle <= 7;
      if (rxCnt>8) begin
        rxCnt <= 0;
        rxReady <= 1;
      end

    end
  end
  if (ping) ping<=0;
end

assign rxData = rxBuf[7:0];
assign rxRdy = rxReady;

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ UART TRANSMIT █ ▇ ▆ ▅ ▄ ▂ ▁
//

//
//
//

reg [9:0] txBuf=0;    // The byte being transmitted plus Start and Stop bits
reg [3:0] txCnt=0;    // Counter for the bits of the byte while transmitting
reg txTriggered=0;    // Set high at txStb and low when the transmission starts
                      // at the next baudTick
always @(posedge SYSCLK) begin

  // If upstream wants to send something, store the data and set the triggered 
  // flag to start waiting for the next baudTick
  if (txStb) begin
    txBuf <= {1'b0, ~txData, 1'b1};
    txTriggered <= 1;

  // Check if it's time to start sending the pending data
  end else if (txTriggered & baudTick) begin
    txTriggered <= 0;
    txCnt <= 9;

  // As long as not all bits are sent - output the next bit
  end else if (txCnt>0 & baudTick) begin
    txBuf <= txBuf >> 1;
    txCnt <= txCnt - 1;
  end
end

//
// The TX output stream needs to be inverted since it's stored invered to have the
// remaining (after all bits are sent) zero-value in the register to be outputted as 'one'
// representing the idle state. 
//
// The oring of the txTrigger keeps the TX as idle until the actual sending starts at the
// next baudTick.
//
assign tx=~txBuf[0] | txTriggered;

//
// The ready signal is set already in the stop bit so it can be possible to send data
// back-to-back.  Even is the controller strobes in new data in the middle of the stopbit
// the new transmission will not start unti the next baudTick.
//
// By anding the txTrigger the ready bit will be deactivated as soon as the txStb arrives
//
assign txRdy=(txCnt==0) & ~txTriggered;

endmodule