//
// InstructionIOT600x.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

//
// 6000 - SKON Skip if interrupt ON, and turn OFF.  SKON is used to test the state of the interrupt enable 
//             flipflop. If interrupts are enabled, the next instruction in sequence is skipped.
//
// 6001 - ION Turn interrupt ON. The effect of this instruction is delayed one instruction so that, for example, 
//            an ION instruction immediately before a return instruction will not take effect until the return 
//            instruction is executed.
//
// 6002 - IOF Turn interrupt OFF. The effect of this instruction is immediate. In addition, interrupts are 
//            disabled immediately when an interrupt occurs.
//
// 6003 - SRQ Skip interrupt request. SRQ is used to test whether there is a pending interrupt request. If a 
//            request is pending, the next instruction in sequence is skipped. This test is only meaningful 
//            when interrupts are disabled; it may be used, for example, to avoid the expense of an unnecessary 
//            return from interrupt when some device other than the one just serviced is also requesting service.
//
// 6004 - GTF Get interrupt flags. GTF loads the accumulator with various information that may need to be saved 
//            and restored during interrupts. This includes the link bit, the state of the optional memory 
//            management unit, and the greater-than flag from the optional extended arithmetic unit. These are 
//            packed into the accumulator
//
//            00 01 02  03 04 05  06 07 08  09 10 11
//            ______________________________________
//           |  |  |  ||  |  |  ||  |  |  ||  |  |  |
//           |__|__|__||__|__|__||__|__|__||__|__|__|
//           |  |  |  ||  |  |  ||        ||        |
//          LINK GT IR  II IE U   0  IF 0  DF0 DF1 DF2
// 0200       0  0  0   0  1  0   0 .0  0   0   0   0
//
//            LINK -- the link bit.
//            GT -- the Greater Than bit (see the SGT instruction supported by the extended arithmetic element.
//            IR -- the interrupt request status, as tested by SRQ. This is set to one if an interrupt requesting is pending.
//            II -- the interrupt inhibit bit associated with the Time-Share option of the memory management unit.
//            IE -- the state of the interrupt enable flipflop, as set by the ION and reset by the IOF instructions. This is set to one if interrupts are enabled.
//            U -- the user-mode bit.
//            IF -- the instruction field.
//            DF -- the data field.
//
// 6005 - RTF Restore interrupt flags. RTF restores the state of the flags that are saved by the GTF instruction, using the 
//            same data format. RTF ignores the IR (interrupt request) bit that was saved by GTF, and the IE (interrupt enable)
//            bit is not fully restored until the instruction after the RTF instruction, so that a return from interrupt may 
//            be executed before the next interrupt request is serviced.
//
// 6006 - SGT Skip on Greater Than flag - In EAE-equipped systems, the next instruction is skipped if the "GT" flag is set.
//
// 6007 - CAF Clear all flags - AC and LINK are cleared, interrupts are disabled globally, and all I/O devices are reset.
//            If EAE is present, then it is set to mode "A" and the "GT" flag is cleared.
//

module InstructionIOT600x(
  input clk,
  input reset,
  input CLEAR,
  input EN,                             // High when this module is to be activated
  input [2:0] IR,
  input [11:0] AC,
  input LINK,
  input ckFetch, ck1,ck2,ck3,ck4,ck5,ck6,
  input stbFetch,stb1,stb2,stb3,stb4,stb5,stb6,
  input irqRq,
  input anyDone,
  output done,
  output rot2ac,
  output ac_ck,
  output clr,
  output ACclr,
  output linkclr,
  output linkcml,
  output link_ck,
  output pc_ck,
  output [11:0] ACGTF,
  output GIE,
  output irqOverride
);

reg IE;
reg IEdly1, IEdly2;
reg irqActive;

wire        link_ck5, link_ck7;
or(link_ck, link_ck5, link_ck7);

wire        linkclr5, linkclr7;
or(linkclr, linkclr5, linkclr7);

wire        linkcml5;
or(linkcml, linkcml5);

