`timescale 1us/1ns

module SEQUENCER_tb ();
    reg CK,CLEAR;
    reg RUN,HALT,STEPI,STEPC;
    reg NOAUTO,NOIND;
    wire CK_FETCH,  CK_AUTOINC1,  CK_AUTOINC2,  CK_INDIRECT,  CK_1,  CK_2,  CK_3,  CK_4,  CK_5,  CK_6;
    wire STB_FETCH, STB_AUTOINC1, STB_AUTOINC2, STB_INDIRECT, STB_1, STB_2, STB_3, STB_4, STB_5, STB_6;

  SEQUENCER dut(
    .CK(CK),
    .CLEAR(CLEAR),
    .RUN(RUN),
    .HALT(HALT),
    .STEPI(STEPI),
    .STEPC(STEPC),
    .NOAUTO(NOAUTO),
    .NOIND(NOIND),
    .CK_FETCH(CK_FETCH),
    .CK_AUTOINC1(CK_AUTOINC1),
    .CK_AUTOINC2(CK_AUTOINC2),
    .CK_INDIRECT(CK_INDIRECT),
    .CK_1(CK_1),
    .CK_2(CK_2),
    .CK_3(CK_3),
    .CK_4(CK_4),
    .CK_5(CK_5),
    .CK_6(CK_6),
    .STB_FETCH(STB_FETCH),
    .STB_AUTOINC1(STB_AUTOINC1),
    .STB_AUTOINC2(STB_AUTOINC2),
    .STB_INDIRECT(STB_INDIRECT),
    .STB_1(STB_1),
    .STB_2(STB_2),
    .STB_3(STB_3),
    .STB_4(STB_4),
    .STB_5(STB_5),
    .STB_6(STB_6)
  );

    always begin
        #1 CK = ~CK;
    end

  initial begin
    $dumpfile("SEQUENCER.vcd");
    $dumpvars(2);
    CK=0;
    CLEAR=1;
    RUN=1;
    HALT=1;
    STEPI=0;
    STEPC=0;
    NOAUTO=0;
    NOIND=0;
    #4 CLEAR=0;
    #63 CLEAR=1;
    #4 CLEAR=0; NOAUTO=1;
    #51 CLEAR=1;
    #4 CLEAR=0; NOAUTO=0; NOIND=1;
    #47 CLEAR=1;

    #1 $finish;
  end

endmodule
