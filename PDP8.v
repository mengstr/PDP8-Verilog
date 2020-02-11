//
// PDP8 in Verilog for ICE40
//
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module PDP8(
  input CLK,
  input sw_RESET,    // Reset CPU (power on reset)
  input sw_CLEAR,    // Clear CPU (button)
  input sw_RUN,      // Start CPU
  input sw_HALT,     // Halt CPU at next instruction
  output LED1, LED2,
  // UART
  input rx,
  output tx,
  // FrontPanel
  input  REFRESHCLK,
  output GREEN1, GREEN2,
  output RED1, RED2,
  output YELLOW1, YELLOW2,
  output PLED1, PLED2, PLED3, PLED4, PLED5, PLED6
);


// The buses
wire [11:0] busReg;
reg [11:0] busIR;
wire [11:0] busData;
wire [11:0] busAddress;
wire [11:0] busPC;
wire [11:0] busLatPC;
wire [11:0] busPCin;
wire [11:0] busORacc;

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ FRONT PANEL █ ▇ ▆ ▅ ▄ ▂ ▁
//

FrontPanel thePanel(
  .REFRESHCLK(REFRESHCLK),
  .green(busLatPC),
  .red(busIR),
  .yellow(accout1),
  .GREEN1(GREEN1), .GREEN2(GREEN2),
  .RED1(RED1), .RED2(RED2),
  .YELLOW1(YELLOW1), .YELLOW2(YELLOW2),
  .PLED1(PLED1), .PLED2(PLED2), .PLED3(PLED3), .PLED4(PLED4), .PLED5(PLED5), .PLED6(PLED6)
 );

wire irqRq;           // Some device is asserting irq
wire      irqRqIOT34;
or(irqRq, irqRqIOT34);

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ SEQUENCER & START/STOP █ ▇ ▆ ▅ ▄ ▂ ▁
//
wire ckFetch, ckAuto1, ckAuto2, ckInd;
wire ck1, ck2, ck3, ck4, ck5, ck6;
wire stbFetch, stbAuto1, stbAuto2, stbInd;
wire stb1, stb2, stb3, stb4, stb5, stb6;

wire done_;
wire      done05, doneIOT0, doneIOT34, done7, doneIgnore;
or(done_, done05, doneIOT0, doneIOT34, done7, doneIgnore);
 
Sequencer theSEQUENCER(
  .CLK(CLK),
  .RESET(sw_RESET),
  .RUN(sw_RUN),
  .HALT(sw_HALT | (oprHLT & ck2)),
  .DONE(done_), 
  .SEQTYPE({instIsPPIND,instIsIND}),
  .CK_FETCH(ckFetch), .CK_AUTO1(ckAuto1), .CK_AUTO2(ckAuto2), .CK_IND(ckInd),
  .CK_1(ck1), .CK_2(ck2), .CK_3(ck3), .CK_4(ck4), .CK_5(ck5), .CK_6(ck6),
  .STB_FETCH(stbFetch), .STB_AUTO1(stbAuto1), .STB_AUTO2(stbAuto2), .STB_IND(stbInd), 
  .STB_1(stb1), .STB_2(stb2), .STB_3(stb3), .STB_4(stb4), .STB_5(stb5), .STB_6(stb6),
  .running(LED1)
);

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ PROGRAM COUNTER █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire pc_ld_;
wire       pc_ld05;
or(pc_ld_, pc_ld05);

wire pc_ck_;
wire       pc_ckIFI, pc_ck05, pc_ckIOT0, pc_ckIOT34, pc_ck7;
or(pc_ck_, pc_ckIFI, pc_ck05, pc_ckIOT0, pc_ckIOT34, pc_ck7);

