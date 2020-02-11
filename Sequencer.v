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
  input RUN,              // Rising edge starts continous run
  input HALT,             // Rising edge halts at next instruction
  input [1:0] SEQTYPE,    // ({instIsPPIND,instIsIND}),
  output CK_FETCH, CK_AUTO1, CK_AUTO2, CK_IND,
  output CK_1, CK_2, CK_3, CK_4, CK_5, CK_6,
  output STB_FETCH, STB_AUTO1, STB_AUTO2, STB_IND,
  output STB_1, STB_2, STB_3, STB_4, STB_5, STB_6,
  output reg running=0
);

reg [4:0] stepCnt; 
wire run;
Debounce_Switch debRun(CLK, RUN, run);
 
always @(posedge CLK) begin 
    if (RESET) begin
        running<=0;
        stepCnt<=31;
    end 
    else 
    if (DONE) begin
        stepCnt<=0;
    end
    else
    begin
        if (run) running<=1;
        if (HALT) running<=0;
        if (running) begin
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

assign CK_FETCH  = !RESET & (stepCnt==0 || stepCnt==1);
assign CK_AUTO1  = !RESET & (stepCnt==2 || stepCnt==3);
assign CK_AUTO2  = !RESET & (stepCnt==4 || stepCnt==5);
assign CK_IND    = !RESET & (stepCnt==6 || stepCnt==7);
assign CK_1      = !RESET & (stepCnt==8 || stepCnt==9);
assign CK_2      = !RESET & (stepCnt==10 || stepCnt==11);
assign CK_3      = !RESET & (stepCnt==12 || stepCnt==13);
assign CK_4      = !RESET & (stepCnt==14 || stepCnt==15);
assign CK_5      = !RESET & (stepCnt==16 || stepCnt==17);
assign CK_6      = !RESET & (stepCnt==18 || stepCnt==19);

assign STB_FETCH = !RESET & (stepCnt==1);
assign STB_AUTO1 = !RESET & (stepCnt==3);
assign STB_AUTO2 = !RESET & (stepCnt==5);
assign STB_IND   = !RESET & (stepCnt==7);
assign STB_1     = !RESET & (stepCnt==9);
assign STB_2     = !RESET & (stepCnt==11);
assign STB_3     = !RESET & (stepCnt==13);
assign STB_4     = !RESET & (stepCnt==15);
assign STB_5     = !RESET & (stepCnt==17);
assign STB_6     = !RESET & (stepCnt==19);

endmodule



/* verilator lint_off DECLFILENAME */
// FIXME
module Debounce_Switch (input i_Clk, input i_Switch, output o_Switch);
 
  parameter c_DEBOUNCE_LIMIT = 250000;  // 10 ms at 25 MHz
   
  reg [17:0] r_Count = 0;
  reg r_State = 1'b0;
 
  always @(posedge i_Clk)
  begin
    // Switch input is different than internal switch value, so an input is
    // changing.  Increase the counter until it is stable for enough time.  
    if (i_Switch !== r_State && r_Count < c_DEBOUNCE_LIMIT)
      r_Count <= r_Count + 1;
 
    // End of counter reached, switch is stable, register it, reset counter
    else if (r_Count == c_DEBOUNCE_LIMIT)
    begin
      r_State <= i_Switch;
      r_Count <= 0;
    end 
 
    // Switches are the same state, reset the counter
    else
      r_Count <= 0;
  end
 
  // Assign internal register to output (debounced!)
  assign o_Switch = r_State;
 
endmodule
/* verilator lint_on DECLFILENAME */
