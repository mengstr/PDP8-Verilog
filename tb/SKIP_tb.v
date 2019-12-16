`timescale 1us/1ns

module SKIP_tb();
    reg [11:0] AC;
    reg LINK;
    reg SZASNA,SMASPA,SNLSZL;
    reg TSTINV;
    reg SK1,SK2,SK3;

    wire OUT,OUT_;

SKIP dut(
  .AC(AC),
  .LINK(LINK),
  .SZASNA(SZASNA),
  .SMASPA(SMASPA),
  .SNLSZL(SNLSZL),
  .TSTINV(TSTINV),
  .SK1(SK1),
  .SK2(SK2),
  .SK3(SK3),
  .OUT(OUT)
);

SKIP_ dut_(
  .AC(AC),
  .LINK(LINK),
  .SZASNA(SZASNA),
  .SMASPA(SMASPA),
  .SNLSZL(SNLSZL),
  .TSTINV(TSTINV),
  .SK1(SK1),
  .SK2(SK2),
  .SK3(SK3),
  .OUT(OUT_)
);


  integer ac;
  integer link;
  integer szasna,smaspa,snlszl;
  integer tstinv;
  integer sk1,sk2,sk3;
  initial begin
    for (ac=0; ac<4096; ac=ac+1) begin
      for (link=0; link<2; link=link+1) begin
        for (szasna=0; szasna<2; szasna=szasna+1) begin
          for (smaspa=0; smaspa<2; smaspa=smaspa+1) begin
            for (snlszl=0; snlszl<2; snlszl=snlszl+1) begin
              for (sk1=0; sk1<2; sk1=sk1+1) begin
                for (sk2=0; sk2<2; sk2=sk2+1) begin
                  for (sk3=0; sk3<2; sk3=sk3+1) begin
                    AC=ac;
                    LINK=link;
                    SZASNA=szasna; SMASPA=smaspa; SNLSZL=snlszl;
                    SK1=sk1;SK2=sk2;SK3=sk3;
                    #1;
                    if(OUT!=OUT_) $display("SKIP @ ","ac:",AC," link:",LINK," szasna,smaspa,snlszl:",szasna,smaspa,snlszl," sk1,sk2,sk3:",sk1,sk2,sk3);
                  end
                end
              end
            end
          end
        end
      end
    end
  end
endmodule

