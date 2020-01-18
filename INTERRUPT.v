`default_nettype none

//
// 6000 - SKON Skip if interrupt ON, and turn OFF
//
// 6001 - ION Turn interrupt ON
//
// 6002 - IOF Turn interrupt OFF
//
// 6003 - SRQ Skip interrupt request
//
// 6004 - GTF Get interrupt flags
//
// 6005 - RTF Restore interrupt flags
//
// 6006 - SGT Skip on Greater Than flag - In EAE-equipped systems, the next instruction is skipped if the "GT" flag is set.
//
// 6007 - CAF Clear all flags - The user Link and AC are cleared.  If EAE is present, then it is set to mode "A" and the "GT" 
//            flag is cleared.  All assigned devices are de-assigned.
//

module INTERRUPT(
  input CLK,
  input clear,
  input EN,                             // High when this module is to be activated
  input [2:0] IR,
  input ck1,ck2,ck3,ck4,ck5,ck6,
  input stb1,stb2,stb3,stb4,stb5,stb6,
  input irqRq,
  output done,
  output rot2ac,
  output ac_ck,
  output clr,
  output linkclr,
  output link_ck,
  output pc_ck
);

wire irqRqPulldown = (irqRq === 1'dx) ? 1'b0 : irqRq;

wire      ac_ck7;
or(ac_ck, ac_ck7);

wire      pc_ck3;
or(pc_ck, pc_ck3);

wire     done1, done2, done3, done7;
or(done, done1, done2, done3, done7);

wire instSKON=(EN & (IR==3'o0));
wire instION= (EN & (IR==3'o1));
wire instIOF= (EN & (IR==3'o2));
wire instSRQ= (EN & (IR==3'o3));
wire instGTF= (EN & (IR==3'o4));
wire instRTF= (EN & (IR==3'o5));
wire instSGT= (EN & (IR==3'o6));
wire instCAF= (EN & (IR==3'o7));

reg flgION=0;

always @(posedge CLK) begin
    if (clear)   flgION<=0;
    if (instIOF) flgION<=0;
    if (instCAF) flgION<=0;
    if (instION) flgION<=1;
end
assign done1 = instION & ck1;
assign done2 = instIOF & ck1;

assign pc_ck3=  instSRQ & stb1 & irqRqPulldown;
assign done3=   instSRQ & ck2;

assign rot2ac=  instCAF & ck1;
assign clr=     instCAF & ck1;
assign linkclr= instCAF & ck1;
assign ac_ck7=  instCAF & stb1;
assign link_ck= instCAF & stb1;
assign done7=   instCAF & ck2;

//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 

endmodule

//
// FLAG_ION: reset IOT_IOF or IRQ_JMS or IOT_CAF or IOT_SKON or RESET 
//           set   IOT_ION or RTF_ION
//
// SkipInterruptRequest IOT_SRQ and IRQ_BUS
//

