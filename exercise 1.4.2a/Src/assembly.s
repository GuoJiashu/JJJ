.syntax unified
.thumb

#include "initialise.s"

.global main


.data
@ define variables
pattern:  .word 0X33
.text
@ define text



main:
	@ Branch with link to set the clocks for the I/O and UART
	BL enable_peripheral_clocks

	@ Once the clocks are started, need to initialise the discovery board I/O
	BL initialise_discovery_board

	@ store the current light pattern (binary mask) in R4
	LDR R4, = 0b00110011 		@ Toad a pattern for the set of LEDs (every second one is on)


	LDR R0, =GPIOE  		@ Load the address of the GPIOE register into R0
	STRB R4, [R0, #ODR + 1]   	@ Store this to the second byte of the ODR (bits 8-15)
	EOR R4, #0xFF			@ Toggle all of the bits in the byte (1->0 0->1)
