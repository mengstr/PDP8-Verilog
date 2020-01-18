`default_nettype none

//
// 6030 - KCF Keyboard Clear Flags
//  The keyboard flag, signalling input data ready, is cleared. 
//
// 6031 - KSF Keyboard Skip if Flag
//  If the keyboard flag is set, indicating that input data is ready, the next instruction in sequence is skipped.
//
// 6032 - KCC Keyboard Clear and read character
//  The keyboard flag is reset, the accumulator is cleared, and the process of reading the next character of input is initiated.
//
// 6033 - ?
//
// 6034 - KRS Keyboard Read Static
//  The 8-bit character in the keyboard buffer is ored with the accumulator.
//
// 6035 - KIE Keyboard Interrupt Enable
//  The accumulator is loaded into the device control register (the interrupt enable and status report control bits). 
//
// 6036 - KRB Keyboard Read and begin next read
//  The 8 bit character in the keyboard buffer is transferred to the accumulator, and the keyboard flag is cleared, allowing the 
//  reading of the next character to begin. In effect, this operation combines the KCC and KRS operations;
//
// 6037 - ?
//
// 6040 - TFL Teleprinter Flag set
//  The printer flag, signalling output complete, is set. 
//
// 6041 - TSF Teleprinter Skip if Flag
//  If the printer flag is set, indicating output is complete, the next instruction in sequence is skipped. 
//
// 6042 - TCF Teleprinter Clear Flag
//  The printer flag is reset.
//
// 6043 - ?
//
// 6044 - TPC Teleprinter Print Character
//  The least significant 8-bits of the accumulator is copied to the print buffer, initiating output. 
//
// 6045 - TSK Teleprinter Skip
//  If either the print flag or the keyboard flag are set, the next instruction in sequence is skipped. 
//
// 6046 - TLS Teleprinter Load and start
//  The least significant 8 bits of the accumulator are copied to the print buffer, initiating output, and the printer flag is 
//  reset. In effect, this operation combines the TCF and TPC operations.
//
// 6047 - ?
//


module TTY(
  input CLK,
  input clear,
  input EN1,                             // High when this module is to be activated  603x
  input EN2,                             // High when this module is to be activated  604x
  input [2:0] IR,
  input ACbit11,
  input ck1,ck2,ck3,ck4,ck5,ck6,
  input stb1,stb2,stb3,stb4,stb5,stb6,
  output done,
  output pc_ck,
  output irq
);

reg flgKBDIE=0;
reg flgKBD=0;
reg flgTTY=0;
or(irq, flgKBD, flgTTY);

wire     done30, done35, done40, done41;
or(done, done30, done35, done40, done41);

wire pc_ck1;
or (pc_ck, pc_ck1);

wire instKCF=(EN1 & (IR==3'o0)); //Keyboard Clear Flags
wire instKSF=(EN1 & (IR==3'o1)); //Keyboard Skip if Flag
wire instKCC=(EN1 & (IR==3'o2)); //Keyboard Clear and read character
// TODO Handle 6033
wire instKRS=(EN1 & (IR==3'o4)); //Keyboard Read Static
wire instKIE=(EN1 & (IR==3'o5)); //Keyboard Interrupt Enable
wire instKRB=(EN1 & (IR==3'o6)); //Keyboard Read and begin next read
// TODO Handle 6037
wire instTFL=(EN2 & (IR==3'o0)); //Teleprinter Flag set
wire instTSF=(EN2 & (IR==3'o1)); //Teleprinter Skip if Flag
// TODO Handle 6042
// TODO Handle 6043
wire instTPC=(EN2 & (IR==3'o4)); //Teleprinter Print Character
wire instTSK=(EN2 & (IR==3'o5)); //Teleprinter Skip
wire instTLS=(EN2 & (IR==3'o6)); //Teleprinter Load and start
// TODO Handle 6047

always @(posedge CLK) begin
    if (clear)   begin
        flgKBDIE<=0;
        flgKBD<=0;
        flgTTY<=0;
    end
    if (instKIE) flgKBDIE<=ACbit11; ////Keyboard Interrupt Set/Reset
    if (instKCF) flgKBD<=0; //Keyboard Clear Flags
    if (instTFL) flgTTY<=1; //Teleprinter Flag set
end

assign done30 = instKCF & ck1;
assign done35 = instKIE & ck1;
assign done40 = instTFL & ck1;

assign pc_ck1=   (instTSF & flgTTY & stb1);
assign done41 = instTSF & ck2;



endmodule


//
// FLAG_KBD: reset IOT_KCF or IOT_KCC or IOT_KRB or RESET
//           set   TTY_RDY
//
// FLAG_KBDIE: reset (IOT_KIE and AC11=0)
//             set   IOT_CAF or (IOT_KIE and AC11=1) or RESET
//
// FLAG_PRNCOMPLETE: reset RisingEdge(IOT_TLS or IOT_TCF or IOT_CAF or RESET)
//                   set   RisingEdge(IOT_TFL or TTY_BSY)
//
// IRQ=FLAG_KBIE and (FLAG_PRNCOMPLETE or FLAG_KBD)
//
// TTY_STB=IOT_TPC or TIO_TLS
//
// TeleprinterSkip=IOT_TSF and (FLAG_PRNCOMPLETE)
// TeleprinterSkip=IOT_TSK and (FLAG_PRNCOMPLETE or FLAG_KBD)
//
// KeyboardSkip=IOT_KSF and FLAG_KBD
//
//
//-----------------------------
//

