# PDP8/X-Verilog

## Usage of Sequencer signals

FILE | ckFetch | stbFetch | ckAuto1 | stbAuto1 | ckAuto2 | stbAuto2 | ckInd | stbInd
---|----|----|----|----|----|----|----|----
AddAnd.v                 |  |  |  |  |  |  |  |
ClockGen.v               |  |  |  |  |  |  |  |
ClrOrInv.v               |  |  |  |  |  |  |  |
FrontPanel.v             |  |  |  |  |  |  |  |
IR.v                     | 2 |  |  |  |  |  |  |
IRdecode.v               |  |  |  |  |  |  |  |
Incrementer.v            |  |  |  |  |  |  |  |
InstructionFetch.v       | 1 | 1 | 3 | 1 | 3 | 1 | 4 | 2
InstructionIOT600x.v     | 2 | 1 |  |  |  |  |  |
InstructionIOT603x.v     |  |  |  |  |  |  |  |
InstructionIOTdecode.v   | 1 |  |  |  |  |  |  |
InstructionOPR.v         |  |  |  |  |  |  |  |
Instructions.v           |  |  |  |  |  |  |  |
Link.v                   |  |  |  |  |  |  |  |
MultiLatch.v             |  |  |  |  |  |  |  |
OPRdecoder.v             |  |  |  |  |  |  |  |
ProgramCounter.v         |  |  |  |  |  |  |  |
RAM.v                    |  |  |  |  |  |  |  |
RIMloader.v              |  |  |  |  |  |  |  |
Rotater.v                |  |  |  |  |  |  |  |
Sequencer.v              | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1
Skip.v                   |  |  |  |  |  |  |  |
UART.v                   |  |  |  |  |  |  |  |


FILE | ck1 | stb1 | ck2 | stb2 | ck3 | stb3 | ck4 | stb4 | ck5 | stb5 | ch6 | stb6
---|----|----|----|----|----|----|----|----|----|----|----|----
AddAnd.v                 |  |  |  |  |  |  |  |  |  |  |  |
ClockGen.v               |  |  |  |  |  |  |  |  |  |  |  |
ClrOrInv.v               |  |  |  |  |  |  |  |  |  |  |  |
FrontPanel.v             |  |  |  |  |  |  |  |  |  |  |  |
IR.v                     |  |  |  |  |  |  |  |  |  |  |  |
IRdecode.v               |  |  |  |  |  |  |  |  |  |  |  |
Incrementer.v            |  |  |  |  |  |  |  |  |  |  |  |
InstructionFetch.v       |  |  |  |  |  |  |  |  |  |  |  |
InstructionIOT600x.v     | 8 | 11 | 7 |  | 3 |  | 3 |  | 3 |  |  |
InstructionIOT603x.v     | 13 | 4 | 4 |  | 6 |  | 4 |  |  |  |  |
InstructionIOTdecode.v   |  |  |  |  | 1 |  |  |  |  |  |  |
InstructionOPR.v         | 17 | 9 | 14 | 6 | 8 |  | 1 |  |  |  |  |
Instructions.v           | 32 | 18 | 27 | 4 | 9 | 4 | 6 | 2 | 3 |  |  |
Link.v                   |  |  |  |  |  |  |  |  |  |  |  |
MultiLatch.v             |  |  |  |  |  |  |  |  |  |  |  |
OPRdecoder.v             |  |  |  |  |  |  |  |  |  |  |  |
ProgramCounter.v         |  |  |  |  |  |  |  |  |  |  |  |
RAM.v                    |  |  |  |  |  |  |  |  |  |  |  |
RIMloader.v              |  |  |  |  |  |  |  |  |  |  |  |
Rotater.v                |  |  |  |  |  |  |  |  |  |  |  |
Sequencer.v              | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |  | 1
Skip.v                   |  |  |  |  |  |  |  |  |  |  |  |
UART.v                   |  |  |  |  |  |  |  |  |  |  |  |

## Interrupts

### GIE - Global Interrupt Enable

This flag/flipflop is controlled by some of the IOT/600x instructions as well as RESET, CLEAR and the actual handling of the interrupt request.

__Set to 0 by/when:__
* Executing the forced JMS for handing the IRQ
* RESET
* CLEAR
* 6000 - SKON Skip if interrupt ON, and turn OFF
* 6002 - IOF Turn interrupt OFF
* 6007 - CAF Clear all flags

__Set to 1 by/when:__
* 6001 - ION Turn interrupt ON. Delayed one instruction
* 6005 - RTF Restore interrupt flags. Delayed one instruction

### GIEdly1 & GIEdly2 - GIE Delay 

As long as either one of these flags are set to 1 the GIE is ineffective to allow for the next instruction (usually a JMP I 0000 when returning from the ISR) to be executed before the the next IRQ can be handled again.

__Set to 1 by/when:__
* GIE is set by the ION or RTF instructions

__Set to 0 by/when:__
* RESET
* CLEAR
* GIEdly1 is cleared at anyDone
* GIEdly2 is cleared at anyDone if GIEdly1 is already cleared
