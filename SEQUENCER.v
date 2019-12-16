`default_nettype none

module SEQUENCER (
    input SYSCLK,           // 100MHz FPGA external clock
    input CLK,              // PDP Clock
    input CLEAR,            // Reset step counter before the natural end at step 31
    input RUN,              // Rising edge starts continous run
    input HALT,             // Rising edge halts at next instruction
    input STEPM,            // Rising edge executes one microstep
    input STEPI,            // Rising edge executes one instruction
    input NOAUTO,           // If set at step2 then skip the "autoIncrement"-handling microsteps
    input NOIND,            // If set at step2 then skip the "indirect"-handling microsteps
    output PH1,PH2,PH3,
    output CK_FETCH,
    output CK_AUTOINC1, CK_AUTOINC2,
    output CK_INDIRECT,
    output CK_1, CK_2, CK_3, CK_4, CK_5, CK_6,
    output STB_FETCH,
    output STB_AUTOINC1, STB_AUTOINC2,
    output STB_INDIRECT,
    output STB_1, STB_2, STB_3, STB_4, STB_5, STB_6
);

    reg [4:0] stepCnt=0; 
    reg running=0;              // CPU is running continously
    reg run1m=0,run1i=0;        // CPU is runign a single microstep/instruction
    reg wfRUN=0, wfHALT=0;      // FF's to capture short pulses from the RUN and HALT switches
    reg wfSTEPM=0, wfSTEPI=0;   // FF's to capture short pulses from the two STEP switches
    
    always @(posedge CLK or posedge CLEAR) begin
        if (CLEAR) begin
            stepCnt<=0;
            run1i<=0;
        end else begin
            if (RUN==1) wfRUN<=1;
            if (HALT==1) wfHALT<=1;
            if (STEPM==1) wfSTEPM<=1;
            if (STEPI==1) wfSTEPI<=1;
            if (wfRUN==1) begin wfRUN<=0; running<=1; end
            if (wfHALT==1 && stepCnt==31) begin wfHALT<=0; running<=0; end
            if (wfSTEPM==1 && !STEPM) begin wfSTEPM<=0; run1m<=1; end
            if (wfSTEPI==1) begin wfSTEPI<=0; run1i<=1; end
            if (running || run1m || run1i) begin
                run1m<=0;
                if (stepCnt==31) run1i<=0;
                if (stepCnt==2) begin
                    if (NOIND) stepCnt<=stepCnt+10;
                    else if (NOAUTO) stepCnt<=stepCnt+7;
                end else begin
                    stepCnt<=stepCnt+1;
                end
            end
        end
    end

    assign PH1=((stepCnt%3)==0);
    assign PH2=((stepCnt%3)==1);
    assign PH3=((stepCnt%3)==2);
    assign STB_FETCH=(stepCnt==1);
    assign STB_AUTOINC1=(stepCnt==1+3*1);
    assign STB_AUTOINC2=(stepCnt==1+3*2);
    assign STB_INDIRECT=(stepCnt==1+3*3);
    assign STB_1=(stepCnt==1+3*4);
    assign STB_2=(stepCnt==1+3*5);
    assign STB_3=(stepCnt==1+3*6);
    assign STB_4=(stepCnt==1+3*7);
    assign STB_5=(stepCnt==1+3*8);
    assign STB_6=(stepCnt==1+3*9);
    assign CK_FETCH=(stepCnt==0 || stepCnt==1 || stepCnt==2);
    assign CK_AUTOINC1=(stepCnt==3 ||stepCnt==4 || stepCnt==5);
    assign CK_AUTOINC2=(stepCnt==6 || stepCnt==7 || stepCnt==8);
    assign CK_INDIRECT=(stepCnt==9 || stepCnt==10 || stepCnt==11);
    assign CK_1=(stepCnt==12 || stepCnt==13 || stepCnt==14);
    assign CK_2=(stepCnt==15 || stepCnt==16 || stepCnt==17);
    assign CK_3=(stepCnt==18 || stepCnt==19 || stepCnt==20);
    assign CK_4=(stepCnt==21 || stepCnt==22 || stepCnt==23);
    assign CK_5=(stepCnt==24 || stepCnt==25 || stepCnt==26);
    assign CK_6=(stepCnt==27 || stepCnt==28 || stepCnt==29);

endmodule
