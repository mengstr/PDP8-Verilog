`default_nettype none

//
// SKON     6000  skip if interrupt ON, and turn OFF
//
// ION      6001  turn interrupt ON
//
// IOF      6002  turn interrupt OFF
//
// SRQ      6003  skip interrupt request
//
// GTF      6004  get interrupt flags
//
// RTF      6005  restore interrupt flags
//
// SGT      6006  Skip on Greater Than flag - In EAE-equipped systems, the next 
//                instruction is skipped if the "GT" flag is set.
//
// CAF      6007  Clear all flags - The user Link and AC are cleared.  If EAE
//                is present, then it is set to mode "A" and the "GT" flag is 
//                cleared.  All assigned devices are de-assigned.
//

module INTERRUPT(
  input CLK,
  input clear,
  input EN,                             // High when this module is to be activated
  input [2:0] IR,
  input ck1,ck2,ck3,ck4,ck5,ck6,
  input stb1,stb2,stb3,stb4,stb5,stb6,
  output done,
  output rot2ac,
  output ac_ck,
  output clr,
  output linkclr,
  output link_ck
);

wire done1;
or(done, done1);

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

assign rot2ac=  instCAF & ck1;
assign clr=     instCAF & ck1;
assign linkclr= instCAF & ck1;
assign ac_ck=   instCAF & stb1;
assign link_ck= instCAF & stb1;

assign done1=   EN & ck2;


//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 


endmodule
