//
// MultiLatch.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

//
// 12 bit synch clear register with 2 outputs having separate enables
//

module MultiLatch (
  input RESET,
  input CLK, 
  input [11:0] in,
  input hold,
  input latch,
  input latch3,
  input oe1,oe2,oe3,
  output [11:0] out1, out2
);

reg [11:0] data=0;
reg [11:0] data3=0;
reg [11:0] holdreg=0;

always @(posedge CLK) begin
  if (RESET) begin
    holdreg<=0;
    data<=0;
  end else begin
    if (!hold) holdreg<=in;
    if (latch) data<=holdreg;
    if (latch3) data3<=holdreg;
  end
end

wire [11:0] out1a=oe1 ? data : 12'b0;
wire [11:0] out1b=oe3 ? data3 : 12'b0;
assign out1=out1a | out1b;
assign out2=oe2 ? data : 12'b0;

endmodule



//MQ      .in(accout1) .latch(mq_ck)   .hold(mq_hold) .oe1(mq2orbus) .oe2(0)        .out1(mqout1)
//ACC     .in(accIn)   .latch(ac_ck)   .hold(0)       .oe1(1)        .oe2(ac2ramd)  .out1(accout1)     .out2(busData_acc) 
//IndReg  .in(busData) .latch(ind_ck)  .hold(0)       .oe1(ind2inc)  .oe2(ind2rama) .out1(busReg_ind)  .out2(busAddress_ind)
//DataReg .in(busData) .latch(data_ck) .hold(0)       .oe1(ld2inc)   .oe2(0)        .out1(busReg_data)


// mq_ck       // Clock data into MQ register
// mq_hold
// mq2orbus    // Select MQ data into ClrOrInv's OR-bus input
// mqout1      // Data from MQ into ClrOrInv's OR-bus      

// accIn       // Input to AC latch coming either from Rotater or AddAnd
// ac_ck       // Clock/store the input into AC register
// accout1     // (always on) Data from AC going into MQ, AdAnd, ClrOrInv, InstructionIOT600x, InstructionIOT603x
// ac2ramd     // Select AC data into the main data-bus
// busData_acc // Data from AC going into the main data-bus

// busData     // The main data-bus
// ind_ck      // Clock/store the input into the IND register
// ind2inc
// ind2rama
// busReg_ind
// busAddress_ind

// data_ck     // Clock/store the input into the DATA register
// ld2inc
// busReg_data

