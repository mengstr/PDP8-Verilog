//
// Sequencer.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
`default_nettype none

module Sequencer (
  input CLK,           //
  input RESET,            //
  input DONE,             // Reset step counter before the natural end at step 31
  input HALT,             // Rising edge halts at next instruction
  input startstop,        // Strobe -  toggles continous run/halt
  input sst,              // Strobe - executes one instruction 
  input [1:0] SEQTYPE,    // ({instIsPPIND,instIsIND}),
  output ckFetch, ckAuto1, ckAuto2, ckInd,
  output ck1, ck2, ck3, ck4, ck5, ck6,
  output stbFetch, stbAuto1, stbAuto2, stbInd,
  output stb1, stb2, stb3, stb4, stb5, stb6,
  output reg running=0
);

reg [4:0] stepCnt; 
reg singleinst=0;
reg lastSst=0;
reg lastStartstop=0;

always @(posedge CLK) begin 
    if (RESET) begin
        running<=0;
        singleinst<=0;
        stepCnt<=31;
    end 
    else 
    if (DONE) begin
        stepCnt<=0;
        singleinst<=0;
    end
    else
    begin
        if (startstop & ~lastStartstop) running<=~running;
        lastStartstop<=startstop;
        if (sst & ~lastSst) singleinst<=1;
        lastSst<=sst;
        if (HALT) running<=0;
        if (running | singleinst) begin
            if (stepCnt==1) begin
                case (SEQTYPE)
                    2'b00: stepCnt<=stepCnt+7;
                    2'b01: stepCnt<=stepCnt+5;
                    2'b10: stepCnt<=stepCnt+1; 
                    2'b11: stepCnt<=stepCnt+1;
                endcase
            end else stepCnt<=stepCnt+1;
        end
    end
end

assign ckFetch  = !RESET & (stepCnt==0 || stepCnt==1);
assign ckAuto1  = !RESET & (stepCnt==2 || stepCnt==3);
assign ckAuto2  = !RESET & (stepCnt==4 || stepCnt==5);
assign ckInd    = !RESET & (stepCnt==6 || stepCnt==7);
assign ck1      = !RESET & (stepCnt==8 || stepCnt==9);
assign ck2      = !RESET & (stepCnt==10 || stepCnt==11);
assign ck3      = !RESET & (stepCnt==12 || stepCnt==13);
assign ck4      = !RESET & (stepCnt==14 || stepCnt==15);
assign ck5      = !RESET & (stepCnt==16 || stepCnt==17);
assign ck6      = !RESET & (stepCnt==18 || stepCnt==19);

assign stbFetch = !RESET & (stepCnt==1);
assign stbAuto1 = !RESET & (stepCnt==3);
assign stbAuto2 = !RESET & (stepCnt==5);
assign stbInd   = !RESET & (stepCnt==7);
assign stb1     = !RESET & (stepCnt==9);
assign stb2     = !RESET & (stepCnt==11);
assign stb3     = !RESET & (stepCnt==13);
assign stb4     = !RESET & (stepCnt==15);
assign stb5     = !RESET & (stepCnt==17);
assign stb6     = !RESET & (stepCnt==19);

endmodule
