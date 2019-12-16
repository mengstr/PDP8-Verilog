`timescale 1us/1ns

module OPRDECODER_tb();
    reg OPR;
    reg [11:0] IR;

    wire OPR1, OPR2, OPR3, IAC, X2, LEFT, RIGHT, CML, CMA, CLL, CLA1, NA1, HLT, OSR;
    wire TSTINV, SNLSZL, SZASNA, SMASPA, CLA2, MQL, SWP, MQA, SCA, CLA_3, LSR, ASL, SHL;
    wire NMI, DVI, MUY, SCL, NOP0, NOP;

    wire OPR1_, OPR2_, OPR3_, IAC_, X2_, LEFT_, RIGHT_, CML_, CMA_, CLL_, CLA1_, NA1_, HLT_, OSR_;
    wire TSTINV_, SNLSZL_, SZASNA_, SMASPA_, CLA2_, MQL_, SWP_, MQA_, SCA_, CLA_3_, LSR_, ASL_, SHL_;
    wire NMI_, DVI_, MUY_, SCL_, NOP0_, NOP_;



    OPRDECODER dut(
        .IR(IR),
        .OPR(OPR),
        .OPR1(OPR1),
        .OPR2(OPR2),
        .OPR3(OPR3),
        .IAC(IAC),
        .X2(X2),
        .LEFT(LEFT),
        .RIGHT(RIGHT),
        .CML(CML),
        .CMA(CMA),
        .CLL(CLL),
        .CLA1(CLA1),
        .NA1(NA1),
        .HLT(HLT),
        .OSR(OSR),
        .TSTINV(TSTINV),
        .SNLSZL(SNLSZL),
        .SZASNA(SZASNA),
        .SMASPA(SMASPA),
        .CLA2(CLA2),
        .MQL(MQL),
        .SWP(SWP),
        .MQA(MQA),
        .SCA(SCA),
        .CLA_3(CLA_3),
        .LSR(LSR),
        .ASL(ASL),
        .SHL(SHL),
        .NMI(NMI),
        .DVI(DVI),
        .MUY(MUY),
        .SCL(SCL),
        .NOP0(NOP0),
        .NOP(NOP)
    );

  
    OPRDECODER_ dut_(
        .BUS_IR(IR),
        .OPR(OPR),
        .OPR1(OPR1_),
        .OPR2(OPR2_),
        .OPR3(OPR3_),
        .IAC(IAC_),
        .X2(X2_),
        .LEFT(LEFT_),
        .RIGHT(RIGHT_),
        .CML(CML_),
        .CMA(CMA_),
        .CLL(CLL_),
        .CLA1(CLA1_),
        .NA1(NA1_),
        .HLT(HLT_),
        .OSR(OSR_),
        .TSTINV(TSTINV_),
        .SNLSZL(SNLSZL_),
        .SZASNA(SZASNA_),
        .SMASPA(SMASPA_),
        .CLA2(CLA2_),
        .MQL(MQL_),
        .SWP(SWP_),
        .MQA(MQA_),
        .SCA(SCA_),
        .CLA_3(CLA_3_),
        .LSR(LSR_),
        .ASL(ASL_),
        .SHL(SHL_),
        .NMI(NMI_),
        .DVI(DVI_),
        .MUY(MUY_),
        .SCL(SCL_),
        .NOP0(NOP0_),
        .NOP(NOP_)
    );


    integer ir;
    integer opr;      	
    initial begin
        for ( opr=0; opr<2; opr=opr+1) begin
            for ( ir=0; ir<512; ir=ir+1) begin
                IR=ir;
                OPR=opr;
                #1;
                if (OPR1!=OPR1_) $display("OPR1 @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (OPR2!=OPR2_) $display("OPR2 @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (OPR3!=OPR3_) $display("OPR3 @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (IAC!=IAC_) $display("IAC @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (X2!=X2_) $display("X2 @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (LEFT!=LEFT_) $display("LEFT @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (RIGHT!=RIGHT_) $display("RIGHT @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (CML!=CML_) $display("CML @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (CMA!=CMA_) $display("CMA @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (CLL!=CLL_) $display("CLL @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (CLA1!=CLA1_) $display("CLA1 @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (NA1!=NA1_) $display("NA1 @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (HLT!=HLT_) $display("HLT @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (OSR!=OSR_) $display("OSR @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]);
                if (TSTINV!=TSTINV_) $display("TSTINV @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (SNLSZL!=SNLSZL_) $display("SNLSZL @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (SZASNA!=SZASNA_) $display("SZASNA @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (SMASPA!=SMASPA_) $display("SMASPA @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (CLA2!=CLA2_) $display("CLA2 @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (MQL!=MQL_) $display("MQL @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (SWP!=SWP_) $display("SWP @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (MQA!=MQA_) $display("MQA @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (SCA!=SCA_) $display("SCA @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (CLA_3!=CLA_3_) $display("CLA_3 @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (LSR!=LSR_) $display("LSR @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (ASL!=ASL_) $display("ASL @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (SHL!=SHL_) $display("SHL @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]);
                if (NMI!=NMI_) $display("NMI @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (DVI!=DVI_) $display("DVI @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (MUY!=MUY_) $display("MUY @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (SCL!=SCL_) $display("SCL @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (NOP0!=NOP0_) $display("NOP0 @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]); 
                if (NOP!=NOP_) $display("NOP @ ","IR:",IR[8],IR[7],IR[6],IR[5],IR[4],IR[3],IR[2],IR[1],IR[0]);
            end
        end
    end
endmodule

