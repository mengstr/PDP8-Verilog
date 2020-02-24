//
// IRdecode.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module IRdecode (
  /* verilator lint_off UNUSED */
  input [11:0]PCLATCHED,
  input [11:0]IR,
  /* verilator lint_on UNUSED */
  output PPIND ,
  output IND,
  output DIR,
  output MP,
  output AAND,
  output TAD,
  output ISZ,
  output DCA,
  output JMS,
  output JMP,
  output IOT,
  output OPR
);

assign AAND  = IR[11:9]==3'd0;
assign TAD   = IR[11:9]==3'd1;
assign ISZ   = IR[11:9]==3'd2;
assign DCA   = IR[11:9]==3'd3;
assign JMS   = IR[11:9]==3'd4;
assign JMP   = IR[11:9]==3'd5;
assign IOT   = IR[11:9]==3'd6;
assign OPR   = IR[11:9]==3'd7;

//
// MSB                                                    LSB
// 11   10    9    8    7    6    5    4    3    2    1    0
// -------------  -+-  -+-  ---------------------------------
//   Operation     |    |           Seven-bit address part   
//                 |    +-- Z - Page selector
//                 +-- I - Indirect

// Page selector - If set, complete the address using the 5 high-order bits of the program counter (PC) register, 
//                 meaning that the addressed location was within the same 128 words as the instruction. If clear, 
//                 zeroes are used, so the addressed location is within the first 128 words of memory.
// Indirect      - If set, the address obtained as described so far points to a 12-bit value in memory that gives 
//                 the actual effective address for the instruction; this allows operands to be anywhere in memory 
//                 at the expense of an additional word. 
//
//
//
// Operations
//------------
// 000 - AND M
//   The contents of memory location M are logically anded with AC, bit by bit. There is no effect on the link bit. 
//   All other logical operations must be accomplished with macros.
//
// 001 - TAD M
//   The contents of memory location M are added to AC. A carry out of the high bit of AC will complement the link 
//   bit. Most other arithmetic operations must be accomplished with macros.
//
// 010 - ISZ M
//   The contents of memory location M are incremented and placed back in memory. If the result stored in memory 
//   is zero, the program counter is incremented; as a result that the next instruction will be skipped if the 
//   result is zero. AC and LINK are not modified. ISZ is frequently used to increment memory addresses; unless 
//   the address could wrap around from 7777 to 0000, ISZ is used as if it will never skip. If a wraparound is 
//   possible, it must be followed by a no-op. ISZ allows the construction of a number of fast macros for 
//   block operations.
//
// 011 - DCA M
//   The contents of the accumulator are stored in the memory location M; the accumulator is then cleared. There 
//   is no effect on the link bit. The corresponding load operation must be accomplished by a macro
//
// 100 - JMS P
//   The contents of PC (a pointer to the next instruction) is stored in memory location P as a return address, 
//   and then control is transfered to the location following P. AC and LINK remain unchanged. There is no return 
//   instruction; this is done using an indirect jump through P.
//
// 101 - JMP P
//   Control is transferred to memory location P. AC and LINK remain unchanged.
//
//
//
// Addressing Modes
//-----------------
//
// Z - The Page Select Bit
// TAD Z	ADDR
// TAD	ADDR
//
//   When the Z bit of the instruction is zero, page zero addressing mode is used. This allows addressing of memory 
//   locations 0000 through 0177 (octal) of the current memory from an instruction located anywhere in theat field. 
//   The Z qualifier may be used to indicate that page zero mode is desired, but most PDP-8 assemblers will 
//   automatically generate page zero mode if the addressed location is in page zero. When the Z bit of the instruction 
//   is one, current page addressing mode is used. This allows addressing of memory locations in the current page, 
//   as determined by the 5 most significant bits of the program counter (more accurately, the 5 most significant 
//   bits of the address of the location from which the instruction was fetched). All PDP-8 assemblers will generate 
//   current page mode when the addressed location is in the current page. Direct addressing of locations not on the 
//   current page is impossible, but some PDP-8 assemblers will automatically generate indirect references to off-page 
//   locations, storing the indirect word at the end of the current page. This usage is considered unsafe because 
//   indirection may change the memory field being referenced!
//
// I - The Indirect Bit
// TAD I	ADDR
//
//   When the I bit of the instruction is zero, direct addressing is used. This allows any word in either page zero 
//   or the current page to be referenced as an operand. When the I bit of the instruction is one, indirect addressing 
//   is used. In this mode, the word at the addressed location in page zero or the current page is used as a pointer 
//   to the intended operand. This requires one additional memory cycle for the instruction. All PDP-8 assemblers require 
//   the use of the I qualifier to indicate indirect mode. Some PDP-8 assemblers will automatically generate indirect 
//   references for those instructions that directly reference off-page locations. Indirect addressing using locations 
//   0010 through 0017 (octal) has the side effect of incrementing these locations prior to use. This is called 
//   autoindexed addressing. Indirect addressing may be used to reference operands in any memory field, depending on 
//   how the DF (data_field) register is set. By default, this is usually the current field, the same field as that 
//   from which the instruction was fetched.
//
// Autoindex Addressing
//   If indirect addressing is done through locations 0010 and 0017 (octal) of any memory field, the indirect word 
//   will be incremented prior to use. Other than this increment, auto-indexed mode is the same as indirect mode. 
//   Autoindex addressing is particularly useful for operations on blocks of consecutive words.
//


//
// 11 10  9   8  7  6   5  4  3   2  1  0
// ---------------------------------------
//  0  0  0   0  0  0   0  0  1   x  x  x   0010 - 0017
//
//  0  0  0   x  x  x   x  x  x   x  x  x   AND
//  0  0  1   x  x  x   x  x  x   x  x  x   TAD
//  0  1  0   x  x  x   x  x  x   x  x  x   ISZ
//  0  1  1   x  x  x   x  x  x   x  x  x   DCA
//  1  0  0   x  x  x   x  x  x   x  x  x   JMS
//  1  0  1   x  x  x   x  x  x   x  x  x   JMP
//  1  1  0   x  x  x   x  x  x   x  x  x   IOT
//  1  1  1   x  x  x   x  x  x   x  x  x   OPR
//
//  x  x  x   x  0  x   x  x  x   x  x  x   Access Zero Page
//  x  x  x   x  1  x   x  x  x   x  x  x   Access Current Page
//
//  x  x  x   0  x  x   x  x  x   x  x  x   Direct addressing
//  x  x  x   1  x  x   x  x  x   x  x  x   Indirect addressing
//

localparam BIT_INDEXED  = 8;  // If 0 normal addressing, if 1 indexed addressing
localparam BIT_PAGE     = 7;  // If 0 force page zero, if 1 use current page from PC[11:7]

wire isPP1 = ~PCLATCHED[11] & ~PCLATCHED[10] & ~PCLATCHED[9] & ~PCLATCHED[8] & ~PCLATCHED[7];
wire isPP2 = ~IR[6] & ~IR[5] & ~IR[4] & IR[3];
wire isPP = (isPP1 | ~MP) & isPP2;

wire normalInstruction = ~IOT & ~OPR;
assign IND   = normalInstruction &  IR[BIT_INDEXED] & ~isPP;
assign PPIND = normalInstruction &  IR[BIT_INDEXED] &  isPP;
assign DIR   = normalInstruction & ~IR[BIT_INDEXED];
assign MP    = normalInstruction &  IR[BIT_PAGE];

endmodule
