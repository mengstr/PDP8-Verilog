`timescale 1us/1ns

module ADDAND_tb();
  reg [11:0] A;
  reg [11:0] B;
  reg CI;
  reg OE_ADD;
  reg OE_AND;
  wire [11:0] SA,SA_;
  wire CO,CO_;
  wire [11:0] SB,SB_;

    ADDAND dut(
        .A(A),
        .B(B),
        .CI(CI),
        .OE_ADD(OE_ADD),
        .OE_AND(OE_AND),
        .SA(SA),
        .CO(CO),
        .SB(SB)
    );

    ADDAND_ dut_(
        .A(A),
        .B(B),
        .CI(CI),
        .OE_ADD(OE_ADD),
        .OE_AND(OE_AND),
        .SA(SA_),
        .CO(CO_),
        .SB(SB_)
    );

  

    integer i,a,b,ci,oe_add,oe_and;
    initial begin
        for ( i=0; i<100000; i++) begin
            a=$urandom%4096;
            b=$urandom%4096;
            for ( ci=0; ci<2; ci++) begin
                for ( oe_add=0; oe_add<2; oe_add++) begin
                    for ( oe_and=0; oe_and<2; oe_and++) begin
                        A=a;
                        B=b;
                        CI=ci;
                        OE_ADD = oe_add;
                        OE_AND = oe_and;
                        #1;
                        if (SA!=SA_) $display("SA (",SA,",",SA_,") @ ","A:",A,",B:",B," CI:",CI," OE_ADD:",OE_ADD," OE_AND:",OE_AND);
                        if (SB!=SB_) $display("SB (",SB,",",SB_,") @ ","A:",A,",B:",B," CI:",CI," OE_ADD:",OE_ADD," OE_AND:",OE_AND);
                        if (CO!=CO_) $display("C (",CO,",",CO_,") @ ","A:",A,",B:",B," CI:",CI," OE_ADD:",OE_ADD," OE_AND:",OE_AND);
                    end
                end
            end
        end
    end
endmodule

