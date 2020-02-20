//
// UART.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
`default_nettype none

module ClockGen (
  input clk,
  output baudX7,
  output frontRefresh,
  output buttonDelay
);

// Predivide 25Mhz with 23 to 1086956.52 Hz
// Using a x7 oversample clock:
//  []         /1                              0.92 us
//  [0]        /2                              1.84 us
//  [1]        /4  = 38400 baud 271.74 KHz     3.68 us
//  [2]        /8  = 19200 baud 135,87 KHz     7.36 us
//  [3]        /16 = 9600 baud   67.93 KHz    14.72 us
//  [4]        /32 = 4800 baud   33.97 KHz    29.44 us
//  [5]        /64 = 2400 baud   16 98 KHz    58.88 us
//  [6]       /128 = 1200 baud    8.49 KHz   117.76 us
//  [7]       /256 = 600 baud     4.25 KHz   235.52 us
//  [8]       /512 = 300 baud     2.12 KHz   471.04 us
//  [9]      /1024 = 150 baud     1.06 KHz   942.08 us
// [10]      /2048 =  75 baud   530.74 Hz      1.88 ms
// [11]      /4096 =            265.37 Hz      3.76 ms
// [12]      /8192 =            132.69 Hz      7.53 ms
// [13]     /16384 =             66.34 Hz     15.07 ms
// [14]     /32768 =             33.17 Hz     30.14 ms
// [15]     /65536 =             16.59 Hz     60.29 ms
// [16]    /131072 =                         120.58 ms


`ifdef IVERILOG
  parameter BAUDTAP=0;
`else
  parameter BAUDTAP=3;
`endif

reg [5:0] preDiv=0;
parameter PREDIVTOP=23;
reg [16:0] counter=0;
reg lastX7=0;
reg lastFrontRefresh=0;

always @(posedge clk) begin
  preDiv <= preDiv - 1;
  if (preDiv[5]==1) begin
    preDiv <= PREDIVTOP - 2;
    counter <= counter + 1;
  end
  lastX7<=counter[BAUDTAP];
  lastFrontRefresh<=counter[6];
end

assign baudX7=counter[BAUDTAP] & ~lastX7;             // 9600 baud
assign frontRefresh=counter[6] & ~lastFrontRefresh;   // 8.49 KHz
assign buttonDelay=counter[12];   // 7.53 ms

endmodule
