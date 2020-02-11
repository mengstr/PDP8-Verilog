//
// InstructionOPR.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module InstructionOPR (
  input ck1, ck2, ck3, ck4, ck5, ck6,
  input stb1,stb2,stb3,stb4,stb5,stb6,
  input doSkip,
  input instOPR,
  input opr1,
  input opr2,
  input opr3,
  input oprCLA,
  input oprMQA,
  input oprMQL,
  input oprSCA,

  output ac_ck,
  output cla,
  output done,
  output link_ck,
  output mq_ck,
  output mq_hold,
  output mq2orbus,
  output pc_ck,
  output rot2ac
);

wire      ac_ckOPR1, ac_ckOPR2, ac_ckOPR3B, ac_ckOPR3C, ac_ckOPR3D, ac_ckOPR3I, ac_ckOPR3J, ac_ckOPR3K, ac_ckOPR3L;
or(ac_ck, ac_ckOPR1, ac_ckOPR2, ac_ckOPR3B, ac_ckOPR3C, ac_ckOPR3D, ac_ckOPR3I, ac_ckOPR3J, ac_ckOPR3K, ac_ckOPR3L);

wire    claO3D, claO3I, claO3J, claO3K, claO3L;
or(cla, claO3D, claO3I, claO3J, claO3K, claO3L);

wire     doneOPR1, doneOPR2, doneOPR3A, doneOPR3B, doneOPR3C, doneOPR3D, doneOPR3I, doneOPR3J, doneOPR3K, doneOPR3L;
or(done, doneOPR1, doneOPR2, doneOPR3A, doneOPR3B, doneOPR3C, doneOPR3D, doneOPR3I, doneOPR3J, doneOPR3K, doneOPR3L);

wire        link_ckOPR1;
or(link_ck, link_ckOPR1);

wire      mq_ckOPR3I, mq_ckOPR3J, mq_ckOPR3K, mq_ckOPR3L;
or(mq_ck, mq_ckOPR3I, mq_ckOPR3J, mq_ckOPR3K, mq_ckOPR3L);

wire        mq_holdOPR3K, mq_holdOPR3L;
or(mq_hold, mq_holdOPR3K, mq_holdOPR3L);

wire         mq2orbusOPR3C, mq2orbusOPR3D, mq2orbusOPR3K, mq2orbusOPR3L;
or(mq2orbus, mq2orbusOPR3C, mq2orbusOPR3D, mq2orbusOPR3K, mq2orbusOPR3L);

wire      pc_ckOPR2;
or(pc_ck, pc_ckOPR2);

