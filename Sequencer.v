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
  input done,             // Reset step counter before the natural end at step 31
  input halt,             // Rising edge halts at next instruction
  input startstop,        // Strobe -  toggles continous run/halt
  input sst,              // Strobe - executes one instruction 
  input [1:0] SEQTYPE,    // ({instIsPPIND,instIsIND}),
  output ckFetch, ckAuto1, ckAuto2, ckInd,
  output ck1, ck2, ck3, ck4, ck5,
  output stbFetch, stbAuto1, stbAuto2, stbInd,
  output stb1, stb2, stb3, stb4, stb5,
  output stbFetch2,
  output reg running=0
);

localparam EXTRA_FETCH=1;
if (EXTRA_FETCH==0) assign stbFetch2 = 0;

reg [4:0] stepCnt; 
reg haltAt1=0;
reg lastSst=0;
reg lastHalt=0;
reg lastReset=0;
reg lastStartstop=0;

always @(posedge clk) begin 
    if (reset) begin
        running    <= 0;
        stepCnt    <= 0;
        haltAt1 <= 0;
    end 
    
    // Auto-trigger a single instruction run at release of reset
    if (~reset & lastReset) begin running <= 1; haltAt1<=1; end
    lastReset <= reset;

    // Toggle running flag on rising edge of startstop
    if (startstop & ~lastStartstop) begin
      if (~running) begin
        running <= 1;
        haltAt1 <= 0;
      end
      if (running) haltAt1 <= 1;
    end
    lastStartstop <= startstop;

    // Turn off running flag if halt
    if (halt & ~lastHalt) begin
      if (running) haltAt1 <= 1;
    end
    lastHalt <= halt;

    // Execute a single instruction on rising edge of sst
    if (sst & ~lastSst) begin running <=1; haltAt1<=1; end
    lastSst <= sst;

    if (running) begin
      // If single stepping or asked to halt then stop at step1
      if (haltAt1 & stepCnt==0) running<=0;
      // Restart step counter when done is signalled
      if (done) stepCnt <= 0;
      else if (stepCnt==1+EXTRA_FETCH) begin
          case (SEQTYPE)
              2'b00: stepCnt <= stepCnt+7;
              2'b01: stepCnt <= stepCnt+5;
              2'b10: stepCnt <= stepCnt+1; 
              2'b11: stepCnt <= stepCnt+1;
          endcase
      end else begin
        stepCnt <= stepCnt+1;
      end
    end

end

assign ckFetch  = !reset & (stepCnt==0 || stepCnt==1 || stepCnt==2);
assign ckAuto1  = !reset & (stepCnt==2+EXTRA_FETCH || stepCnt==3+EXTRA_FETCH);
assign ckAuto2  = !reset & (stepCnt==4+EXTRA_FETCH || stepCnt==5+EXTRA_FETCH);
assign ckInd    = !reset & (stepCnt==6+EXTRA_FETCH || stepCnt==7+EXTRA_FETCH);
assign ck1      = !reset & (stepCnt==8+EXTRA_FETCH || stepCnt==9+EXTRA_FETCH);
assign ck2      = !reset & (stepCnt==10+EXTRA_FETCH || stepCnt==11+EXTRA_FETCH);
assign ck3      = !reset & (stepCnt==12+EXTRA_FETCH || stepCnt==13+EXTRA_FETCH);
assign ck4      = !reset & (stepCnt==14+EXTRA_FETCH || stepCnt==15+EXTRA_FETCH);
assign ck5      = !reset & (stepCnt==16+EXTRA_FETCH || stepCnt==17+EXTRA_FETCH);

assign stbFetch = !reset & (stepCnt==1);
assign stbFetch2 = !reset & (stepCnt==2);
assign stbAuto1 = !reset & (stepCnt==3+EXTRA_FETCH);
assign stbAuto2 = !reset & (stepCnt==5+EXTRA_FETCH);
assign stbInd   = !reset & (stepCnt==7+EXTRA_FETCH);
assign stb1     = !reset & (stepCnt==9+EXTRA_FETCH);
assign stb2     = !reset & (stepCnt==11+EXTRA_FETCH);
assign stb3     = !reset & (stepCnt==13+EXTRA_FETCH);
assign stb4     = !reset & (stepCnt==15+EXTRA_FETCH);
assign stb5     = !reset & (stepCnt==17+EXTRA_FETCH);

endmodule


// ckFetch and stbFetch are used in:
//-------------------------------------
//   PDP8.v
//    Affects busAddress via busAddress_pc
//
//
//   InstructionFetch.v
//      Affects ram_oe and pc_ck
//      Afects programCounters CK and FETCH
//      Affects InstructionRegisters LATCH
//
//   InstructionIOT600x.v
//      Affects irqOverride
//

//
//
//           AAAAAAAAAAA B     C     D     E     F     AAAAAAAAAAAAA
//           +-----+-----+-----+-----+                 +-----+-----+
// ckFetch                           |                 |            
//                                   +-----+-----+-----+ 
//          
//                       +-----+                                     
// stbFetch1             |     |                                    
//           +-----+-----+     +-----+-----+-----+-----+-----+-----+
//          
//                             +-----+                               
// stbFetch2                   |     |                              
//           +-----+-----+-----+     +-----+-----+-----+-----+-----+
//          
//                                   +-----+-----+                   
//  ck1                              |           |                  
//           +-----+-----+-----+-----+           +-----+-----+-----+
//          
//                                         +-----+                   
//  stb1                                   |     |                  
//           +-----+-----+-----+-----+-----+     +-----+-----+-----+
//          
//                                               +-----+             
//  done                                         |     |            
//           +-----+-----+-----+-----+-----+-----+     +-----+-----+
//           AAAAAAAAAAA B     C     D     E     F     AAAAAAAAAAAAA
//          
//
// A Idle state - Enable ramOE, output PC onto addressBus