//
// Instructions.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module Instructions (
  input instIsDIR, instIsIND, instIsPPIND,
  input instAND, instDCA, instISZ, instJMP, instJMS, instTAD,
  input incZero,
  input irqOverride,
  input ck1, ck2, ck3, ck4, ck5, ck6,
  input stb1,stb2,stb3,stb4,stb5,stb6,
  
  output ac2ramd,
  output cla,
  output inc2ramd,
  output data_ck,
  output ind2reg,
  output ld2inc,
  output link_ck,
  output pc2ramd,
  output ramd2ac_add,
  output ramd2ac_and,
  output reg2pc,
  output rot2ac,
  output ir2pc,
  output ind2rama,
  output pc_ld,
  output ac_ck,
  output ir2rama,
  output ram_oe,
  output pc_ck,
  output ram_we,
  output done
);

wire        ac2ramdDCA1, ac2ramdDCA2;
or(ac2ramd, ac2ramdDCA1, ac2ramdDCA2);

wire    claDCA1, claDCA2;
or(cla, claDCA1, claDCA2);

wire         inc2ramdISZ1, inc2ramdISZ2;
or(inc2ramd, inc2ramdISZ1, inc2ramdISZ2);

wire        data_ckISZ1, data_ckISZ2;
or(data_ck, data_ckISZ1, data_ckISZ2);

wire        ind2regJMP2, ind2regJMS2;
or(ind2reg, ind2regJMP2, ind2regJMS2);

wire       ld2incISZ1, ld2incISZ2;
or(ld2inc, ld2incISZ1, ld2incISZ2);

wire        link_ckTAD1, link_ckTAD2;
or(link_ck, link_ckTAD1, link_ckTAD2);

wire        pc2ramdJMS1, pc2ramdJMS2;
or(pc2ramd, pc2ramdJMS1, pc2ramdJMS2);

wire            ramd2ac_addTAD1, ramd2ac_addTAD2;
or(ramd2ac_add, ramd2ac_addTAD1, ramd2ac_addTAD2);

wire            ramd2ac_andAND1, ramd2ac_andAND2;
or(ramd2ac_and, ramd2ac_andAND1, ramd2ac_andAND2);

wire       reg2pcJMP2, reg2pcJMS2;
or(reg2pc, reg2pcJMP2, reg2pcJMS2);

wire       rot2acDCA1, rot2acDCA2;
or(rot2ac, rot2acDCA1, rot2acDCA2);

wire      ir2pcJMP1, ir2pcJMS1;
or(ir2pc, ir2pcJMP1, ir2pcJMS1);

wire         ind2ramaAND2, ind2ramaDCA2, ind2ramaISZ2, ind2ramaJMS2, ind2ramaTAD2;
or(ind2rama, ind2ramaAND2, ind2ramaDCA2, ind2ramaISZ2, ind2ramaJMS2, ind2ramaTAD2);

wire      pc_ldJMP1 ,pc_ldJMP2 ,pc_ldJMS1 ,pc_ldJMS2;
or(pc_ld, pc_ldJMP1 ,pc_ldJMP2 ,pc_ldJMS1 ,pc_ldJMS2);

wire ac_ckAND1, ac_ckAND2, ac_ckDCA1, ac_ckDCA2, ac_ckTAD1, ac_ckTAD2;
or(ac_ck      , ac_ckAND1, ac_ckAND2, ac_ckDCA1, ac_ckDCA2, ac_ckTAD1, ac_ckTAD2);

wire        ir2ramaAND1, ir2ramaDCA1, ir2ramaISZ1, ir2ramaJMS1, ir2ramaTAD1;
or(ir2rama, ir2ramaAND1, ir2ramaDCA1, ir2ramaISZ1, ir2ramaJMS1, ir2ramaTAD1);

wire       ram_oeAND1 ,ram_oeAND2 ,ram_oeISZ1 ,ram_oeISZ2 ,ram_oeTAD1 ,ram_oeTAD2;
or(ram_oe, ram_oeAND1 ,ram_oeAND2 ,ram_oeISZ1 ,ram_oeISZ2 ,ram_oeTAD1 ,ram_oeTAD2);

