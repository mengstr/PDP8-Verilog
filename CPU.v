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

  // The main buses
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

assign busRamA=ckFetch?busLatPC:12'bz;

RAM theRAM(
  .clk(SYSCLK),
  .oe(1'b1),
  .we(1'b0),
  .addr(busRamA), 
  .dataI(12'h123), 
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
wire oprIAC, oprX2, oprLEFT, oprRIGHT, oprCML, oprCMA, oprCLL, oprCLA1; // OPR 1
wire oprHLT, oprOSR, oprTSTINV, oprSNLSZL, oprSZASNA, oprSMASPA, oprCLA2; // OPR 2
wire oprMQL, oprSWP, oprMQA, oprSCA, oprCLA_3; // OPR 3 
wire oprNOP0, oprSCL, oprMUY, oprDVI, oprNMI, oprSHL, oprASL, oprLSR; // OPR 3
wire oprNOP;

OPRDECODER  theOPRDECODER(
  .IR(busIR),
  .OPR(instOPR),
  .opr1(opr1), .opr2(opr2), .opr3(opr3),
  .oprIAC(oprIAC), .oprX2(oprX2), .oprLEFT(oprLEFT), .oprRIGHT(oprRIGHT), .oprCML(oprCML), .oprCMA(oprCMA), .oprCLL(oprCLL), .oprCLA1(oprCLA1), // OPR 1
  .oprHLT(oprHLT), .oprOSR(oprOSR), .oprTSTINV(oprTSTINV), .oprSNLSZL(oprSNLSZL), .oprSZASNA(oprSZASNA), .oprSMASPA(oprSMASPA), .oprCLA2(oprCLA2), // OPR 2
  .oprMQL(oprMQL), .oprSWP(oprSWP), .oprMQA(oprMQA), .oprSCA(oprSCA), .oprCLA_3(oprCLA_3), // OPR 3 
  .oprNOP0(oprNOP0), .oprSCL(oprSCL), .oprMUY(oprMUY), .oprDVI(oprDVI), .oprNMI(oprNMI), .oprSHL(oprSHL), .oprASL(oprASL), .oprLSR(oprLSR), // OPR 3
  .oprNOP(oprNOP)
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

wire [11:0] accIn;
wire [11:0] accout1;
MULTILATCH theACC(
    .in(accIn),
    .clear(sw_CLEAR),
    .latch(ac_ck),
    .oe1(1'b1),
    .oe2(ac2ramd),
    .out1(accout1), 
    .out2(busData)
);

assign busORacc=0;

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ ACC CLORIN █ ▇ ▆ ▅ ▄ ▂ ▁
//

wire [11:0] clorinOut;
CLORIN theCLORIN(
  .IN(accout1),
  .CLR(8'b00000000),
  .DOR(busORacc),
  .INV(1'b0),
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
  .LI(1'b0),
  .OE(rot2ac),
  .AO(accIn),
  .LO(rotaterLO)
);


reg done=0;
reg ir2pc=0, ir2rama=0;
reg pc_ld=0, pc_ck=0;
reg ramd2ac_and=0,ramd2ac_add=0;
reg ac2ramd=0;
reg ram_oe=0;
reg ac_ck=0;
reg link_ck=0;
reg rot2ac=0;

//
// ▁ ▂ ▄ ▅ ▆ ▇ █ BUS INTERCONNECTS █ ▇ ▆ ▅ ▄ ▂ ▁
//

//wire [11:0] irzp= { (instIsMP ? busLatPC[11:7] : 5'b00000) , busIR[6:0]};
assign busPCin=ir2pc ? { (instIsMP ? busLatPC[11:7] : 5'b00000) , busIR[6:0]} : 12'bzzzzzzzz; // First OC12 module
assign busRamA=ir2rama ? { (instIsMP ? busLatPC[11:7] : 5'b00000) , busIR[6:0]} : 12'bzzzzzzzz; // Second OC12 module


always @* begin
  pc_ck<=stbFetch;
end


// AND 0xxx
always @* begin
  if (instAND ) begin
    done<=ck1;
  end
end

// TAD 1xx
always @* begin
  if (instTAD && instIsDIR) begin
    ir2rama<=ck1;
    ramd2ac_add<=ck1;
    ram_oe<=ck1;

    ac_ck<=stb1;
    link_ck<=stb1;

    done<=ck2;
  end
end

// ISZ 2xx
always @* begin
  if (instISZ ) begin
    done<=ck1;
  end
end

// DCA 3xx
always @* begin
  if (instDCA ) begin
    done<=ck1;
  end
end

// JMS 4xx
always @* begin
  if (instJMS ) begin
    done<=ck1;
  end
end

// JMP 5xx DIRECT
always @* begin
  if (instJMP && instIsDIR) begin
    ir2pc<=ck1; 
    pc_ld<=ck1;
    pc_ck<=stb1;
    done<=ck2;
  end
end

// IOT 6xx
always @* begin
  if (instIOT ) begin
    done<=ck1;
  end
end

// OPR 7xx
always @* begin
  if (instOPR ) begin
    done<=ck1;
  end
end



endmodule
