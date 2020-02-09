//
// TTY.v - for the PDP-8 in Verilog project
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


module TTY(
  input CLK,
  input clear,
  input EN1,                             // High when this module is to be activated  603x
  input EN2,                             // High when this module is to be activated  604x
  input [2:0] IR,
  input [11:0] AC,
  input ck1, ck2, ck3, ck4, ck5, ck6,
  input stb1,stb2,stb3,stb4,stb5,stb6,
  output done,
  output pc_ck,
  output irq,
  input rx,
  output tx
);

reg [7:0] txData=0;
reg txStb=0;
wire txRdy;
wire rxRdy;
wire [7:0] rxData;
reg rxAck=0;

UART uart(
    .SYSCLK(CLK),
    .RESET(1'b0),
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

wire     done30, done31, done35, done40, done41, done42, done44, done46;
or(done, done30, done31, done35, done40, done41, done42, done44, done46);

wire       pc_ck31, pc_ck41;
or (pc_ck, pc_ck31, pc_ck41);

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
wire instTFC=(EN2 & (IR==3'o2)); //Teleprinter Flag clear
// TODO Handle 6043
wire instTPC=(EN2 & (IR==3'o4)); //Teleprinter Print Character
wire instTSK=(EN2 & (IR==3'o5)); //Teleprinter Skip
wire instTLS=(EN2 & (IR==3'o6)); //Teleprinter Load and start
// TODO Handle 6047

wire ACbit11=AC[0:0]; // PDP has the bit order reversed

reg lastTxRdy=0;

always @(posedge CLK) begin
    if (clear)   begin
        flgTTYIE<=1;
        flgKBD<=0;
        flgPRN<=0;
        // txtick<=0;
    end else begin
      if (instKIE) flgTTYIE<=ACbit11; ////Keyboard Interrupt Set/Reset
      if (instKCF) flgKBD<=0; //Keyboard Clear Flags
      if (instTFL) flgPRN<=1; //Teleprinter Flag set
      if (instTFC) flgPRN<=0; //Teleprinter Flag clear
      if (instTPC) begin
`ifndef VERILATOR
      // FIXME
      if (ck1) $display("(%c)", AC & 12'd127);
`endif
      if (ck1) begin txData<={1'b0,AC[6:0]}; txStb<=1; end;
    end
      if (instTLS) begin      //Teleprinter Load and start
        flgPRN<=0;
`ifndef VERILATOR
        // FIXME
        if (ck1) $display("[%c]", AC & 12'd127);
`endif
        if (ck1) begin txData<={1'b0,AC[6:0]}; txStb<=1; end;
      end
      if (txStb==1) txStb<=0; 
      if (txRdy & ~lastTxRdy) flgPRN<=1;
      lastTxRdy<=txRdy;
    end
end

assign done30 = instKCF & ck1;
assign pc_ck31= instKSF & flgKBD & stb1;
assign done31 = instKSF & ck2;
assign done35 = instKIE & ck1;
assign done40 = instTFL & ck1;
assign pc_ck41= instTSF & flgPRN & stb1;
assign done41 = instTSF & ck2;
assign done42 = instTFC & ck1;
assign done44 = instTPC & ck1;
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

//            TTYin TTYou INT NO
//            IE IO IE IO BUS INT ION
//----------------------------------------------------
//IOT TEST 11
// 4340 CAF   1  0  1  1  1   0   0
// 4341 TAD   1  0  1  0  0   0   0
// 4342 DCA   1  0  1  0  0   0   0
// 4343 ION   1  0  1  0  0   0   0
// 4344 GTF   1  0  1  0  0   1   1     L-0 AC=0000 
// 4345 AND   1  0  1  0  0   0   1     L=0 AC=0200
// 4346 SKON  1  0  1  0  0   0   1     L=0 AC=0200
// 4350 BSW   1  0  1  0  0   0   0     L=0 AC=0200
// 4351 RTR   1  0  1  0  0   0   0     L=0 AC=0002
// 4352 SZL   1  0  1  0  0   0   0     L=1 AC=0000
// 4354 SZA   1  0  1  0  0   0   0     L=1 AC=0000
// 4355 JMP   1  0  1  0  0   0   0     L=1 AC=0000
//
//IOT TEST 12
// 4360 7320  1  0  1  0  0   0   0     L=1 AC=0000
// 4361 TAD   1  0  1  0  0   0   0     L=1 AC=0000
// 4362 DCA   1  0  1  0  0   0   0     L=1 AC=4376
// 4363 RTF   1  0  1  0  0   0   0     L=1 AC=0000
// 4364 SKP   1  0  1  0  0   1   1     L=0 AC=0000
// 4366 SNL   1  0  1  0  0   1   1     L=0 AC=0000
// 4367 SNA   1  0  1  0  0   1   1     L=0 AC=0000
// 4371 SKON  1  0  1  0  0   1   1     L=0 AC=0000
// 4373 JMPi  1  0  1  0  0   1   0     L=0 AC=0000
// 4400 CAF   1  0  1  0  0   0   0     L=0 AC=0000
// 4401 TAD   1  0  1  0  0   0   0     L=0 AC=0000
//



