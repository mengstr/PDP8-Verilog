`timescale 1us/1ns

module MULTILATCH_tb ();
    reg [11:0] in;
    reg clear,latch;
    reg oe1,oe2;
    wire [11:0] out1, out2;


  MULTILATCH dut(
    .in(in),
    .clear(clear),
    .latch(latch),
    .oe1(oe1),
    .oe2(oe2),
    .out1(out1),
    .out2(out2)
  );


  initial begin
    $dumpfile("MULTILATCH.vcd");
    $dumpvars(2);
    in=12'h123;
    clear=0;
    latch=0;
    oe1=0;
    oe2=0;
    #2 clear=1;
    #2 clear=0;
    #2 latch=1;
    #1 latch=0;
    #2 oe1=1;
    #2 oe2=1;
    #2 clear=1;
    #2 latch=1;
    #1 latch=0;
    #2 clear=0;
    #2 oe1=0;
    #2 oe2=0;
    #2 $finish;
  end

endmodule