wire       rot2acOPR1, rot2acOPR2, rot2acOPR3B, rot2acOPR3C, rot2acOPR3D, rot2acOPR3I, rot2acOPR3J, rot2acOPR3K, rot2acOPR3L;
or(rot2ac, rot2acOPR1, rot2acOPR2, rot2acOPR3B, rot2acOPR3C, rot2acOPR3D, rot2acOPR3I, rot2acOPR3J, rot2acOPR3K, rot2acOPR3L);

    wire OP1=(instOPR & opr1);
    wire OP2=(instOPR & opr2);
    wire O3a=instOPR & opr3 & !oprCLA & !oprMQA & !oprSCA & !oprMQL; // 7401 NOP
    wire O3b=instOPR & opr3 &  oprCLA & !oprMQA & !oprSCA & !oprMQL; // 7601 CLA
    wire O3c=instOPR & opr3 & !oprCLA &  oprMQA & !oprSCA & !oprMQL; // 7501 MQA
    wire O3d=instOPR & opr3 &  oprCLA &  oprMQA & !oprSCA & !oprMQL; // 7701 ACL
    // wire O3e=instOPR & opr3 & !oprCLA & !oprMQA &  oprSCA & !oprMQL;
    // wire O3f=instOPR & opr3 &  oprCLA & !oprMQA &  oprSCA & !oprMQL;
    // wire O3g=instOPR & opr3 & !oprCLA &  oprMQA &  oprSCA & !oprMQL;
    // wire O3h=instOPR & opr3 &  oprCLA &  oprMQA &  oprSCA & !oprMQL;
    wire O3i=instOPR & opr3 & !oprCLA & !oprMQA & !oprSCA &  oprMQL; // 7421 MQL
    wire O3j=instOPR & opr3 &  oprCLA & !oprMQA & !oprSCA &  oprMQL; // 7621 CAM
    wire O3k=instOPR & opr3 & !oprCLA &  oprMQA & !oprSCA &  oprMQL; // 7521 SWP
    wire O3l=instOPR & opr3 &  oprCLA &  oprMQA & !oprSCA &  oprMQL; // 7721 CLA, SWP
    // wire O3m=instOPR & opr3 & !oprCLA & !oprMQA &  oprSCA &  oprMQL;
    // wire O3n=instOPR & opr3 &  oprCLA & !oprMQA &  oprSCA &  oprMQL;
    // wire O3o=instOPR & opr3 & !oprCLA &  oprMQA &  oprSCA &  oprMQL;
    // wire O3p=instOPR & opr3 &  oprCLA &  oprMQA &  oprSCA &  oprMQL;

    //                            1     1      2     2      3     3      4     4      5     5      6     6
    //                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
    assign rot2acOPR1=      OP1&(ck1                                                                        );
    assign ac_ckOPR1=       OP1&(      stb1                                                                 );
    assign link_ckOPR1=     OP1&(      stb1                                                                 );
    assign doneOPR1=        OP1&(           ck2                                                             );

    //                            1     1      2     2      3     3      4     4      5     5      6     6
    //                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
    assign rot2acOPR2=      OP2&(ck1 |        ck2                                                           );
    assign pc_ckOPR2=       OP2&(      stb1 & doSkip                                                        );
    assign ac_ckOPR2=       OP2&(                   stb2                                                    );
    assign doneOPR2=        OP2&(                          ck3                                              );

    //  1--CLA
    //  2--MQA, MQL
    //  3--ALL OTHERS

    //
    // NOP        7401    no operation                      ()
    // CLA        7601    clear AC                          (CLA)
    // MQL        7421    load MQ from AC then clear AC     (MQL)
    // MQA        7501    inclusive OR the MQ with the AC   (MQA)
    // CAM        7621    clear AC and MQ                   (CLA, MQL)
    // SWP        7521    swap AC and MQ                    (MQL,MQA,SWP)
    // ACL        7701    load MQ into AC                   (CLA,MQA)
    // CLA, SWP   7721    load AC from MQ then clear MQ     (CLA,MQL,MQA,SWP)
    //


    // NOP        7401    no operation                      ()
    //                            1     1      2     2      3     3      4     4      5     5      6     6
    //                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
    assign doneOPR3A=        O3a&(ck1                                                                        );


    // CLA        7601    clear AC                          (CLA)
    //                            1     1      2     2      3     3      4     4      5     5      6     6
    //                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
    assign rot2acOPR3B=      O3b&(ck1                                                                        );
    assign ac_ckOPR3B=       O3b&(      stb1                                                                 );
    assign doneOPR3B=        O3b&(             ck2                                                           );


    // MQA        7501    inclusive OR the MQ with the AC   (MQA)
    //                            1     1      2     2      3     3      4     4      5     5      6     6
    //                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
    assign rot2acOPR3C=      O3c&(ck1                                                                        );
    assign mq2orbusOPR3C=    O3c&(ck1);
    assign ac_ckOPR3C=       O3c&(      stb1                                                                 );
    assign doneOPR3C=        O3c&(             ck2                                                           );

    // ACL        7701    load MQ into AC                   (CLA,MQA)
    //                            1     1      2     2      3     3      4     4      5     5      6     6
    //                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
    assign rot2acOPR3D=      O3d&(ck1                                                            );
    assign mq2orbusOPR3D=    O3d&(ck1);
    assign claO3D=           O3d&(ck1                                                                        );
    assign ac_ckOPR3D=       O3d&(      stb1                                                                 );
    assign doneOPR3D=        O3d&(                          ck2                                              );


    // MQL        7421    load MQ from AC then clear AC     (MQL)
    //                            1     1      2     2      3     3      4     4      5     5      6     6
    //                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
    assign rot2acOPR3I=      O3i&(ck1 |        ck2                                                           );
    assign mq_ckOPR3I=       O3i&(      stb1                                                                 );
    assign claO3I=           O3i&(             ck2                                                           );
    assign ac_ckOPR3I=       O3i&(                   stb2                                                    );
    assign doneOPR3I=        O3i&(                          ck3                                              );


    // CAM        7621    clear AC and MQ                   (CLA, MQL)
    //                            1     1      2     2      3     3      4     4      5     5      6     6
    //                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
    assign rot2acOPR3J=      O3j&(ck1 |        ck1                                                           );
    assign mq_ckOPR3J=       O3j&(      stb2                                                                 );
    assign claO3J=           O3j&(             ck1                                                           );
    assign ac_ckOPR3J=       O3j&(                   stb1                                                    );
    assign doneOPR3J=        O3j&(                          ck3                                              );

    // SWP        7521    swap AC and MQ                    (MQL,MQA,SWP)
    //                            1     1      2     2      3     3      4     4      5     5      6     6
    //                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
    assign rot2acOPR3K=      O3k&(ck1 |        ck2 |        ck3                                              );
    assign mq2orbusOPR3K=    O3k&(ck1|ck2|ck3);
    assign mq_holdOPR3K=     O3k&(ck1 |        ck2 |        ck3                                              );
    assign claO3K=           O3k&(             ck2                                                           );
    assign ac_ckOPR3K=       O3k&(                   stb2                                                    );
    assign mq_ckOPR3K=       O3k&(                          ck3                                              );
    assign doneOPR3K=        O3k&(                                       ck4                                 );

    // CLA, SWP   7721    load AC from MQ then clear MQ     (CLA,MQL,MQA,SWP)
    //                            1     1      2     2      3     3      4     4      5     5      6     6
    //                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
    assign rot2acOPR3L=      O3l&(ck1 |        ck2                                                           );
    assign mq2orbusOPR3L=    O3l&(             ck2                                                           );
    assign claO3L=           O3l&(ck1                                                                        );
    assign ac_ckOPR3L=       O3l&(      stb1 |       stb2                                                    );
    assign mq_holdOPR3L=     O3l&(             ck2                                                           );
    assign mq_ckOPR3L=       O3l&(                   stb2                                                    );
    assign doneOPR3L=        O3l&(                          ck3                                              );

endmodule
