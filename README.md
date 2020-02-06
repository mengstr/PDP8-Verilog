# PDP8/X-Verilog

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
