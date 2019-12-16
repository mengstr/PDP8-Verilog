`timescale 1us/1ns

module PC_tb ();
  reg [11:0] IN;
  reg CLR;
  reg LD;
  reg CLK;
  reg LATCH1;
  reg LATCH2;
  wire [11:0] PC;
  wire [11:0] PCLAT;

  PROGRAMCOUNTER dut(
    .IN(IN),
    .CLR(CLR),
    .LD(LD),
    .CLK(CLK),
    .LATCH1(LATCH1),
    .LATCH2(LATCH2),
    .PC(PC),
    .PCLAT(PCLAT)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    IN=12'h123;
    CLR=0;
    LD=0;
    CLK=0;
    LATCH1=0;
    LATCH2=0;
    #1 CLR=1; #1; CLR=0;
    #1 LD=1; #1; LD=0;
    #1 LD=1; CLK=1; #1; LD=0; CLK=0;
    #1 CLK=1; #1; CLK=0;
    #1 CLK=1; #1; CLK=0;
    #1 LATCH1=1; 
    #1 CLK=1; #1; CLK=0;
    #1 CLK=1; #1; CLK=0;
    #1 LATCH1=0; 
    #1 CLK=1; #1; CLK=0;
    #1 CLK=1; #1; CLK=0;
    #2
    $finish;
  end

endmodule
