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
//
//
// CPU
// ADDAND           comb  [A] [B]             -> [zOUT]
// CLORIN           comb  [IN] CLR [OR] INV   -> [OUT]
// ROTATER          comb  [IN] L              -> [zOUT] L
// OPRDECODER       comb  [IR]                -> opr*
// SKIP             comb  [AC] flags*         -> OUT
// IRDECODER        comb  [PCL] [IR]          -> instType*
// IOTBASEDECODER   comb  [IR]                -> iotRange*
// INCREMENTER      comb  [IN]                -> [zOUT] C
// PROGRAMCOUNTER   seq   [IN]                -> [PC] [PCLAT]
// SEQUENCER
// MULTILATCH
// LINK
// INTERRUPT
// RAM
// TTY
//

`default_nettype none

module CPU(
  input SYSCLK,
  input sw_RESET,    // Clear/reset CPU
  input sw_RUN,      // Start CPU
  input sw_HALT,     // Halt CPU at next instruction
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
reg [11:0] busIRx;
wire [11:0] busData;
wire [11:0] busRamD;
wire [11:0] busRamA;
wire [11:0] busPC;
wire [11:0] busLatPC;
wire [11:0] busPCin;
wire [11:0] busORacc;

  wire irqRq;           // Some device is asserting irq
  wire      irqRqIOT34;
  or(irqRq, irqRqIOT34);

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ SEQUENCER █ ▇ ▆ ▅ ▄ ▂ ▁
//

// Signals from the sequencer
wire ckFetch;
wire ckAutoinc1, ckAutoinc2; 
wire ckIndirect;
wire ck1, ck2, ck3, ck4, ck5, ck6;
wire stbFetch;
wire stbAutoinc1, stbAutoinc2; 
wire stbIndirect;
wire stb1, stb2, stb3, stb4, stb5, stb6;

wire done_;
wire      done05, doneIOT0, doneIOT34, doneOPR1, doneOPR2, doneOPR3A, doneOPR3B, doneOPR3C, doneOPR3D, doneOPR3I, doneOPR3J, doneOPR3K, doneOPR3L;
or(done_, done05, doneIOT0, doneIOT34, doneOPR1, doneOPR2, doneOPR3A, doneOPR3B, doneOPR3C, doneOPR3D, doneOPR3I, doneOPR3J, doneOPR3K, doneOPR3L);

SEQUENCER theSEQUENCER(
    .CLK(SYSCLK),
    .RESET(sw_RESET),
    .RUN(sw_RUN),
    .HALT(sw_HALT),
    .DONE(done_), 
    .SEQTYPE({instIsPPIND,instIsIND}),
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

wire pc_ld_;
wire       pc_ld05;
or(pc_ld_, pc_ld05);

wire pc_ck_;
wire       pc_ckIFI, pc_ck05, pc_ckIOT0, pc_ckIOT34, pc_ckOPR2;
or(pc_ck_, pc_ckIFI, pc_ck05, pc_ckIOT0, pc_ckIOT34, pc_ckOPR2);


PROGRAMCOUNTER thePC(
  .RESET(sw_RESET),
  .IN(busPCin),
  .LD(pc_ld_),
  .CK(pc_ck_),
  .LATCH(ckFetch & (!stbFetch)),
  .PC(busPC),
  .PCLAT(busLatPC)
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ RAM MEMORY █ ▇ ▆ ▅ ▄ ▂ ▁
//
wire ram_oe_;
wire        ram_oeIFI, ram_oe05;
or(ram_oe_, ram_oeIFI, ram_oe05);

wire ram_we_;
wire        ram_weIFI, ram_we05;
or(ram_we_, ram_weIFI, ram_we05);

RAM theRAM(
  .clk(SYSCLK),
  .oe(ram_oe_),
  .we(ram_we_),
  .addr(busRamA), 
  .dataI(busRamD), 
  .dataO(busRamD)
);


assign busData = ckFetch ? busRamD : 12'bzzzzzzzzzzzz;
assign busData = ram_oe_ ? busRamD : 12'bzzzzzzzzzzzz;
always @(negedge SYSCLK) begin
  if (ckFetch) busIR= irqOverride ? 12'o4000 : busData; //FIXME
  if (stbFetch) busIRx= irqOverride ? 12'o4000 : busData; //FIXME
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
wire oprCLA;

OPRDECODER  theOPRDECODER(
  .IR(busIR[8:0]),
  .OPR(instOPR),
  .opr1(opr1), .opr2(opr2), .opr3(opr3),
  .oprIAC(oprIAC), .oprX2(oprX2), .oprLEFT(oprLEFT), .oprRIGHT(oprRIGHT), .oprCML(oprCML), .oprCMA(oprCMA), .oprCLL(oprCLL), // OPR 1
  .oprHLT(oprHLT), .oprOSR(oprOSR), .oprTSTINV(oprTSTINV), .oprSNLSZL(oprSNLSZL), .oprSZASNA(oprSZASNA), .oprSMASPA(oprSMASPA),  // OPR 2
  .oprMQL(oprMQL), .oprSWP(oprSWP), .oprMQA(oprMQA), .oprSCA(oprSCA), // OPR 3 
  .oprSCL(oprSCL), .oprMUY(oprMUY), .oprDVI(oprDVI), .oprNMI(oprNMI), .oprSHL(oprSHL), .oprASL(oprASL), .oprLSR(oprLSR), // OPR 3
  .oprCLA(oprCLA)   // OPR 1,2,3
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

wire mq_ck_;
wire  mq_ckOPR3I, mq_ckOPR3J, mq_ckOPR3K, mq_ckOPR3L;
or (mq_ck_, mq_ckOPR3I, mq_ckOPR3J, mq_ckOPR3K, mq_ckOPR3L);

wire mq_hold_;
wire mq_holdOPR3K, mq_holdOPR3L;
or (mq_hold_, mq_holdOPR3K, mq_holdOPR3L);

wire mq2orbus_;
wire mq2orbusOPR3C, mq2orbusOPR3D, mq2orbusOPR3K, mq2orbusOPR3L;
or (mq2orbus_, mq2orbusOPR3C, mq2orbusOPR3D, mq2orbusOPR3K, mq2orbusOPR3L);

wire [11:0] mqout1;
wire [11:0] mqout2;
MULTILATCH theMQ(
    .RESET(sw_RESET),
    .CLK(SYSCLK),
    .in(accout1),
    .latch(mq_ck_), 
    .hold(mq_hold_),
    .oe1(mq2orbus_), 
    .oe2(1'b1),
    .out1(mqout1), 
    .out2(mqout2)
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ LINK █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire link_ck_;
wire         link_ck05, link_ckIOT0, link_ckOPR1;
or(link_ck_, link_ck05, link_ckIOT0, link_ckOPR1);

wire link;
wire rotaterLI;

LINK theLINK(
  .SYSCLK(SYSCLK),
  .CLEAR(sw_RESET),
  .LINK_CK(link_ck_),
  .CLL(oprCLL | linkclrIOT0),
  .CML(((oprCML ^ (incC & oprIAC)) | (andaddC & instTAD)) | linkcmlIOT0),
  .SET(oprLEFT|oprRIGHT),
  .FROM_ROTATER(rotaterLO),
  .L(link),
  .TO_ROTATER(rotaterLI)
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ ADD/AND █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire ramd2ac_add_, ramd2ac_and_;
wire ramd2ac_and05;
wire ramd2ac_add05;

or(ramd2ac_and_, ramd2ac_and05);
or(ramd2ac_add_, ramd2ac_add05);

wire andaddC;
ADDAND theADDAND(
  .A(accout1),
  .B(busData),
  .CI(1'b0),
  .OE_ADD(ramd2ac_add_),
  .OE_AND(ramd2ac_and_),
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

//
//             +--------------------> theADDAND -->--------------->+
//             ^                                                   v
//             +--> theSkip                                        v
//             ^                                                   v
//             +--> theMQ-+                                        v
//             ^          v                                        v
// +--> theAcc +--> theCLORIN --> theIncrementer --> theRotater -->+
// |                                                               v
// +-<---------------------------<------------------------------<--+
//
//
//      ac2ramd     (perm)        (perm)            rot2ac
//
//

wire ac_ck_;
wire        ac_ck05, ac_ckIOT0, ac_ckOPR1, ac_ckOPR2, ac_ckOPR3B, ac_ckOPR3C, ac_ckOPR3D, ac_ckOPR3I, ac_ckOPR3J, ac_ckOPR3K, ac_ckOPR3L;
or (ac_ck_, ac_ck05, ac_ckIOT0, ac_ckOPR1, ac_ckOPR2, ac_ckOPR3B, ac_ckOPR3C, ac_ckOPR3D, ac_ckOPR3I, ac_ckOPR3J, ac_ckOPR3K, ac_ckOPR3L);

wire ac2ramd_;
wire ac2ramd05;
or (ac2ramd_, ac2ramd05);

wire [11:0] accIn;
wire [11:0] accout1;
MULTILATCH theACC(
    .RESET(sw_RESET),
    .CLK(SYSCLK),
    .in(accIn),
    .latch(ac_ck_),
    .hold(1'b0),
    .oe1(1'b1),
    .oe2(ac2ramd_),
    .out1(accout1), 
    .out2(busData)
);

assign busORacc=
  (oprOSR ? 12'o7777 : 12'o0000) |
  (mq2orbus_ ? mqout1   : 12'o0000) |
  busACGTF;

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ ACC CLORIN █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire claDCA_;
wire         cla05, claO3D, claO3I, claO3J, claO3K, claO3L;
or (claDCA_, cla05, claO3D, claO3I, claO3J, claO3K, claO3L);

wire clorinCLR;
or (clorinCLR, claDCA_, oprCLA, iotCLR0);

wire [11:0] clorinOut;
CLORIN theCLORIN(
  .IN(accout1),
  .CLR(clorinCLR),
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

wire rot2ac_;
wire        rot2ac05, rot2acIOT0, rot2acOPR1, rot2acOPR2, rot2acOPR3B, rot2acOPR3C, rot2acOPR3D, rot2acOPR3I, rot2acOPR3J, rot2acOPR3K, rot2acOPR3L;
or(rot2ac_, rot2ac05, rot2acIOT0, rot2acOPR1, rot2acOPR2, rot2acOPR3B, rot2acOPR3C, rot2acOPR3D, rot2acOPR3I, rot2acOPR3J, rot2acOPR3K, rot2acOPR3L);

wire rotaterLO;
ROTATER theRotater(
  .OP({oprRIGHT,oprLEFT,oprX2}),
  .AI(incOut),
  .LI(rotaterLI),
  .OE(rot2ac_),
  .AO(accIn),
  .LO(rotaterLO)
);



//
// ▁ ▂ ▄ ▅ ▆ ▇ █ INDIRECT REGISTER █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire ind_ck_;
wire        ind_ckIFI;
or(ind_ck_, ind_ckIFI);

wire ind2inc_;
wire          ind2incIFI, ind2reg05;
or (ind2inc_, ind2incIFI, ind2reg05);

wire ind2rama_;
wire          ind2rama05;
or(ind2rama_, ind2rama05);

MULTILATCH theIndReg(
    .RESET(sw_RESET),
    .CLK(SYSCLK),
    .in(busData),
    .latch(ind_ck_),
    .hold(1'b0),
    .oe1(ind2inc_),
    .oe2(ind2rama_),
    .out1(busReg), 
    .out2(busRamA)
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ DATA REGISTER █ ▇ ▆ ▅ ▄ ▂ ▁
//
wire data_ck_;
wire data_ck05;
or (data_ck_ ,data_ck05);

wire ld2inc_;
wire ld2inc05;
or (ld2inc_ ,ld2inc05);

wire [11:0] dummy1;   
MULTILATCH theDataReg(
    .RESET(sw_RESET),
    .CLK(SYSCLK),
    .in(busData),
    .latch(data_ck_),
    .hold(1'b0),
    .oe1(ld2inc_),
    .oe2(1'b0),
    .out1(busReg),
    .out2(dummy1)
);

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ BUS INCREMENTER █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire inc2ramd_;
wire inc2ramdIFI, inc2ramd05;
or (inc2ramd_, inc2ramdIFI, inc2ramd05);

wire incZero;
INCREMENTER theBUSINCREMENTER(
  .IN(busReg),
  .INC(1'b1),
  .OE(inc2ramd_),
  .OUT(busData),
  .C(incZero)
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ BUS INTERCONNECTS █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire ir2pc_;
wire       ir2pc05;
or(ir2pc_, ir2pc05);

wire reg2pc_;
wire reg2pc05;
or (reg2pc_, reg2pc05);


wire ir2rama_;
wire         ir2ramaIFI, ir2rama05;
or(ir2rama_, ir2ramaIFI, ir2rama05);

wire pc2ramd_;
wire          pc2ramd05;
or (pc2ramd_, pc2ramd05);

wire pclat2ramd_;
wire            pclat2ramd05;
or(pclat2ramd_, pclat2ramd05);

assign busPCin=ir2pc_ ? { (instIsMP ? busLatPC[11:7] : 5'b00000) , busIR[6:0]} : 12'bzzzzzzzz; // First OC12 module
assign busPCin=reg2pc_ ? busReg[11:0] : 12'bzzzzzzzz;
//assign busPCin=ind2pc_ ? busReg[11:0] : 12'bzzzzzzzz;
assign busRamA=ir2rama_ ? { (instIsMP ? busLatPC[11:7] : 5'b00000) , busIR[6:0]} : 12'bzzzzzzzz; // Second OC12 module
assign busRamA=ckFetch ? busLatPC : 12'bzzzzzzzzzzzz;
// assign busRamA=reg2rama_ ?  busReg[11:0] : 12'bzzzzzzzz;
assign busRamD=ram_we_ ? busData : 12'bzzzzzzzzzzzz;
assign busRamD=pc2ramd_ ? busPC : 12'bzzzzzzzzzzzz;
assign busRamD=pclat2ramd_ ? busLatPC : 12'bzzzzzzzzzzzz;

INSTFETCHIND theinstFI (
   .stbFetch(stbFetch),
   .ckFetch(ckFetch),
   .instIsIND(instIsIND),
   .instIsPPIND(instIsPPIND),
   .ckIndirect(ckIndirect),
   .stbIndirect(stbIndirect),
   .ckAutoinc1(ckAutoinc1),
   .stbAutoinc2(stbAutoinc2),
   .ckAutoinc2(ckAutoinc2),
   .stbAutoinc1(stbAutoinc1),
  .inc2ramd(inc2ramdIFI),
  .ind_ck(ind_ckIFI),
  .ind2inc(ind2incIFI),
  .ir2rama(ir2ramaIFI),
  .pc_ck(pc_ckIFI),
  .ram_oe(ram_oeIFI),
  .ram_we(ram_weIFI)
);



INST0_5 theinst0_5 (
 .instIsDIR(instIsDIR), .instIsIND(instIsIND), .instIsPPIND(instIsPPIND),
 .instAND(instAND), .instDCA(instDCA), .instISZ(instISZ), .instJMP(instJMP), .instJMS(instJMS), .instTAD(instTAD),
.incZero(incZero),
.irqOverride(irqOverride),
.ck1(ck1), .ck2(ck2), .ck3(ck3), .ck4(ck4), .ck5(ck5),
.stb1(stb1), .stb2(stb2), .stb3(stb3),
.pclat2ramd(pclat2ramd05),
.ac2ramd(ac2ramd05),
.cla(cla05),
.inc2ramd(inc2ramd05),
.data_ck(data_ck05),
.ind2reg(ind2reg05),
.ld2inc(ld2inc05),
.link_ck(link_ck05),
.pc2ramd(pc2ramd05),
.ramd2ac_add(ramd2ac_add05),
.ramd2ac_and(ramd2ac_and05),
.reg2pc(reg2pc05),
.rot2ac(rot2ac05),
.ir2pc(ir2pc05),
.ind2rama(ind2rama05),
.pc_ld(pc_ld05),
.ac_ck(ac_ck05),
.ir2rama(ir2rama05),
.ram_oe(ram_oe05),
.pc_ck(pc_ck05),
.ram_we(ram_we05),
.done(done05)
);



//
// IOT 6xxx
//

// 600x CPU INTERRUPT HANDLING
wire iotCLR0;
wire linkclrIOT0;
wire linkcmlIOT0;
wire [11:0] busACGTF;
wire irqOverride;
INTERRUPT theInterrupt(
  .CLK(SYSCLK),
  .clear(sw_RESET),
  .EN(instIOT & (busIR[8:3]==6'o00)),
  .IR(busIR[2:0]),
  .AC(accout1),
  .LINK(link),
  .ck1(ck1), .ck2(ck2), .ck3(ck3), .ck4(ck4), .ck5(ck5), .ck6(ck6),
  .stbFetch(stbFetch), .stb1(stb1), .stb2(stb2), .stb3(stb3), .stb4(stb4), .stb5(stb5), .stb6(stb6),
  .irqRq(irqRq),
  .done(doneIOT0),
  .rot2ac(rot2acIOT0),
  .ac_ck(ac_ckIOT0),
  .clr(iotCLR0),
  .linkclr(linkclrIOT0),
  .linkcml(linkcmlIOT0),
  .link_ck(link_ckIOT0),
  .pc_ck(pc_ckIOT0),
  .ACGTF(busACGTF),
  .IRQOVERRIDE(irqOverride)
);

// 603x & 604x TTY HANDLING
wire iotCLR34;
TTY theTTY(
  .CLK(SYSCLK),
  .clear(sw_RESET | iotCLR0),
  .EN1(instIOT & (busIR[8:3]==6'o03)),
  .EN2(instIOT & (busIR[8:3]==6'o04)),
  .IR(busIR[2:0]),
  .ACbit11(accout1[0:0]), // PDP has the bit order reversed
  .ck1(ck1), .ck2(ck2), .ck3(ck3), .ck4(ck4), .ck5(ck5), .ck6(ck6),
  .stb1(stb1), .stb2(stb2), .stb3(stb3), .stb4(stb4), .stb5(stb5), .stb6(stb6),
  .done(doneIOT34),
  .pc_ck(pc_ckIOT34),
  .irq(irqRqIOT34)
);


//
// OPR 7xx
//
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
wire O3l=instOPR & opr3 &  oprCLA &  oprMQA & !oprSCA &  oprMQL; // 7721 CLA,SWP
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