wire    clr7;
or(clr, clr7);

wire       rot2ac4, rot2ac7;
or(rot2ac, rot2ac4, rot2ac7);

wire      ac_ck4, ac_ck7;
or(ac_ck, ac_ck4, ac_ck7);

wire      pc_ck0, pc_ck3;
or(pc_ck, pc_ck0, pc_ck3);

wire     done0, done1, done2, done3, done4, done5, done7;
or(done, done0, done1, done2, done3, done4, done5, done7);

wire instSKON=(EN & (IR==3'o0));
wire instION= (EN & (IR==3'o1));
wire instIOF= (EN & (IR==3'o2));
wire instSRQ= (EN & (IR==3'o3));
wire instGTF= (EN & (IR==3'o4));
wire instRTF= (EN & (IR==3'o5));
wire instSGT= (EN & (IR==3'o6));
wire instCAF= (EN & (IR==3'o7));

wire AC8=~AC[8];
wire preIrq;

always @(posedge clk) begin
  if (CLEAR | reset)       begin IE<=0; IEdly1<=0; IEdly2<=0; irqActive<=0; end
  if (ckFetch & ~stbFetch & preIrq)    begin irqActive<=1; end
  if (stb1 & instCAF)      begin IE<=0; IEdly1<=0; IEdly2<=0; end
  if (stb1 & instIOF)      begin IE<=0; IEdly1<=0; IEdly2<=0; end
  if (stb1 & instSKON)     begin IE<=0; IEdly1<=0; IEdly2<=0; end
  if (stb1 & instRTF)      begin IE<=AC8; IEdly1<=AC8; IEdly2<=AC8; end

  if (stb1 & instION)      begin IE<=1; IEdly1<=1; IEdly2<=1; end
  if (anyDone & IEdly1)           begin IEdly1<=0; end
  if (anyDone & IEdly2 & ~IEdly1) begin IEdly2<=0; end
  // if (anyDone & GIE & irqRq)      begin IE<=0; end
  if (anyDone & GIE & irqActive)      begin IE<=0; irqActive<=0; end
end

assign GIE=IE & ~IEdly1 & ~IEdly2;
assign preIrq=GIE & irqRq;
assign irqOverride=preIrq & (irqActive | ckFetch);

//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
assign pc_ck0=    instSKON & stb1 & IE;           // 6000 SKON
assign done0=     instSKON & ck2;

//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
assign done1 =    instION & ck2;                  // 6001 ION
assign done2 =    instIOF & ck2;                  // 6002 IOF

//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
assign pc_ck3=    instSRQ & stb1 & irqRq;         // 6003 SRQ
assign done3=     instSRQ & ck2;

reg IF=0;       // TODO Instruction Field
reg [2:0] DF=0; // TODO Data Field
reg GT=0;       // TODO Greater Than
reg II=0;       // TODO Interrupt Inhibit bit 
reg U=0;        // TODO User mode flag

//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
assign rot2ac4=   instGTF & ck1;                  // 6004 GTF
assign ACGTF =    instGTF & ck1 ? {LINK, GT, irqRq, II, IE , U, 1'b0, IF, 1'b0, DF} : 12'b0;
assign ACclr=     instGTF & ck1;
assign ac_ck4=    instGTF & stb1;
assign done4=     instGTF & ck2;

//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
assign linkclr5=  instRTF & ck1;                  // 6005 RTF
assign linkcml5=  instRTF & ck1 & AC[11]; // GIE is updated in the always @(posedge
assign link_ck5=  instRTF & stb1;
assign done5 =    instRTF & ck2;

//                            1     1      2     2      3     3      4     4      5     5      6     6
//                            ### | #### | ### | #### | ### | #### | ### | #### | ### | #### | ### | #### 
assign rot2ac7=   instCAF & ck1;                  // 6007 CAF
assign clr7=      instCAF & ck1;
assign linkclr7=  instCAF & ck1;
assign ac_ck7=    instCAF & stb1;
assign link_ck7=  instCAF & stb1;
assign done7=     instCAF & ck2;

endmodule


// FROM SIMH
//    2. Interrupts.  Interrupts are maintained by three parallel variables:

//         dev_done        device done flags
//         int_enable      interrupt enable flags
//         int_req         interrupt requests

//       In addition, int_req contains the interrupt enable flag, the
//       CIF not pending flag, and the ION not pending flag.  If all
//       three of these flags are set, and at least one interrupt request
//       is set, then an interrupt occurs.
//
// int32 dev_done = 0;                                     /* dev done flags */
// int32 int_enable = INT_INIT_ENABLE;                     /* intr enables */
// int32 int_req = 0;                                      /* intr requests */
//     { FLDATAD (ION, int_req, INT_V_ION, "interrupt enable") },
//     { FLDATAD (ION_DELAY, int_req, INT_V_NO_ION_PENDING, "interrupt enable delay for ION") },
//     { FLDATAD (CIF_DELAY, int_req, INT_V_NO_CIF_PENDING, "interrupt enable delay for CIF") },
//     { ORDATAD (INT, int_req, INT_V_ION+1, "interrupt pending flags"), REG_RO },
//     { ORDATAD (DONE, dev_done, INT_V_DIRECT, "device done flags"), REG_RO },
//     { ORDATAD (ENABLE, int_enable, INT_V_DIRECT, "device interrupt enable flags"), REG_RO },

//     if (int_req > INT_PENDING) {                        /* interrupt? */
//         int_req = int_req & ~INT_ION;                   /* interrupts off */
//         SF = (UF << 6) | (IF >> 9) | (DF >> 12);        /* form save field */
//         PCQ_ENTRY (IF | PC);                            /* save old PC with IF */
//         IF = IB = DF = UF = UB = 0;                     /* clear mem ext */
//         M[0] = PC;                                      /* save PC in 0 */
//         PC = 1;                                         /* fetch next from 1 */
//     }

//     PC = (PC + 1) & 07777;                              /* increment PC */
//     int_req = int_req | INT_NO_ION_PENDING;             /* clear ION delay */

            // case 0:                                     /* SKON */
            //     if (int_req & INT_ION)
            //         PC = (PC + 1) & 07777;
            //     int_req = int_req & ~INT_ION;
            //     break;

            // case 1:                                     /* ION */
            //     int_req = (int_req | INT_ION) & ~INT_NO_ION_PENDING;
            //     break;

            // case 2:                                     /* IOF */
            //     int_req = int_req & ~INT_ION;
            //     break;

            // case 3:                                     /* SRQ */
            //     if (int_req & INT_ALL)
            //         PC = (PC + 1) & 07777;
            //     break;

            // case 4:                                     /* GTF */
            //     LAC = (LAC & 010000) |
            //           ((LAC & 010000) >> 1) | (gtf << 10) |
            //           (((int_req & INT_ALL) != 0) << 9) |
            //           (((int_req & INT_ION) != 0) << 7) | SF;
            //     break;

            // case 5:                                     /* RTF */
            //     gtf = ((LAC & 02000) >> 10);
            //     UB = (LAC & 0100) >> 6;
            //     IB = (LAC & 0070) << 9;
            //     DF = (LAC & 0007) << 12;
            //     LAC = ((LAC & 04000) << 1) | iot_data;
            //     int_req = (int_req | INT_ION) & ~INT_NO_CIF_PENDING;
            //     break;

            // case 6:                                     /* SGT */
            //     if (gtf)
            //         PC = (PC + 1) & 07777;
            //     break;

            // case 7:                                     /* CAF */
            //     gtf = 0;
            //     emode = 0;
            //     int_req = int_req & INT_NO_CIF_PENDING;
            //     dev_done = 0;
            //     int_enable = INT_INIT_ENABLE;
            //     LAC = 0;
            //     reset_all (1);                          /* reset all dev */
            //     break;
            //     }                                       /* end switch pulse */
            // break;           
            