ProgramCounter thePC(
  .CLK(CLK),
  .RESET(sw_RESET),
  .IN(busPCin),
  .LD(pc_ld_),
  .CK(pc_ck_ & ~(inIrq & ckFetch)),
  .LATCH(1'b0),
  .FETCH(ckFetch & ~inIrq),
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
  .clk(CLK),
  .oe(ram_oe_),
  .we(ram_we_),
  .addr(busAddress), 
  .dataI(busData),
  .dataO(busData) 
);

// wire i=theInterrupt.flgGIE & (!theInterrupt.flgNoInt);
// reg ckF=0;
// always @(posedge CLK) begin
// //  if (ckFetch) busIR<= busData;
//   if (instJMS & ck2 & i & irqRq) theInterrupt.flgGIE<=0;
//   if (ckFetch & !ckF) busIR<= (i & irqRq) ? 12'o4000 : busData;
//   ckF<=ckFetch;
// end

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ IR █ ▇ ▆ ▅ ▄ ▂ ▁
//
IR theIR(
  .CLK(CLK),
  .RESET(sw_RESET),
  .ckFetch(ckFetch),
  .busData(irqOverride ? 12'o4000 : busData),
  .busIR(busIR)
);

wire inIrq=(busIR==12'o4000) | irqOverride;


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ INSTRUCTION DECODER █ ▇ ▆ ▅ ▄ ▂ ▁
//

// IR DECODER outputs
wire instIsPPIND, instIsIND, instIsDIR, instIsMP;
wire instAND, instTAD, instISZ, instDCA, instJMS, instJMP, instIOT, instOPR;

IRdecode theIRDECODER(
  .RESET(sw_RESET),
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

OPRdecoder  theOPRDECODER(
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

Skip theSKIP(
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
wire        mq_ck7;
or (mq_ck_, mq_ck7);

wire mq_hold_;
wire          mq_hold7;
or (mq_hold_, mq_hold7);

wire mq2orbus_;
wire mq2orbus7;
or (mq2orbus_, mq2orbus7);

wire [11:0] mqout1;
/* verilator lint_off PINMISSING */
MultiLatch theMQ(
  .RESET(sw_RESET),
  .CLK(CLK),
  .in(accout1),
  .latch(mq_ck_), 
  .hold(mq_hold_),
  .oe1(mq2orbus_), 
  .oe2(1'b1),
  .out1(mqout1) 
//  .out2(mqout2)
);
/* verilator lint_on PINMISSING */


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ LINK █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire link_ck_;
wire         link_ck05, link_ckIOT0, link_ck7;
or(link_ck_, link_ck05, link_ckIOT0, link_ck7);

wire link;
wire rotaterLI;

Link theLINK(
  .CLK(CLK),
  .RESET(sw_RESET),
  .CLEAR(sw_RESET), //FIXME
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
wire [11:0] accIn_andadd;
AddAnd theADDAND(
  .A(accout1),
  .B(busData),
  .CI(1'b0),
  .OE_ADD(ramd2ac_add_),
  .OE_AND(ramd2ac_and_),
  .S(accIn_andadd),
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
wire        ac_ck05, ac_ckIOT0, ac_ck7, ac_ckTTY;
or (ac_ck_, ac_ck05, ac_ckIOT0, ac_ck7, ac_ckTTY);

wire ac2ramd_;
wire ac2ramd05;
or (ac2ramd_, ac2ramd05);

wire [11:0] accIn;
or(accIn, accIn_andadd, accIn_rotater);

wire [11:0] accout1;
MultiLatch theACC(
  .RESET(sw_RESET),
  .CLK(CLK),
  .in(accIn),
  .latch(ac_ck_),
  .hold(1'b0),
  .oe1(1'b1),
  .oe2(ac2ramd_),
  .out1(accout1), 
  .out2(busData)
);

assign busORacc=
  (oprOSR ? 12'o`OSR : 12'o0000) |
  (mq2orbus_ ? mqout1   : 12'o0000) |
  busACGTF |
  busACTTY;

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ ACC CLORIN █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire claDCA_;
wire         cla05, cla7;
or (claDCA_, cla05, cla7);

wire clorinCLR;
or (clorinCLR, claDCA_, oprCLA, iotCLR0, clrTTY);

wire [11:0] clorinOut;
ClrOrInv theCLORIN(
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
Incrementer theINCREMENTER(
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
wire        rot2ac05, rot2acIOT0, rot2ac7, rot2acTTY;
or(rot2ac_, rot2ac05, rot2acIOT0, rot2ac7, rot2acTTY);

wire rotaterLO;
wire [11:0] accIn_rotater;
Rotater theRotater(
  .OP({oprRIGHT,oprLEFT,oprX2}),
  .AI(incOut),
  .LI(rotaterLI),
  .OE(rot2ac_),
  .AO(accIn_rotater),
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

MultiLatch theIndReg(
  .RESET(sw_RESET),
  .CLK(CLK),
  .in(busData),
  .latch(ind_ck_),
  .hold(1'b0),
  .oe1(ind2inc_),
  .oe2(ind2rama_),
  .out1(busReg), 
  .out2(busAddress)
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

/* verilator lint_off PINMISSING */
MultiLatch theDataReg(
  .RESET(sw_RESET),
  .CLK(CLK),
  .in(busData),
  .latch(data_ck_),
  .hold(1'b0),
  .oe1(ld2inc_),
  .oe2(1'b0),
  .out1(busReg)
//  .out2(dummy1)
);
/* verilator lint_on PINMISSING */

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ BUS INCREMENTER █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire inc2ramd_;
wire inc2ramdIFI, inc2ramd05;
or (inc2ramd_, inc2ramdIFI, inc2ramd05);

wire incZero;
Incrementer theBUSINCREMENTER(
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

assign busPCin    = ir2pc_ ? { (instIsMP ? busLatPC[11:7] : 5'b00000) , busIR[6:0]} : 12'bzzzzzzzz; // First OC12 module
assign busPCin    = reg2pc_ ? busReg[11:0] : 12'bzzzzzzzz;

// assign busAddress=ckFetch ? busLatPC : 12'bzzzzzzzzzzzz;
assign busAddress = ir2rama_ ? { (instIsMP ? busLatPC[11:7] : 5'b00000) , busIR[6:0]} : 12'bzzzzzzzz; // Second OC12 module
assign busAddress = ckFetch ? busPC : 12'bzzzzzzzzzzzz;

assign busData    = pc2ramd_ ? busPC : 12'bzzzzzzzzzzzz;
assign busData    = pclat2ramd_ ? busLatPC : 12'bzzzzzzzzzzzz;

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ INSTRUCTION HANDLING - FETCH & INDEXING █ ▇ ▆ ▅ ▄ ▂ ▁
//

InstructionFetch theinstFI (
   .instIsIND(instIsIND),
   .instIsPPIND(instIsPPIND),
   .ckFetch(ckFetch), .ckAuto1(ckAuto1), .ckAuto2(ckAuto2), .ckInd(ckInd),
   .stbFetch(stbFetch), .stbAuto2(stbAuto2), .stbAuto1(stbAuto1), .stbInd(stbInd),
  .irqOverride(irqOverride),
  .inc2ramd(inc2ramdIFI),
  .ind_ck(ind_ckIFI),
  .ind2inc(ind2incIFI),
  .ir2rama(ir2ramaIFI),
  .pc_ck(pc_ckIFI),
  .ram_oe(ram_oeIFI),
  .ram_we(ram_weIFI)
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ INSTRUCTION HANDLING - 7xxx OPR █ ▇ ▆ ▅ ▄ ▂ ▁
//

InstructionOPR theinst7 (
  .ck1(ck1),   .ck2(ck2),   .ck3(ck3),   .ck4(ck4),   .ck5(ck5),   .ck6(ck6),
  .stb1(stb1), .stb2(stb2), .stb3(stb3), .stb4(stb4), .stb5(stb5), .stb6(stb6),
  .doSkip(doSkip),
  .instOPR(instOPR),
  .opr1(opr1),
  .opr2(opr2),
  .opr3(opr3),
  .oprCLA(oprCLA),
  .oprMQA(oprMQA),
  .oprMQL(oprMQL),
  .oprSCA(oprSCA),

  .ac_ck(ac_ck7),
  .cla(cla7),
  .done(done7),
  .link_ck(link_ck7),
  .mq_ck(mq_ck7),
  .mq_hold(mq_hold7),
  .mq2orbus(mq2orbus7),
  .pc_ck(pc_ck7),
  .rot2ac(rot2ac7)
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ INSTRUCTION HANDLING - 0,1,2,3,4,5xxx  █ ▇ ▆ ▅ ▄ ▂ ▁
//
Instructions theinst0_5 (
 .instIsDIR(instIsDIR), .instIsIND(instIsIND), .instIsPPIND(instIsPPIND),
 .instAND(instAND), .instDCA(instDCA), .instISZ(instISZ), .instJMP(instJMP), .instJMS(instJMS), .instTAD(instTAD),
  .incZero(incZero),
  .irqOverride(irqOverride),
  .ck1(ck1),   .ck2(ck2),   .ck3(ck3),   .ck4(ck4),   .ck5(ck5),   .ck6(ck6),
  .stb1(stb1), .stb2(stb2), .stb3(stb3), .stb4(stb4), .stb5(stb5), .stb6(stb6),
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
// ▁ ▂ ▄ ▅ ▆ ▇ █ INSTRUCTION HANDLING - 600x IOT CPU/INT █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire iotCLR0;
wire linkclrIOT0;
wire linkcmlIOT0;
wire [11:0] busACGTF;
wire irqOverride;
wire GIE;

InstructionIOT600x theInterrupt(
  .CLK(CLK),
  .RESET(sw_RESET),
  .CLEAR(sw_CLEAR),
  .EN(instIOT & (busIR[8:3]==6'o00)),
  .IR(busIR[2:0]),
  .AC(accout1),
  .LINK(link),
  .ckFetch(ckFetch), .ck1(ck1),   .ck2(ck2),   .ck3(ck3),   .ck4(ck4),   .ck5(ck5),   .ck6(ck6),
  .stbFetch(stbFetch), .stb1(stb1), .stb2(stb2), .stb3(stb3), .stb4(stb4), .stb5(stb5), .stb6(stb6),
  .irqRq(irqRq),
  .anyDone(done_),
  .done(doneIOT0),
  .rot2ac(rot2acIOT0),
  .ac_ck(ac_ckIOT0),
  .clr(iotCLR0),
  .linkclr(linkclrIOT0),
  .linkcml(linkcmlIOT0),
  .link_ck(link_ckIOT0),
  .pc_ck(pc_ckIOT0),
  .ACGTF(busACGTF),
  .GIE(GIE),
  .irqOverride(irqOverride)
);

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ INSTRUCTION HANDLING - 603x/604x IOT TTY █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire [11:0] busACTTY;
wire clrTTY;
InstructionIOT603x theTTY(
  .CLK(CLK),
  .clear(sw_RESET | iotCLR0),
  .EN1(instIOT & (busIR[8:3]==6'o03)),
  .EN2(instIOT & (busIR[8:3]==6'o04)),
  .IR(busIR[2:0]),
  .AC(accout1), //.ACbit11(accout1[0:0]), // PDP has the bit order reversed
  .ck1(ck1),   .ck2(ck2),   .ck3(ck3),   .ck4(ck4),   .ck5(ck5),   .ck6(ck6),
  .stb1(stb1), .stb2(stb2), .stb3(stb3), .stb4(stb4), .stb5(stb5), .stb6(stb6),
  .done(doneIOT34),
  .pc_ck(pc_ckIOT34),
  .irq(irqRqIOT34),
  .rx(rx),
  .tx(tx),
  .LED2(LED2),
  .ACTTY(busACTTY),
  .rot2ac(rot2acTTY),
  .clr(clrTTY),
  .ac_ck(ac_ckTTY)
);


//601x 607x 610x 614x 615x 616x 617x 624x 633x 634x 676x 677x
assign doneIgnore=ck6 & 
  & ((busIR==12'o6011) // RSF  PR8-E: Skip on Reader Flag
  |  (busIR==12'o6012) // RRB  PR8-E: Read Reader Buffer
  |  (busIR==12'o6077)
  |  (busIR==12'o6101) // SMP  MP8-E: Skip on No Memory Parity Error
  |  (busIR==12'o6141)
  |  (busIR==12'o6142) 
  |  (busIR==12'o6152)
  |  (busIR==12'o6167)
  |  (busIR==12'o6171)
  |  (busIR==12'o6244) // RMF  KM8-E: Restore Memory Field
  |  (busIR==12'o6331)
  |  (busIR==12'o6344)
  |  (busIR==12'o6346)
  |  (busIR==12'o6762) // DTCA TC08-P: Clear Status Register A
  |  (busIR==12'o6772) // DTRB TC08-P: Read Status Register B
  );

endmodule


