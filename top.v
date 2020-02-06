`default_nettype none

module top(
    input SYSCLK,
    output P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,
    P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23,
     output P24,P25,P26,P27,P28,P29,P30,P31,
    //P32,P33,P34,P35,P36,P37,P38,P39,P40,P41,P42,P43,P44,P45,P46,P47,P48,P49,P50,P51,P52,P53,P54,P55,P56,P57,P58,P59,P60,P61,P62
    input P63,P64,P65,P66
);
    CPU dut(
        .SYSCLK(SYSCLK),
        .sw_RESET(P63),
        .sw_CLEAR(P64),
        .sw_RUN(P65), 
        .sw_HALT(P66),
        .pBusPC({P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11}),
       .pBusData({P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23}),
        .pInstAND(P24), .pInstTAD(P25), .pInstISZ(P26), .pInstDCA(P27), .pInstJMS(P28), .pInstJMP(P29), .pInstIOT(P30), .pInstOPR(P31)
    );
endmodule
