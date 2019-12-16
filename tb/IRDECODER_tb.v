`timescale 1us/1ns

module IRDECODER_tb();
    reg [11:0] PC;
    reg [11:0] IR;

  wire PPIND,IND,DIR,MP;
  wire AAND,TAD,ISZ,DCA,JMS,JMP,IOT,OPR;

  wire PPIND_,IND_,DIR_,MP_;
  wire AAND_,TAD_,ISZ_,DCA_,JMS_,JMP_,IOT_,OPR_;


    IRDECODER dut(
        .PCLATCHED(PC),
        .IR(IR),
      .PPIND(PPIND),
      .IND(IND),
      .DIR(DIR),
      .MP(MP),
      .AAND(AAND),
      .TAD(TAD),
      .ISZ(ISZ),
      .DCA(DCA),
      .JMS(JMS),
      .JMP(JMP),
      .IOT(IOT),
      .OPR(OPR)
    );



    IRDECODER_ dut_(
        .PCLATCHED(PC),
        .IR(IR),
        .PPIND(PPIND_),
        .IND(IND_),
        .DIR(DIR_),
        .MP(MP_),
        .AAND(AAND_),
        .TAD(TAD_),
        .ISZ(ISZ_),
        .DCA(DCA_),
        .JMS(JMS_),
        .JMP(JMP_),
        .IOT(IOT_),
        .OPR(OPR_)
    );

  

     integer pc;
     integer ir;      	
  initial begin
      for ( pc=0; pc<32; pc=pc+1) begin
        for ( ir=0; ir<512; ir=ir+1) begin
        PC= pc;
        IR = ir;
            #1;
          if(PPIND!=PPIND_) $display("PPIND @ ","PC:",PC[11],PC[10],PC[9],PC[8],PC[7],",IR:",IR[11],IR[10],IR[9],IR[8],IR[7],IR[6],IR[5],IR[4],IR[3]);
          if(IND!=IND_) $display("IND @ ","PC:",PC[11],PC[10],PC[9],PC[8],PC[7],",IR:",IR[11],IR[10],IR[9],IR[8],IR[7],IR[6],IR[5],IR[4],IR[3]);
          if(DIR!=DIR_) $display("DIR @ ","PC:",PC[11],PC[10],PC[9],PC[8],PC[7],",IR:",IR[11],IR[10],IR[9],IR[8],IR[7],IR[6],IR[5],IR[4],IR[3]);
          if(MP!=MP_) $display("MP @ ","PC:",PC[11],PC[10],PC[9],PC[8],PC[7],",IR:",IR[11],IR[10],IR[9],IR[8],IR[7],IR[6],IR[5],IR[4],IR[3]);
          if(AAND!=AAND_) $display("AAND @ ","PC:",PC[11],PC[10],PC[9],PC[8],PC[7],",IR:",IR[11],IR[10],IR[9],IR[8],IR[7],IR[6],IR[5],IR[4],IR[3]);
          if(TAD!=TAD_) $display("TAD @ ","PC:",PC[11],PC[10],PC[9],PC[8],PC[7],",IR:",IR[11],IR[10],IR[9],IR[8],IR[7],IR[6],IR[5],IR[4],IR[3]);
          if(ISZ!=ISZ_) $display("ISZ @ ","PC:",PC[11],PC[10],PC[9],PC[8],PC[7],",IR:",IR[11],IR[10],IR[9],IR[8],IR[7],IR[6],IR[5],IR[4],IR[3]);
          if(DCA!=DCA_) $display("DCA @ ","PC:",PC[11],PC[10],PC[9],PC[8],PC[7],",IR:",IR[11],IR[10],IR[9],IR[8],IR[7],IR[6],IR[5],IR[4],IR[3]);
          if(IOT!=IOT_) $display("ISZ @ ","PC:",PC[11],PC[10],PC[9],PC[8],PC[7],",IR:",IR[11],IR[10],IR[9],IR[8],IR[7],IR[6],IR[5],IR[4],IR[3]);
          if(OPR!=OPR_) $display("DCA @ ","PC:",PC[11],PC[10],PC[9],PC[8],PC[7],",IR:",IR[11],IR[10],IR[9],IR[8],IR[7],IR[6],IR[5],IR[4],IR[3]);
         end
      end
    end
endmodule

