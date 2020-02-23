//
// Sequencer.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
`default_nettype none

module Sequencer (
  input clk,           //
  input reset,            //
  input DONE,             // Reset step counter before the natural end at step 31
  input HALT,             // Rising edge halts at next instruction
  input startstop,        // Strobe -  toggles continous run/halt
  input sst,              // Strobe - executes one instruction 
  input [1:0] SEQTYPE,    // ({instIsPPIND,instIsIND}),
  output ckFetch, ckAuto1, ckAuto2, ckInd,
  output ck1, ck2, ck3, ck4, ck5,
  output stbFetch, stbAuto1, stbAuto2, stbInd,
  output stb1, stb2, stb3, stb4, stb5,
  output reg running=0
);

reg [4:0] stepCnt; 
reg singleinst=0;
reg lastSst=0;
reg lastStartstop=0;

always @(posedge clk) begin 
    if (reset) begin
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

assign ckFetch  = !reset & (stepCnt==0 || stepCnt==1);
assign ckAuto1  = !reset & (stepCnt==2 || stepCnt==3);
assign ckAuto2  = !reset & (stepCnt==4 || stepCnt==5);
assign ckInd    = !reset & (stepCnt==6 || stepCnt==7);
assign ck1      = !reset & (stepCnt==8 || stepCnt==9);
assign ck2      = !reset & (stepCnt==10 || stepCnt==11);
assign ck3      = !reset & (stepCnt==12 || stepCnt==13);
assign ck4      = !reset & (stepCnt==14 || stepCnt==15);
assign ck5      = !reset & (stepCnt==16 || stepCnt==17);

assign stbFetch = !reset & (stepCnt==1);
assign stbAuto1 = !reset & (stepCnt==3);
assign stbAuto2 = !reset & (stepCnt==5);
assign stbInd   = !reset & (stepCnt==7);
assign stb1     = !reset & (stepCnt==9);
assign stb2     = !reset & (stepCnt==11);
assign stb3     = !reset & (stepCnt==13);
assign stb4     = !reset & (stepCnt==15);
assign stb5     = !reset & (stepCnt==17);

endmodule
