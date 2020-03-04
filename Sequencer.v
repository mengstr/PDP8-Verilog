//
// Sequencer.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//
// Sequencer | 0 | 8 | 0 | 20
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
  output ck1, ck2, ck3, ck4,
  output stbFetchA, stbAuto1, stbAuto2, stbInd,
  output stb1, stb2, stb3, stb4, 
  output stbFetchB,
  output reg running=0
);


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
      else if (stepCnt==2) begin
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

assign ckFetch   = stepCnt==0 || stepCnt==1 || stepCnt==2;
assign stbFetchA = stepCnt==1;
assign stbFetchB = stepCnt==2;

assign ckAuto1   = stepCnt==3 || stepCnt==4;
assign stbAuto1  = stepCnt==4;
assign ckAuto2   = stepCnt==5 || stepCnt==6;
assign stbAuto2  = stepCnt==6;

assign ckInd     = stepCnt==7 || stepCnt==8;
assign stbInd    = stepCnt==8;

assign ck1       = stepCnt==9 || stepCnt==10;
assign stb1      = stepCnt==10;
assign ck2       = stepCnt==11 || stepCnt==12;
assign stb2      = stepCnt==12;
assign ck3       = stepCnt==13 || stepCnt==14;
assign stb3      = stepCnt==14;
assign ck4       = stepCnt==15 || stepCnt==16;
assign stb4      = stepCnt==16;


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