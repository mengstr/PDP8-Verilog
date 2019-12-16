`timescale 1us/1ns

module RAM_tb();
  reg clk;
  reg wen;
  reg [11:0] addr;
  reg [11:0] wdata; 
  wire [11:0] rdata;

  RAM dut(
    .clk(clk),
    .wen(wen),
    .addr(addr),
    .wdata(wdata),
    .rdata(rdata)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    clk=0;
    wen=0;
    addr=0;
    wdata=0;
    #1
    $finish;
  end

endmodule
