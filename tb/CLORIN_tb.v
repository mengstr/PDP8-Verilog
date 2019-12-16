`timescale 1us/1ns

module CLORIN_tb();
  reg [11:0] IN;
  reg [7:0] CLR;
  reg [11:0] DOR;
  reg INV;
  wire [11:0] OUT, OUT_;

CLORIN dut(
  .IN(IN),
  .CLR(CLR),
  .DOR(DOR),
  .INV(INV),
  .OUT(OUT)
);

CLORIN_ dut_(
  .IN(IN),
  .CLR(CLR),
  .DOR(DOR),
  .INV(INV),
  .OUT(OUT_)
);


  integer in;
  integer clr;
  integer dor;
  integer inv;
  initial begin
    for (integer i=0; i<100000; i++) begin
      IN  = $urandom % 4096;
      CLR = $urandom % 2;
      DOR = $urandom % 4096;
      INV = $urandom % 2;
      #10;
      if (OUT !== OUT_) $display("OUT (",OUT,"/",OUT_,") @ ","in:",IN," clr:",CLR," dor:",DOR," inv:",INV);
    end
  end
endmodule

