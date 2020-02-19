//
// PDP8 in Verilog for ICE40
//
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module PDP8(
  input clk,
  input reset,       // Power On Reset
  input sw_CLEAR,    // Clear CPU (button)
  input sw_RUN,      // Start CPU
  output LED1, LED2,
  // UART
  input rx,
  output tx,
  // FrontPanel
  output GREEN1, GREEN2,
  output RED1, RED2,
  output YELLOW1, YELLOW2,
  output PLED1, PLED2, PLED3, PLED4, PLED5, PLED6,
  input SW1, SW2, SW3
);



//
// ▁ ▂ ▄ ▅ ▆ ▇ █    CLOCK GENERATOR    █ ▇ ▆ ▅ ▄ ▂ ▁
//
wire baudX7;
wire frontRefresh;
wire buttonDelay;

ClockGen ClockGen(
  .clk(clk),
  .baudX7(baudX7),
  .frontRefresh(frontRefresh),
  .buttonDelay(buttonDelay)
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █         BUSSES        █ ▇ ▆ ▅ ▄ ▂ ▁
// ▁ ▂ ▄ ▅ ▆ ▇ █   BUS INTERCONNECTS   █ ▇ ▆ ▅ ▄ ▂ ▁
// ▁ ▂ ▄ ▅ ▆ ▇ █      OR'ed BUSSES     █ ▇ ▆ ▅ ▄ ▂ ▁
//

reg [11:0] busIR;
wire [11:0] busPC;
wire [11:0] busLatPC;

wire [11:0] busPCin_ir    = ir2pc ? { (instIsMP ? busLatPC[11:7] : 5'b00000) , busIR[6:0]} : 12'b0; // First OC12 module
wire [11:0] busPCin_reg   = reg2pc ? busReg : 12'b0; 
wire [11:0] busAddress_ir = ir2rama ? { (instIsMP ? busLatPC[11:7] : 5'b00000) , busIR[6:0]} : 12'b0; // Second OC12 module
wire [11:0] busAddress_pc = ckFetch ? busPC : 12'b0;
wire [11:0] busData_pc    = pc2ramd ? busPC : 12'b0; 

wire [11:0] busReg        = busReg_ind | busReg_data;
wire [11:0] busAddress    = busAddress_ind | busAddress_pc | busAddress_ir;
wire [11:0] busPCin       = busPCin_ir | busPCin_reg | (setpc ? switches : 12'o0000); 
wire [11:0] busData       = busData_inc | busData_ram |busData_acc | busData_pc;
wire [11:0] busORacc      = mqout1 | busACGTF | busACTTY | (oprOSR ? 12'o`OSR : 12'o0000);
wire [11:0] accIn         = accIn_andadd | accIn_rotater; 


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ OR'ed CONTROL SIGNALS █ ▇ ▆ ▅ ▄ ▂ ▁
//

// 5 input or
wire done         = done05 | doneIOT0 | doneIOT34 | done7 | doneIgnore;
wire pc_ck        = pc_ckIFI | pc_ck05 | pc_ckIOT0 | pc_ckIOT34 | pc_ck7 | setpc;
// 4 input or
wire ac_ck        = ac_ck05 | ac_ckIOT0 | ac_ck7 | ac_ckTTY;
wire rot2ac       = rot2ac05 | rot2acIOT0 | rot2ac7 | rot2acTTY;
wire clorinCLR    = claDCA | oprCLA | iotCLR0 |clrTTY;
// 3 input or
wire link_ck      = link_ck05 | link_ckIOT0 | link_ck7;
// 2 input or
wire ram_oe       = ram_oeIFI | ram_oe05;
wire ram_we       = ram_weIFI | ram_we05;
wire claDCA       = cla05 | cla7;
wire ind2inc      = ind2incIFI | ind2reg05;
wire inc2ramd     = inc2ramdIFI | inc2ramd05;
wire ir2rama      = ir2ramaIFI | ir2rama05;
// Direct connected
wire pc_ld        = pc_ld05  | setpc;
wire irqRq        = irqRqIOT34;  // Some device is asserting irq
wire mq_ck        = mq_ck7;
wire mq_hold      = mq_hold7;
wire mq2orbus     = mq2orbus7;
wire ramd2ac_add  = ramd2ac_add05;
wire ramd2ac_and  = ramd2ac_and05;
wire ac2ramd      = ac2ramd05;
wire ind_ck       = ind_ckIFI;
wire ind2rama     = ind2rama05;
wire data_ck      = data_ck05;
wire ld2inc       = ld2inc05;
wire ir2pc        = ir2pc05;
wire reg2pc       = reg2pc05;
wire pc2ramd      = pc2ramd05;

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ FRONT PANEL █ ▇ ▆ ▅ ▄ ▂ ▁
//
wire [11:0]switches;
wire startstop, sst, setpc, button3, button4, button5;

FrontPanel thePanel(
  // Inputs
  .clk(clk),
  .REFRESHCLK(frontRefresh),
  .BUTTONDELAY(buttonDelay),
  .green(busLatPC),
  .red(busIR),
  .yellow(switches),
  // Outputs
  .toggles(switches),
  .buttons({startstop, sst, setpc, button3, button4, button5}),
  .GREEN1(GREEN1), .GREEN2(GREEN2),
  .RED1(RED1), .RED2(RED2),
  .YELLOW1(YELLOW1), .YELLOW2(YELLOW2),
  .PLED1(PLED1), .PLED2(PLED2), .PLED3(PLED3), .PLED4(PLED4), .PLED5(PLED5), .PLED6(PLED6),
  .SW1(SW1), .SW2(SW2), .SW3(SW3)
 );


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ SEQUENCER & START/STOP █ ▇ ▆ ▅ ▄ ▂ ▁
//
wire ckFetch, ckAuto1, ckAuto2, ckInd;
wire ck1, ck2, ck3, ck4, ck5, ck6;
wire stbFetch, stbAuto1, stbAuto2, stbInd;
wire stb1, stb2, stb3, stb4, stb5, stb6;
wire running;

Sequencer theSEQUENCER(
  .CLK(clk),
  .RESET(reset),
  // Inputs
  .HALT((oprHLT & ck2)), //FIX
  .DONE(done), 
  .startstop(startstop|sw_RUN),
  .sst(sst),
  .SEQTYPE({instIsPPIND,instIsIND}),
  // Outputs
  .ckFetch(ckFetch), .ckAuto1(ckAuto1), .ckAuto2(ckAuto2), .ckInd(ckInd),
  .ck1(ck1), .ck2(ck2), .ck3(ck3), .ck4(ck4), .ck5(ck5), .ck6(ck6),
  .stbFetch(stbFetch), .stbAuto1(stbAuto1), .stbAuto2(stbAuto2), .stbInd(stbInd), 
  .stb1(stb1), .stb2(stb2), .stb3(stb3), .stb4(stb4), .stb5(stb5), .stb6(stb6),
  .running(running)
);
assign LED1=running;

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ PROGRAM COUNTER █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire inIrq=(busIR==12'o4000) | irqOverride; //FIX

ProgramCounter thePC(
  .CLK(clk),
  .RESET(reset),
  // Inputs
  .IN(busPCin),
  .LD(pc_ld),
  .CK(pc_ck & ~(inIrq & ckFetch)), //FIX
  .LATCH(1'b0),
  .FETCH(ckFetch & ~inIrq), //FIX
  //Outputs
  .PC(busPC),
  .PCLAT(busLatPC)
); 


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ RAM MEMORY █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire [11:0] busData_ram;

RAM theRAM(
  .clk(clk),
  // Inputs
  .oe(ram_oe),
  .we(ram_we),
  .addr(busAddress), 
  .dataI(busData), 
  // Outputs
  .dataO(busData_ram)  
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ IR █ ▇ ▆ ▅ ▄ ▂ ▁
//
IR theIR(   // TODO Should IR be a Multilatch?
  .CLK(clk),
  .RESET(reset),
  // Inputs
  .ckFetch(ckFetch),
  .irqOverride(irqOverride),
  .busData(busData),
  // Outputs
  .busIR(busIR)
);



//
// ▁ ▂ ▄ ▅ ▆ ▇ █ INSTRUCTION DECODER █ ▇ ▆ ▅ ▄ ▂ ▁
//

// IR DECODER outputs
wire instIsPPIND, instIsIND, instIsDIR, instIsMP;
wire instAND, instTAD, instISZ, instDCA, instJMS, instJMP, instIOT, instOPR;

IRdecode theIRDECODER(
  .RESET(reset),
  // Inputs
  .PCLATCHED(busLatPC),
  .IR(busIR),
  // Outputs
  .PPIND(instIsPPIND), 
  .IND(instIsIND), 
  .DIR(instIsDIR), 
  .MP(instIsMP),
  .AAND(instAND), 
  .TAD(instTAD), 
  .ISZ(instISZ), 
  .DCA(instDCA), 
  .JMS(instJMS), 
  .JMP(instJMP), 
  .IOT(instIOT), 
  .OPR(instOPR)
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ OPERAND DECODER █ ▇ ▆ ▅ ▄ ▂ ▁
//

// OPR DECODER outputs
wire opr1,opr2,opr3;
wire oprIAC, oprX2, oprLEFT, oprRIGHT, oprCML, oprCMA, oprCLL;    // OPR 1
wire oprHLT, oprOSR, oprTSTINV, oprSNLSZL, oprSZASNA, oprSMASPA;  // OPR 2
wire oprMQL, oprSWP, oprMQA, oprSCA;                              // OPR 3 
wire oprSCL, oprMUY, oprDVI, oprNMI, oprSHL, oprASL, oprLSR;      // OPR 3
wire oprCLA;

OPRdecoder  theOPRDECODER(
  // Inputs
  .IR(busIR[8:0]),
  .OPR(instOPR),
  // Outputs
  .opr1(opr1), .opr2(opr2), .opr3(opr3),
  .oprIAC(oprIAC), .oprX2(oprX2), .oprLEFT(oprLEFT), .oprRIGHT(oprRIGHT), .oprCML(oprCML), .oprCMA(oprCMA), .oprCLL(oprCLL),    // OPR 1
  .oprHLT(oprHLT), .oprOSR(oprOSR), .oprTSTINV(oprTSTINV), .oprSNLSZL(oprSNLSZL), .oprSZASNA(oprSZASNA), .oprSMASPA(oprSMASPA), // OPR 2
  .oprMQL(oprMQL), .oprSWP(oprSWP), .oprMQA(oprMQA), .oprSCA(oprSCA),                                                           // OPR 3 
  .oprSCL(oprSCL), .oprMUY(oprMUY), .oprDVI(oprDVI), .oprNMI(oprNMI), .oprSHL(oprSHL), .oprASL(oprASL), .oprLSR(oprLSR),        // OPR 3
  .oprCLA(oprCLA)                                                                                                               // OPR 1,2,3
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ SKIP █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire doSkip;

Skip theSKIP(
  // Inputs
  .AC(accout1),
  .LINK(link),
  .SZASNA(oprSZASNA),
  .SMASPA(oprSMASPA),
  .SNLSZL(oprSNLSZL),
  .TSTINV(oprTSTINV),
  // Outputs
  .OUT(doSkip)
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ MQ █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire [11:0] mqout1;

/* verilator lint_off PINMISSING */
MultiLatch theMQ(
  .RESET(reset),
  .CLK(clk),
  // Inputs
  .in(accout1),
  .latch(mq_ck), 
  .hold(mq_hold),
  .oe1(mq2orbus), 
  .oe2(1'b0),
  // Outputs
  .out1(mqout1) 
);
/* verilator lint_on PINMISSING */


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ LINK █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire link;
wire rotaterLI;

Link theLINK(
  .CLK(clk),
  .RESET(reset),
  .CLEAR(reset), // FIX
  // Inputs
  .LINK_CK(link_ck),
  .CLL(oprCLL | linkclrIOT0), // FIX
  .CML(((oprCML ^ (incC & oprIAC)) | (andaddC & instTAD)) | linkcmlIOT0), // FIX
  .SET(oprLEFT|oprRIGHT), // FIX
  .FROM_ROTATER(rotaterLO),
  // Outputs
  .L(link),
  .TO_ROTATER(rotaterLI)
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ ADD/AND █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire andaddC;
wire [11:0] accIn_andadd;

AddAnd theADDAND(
  // Inputs
  .A(accout1),
  .B(busData),  
  .CI(1'b0),
  .OE_ADD(ramd2ac_add),
  .OE_AND(ramd2ac_and),
  // Outputs
  .S(accIn_andadd),
  .CO(andaddC)
);

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ ACCUMULATOR █ ▇ ▆ ▅ ▄ ▂ ▁
//

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
wire [11:0] busData_acc;

wire [11:0] accout1;
MultiLatch theACC(
  .RESET(reset),
  .CLK(clk),
  // Inputs
  .in(accIn),
  .latch(ac_ck),
  .hold(1'b0),
  .oe1(1'b1),
  .oe2(ac2ramd),
  // Outputs
  .out1(accout1), 
  .out2(busData_acc) 
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ ACC CLORIN █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire [11:0] clorinOut;

ClrOrInv theCLORIN(
  // Inputs
  .IN(accout1),
  .CLR(clorinCLR),
  .DOR(busORacc),
  .INV(oprCMA),
  // Outputs
  .OUT(clorinOut)
);

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ ACC INCREMENTER █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire [11:0] incOut;
wire incC;

Incrementer theINCREMENTER(
  // Inputs
  .IN(clorinOut),
  .INC(oprIAC),
  .OE(1'b1),
  // Outputs
  .OUT(incOut),
  .C(incC)
);

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ ACC ROTATER █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire rotaterLO;
wire [11:0] accIn_rotater;

Rotater theRotater(
  // Inputs
  .OP({oprRIGHT,oprLEFT,oprX2}),
  .AI(incOut),
  .LI(rotaterLI),
  .OE(rot2ac),
  // Outputs
  .AO(accIn_rotater),
  .LO(rotaterLO)
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ INDIRECT REGISTER █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire [11:0] busAddress_ind;
wire [11:0] busReg_ind;

MultiLatch theIndReg(
  .RESET(reset),
  .CLK(clk),
  // Inputs
  .in(busData), 
  .latch(ind_ck),
  .hold(1'b0),
  .oe1(ind2inc),
  .oe2(ind2rama),
  // Outputs
  .out1(busReg_ind), 
  .out2(busAddress_ind)
);


//
// ▁ ▂ ▄ ▅ ▆ ▇ █ DATA REGISTER █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire [11:0] busReg_data;

/* verilator lint_off PINMISSING */
MultiLatch theDataReg(
  .RESET(reset),
  .CLK(clk),
  // Inputs
  .in(busData), 
  .latch(data_ck),
  .hold(1'b0),
  .oe1(ld2inc),
  .oe2(1'b0),
  // Outputs
  .out1(busReg_data)
);
/* verilator lint_on PINMISSING */

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ BUS INCREMENTER █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire incZero;
wire [11:0] busData_inc;

Incrementer theBUSINCREMENTER(
  // Inputs
  .IN(busReg),
  .INC(1'b1),
  .OE(inc2ramd),
  // Outputs
  .OUT(busData_inc), 
  .C(incZero)
);



//
// ▁ ▂ ▄ ▅ ▆ ▇ █ INSTRUCTION HANDLING - FETCH & INDEXING █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire pc_ckIFI;
wire ram_oeIFI;
wire ram_weIFI;
wire ind_ckIFI;
wire ind2incIFI;
wire inc2ramdIFI;
wire ir2ramaIFI;

InstructionFetch theinstFI (
  // Inputs
  .instIsIND(instIsIND),
  .instIsPPIND(instIsPPIND),
  .ckFetch(ckFetch), .ckAuto1(ckAuto1), .ckAuto2(ckAuto2), .ckInd(ckInd),
  .stbFetch(stbFetch), .stbAuto2(stbAuto2), .stbAuto1(stbAuto1), .stbInd(stbInd),
  .irqOverride(irqOverride),
  // Outputs
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

wire pc_ck7;
wire mq_ck7;
wire mq_hold7;
wire link_ck7;
wire cla7;
wire ac_ck7;
wire rot2ac7;
wire done7;
wire mq2orbus7;

InstructionOPR theinst7 (
  // Inputs
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
  // Outputs
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

wire pc_ld05;
wire pc_ck05;
wire ram_oe05;
wire ram_we05;
wire link_ck05;
wire ac_ck05;
wire cla05;
wire ac2ramd05;
wire ramd2ac_add05;
wire ramd2ac_and05;
wire rot2ac05;
wire ind2reg05;
wire ind2rama05;
wire data_ck05;
wire ld2inc05;
wire inc2ramd05;
wire reg2pc05;
wire ir2rama05;
wire pc2ramd05;
wire ir2pc05;
wire done05;

Instructions theinst0_5 (
  // Inputs
  .instIsDIR(instIsDIR), .instIsIND(instIsIND), .instIsPPIND(instIsPPIND),
  .instAND(instAND), .instDCA(instDCA), .instISZ(instISZ), .instJMP(instJMP), .instJMS(instJMS), .instTAD(instTAD),
  .incZero(incZero),
  .irqOverride(irqOverride),
  .ck1(ck1),   .ck2(ck2),   .ck3(ck3),   .ck4(ck4),   .ck5(ck5),   .ck6(ck6),
  .stb1(stb1), .stb2(stb2), .stb3(stb3), .stb4(stb4), .stb5(stb5), .stb6(stb6),
  // Outputs
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

wire ac_ckIOT0;
wire pc_ckIOT0;
wire link_ckIOT0;
wire iotCLR0;
wire linkclrIOT0;
wire linkcmlIOT0;
wire rot2acIOT0;
wire doneIOT0;
wire [11:0] busACGTF;
wire irqOverride;
wire GIE; //FIX

InstructionIOT600x theInterrupt(
  //Inputs
  .CLK(clk),
  .RESET(reset),
  .CLEAR(sw_CLEAR),
  .EN(instIOT & (busIR[8:3]==6'o00)), //FIX
  .IR(busIR[2:0]),
  .AC(accout1),
  .LINK(link),
  .ckFetch(ckFetch), .ck1(ck1),   .ck2(ck2),   .ck3(ck3),   .ck4(ck4),   .ck5(ck5),   .ck6(ck6),
  .stbFetch(stbFetch), .stb1(stb1), .stb2(stb2), .stb3(stb3), .stb4(stb4), .stb5(stb5), .stb6(stb6),
  .irqRq(irqRq),
  .anyDone(done),
  // Outputs
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
wire ac_ckTTY;
wire pc_ckIOT34;
wire irqRqIOT34;
wire doneIOT34;
wire rot2acTTY;

InstructionIOT603x theTTY(
  .CLK(clk),
  .clear(reset | iotCLR0), //FIX
  //Inputs
  .baudX7(baudX7),
  .EN1(instIOT & (busIR[8:3]==6'o03)), //FIX
  .EN2(instIOT & (busIR[8:3]==6'o04)), //FIX
  .IR(busIR[2:0]),
  .AC(accout1),
  .ck1(ck1),   .ck2(ck2),   .ck3(ck3),   .ck4(ck4),   .ck5(ck5),   .ck6(ck6),
  .stb1(stb1), .stb2(stb2), .stb3(stb3), .stb4(stb4), .stb5(stb5), .stb6(stb6),
  .done(doneIOT34),
  .pc_ck(pc_ckIOT34),
  .irq(irqRqIOT34),
  .rx(rx),
  // Outputs
  .tx(tx),
  .LED2(LED2),
  .ACTTY(busACTTY),
  .rot2ac(rot2acTTY),
  .clr(clrTTY),
  .ac_ck(ac_ckTTY)
);


//601x 607x 610x 614x 615x 616x 617x 624x 633x 634x 676x 677x
wire doneIgnore=ck6 &  //FIX - Move this to TB
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


