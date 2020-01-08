//
// PDP8 in Verilog for ICE40
//
// Mats Engstrom - mats.engstrom@gmail.com
//

// Bus        Sends to                                  Receives from
// -------------------------------------------------------------------------------------------------------
// [REG]      [PCIN], INCREMENTER                       INDREG, DATAREG
// [IR]       OC12A, OC12B                              IR
// [DATA]     [PCIN], [RAMDATA],IR, INDREG, DATAREG     4000, [RAMDATA], INCREMENTER
// [RAMDATA]  [DATA], MEMORY                            [DATA], MEMORY
// [RAMADDR]  MEMORY                                    [PC], OC12B, INDREG
// [PC]       [DATA], [RAMADDR]                         PC
// [LATPC]    OC12A, OC12B                              PC
// [PCIN]     PC, [REG],                                [DATA], OC12A ,'NEWPC'

`default_nettype none

module CPU(
  input SYSCLK,
  input sw_CLEAR,    // Clear/reset CPU
  input sw_RUN,      // Start CPU
  input sw_HALT,     // Halt CPU at next instruction
  input sw_STEPM,    // Step one micro step
  input sw_STEPI,    // Step one instruction
  output [11:0] pBusPC,
  output [11:0] pBusData,
  output pInstAND, pInstTAD, pInstISZ, pInstDCA, pInstJMS, pInstJMP, pInstIOT, pInstOPR
);
  
  assign pBusPC=busRamA;
  assign pBusData=busRamD;
  assign pInstAND=instAND;
  assign pInstTAD=instTAD;
  assign pInstISZ=instISZ;
  assign pInstDCA=instDCA;
  assign pInstJMS=instJMS;
  assign pInstJMP=instJMP;
  assign pInstIOT=instIOT;
  assign pInstOPR=instOPR;

  // The buses
wire [11:0] busReg;
reg [11:0] busIR;
wire [11:0] busData;
wire [11:0] busRamD;
wire [11:0] busRamA;
wire [11:0] busPC;
wire [11:0] busLatPC;
wire [11:0] busPCin;
wire [11:0] busORacc;

// Generate the PDP clock pulse @ 1/4th of the SYSCLK
reg [1:0] CLKdivider=0;
reg CLK;
always @(posedge SYSCLK) begin
  CLKdivider<=CLKdivider+1;
//  CLK<=(CLKdivider==0);
  CLK<=CLKdivider[1];
end

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ SEQUENCER █ ▇ ▆ ▅ ▄ ▂ ▁
//

// Signals from the sequencer
wire ph1,ph2,ph3;
wire ckFetch;
wire ckAutoinc1, ckAutoinc2; 
wire ckIndirect;
wire ck1, ck2, ck3, ck4, ck5, ck6;
wire stbFetch;
wire stbAutoinc1, stbAutoinc2; 
wire stbIndirect;
wire stb1, stb2, stb3, stb4, stb5, stb6;

SEQUENCER theSEQUENCER(
    .SYSCLK(SYSCLK),
    .CLK(CLK),
    .CLEAR(sw_CLEAR || done), .RUN(sw_RUN), .HALT(sw_HALT), .STEPM(sw_STEPM), .STEPI(sw_STEPI),
    .NOAUTO(1'b1), .NOIND(1'b1),
    .PH1(ph1), .PH2(ph2), .PH3(ph3),
    .CK_FETCH(ckFetch),
    .CK_AUTOINC1(ckAutoinc1), .CK_AUTOINC2(ckAutoinc2), 
    .CK_INDIRECT(ckIndirect),
    .CK_1(ck1), .CK_2(ck2), .CK_3(ck3), .CK_4(ck4), .CK_5(ck5), .CK_6(ck6),
    .STB_FETCH(stbFetch),
    .STB_AUTOINC1(stbAutoinc1), .STB_AUTOINC2(stbAutoinc2),
    .STB_INDIRECT(stbIndirect), 
    .STB_1(stb1), .STB_2(stb2), .STB_3(stb3), .STB_4(stb4), .STB_5(stb5), .STB_6(stb6)
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ PROGRAM COUNTER █ ▇ ▆ ▅ ▄ ▂ ▁
//

PROGRAMCOUNTER thePC(
  .IN(busPCin),
  .CLR(sw_CLEAR),
  .LD(pc_ld),
  .CLK(pc_ck),
  .LATCH1(ckFetch & ph1),
  .LATCH2(1'b0),
  .PC(busPC),
  .PCLAT(busLatPC)
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ RAM MEMORY █ ▇ ▆ ▅ ▄ ▂ ▁
//
wire ram_oe;
or(ram_oe,ram_oe_1,ram_oe_2);
reg ram_oe_1=0, ram_oe_2=0;
reg ram_we=0;

RAM theRAM(
  .clk(SYSCLK),
  .oe(ram_oe),
  .we(ram_we),
  .addr(busRamA), 
  .dataI(busRamD), 
  .dataO(busRamD)
);


assign busData=ckFetch?busRamD:12'bz;
assign busData=ram_oe?busRamD:12'bz;
always @(posedge CLK) begin
  if (ckFetch) busIR<=busData;
end


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ INSTRUCTION DECODER █ ▇ ▆ ▅ ▄ ▂ ▁
//

// IR DECODER outputs
wire instIsPPIND, instIsIND, instIsDIR, instIsMP;
wire instAND, instTAD, instISZ, instDCA, instJMS, instJMP, instIOT, instOPR;

IRDECODER theIRDECODER(
  .PCLATCHED(busLatPC),
  .IR(busIR),
  .PPIND(instIsPPIND), .IND(instIsIND), .DIR(instIsDIR), .MP(instIsMP),
  .AAND(instAND), .TAD(instTAD), .ISZ(instISZ), .DCA(instDCA), .JMS(instJMS), .JMP(instJMP), .IOT(instIOT), .OPR(instOPR)
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ OPERAND DECODER █ ▇ ▆ ▅ ▄ ▂ ▁
//

// OPR DECODER outputs
wire opr1,opr2,opr3;
wire oprIAC, oprX2, oprLEFT, oprRIGHT, oprCML, oprCMA, oprCLL; // OPR 1
wire oprHLT, oprOSR, oprTSTINV, oprSNLSZL, oprSZASNA, oprSMASPA; // OPR 2
wire oprMQL, oprSWP, oprMQA, oprSCA; // OPR 3 
wire oprSCL, oprMUY, oprDVI, oprNMI, oprSHL, oprASL, oprLSR; // OPR 3
wire oprNOP;
wire oprCLA;

OPRDECODER  theOPRDECODER(
  .IR(busIR),
  .OPR(instOPR),
  .opr1(opr1), .opr2(opr2), .opr3(opr3),
  .oprIAC(oprIAC), .oprX2(oprX2), .oprLEFT(oprLEFT), .oprRIGHT(oprRIGHT), .oprCML(oprCML), .oprCMA(oprCMA), .oprCLL(oprCLL), // OPR 1
  .oprHLT(oprHLT), .oprOSR(oprOSR), .oprTSTINV(oprTSTINV), .oprSNLSZL(oprSNLSZL), .oprSZASNA(oprSZASNA), .oprSMASPA(oprSMASPA),  // OPR 2
  .oprMQL(oprMQL), .oprSWP(oprSWP), .oprMQA(oprMQA), .oprSCA(oprSCA), // OPR 3 
  .oprSCL(oprSCL), .oprMUY(oprMUY), .oprDVI(oprDVI), .oprNMI(oprNMI), .oprSHL(oprSHL), .oprASL(oprASL), .oprLSR(oprLSR), // OPR 3
  .oprCLA(oprCLA),  // OPR 1,2,3
  .oprNOP(oprNOP)   // OPR x,3
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ SKIP █ ▇ ▆ ▅ ▄ ▂ ▁
//
wire doSkip;

SKIP theSKIP(
  .AC(accout1),
  .LINK(link),
  .SZASNA(oprSZASNA),
  .SMASPA(oprSMASPA),
  .SNLSZL(oprSNLSZL),
  .TSTINV(oprTSTINV),
  .OUT(doSkip)
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ MQ █ ▇ ▆ ▅ ▄ ▂ ▁
//
reg mq_clr=0;
wire [11:0] mqout1;
wire [11:0] mqout2;
MULTILATCH theMQ(
    .in(accout1),
    .clear(sw_CLEAR | mq_clr),
    .latch(mq_ck), // & oprMQL),
    .hold(mq_hold),
    .oe1(oprMQA),
    .oe2(1'b1),
    .out1(mqout1), 
    .out2(mqout2)
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ LINK █ ▇ ▆ ▅ ▄ ▂ ▁
//
wire link;
wire rotaterLI;

LINK theLINK(
  .SYSCLK(SYSCLK),
  .CLEAR(sw_CLEAR),
  .LINK_CK(link_ck),
  .CLL(oprCLL),
  .CML((oprCML ^ (incC & oprIAC)) | (andaddC & instTAD)),
  .SET(oprLEFT|oprRIGHT),
   .FROM_ROTATER(rotaterLO),
  .L(link),
  .TO_ROTATER(rotaterLI)
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ ADD/AND █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire andaddC;
ADDAND theADDAND(
  .A(accout1),
  .B(busData),
  .CI(1'b0),
  .OE_ADD(ramd2ac_add),
  .OE_AND(ramd2ac_and),
  .S(accIn),
  .CO(andaddC)
);

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ ACCUMULATOR █ ▇ ▆ ▅ ▄ ▂ ▁
//

// CLA      7200  clear AC                                      1
// CLL      7100  clear link                            1

// CMA      7040  complement AC                                   2
// CML      7020  complement link                                 2

// IAC      7001  increment AC                                      3

// RAR      7010  rotate AC and link right one          4
// RAL      7004  rotate AC and link left one           4
// RTR      7012  rotate AC and link right two          4
// RTL      7006  rotate AC and link left two           4
// BSW      7002  swap bytes in AC                      4

wire [11:0] accIn;
wire [11:0] accout1;
MULTILATCH theACC(
    .in(accIn),
    .clear(sw_CLEAR),
    .latch(ac_ck),
    .hold(1'b0),
    .oe1(1'b1),
    .oe2(ac2ramd),
    .out1(accout1), 
    .out2(busData)
);

assign busORacc=
  (oprOSR ? 12'o7777 : 12'o0000) |
  (oprMQA ? mqout1   : 12'o0000)

;

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ ACC CLORIN █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire [11:0] clorinOut;
CLORIN theCLORIN(
  .IN(accout1),
  .CLR({oprCLA, oprMQL, dcaCLA, 5'b00000}),
  .DOR(busORacc),
  .INV(oprCMA),
  .OUT(clorinOut)
);

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ ACC INCREMENTER █ ▇ ▆ ▅ ▄ ▂ ▁
//

//wire [11:0] incOut;
wire [11:0] incOut;
wire incC;
INCREMENTER theINCREMENTER(
  .IN(clorinOut),
  .INC(oprIAC),
  .OE(1'b1),
  .OUT(incOut),
  .C(incC)
);

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ ACC ROTATER █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire rotaterLO;
ROTATER theRotater(
  .OP({oprRIGHT,oprLEFT,oprX2}),
  .AI(incOut),
  .LI(rotaterLI),
  .OE(rot2ac),
  .AO(accIn),
  .LO(rotaterLO)
);


reg done=0;
reg ir2pc=0, ir2rama=0;
reg pc_ld=0, pc_ck=0;
reg ramd2ac_and=0,ramd2ac_add=0;
reg ac2ramd=0;
reg ac_ck=0;
reg link_ck=0;
reg mq_ck=0;
reg mq_hold=0;
reg rot2ac=0;



//
// ▁ ▂ ▄ ▅ ▆ ▇ █ BUS INTERCONNECTS █ ▇ ▆ ▅ ▄ ▂ ▁
//

//wire [11:0] irzp= { (instIsMP ? busLatPC[11:7] : 5'b00000) , busIR[6:0]};
assign busPCin=ir2pc ? { (instIsMP ? busLatPC[11:7] : 5'b00000) , busIR[6:0]} : 12'bzzzzzzzz; // First OC12 module
assign busRamA=ir2rama ? { (instIsMP ? busLatPC[11:7] : 5'b00000) , busIR[6:0]} : 12'bzzzzzzzz; // Second OC12 module
assign busRamA=ckFetch ? busLatPC : 12'bzzzzzzzzzzzz;
assign busRamD=ram_we ? busData : 12'bzzzzzzzzzzzz;


always @* begin
  pc_ck=stbFetch;
  ram_oe_2=ckFetch;
end


// AND 0xxx
always @* begin
  if (instAND && instIsDIR) begin
    ir2rama=ck1;
    ramd2ac_and=ck1;
    ram_oe_1=ck1;
    ac_ck=stb1;
    done=ck2;
  end
end

// TAD 1xx
always @* begin
  if (instTAD && instIsDIR) begin
    ir2rama=ck1;
    ramd2ac_add=ck1;
    ram_oe_1=ck1;

    ac_ck=stb1;
    link_ck=stb1;

    done=ck2;
  end
end

// ISZ 2xx
always @* begin
  if (instISZ ) begin
    done=ck1;
  end
end

// DCA 3xx
reg dcaCLA=0;
always @* begin
  if (instDCA && instIsDIR) begin
    ir2rama=(ck1|ck1);
    ac2ramd=ck1;
    ram_we=stb1;

    dcaCLA=ck2;
//    ir2rama=ck2;
    ram_oe_1=ck2;
    rot2ac=ck2;
    ac_ck=stb2;

    done=ck3;
  end
end

// JMS 4xx
always @* begin
  if (instJMS ) begin
    done=ck1;
  end
end

// JMP 5xx DIRECT
always @* begin
  if (instJMP && instIsDIR) begin
    ir2pc=ck1; 
    pc_ld=ck1;
    pc_ck=stb1;
    done=ck2;
  end
end

// IOT 6xx
always @* begin
  if (instIOT ) begin
    done=ck1;
  end
end

// OPR 7xx
always @* begin
  if (instOPR & opr1) begin
    rot2ac=ck1;
    ac_ck=stb1;
    link_ck=stb1;
    done=ck2;
  end
  if (instOPR & opr2) begin
    rot2ac=(ck1|ck2);
    pc_ck=(stb1&doSkip);
//    rot2ac=ck2;
 //   mq_ck=ck2;
    ac_ck=stb2;
    done=ck3;
  end


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

// Tests from INSTR#1
// 4746 MQ test1  7601 CLAE
// 4753 MQ test2  7401 NOPE
// 4761 MQ test3  7421 MQL
// 4766 MQ test4  7421 MQL 7501 MQA
// 4776 MQ test5  7421 MQL 7501 MQA
// 5005 MQ test6  7421 MQL 7501 MQA
// 5015 MQ test7  7621 CAM 7421 MQL 7501 MQA
// 5027 MQ test8  7701 ACL 7421 MQL 7501 MQA
// 5040 MQ test9  7701 ACL 7421 MQL 7501 MQA
// 5052 MQ test10 7701 ACL 7421 MQL 7501 MQA
// 5070 MQ test11 7701 ACL 7421 MQL 7501 MQA
// 5106 MQ test12 7621 CAM 7521 SWP 7701 ACL
// 5117 MQ test13 7621 CAM 7521 SWP 7701 ACL
// 5131 MQ test14
// 5147 MQ test15
// 5165 MQ test16
// 5175 MQ test17
// 5207 MQ test18



  if (instOPR & opr3) begin
    if (oprCLA | (oprMQA & !oprMQL)) begin
      rot2ac=ck1;
      ac_ck=stb1;
      done=ck2;
    end
    if (!oprCLA & (!oprMQA & oprMQL)) begin
      rot2ac=ck1|ck2;
      mq_ck=stb1;
      ac_ck=stb2;
      done=ck3;
    end
    if (oprCLA & (!oprMQA & oprMQL)) begin
      rot2ac=ck1|ck2;
      mq_ck=stb2;
      ac_ck=stb1;
      done=ck3;
    end
    if (!oprCLA & (oprMQA & oprMQL)) begin
      rot2ac=ck1|ck2;
      mq_hold=stb1;
      ac_ck=stb2;
      mq_ck=stb2;
      done=ck3;
    end
    if (oprCLA & (oprMQA & oprMQL)) begin
      rot2ac=ck1|ck2;
      //mq_hold=stb1;
      ac_ck=stb2;
      mq_clr=stb2;
      done=ck3;
    end
//    rot2ac=(ck1|ck2);
//    mq_ck=stb1 & oprMQL;
//    ac_ck=stb2;
//    done=ck3;
  end

//   if (instOPR & opr3 & (~oprSWP)) begin
//     rot2ac=(ck1|ck2);
//     if (!oprCLA) begin
//       mq_ck=stb1;
//       ac_ck=stb2;
//     end else begin
//       mq_ck=stb2;
//       ac_ck=stb1;
//     end
// //    rot2ac=ck2;
//     done=ck3;
//   end

//   if (instOPR & opr3 & (oprSWP)) begin
//     rot2ac=(ck1|ck2);
//     ac_ck=(stb1 & oprCLA);
//     mq_ck=stb2;
//     ac_ck=stb2;
//     done=ck3;
//   end

end

endmodule


