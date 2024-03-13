.syntax unified
.thumb

.global main

#include "definitions.s"
#include "initialise.s"

.data
@ Define variables
.section .bss
led_state: .space 2
.text

@ this is the entry function called from the startup file
main:

	@ Branch with link to set the clocks for the I/O and UART
	BL enable_peripheral_clocks

	@ Once the clocks are started, need to initialise the discovery board I/O
	BL initialise_discovery_board

	@ store the current light pattern (binary mask) in R4
	LDR R4, =0b00000000 @ load a pattern for the set of LEDs (every second one is on)


program_loop:

	LDR R0, =GPIOA	@ port for the input button
	LDRB R1, [R0, #IDR]
	CMP R1, #255
	BEQ LED

	B program_loop @ return to the program_loop label

LED:
	LDR R0, =GPIOE  @ load the address of the GPIOE register into R0
	STRB R4, [R0, #ODR + 1]   @ store this to the second byte of the ODR (bits 8-15)
	LSL R4,R4,#1@EOR R4, #0xFF	@ toggle all of the bits in the byte (1->0 0->1)

	ADD R4,R4,#1
	BL delay_function
	CMP R4,0b11111111
	BEQ main

	B program_loop

delay_function:
	MOV R6, #0x0100000

not_finished_yet:
	SUBS R6, 0x01
	BNE not_finished_yet

	BX LR @ return from function call
