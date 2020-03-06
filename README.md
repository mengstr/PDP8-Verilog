# PDP8-Verilog
[![SmallRoomLabs]https://circleci.com/gh/SmallRoomLabs/PDP8-Verilog.svg?style=svg](https://circleci.com/gh/SmallRoomLabs/PDP8-Verilog)

This is a work in progress for a PDP-8 written in Verilog

## Ports on modules
` head -10 *.v | grep -E '^// \w{3,} \| \d+ \| \d+ \| \d+ \| \d+' | cut -c 4- | sort`

FILE | BUSSES IN | IN | BUSSES OUT | OUT
----|----|----|----|----
AddAnd | 2 | 3 | 1 | 1
ClockGen | 0 | 1 | 0 | 3
ClrOrInv | 2 | 2 | 1 | 0
FrontPanel | 0 | 0 | 0 | 0
IRdecode | 2 | 0 | 0 | 12
Incrementer | 1 | 2 | 1 | 1
InstructionFetch | 0 | 10 | 0 | 7
InstructionIOT600x | 1 | 16 | 1 | 10
InstructionIOT603x | 0 | 16 | 0 | 16
InstructionOPR | 0 | 15 | 0 | 10
InstructionOPRdecode | 1 | 1 | 0 | 28
Instructions | 0 | 17 | 0 | 21
Link | 0 | 7 | 0 | 2
MultiLatch | 1 | 7 | 2 | 0
PDP8 | 0 | 0 | 0 | 0
PDP8_top | 0 | 0 | 0 | 0
ProgramCounter | 1 | 5 | 2 | 0
RAM | 2 | 3 | 1 | 0
RIMloader | 0 | 2 | 2 | 2
Rotater | 1 | 5 | 1 | 1
Sequencer | 0 | 8 | 0 | 20
Skip | 1 | 5 | 0 | 1
UART | 0 | 13 | 0 | 11

## Usage of Sequencer signals
`tools/countusage.sh`

FILE | ckFetch | stbFetchA | stbFetchB | ckAuto1 | stbAuto1 | ckAuto2 | stbAuto2 | ckInd | stbInd
---|----|----|----|----|----|----|----|----|----
AddAnd.v                 |  |  |  |  |  |  |  |  |
ClockGen.v               |  |  |  |  |  |  |  |  |
ClrOrInv.v               |  |  |  |  |  |  |  |  |
FrontPanel.v             |  |  |  |  |  |  |  |  |
IRdecode.v               |  |  |  |  |  |  |  |  |
Incrementer.v            |  |  |  |  |  |  |  |  |
InstructionFetch.v       | 1 |  | 1 | 5 | 3 | 5 | 3 | 6 | 4
InstructionIOT600x.v     | 2 | 1 | 1 |  |  |  |  |  |
InstructionIOT603x.v     |  |  |  |  |  |  |  |  |
InstructionOPR.v         |  |  |  |  |  |  |  |  |
InstructionOPRdecode.v   |  |  |  |  |  |  |  |  |
Instructions.v           |  |  |  |  |  |  |  |  |
Link.v                   |  |  |  |  |  |  |  |  |
MultiLatch.v             |  |  |  |  |  |  |  |  |
ProgramCounter.v         |  |  |  |  |  |  |  |  |
RAM.v                    |  |  |  |  |  |  |  |  |
RIMloader.v              |  |  |  |  |  |  |  |  |
Rotater.v                |  |  |  |  |  |  |  |  |
Sequencer.v              | 3 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1
Skip.v                   |  |  |  |  |  |  |  |  |
UART.v                   |  |  |  |  |  |  |  |  |


FILE | ck1 | stb1 | ck2 | stb2 | ck3 | stb3 | ck4 | stb4
---|----|----|----|----|----|----|----|----
AddAnd.v                 |  |  |  |  |  |  |  |
ClockGen.v               |  |  |  |  |  |  |  |
ClrOrInv.v               |  |  |  |  |  |  |  |
FrontPanel.v             |  |  |  |  |  |  |  |
IRdecode.v               |  |  |  |  |  |  |  |
Incrementer.v            |  |  |  |  |  |  |  |
InstructionFetch.v       |  |  |  |  |  |  |  |
InstructionIOT600x.v     | 8 | 11 | 7 |  | 2 |  | 2 |
InstructionIOT603x.v     | 17 | 6 | 6 |  | 7 |  | 3 |
InstructionOPR.v         | 16 | 11 | 16 | 7 | 10 | 2 | 2 |
InstructionOPRdecode.v   |  |  |  |  |  |  |  |
Instructions.v           | 29 | 16 | 24 | 2 | 8 | 4 | 4 |
Link.v                   |  |  |  |  |  |  |  |
MultiLatch.v             |  |  |  |  |  |  |  |
ProgramCounter.v         |  |  |  |  |  |  |  |
RAM.v                    |  |  |  |  |  |  |  |
RIMloader.v              |  |  |  |  |  |  |  |
Rotater.v                |  |  |  |  |  |  |  |
Sequencer.v              | 2 | 2 | 1 | 1 | 1 | 1 | 1 | 1
Skip.v                   |  |  |  |  |  |  |  |
UART.v                   |  |  |  |  |  |  |  |

## Busses

* busIR
* busPC
* busLatPC
* busReg 
  * busReg_ind
  * busReg_data
* busAddress 
  * busAddress_ind 
  * busAddress_pc 
  * busAddress_ir
* busData       
  * busData_inc 
  * busData_ram 
  * busData_acc 
  * busData_pc
* busPCin       
  * busPCin_ir 
  * busPCin_reg 
  * (setpc ? switches : 12'o0000)
* busORacc      
  * mqout1 
  * busACGTF 
  * busACTTY 
  * (oprOSR ? 12'o`OSR : 12'o0000)
* accIn         
  * accIn_andadd 
  * accIn_rotater

* busPCin_ir    = ir2pc ? { (instIsMP ? busLatPC[11:7] : 5'b00000) , busIR[6:0]} : 12'b0 // First OC12 module
* busPCin_reg   = reg2pc ? busReg : 12'b0
* busAddress_ir = ir2rama ? { (instIsMP ? busLatPC[11:7] : 5'b00000) , busIR[6:0]} : 12'b0 // Second OC12 module
* busAddress_pc = ckFetch ? busPC : 12'b0
* busData_pc    = pc2ramd ? busPC : 12'b0
* busData_ram
* accIn_andadd
* busData_acc
* accIn_rotater
* busAddress_ind
* busReg_ind
* busReg_data
* busData_inc

* switches
* mqout1
* accout1
* clorinOut
* incOut
* busACGTF
* busACTTY

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