wire       pc_ckISZ1 ,pc_ckISZ2, pc_ckJMS1 ,pc_ckJMS2;
or(pc_ck,  pc_ckISZ1 ,pc_ckISZ2, pc_ckJMS1 ,pc_ckJMS2);

wire       ram_weDCA1 ,ram_weDCA2, ram_weISZ1 ,ram_weISZ2 ,ram_weJMS1 ,ram_weJMS2;
or(ram_we, ram_weDCA1 ,ram_weDCA2, ram_weISZ1 ,ram_weISZ2 ,ram_weJMS1 ,ram_weJMS2);

wire     doneAND1 ,doneAND2 ,doneDCA1 ,doneDCA2, doneISZ1 ,doneISZ2 ,doneJMP1 ,doneJMP2 ,doneJMS1 ,doneJMS2 ,doneTAD1 ,doneTAD2;
or(done, doneAND1 ,doneAND2 ,doneDCA1 ,doneDCA2, doneISZ1 ,doneISZ2 ,doneJMP1 ,doneJMP2 ,doneJMS1 ,doneJMS2 ,doneTAD1 ,doneTAD2);


//
// AND 0xxx
//
wire AND1=(instAND && instIsDIR);
wire AND2=(instAND && (instIsIND || instIsPPIND));
//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
assign ir2ramaAND1=     AND1&(ck1                                                                        );
assign ramd2ac_andAND1= AND1&(ck1                                                                        );
assign ram_oeAND1=      AND1&(ck1                                                                        );
assign ac_ckAND1=       AND1&(      stb1                                                                 );
assign doneAND1=        AND1&(             ck2                                                           );

//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
assign ind2ramaAND2=    AND2&(ck1                                                                        );
assign ramd2ac_andAND2= AND2&(ck1                                                                        );
assign ram_oeAND2=      AND2&(ck1                                                                        );
assign ac_ckAND2=       AND2&(      stb1                                                                 );
assign doneAND2=        AND2&(             ck2                                                           );

//
// TAD 1xxx
//
wire TAD1=(instTAD && instIsDIR);
wire TAD2=(instTAD && (instIsIND || instIsPPIND));
//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
assign ir2ramaTAD1=     TAD1&(ck1                                                                        );
assign ramd2ac_addTAD1= TAD1&(ck1                                                                        );
assign ram_oeTAD1=      TAD1&(ck1                                                                        );
assign ac_ckTAD1=       TAD1&(      stb1                                                                 );
assign link_ckTAD1=     TAD1&(      stb1                                                                 );
assign doneTAD1=        TAD1&(             ck2                                                           );

//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
assign ind2ramaTAD2=    TAD2&(ck1                                                                        );
assign ramd2ac_addTAD2= TAD2&(ck1                                                                        );
assign ram_oeTAD2=      TAD2&(ck1                                                                        );
assign ac_ckTAD2=       TAD2&(      stb1                                                                 );
assign link_ckTAD2=     TAD2&(      stb1                                                                 );
assign doneTAD2=        TAD2&(             ck2                                                           );

//
// ISZ 2xxx
//
wire ISZ1=(instISZ && instIsDIR);
wire ISZ2=(instISZ && (instIsIND || instIsPPIND));
//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
assign ram_oeISZ1=      ISZ1&(ck1 |                     ck3                                               );
assign ir2ramaISZ1=     ISZ1&(ck1 |        ck2 |        ck3                                               );
assign data_ckISZ1=     ISZ1&(      stb1                                                                  );
assign ld2incISZ1=      ISZ1&(      stb1 | ck2 |        ck3 |        ck4                                  );
assign ram_weISZ1=      ISZ1&(             ck2                                                            );
assign inc2ramdISZ1=    ISZ1&(             ck2                                                            );
assign pc_ckISZ1=       ISZ1&(                                       stb4 & incZero                        );
assign doneISZ1=        ISZ1&(                                                    ck5                     );

