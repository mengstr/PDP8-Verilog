//
// InstructionIOT603x - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

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


module InstructionIOT603x(
  input clk,
  input clear,
  input baudX7,
  input EN1,                             // High when this module is to be activated  603x
  input EN2,                             // High when this module is to be activated  604x
  input [2:0] op,
  input [11:0] AC,
  input ck1, ck2, ck3, ck4, ck5,
  input stb1,stb2,stb3,stb4,stb5,
  output done,
  output pc_ck,
  output irq,
  input rx,
  output tx,
  output LED2,
  output [11:0] ACTTY,
  output rot2ac,
  output clr,
  output ac_ck
);

reg [7:0] txData=0;
reg txStb=0;
wire txRdy;
wire rxRdy;
wire [7:0] rxData;
reg rxAck=0;

UART uart(
    .clk(clk),
    .baudX7(baudX7),
    .txData(txData),
    .txStb(txStb),
    .tx(tx),
    .txRdy(txRdy),
    .rx(rx),
    .rxData(rxData),
    .rxRdy(rxRdy),
    .rxAck(rxAck)
);


reg [5:0] txtick;

reg flgTTYIE=0;
reg flgKBD=0;
reg flgPRN=0;
assign irq=(flgTTYIE) & (flgKBD | flgPRN);

wire     done30, done31, done35, done36, done40, done41, done42, done44, done45, done46;
or(done, done30, done31, done35, done36, done40, done41, done42, done44, done45, done46);

wire       pc_ck31, pc_ck41, pc_ck45;
or (pc_ck, pc_ck31, pc_ck41, pc_ck45);

wire       rot2ac36;
or(rot2ac, rot2ac36);

wire      clr36;
or(clr, clr36);

wire      ac_ck36;
or(ac_ck, ac_ck36);


