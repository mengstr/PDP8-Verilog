//
// SEQUENCER.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module SEQUENCER (
    input CLK,              //
    input RESET,
    input DONE,             // Reset step counter before the natural end at step 31
    input RUN,              // Rising edge starts continous run
    input HALT,             // Rising edge halts at next instruction
    input [1:0] SEQTYPE,           // ({instIsPPIND,instIsIND}),
    output CK_FETCH,
    output CK_AUTOINC1, CK_AUTOINC2,
    output CK_INDIRECT,
    output CK_1, CK_2, CK_3, CK_4, CK_5, CK_6,
    output STB_FETCH,
    output STB_AUTOINC1, STB_AUTOINC2,
    output STB_INDIRECT,
    output STB_1, STB_2, STB_3, STB_4, STB_5, STB_6
);

    reg running;              // CPU is running continously
    reg [4:0] stepCnt; 
    
    always @(posedge CLK) begin 
        if (RESET) begin
            running=0;
            stepCnt=0;
        end 
        else 
        if (DONE) begin
            stepCnt=0;
        end
        else
        begin
            if (RUN==1 & running==0) running=1;
//            if (HALT & running) running=0;
            if (running) begin
                if (stepCnt==1) begin
                    case (SEQTYPE)
                        2'b00: stepCnt=stepCnt+7;
                        2'b01: stepCnt=stepCnt+5;
                        2'b10: stepCnt=stepCnt+1; 
                        2'b11: stepCnt=stepCnt+1;
                    endcase
                end else stepCnt=stepCnt+1;
            end
        end
    end
 
    assign CK_FETCH     = (stepCnt==0 || stepCnt==1);
    assign CK_AUTOINC1  = (stepCnt==2 || stepCnt==3);
    assign CK_AUTOINC2  = (stepCnt==4 || stepCnt==5);
    assign CK_INDIRECT  = (stepCnt==6 || stepCnt==7);
    assign CK_1         = (stepCnt==8 || stepCnt==9);
    assign CK_2         = (stepCnt==10 || stepCnt==11);
    assign CK_3         = (stepCnt==12 || stepCnt==13);
    assign CK_4         = (stepCnt==14 || stepCnt==15);
    assign CK_5         = (stepCnt==16 || stepCnt==17);
    assign CK_6         = (stepCnt==18 || stepCnt==19);

    assign STB_FETCH    = (stepCnt==1);
    assign STB_AUTOINC1 = (stepCnt==3);
    assign STB_AUTOINC2 = (stepCnt==5);
    assign STB_INDIRECT = (stepCnt==7);
    assign STB_1        = (stepCnt==9);
    assign STB_2        = (stepCnt==11);
    assign STB_3        = (stepCnt==13);
    assign STB_4        = (stepCnt==15);
    assign STB_5        = (stepCnt==17);
    assign STB_6        = (stepCnt==19);
endmodule

// 000x Fetch
// 001x Auto1
// 010x Auto2
// 011x Ind
// 100x CK/STB1
// 101x CK/STB2
// 110x CK/STB3
// 111x CK/STB4
