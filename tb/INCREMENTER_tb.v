`timescale 1us/1ns

module INCREMENTER_tb();
  reg [11:0] IN;
  reg INC;
  reg OE;
  wire [11:0] OUT, OUT_;
  wire C, C_;

    INCREMENTER dut(
        .IN(IN),
        .INC(INC),
        .OE(OE),
        .OUT(OUT),
        .C(C)
    );

    INCREMENTER_ dut_(
        .IN(IN),
        .INC(INC),
        .OE(OE),
        .OUT(OUT_),
        .C(C_)
    );

  

    integer in,inc,oe;
    initial begin
        for ( in=0; in<4096; in=in+1) begin
            for ( inc=0; inc<2; inc=inc+1) begin
               for ( oe=0; oe<2; oe=oe+1) begin
                    IN = in;
                    INC = inc;
                    OE = oe;
                    #1;
                    if (OUT!=OUT_) $display("OUT (",OUT,",",OUT_,") @ ","IN:",IN,",INC:",INC," OE:",OE);
                    if (C!=C_) $display("C (",C,",",C_,") @ ","IN:",IN,",INC:",INC," OE:",OE);
                end
            end
        end
    end
endmodule

