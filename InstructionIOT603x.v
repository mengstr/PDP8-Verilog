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
  input [7:0] dataIn,
  input ck1, ck2,
  input stb1,
  output done,
  output pc_ck,
  output irq,
  input rx,
  output tx,
  output LED2,
  output [7:0] dataOut,
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


reg flgTTYIE=0;
reg flgKBD=0;
reg flgPRN=0;
assign irq=(flgTTYIE) & (flgKBD | flgPRN);

wire [7:0] dataOut34, dataOut36;
assign dataOut = dataOut34 | dataOut36;

wire     done30, done31, done32, done34, done35, done36, done40, done41, done42, done44, done45, done46;
or(done, done30, done31, done32, done34, done35, done36, done40, done41, done42, done44, done45, done46);

wire       pc_ck31, pc_ck41, pc_ck45;
or (pc_ck, pc_ck31, pc_ck41, pc_ck45);

wire       rot2ac32, rot2ac34, rot2ac36;
or(rot2ac, rot2ac32, rot2ac34, rot2ac36);

wire    clr32, clr36;
or(clr, clr32, clr36);

wire      ac_ck32, ac_ck34, ac_ck36;
or(ac_ck, ac_ck32, ac_ck34, ac_ck36);


wire instKCF=(EN1 & (op==3'o0)); // 6030 Keyboard Clear Flags
wire instKSF=(EN1 & (op==3'o1)); // 6031 Keyboard Skip if Flag
wire instKCC=(EN1 & (op==3'o2)); // 6032 Keyboard Clear and clear AC
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

wire ACbit11=dataIn[0]; // PDP has the bit order reversed

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
      if (instKCF) flgKBD<=0;           // 6030 Keyboard Clear Flags
      if (instKCC) flgKBD<=0;           // 6032 Keyboard Clear and clear AC
      if (instKIE) flgTTYIE<=ACbit11;   // 6035 Keyboard Interrupt Enable/Disable
      if (instKRB) flgKBD<=0;           // 6036 Keyboard Read and begin next read
      if (instTFL) flgPRN<=1;           // 6040 Teleprinter Flag set
      if (instTFC) flgPRN<=0;           // 6042 Teleprinter Flag clear
      if (instTPC) begin                // 6044 Teleprinter Print Character
`ifdef IVERILOG
      if (ck1) $display("TX %d (%c)", {1'b0,dataIn[6:0]},{1'b0,dataIn[6:0]} );
`endif
      if (ck1) begin txData <= dataIn; txStb<=1; end;
    end
    if (instTLS) begin      //Teleprinter Load and start
      flgPRN<=0;
`ifdef IVERILOG
      if (ck1) $display("TX %d [%c]", dataIn[7:0], {1'b0,dataIn[6:0]} );
`endif
      if (ck1) begin txData <= dataIn; txStb<=1; end;
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


// 6030 - KCF Keyboard Clear Flags
//  The keyboard flag, signalling input data ready, is cleared. 
assign done30 = instKCF & ck1;      // Also handled in the always @(posedge


// 6031 - KSF Keyboard Skip if Flag
//  If the keyboard flag is set, indicating that input data is ready, the next instruction in sequence is skipped.
assign pc_ck31= instKSF & flgKBD & stb1;
assign done31 = instKSF & ck2;


// 6032 - KCC Keyboard Clear and read character
//  The keyboard flag is reset, the accumulator is cleared
assign rot2ac32=   instKCC & ck1;       // also handled in the always @(posedge
assign clr32=      instKCC & ck1;
assign ac_ck32=    instKCC & stb1;
assign done32 =    instKCC & ck2;      

// 6034 - KRS Keyboard Read Static
//  The 8-bit character in the keyboard buffer is ored with the accumulator.
assign rot2ac34=   instKRS & ck1;
assign dataOut34 =   instKRS & ck1 ? rxData : 8'b0;
assign ac_ck34=    instKRS & stb1;
assign done34=     instKRS & ck2;

// 6035 - KIE Keyboard Interrupt Enable
//  The accumulator is loaded into the device control register (the interrupt enable and status report control bits). 
assign done35 = instKIE & ck1;      // also handled in the always @(posedge


// 6036 - KRB Keyboard Read and begin next read
//  The 8 bit character in the keyboard buffer is transferred to the accumulator, and the keyboard flag is cleared, allowing the 
//  reading of the next character to begin. In effect, this operation combines the KCC and KRS operations;
assign rot2ac36=   instKRB & ck1;       // also handled in the always @(posedge
assign dataOut36 =   instKRB & ck1 ? rxData : 8'b0;
assign clr36=      instKRB & ck1;
assign ac_ck36=    instKRB & stb1;
assign done36=     instKRB & ck2;


// 6040 - TFL Teleprinter Flag set
//  The printer flag, signalling output complete, is set. 
assign done40 = instTFL & ck1;        // also handled in the always @(posedge


// 6041 - TSF Teleprinter Skip if Flag
//  If the printer flag is set, indicating output is complete, the next instruction in sequence is skipped. 
assign pc_ck41= instTSF & flgPRN & stb1;
assign done41 = instTSF & ck2;

// 6042 - TCF Teleprinter Clear Flag
//  The printer flag is reset.
assign done42 = instTFC & ck1;        // also handled in the always @(posedge


// 6044 - TPC Teleprinter Print Character
//  The least significant 8-bits of the accumulator is copied to the print buffer, initiating output. 
assign done44 = instTPC & ck1;        // also handled in the always @(posedge


// 6045 - TSK Teleprinter Skip
//  If either the print flag or the keyboard flag are set, the next instruction in sequence is skipped. 
assign pc_ck45= instTSK & (flgPRN | flgKBD) & stb1;
assign done45 = instTSK & ck2;


// 6046 - TLS Teleprinter Load and start
//  The least significant 8 bits of the accumulator are copied to the print buffer, initiating output, and the printer flag is 
//  reset. In effect, this operation combines the TCF and TPC operations.
assign done46 = instTLS & ck1;        // also handled in the always @(posedge

endmodule


