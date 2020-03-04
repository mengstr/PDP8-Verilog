//
// UART.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
// UART | 0 | 13 | 0 | 11
//

`default_nettype none

module UART (
  input clk,
  input baudX7,
  input [7:0] txData, // data to be transmitted serially onto tx
  input txStb,        // positive going strobe for the txData - 1 CLK
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


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ BAUDRATE DIVIDER █ ▇ ▆ ▅ ▄ ▂ ▁
//

reg baudTick=0;       // Strobes at baudrate speed - 1 CLK

reg [2:0] baud7Xcnt=0;

always @(posedge clk) begin
  if (baudX7) baud7Xcnt <= baud7Xcnt + 1;
  if (baud7Xcnt > 6) begin
    baud7Xcnt <= 0;
    baudTick <= 1;
  end else begin
    baudTick <= 0;
  end
end


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ UART RECEIVE █ ▇ ▆ ▅ ▄ ▂ ▁
//

reg [3:0] rxCnt=0;
reg [8:0] rxBuf=0;
reg [3:0] nextMiddle=0;
reg rxReady=0;

always @(posedge clk) begin
  if (rxAck) rxReady<=0;
  if (baudX7) begin
    if (rxCnt==0) begin
      if (~rx) begin
        // Detected the startbit
        nextMiddle <= 8;
        rxCnt <= rxCnt + 1;
        rxBuf <= 0;
        rxReady <= 0;
      end
    end else if (nextMiddle!=0) begin
      nextMiddle <= nextMiddle-1;
    end else begin
      rxBuf <= rxBuf >> 1;
      rxBuf[8] <= rx;
      rxCnt <= rxCnt+1;
      nextMiddle <= 6;
      if (rxCnt>8) begin
        rxCnt <= 0;
        rxReady <= 1;
      end

    end
  end
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
always @(posedge clk) begin

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