//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
assign ram_oeISZ2=      ISZ2&(ck1 |                     ck3                                               );
assign ind2ramaISZ2=    ISZ2&(ck1 |        ck2 |        ck3                                               );
assign data_ckISZ2=     ISZ2&(      stb1                                                                  );
assign ld2incISZ2=      ISZ2&(      stb1 | ck2 |        ck3 |        ck4                                  );
assign ram_weISZ2=      ISZ2&(             ck2                                                            );
assign inc2ramdISZ2=    ISZ2&(             ck2                                                            );
assign pc_ckISZ2=       ISZ2&(                                       stb4 & incZero                        );
assign doneISZ2=        ISZ2&(                                                    ck5                     );

//
// DCA 3xxx
//
wire DCA1=(instDCA && instIsDIR);
wire DCA2=(instDCA && (instIsIND || instIsPPIND));
//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
assign ir2ramaDCA1=     DCA1&(ck1                                                                        );
assign ac2ramdDCA1=     DCA1&(ck1                                                                        );
assign ram_weDCA1=      DCA1&(       stb1                                                                );
assign claDCA1=         DCA1&(              ck2                                                          );
assign rot2acDCA1=      DCA1&(              ck2                                                          );
assign ac_ckDCA1=       DCA1&(                    stb2                                                   );
assign doneDCA1=        DCA1&(                           ck3                                             );

//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
assign ind2ramaDCA2=    DCA2&(ck1                                                                        );
assign ac2ramdDCA2=     DCA2&(ck1                                                                        );
assign ram_weDCA2=      DCA2&(       stb1                                                                );
assign claDCA2=         DCA2&(              ck2                                                          );
assign rot2acDCA2=      DCA2&(              ck2                                                          );
assign ac_ckDCA2=       DCA2&(                    stb2                                                   );
assign doneDCA2=        DCA2&(                           ck3                                             );

//
// JMS 4xxx
//
wire JMS1=(instJMS && instIsDIR);
wire JMS2=(instJMS && (instIsIND || instIsPPIND));
//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
assign ir2ramaJMS1=     JMS1&(ck1                                                                        ); 
assign pc2ramdJMS1=     JMS1&(ck1                                                                        );
assign ram_weJMS1=      JMS1&(stb1                                                                       );
assign ir2pcJMS1=       JMS1&(             ck2                                                                        ); 
assign pc_ldJMS1=       JMS1&(             ck2                                                                        );
assign pc_ckJMS1=       JMS1&(                                stb3                                                    );
assign doneJMS1=        JMS1&(                                       ck4                                              );

//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
assign ind2ramaJMS2=    JMS2&(ck1|         ck2                                                                    );
assign pc2ramdJMS2=     JMS2&(ck1                                                                        );
assign ram_weJMS2=      JMS2&(      stb1                                                                       );
assign ind2regJMS2=     JMS2&(ck1|         ck2                                                                    );
assign reg2pcJMS2=      JMS2&(ck1|         ck2                                                                    );
assign pc_ldJMS2=       JMS2&(             ck2                                                                        );
assign pc_ckJMS2=       JMS2&(                                stb3                                                    );
assign doneJMS2=        JMS2&(                                       ck4                                              );


//
// JMP 5xxx DIRECT
//
wire JMP1=(instJMP && instIsDIR);
wire JMP2=(instJMP && (instIsIND || instIsPPIND));
//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
assign ir2pcJMP1=       JMP1&(ck1                                                                        ); 
assign pc_ldJMP1=       JMP1&(      stb1                                                                 );
assign doneJMP1=        JMP1&(             ck2                                                           );

//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
assign ind2regJMP2=     JMP2&(ck1                                                                        );
assign reg2pcJMP2=      JMP2&(ck1                                                                        );
assign pc_ldJMP2=       JMP2&(      stb1                                                                 );
assign doneJMP2=        JMP2&(             ck2                                                           );

endmodule