wire instKCF=(EN1 & (op==3'o0)); // 6030 Keyboard Clear Flags
wire instKSF=(EN1 & (op==3'o1)); // 6031 Keyboard Skip if Flag
wire instKCC=(EN1 & (op==3'o2)); // 6032 Keyboard Clear and read character
                                 // 6033 invalid
wire instKRS=(EN1 & (op==3'o4)); // 6034 Keyboard Read Static
wire instKIE=(EN1 & (op==3'o5)); // 6035 Keyboard Interrupt Enable
wire instKRB=(EN1 & (op==3'o6)); // 6036 Keyboard Read and begin next read
                                 // 6037 invalid
wire instTFL=(EN2 & (op==3'o0)); // 6040 Teleprinter Flag set
wire instTSF=(EN2 & (op==3'o1)); // 6041 Teleprinter Skip if Flag
wire instTFC=(EN2 & (op==3'o2)); // 6042 Teleprinter Flag clear
                                 // 6043 invalid
wire instTPC=(EN2 & (op==3'o4)); // 6044 Teleprinter Print Character
wire instTSK=(EN2 & (op==3'o5)); // 6045 Teleprinter Skip
wire instTLS=(EN2 & (op==3'o6)); // 6046 Teleprinter Load and start
                                // 6047 invalid

wire ACbit11=AC[0:0]; // PDP has the bit order reversed

reg lastTxRdy=0;
reg lastRxRdy=0;
reg [1:0] cnt=0;

always @(posedge clk) begin
    if (clear) begin
        flgTTYIE<=1;
        flgKBD<=0;
        flgPRN<=0;
        lastTxRdy<=1;
    end else begin
      if (instKIE) flgTTYIE<=ACbit11; ////Keyboard Interrupt Set/Reset
      if (instKCF) flgKBD<=0; //Keyboard Clear Flags
      if (instKRB) flgKBD<=0; //Keyboard Clear Flags
      if (instTFL) flgPRN<=1; //Teleprinter Flag set
      if (instTFC) flgPRN<=0; //Teleprinter Flag clear
      if (instTPC) begin
`ifdef IVERILOG
      if (ck1) $display("TX %d (%c)", {1'b0,AC[6:0]},{1'b0,AC[6:0]} );
`endif
      if (ck1) begin txData<={1'b0,AC[6:0]}; txStb<=1; end;
    end
    if (instTLS) begin      //Teleprinter Load and start
      flgPRN<=0;
`ifdef IVERILOG
      if (ck1) $display("TX %d [%c]", {1'b0,AC[6:0]},{1'b0,AC[6:0]} );
`endif
      if (ck1) begin txData<={1'b0,AC[6:0]}; txStb<=1; end;
    end
    if (txStb==1) txStb<=0; 
    if (txRdy & ~lastTxRdy) flgPRN<=1;
    lastTxRdy<=txRdy;
    if (rxRdy) begin
      cnt<=cnt+1;
      if (rxRdy & ~lastRxRdy) flgKBD<=1;
      rxAck<=1;
    end
    if (rxAck==1) rxAck<=0; 
    lastRxRdy<=rxRdy;
  end
end
assign LED2=cnt[0];



//  TTY2.PAL tests 6031-KSF, 6032-KCC, 6036-KRB, 6041-TSF, 6046-TLS
//


// ------------------------------------------------------------------------------------------------------------------------------
// 6030 - KCF Keyboard Clear Flags
//  The keyboard flag, signalling input data ready, is cleared. 
assign done30 = instKCF & ck1;

// ------------------------------------------------------------------------------------------------------------------------------
// 6031 - KSF Keyboard Skip if Flag
//  If the keyboard flag is set, indicating that input data is ready, the next instruction in sequence is skipped.
assign pc_ck31= instKSF & flgKBD & stb1;
assign done31 = instKSF & ck2;

// ------------------------------------------------------------------------------------------------------------------------------
// 6032 - KCC Keyboard Clear and read character
//  The keyboard flag is reset, the accumulator is cleared, and the process of reading the next character of input is initiated.
//FIXME instKCC

// ------------------------------------------------------------------------------------------------------------------------------
// 6034 - KRS Keyboard Read Static
//  The 8-bit character in the keyboard buffer is ored with the accumulator.
//FIXME instKRS

// ------------------------------------------------------------------------------------------------------------------------------
// 6035 - KIE Keyboard Interrupt Enable
//  The accumulator is loaded into the device control register (the interrupt enable and status report control bits). 
assign done35 = instKIE & ck1;

// ------------------------------------------------------------------------------------------------------------------------------
// 6036 - KRB Keyboard Read and begin next read
//  The 8 bit character in the keyboard buffer is transferred to the accumulator, and the keyboard flag is cleared, allowing the 
//  reading of the next character to begin. In effect, this operation combines the KCC and KRS operations;
assign rot2ac36=   instKRB & ck1; 
assign ACTTY =     instKRB & ck1 ? {4'b0,  rxData} : 12'b0;
assign clr36=      instKRB & ck1;
assign ac_ck36=    instKRB & stb1;
assign done36=     instKRB & ck2;


// ------------------------------------------------------------------------------------------------------------------------------
// 6040 - TFL Teleprinter Flag set
//  The printer flag, signalling output complete, is set. 
assign done40 = instTFL & ck1;

// ------------------------------------------------------------------------------------------------------------------------------
// 6041 - TSF Teleprinter Skip if Flag
//  If the printer flag is set, indicating output is complete, the next instruction in sequence is skipped. 
assign pc_ck41= instTSF & flgPRN & stb1;
assign done41 = instTSF & ck2;

// ------------------------------------------------------------------------------------------------------------------------------
// 6042 - TCF Teleprinter Clear Flag
//  The printer flag is reset.
assign done42 = instTFC & ck1;

// ------------------------------------------------------------------------------------------------------------------------------
// 6044 - TPC Teleprinter Print Character
//  The least significant 8-bits of the accumulator is copied to the print buffer, initiating output. 
assign done44 = instTPC & ck1;

// ------------------------------------------------------------------------------------------------------------------------------
// 6045 - TSK Teleprinter Skip
//  If either the print flag or the keyboard flag are set, the next instruction in sequence is skipped. 
assign pc_ck45= instTSF & (flgPRN | flgKBD) & stb1;
assign done45 = instTSF & ck2;

// ------------------------------------------------------------------------------------------------------------------------------
// 6046 - TLS Teleprinter Load and start
//  The least significant 8 bits of the accumulator are copied to the print buffer, initiating output, and the printer flag is 
//  reset. In effect, this operation combines the TCF and TPC operations.
assign done46 = instTLS & ck1;

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
