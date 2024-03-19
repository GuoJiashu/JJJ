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

@ This is the entry function called from the startup file
main:

	@ Branch with link to set the clocks for the I/O and UART
	BL enable_peripheral_clocks

	@ Once the clocks are started, need to initialise the discovery board I/O
	BL initialise_discovery_board

	@ store the current light pattern (binary mask) in R4
	LDR R4, =0b00000000 @ load a pattern for the set of LEDs (every second one is on)


program_loop:

	LDR R0, =GPIOA		@ Port for the input button. Load the base address of GPIO port A into register R0. 
	LDRB R1, [R0, #IDR] 	@ Load the byte value from the Input Data Register (IDR) of GPIO port A into register R1. LDRB loads a byte showing the current state of all pins in port A
	CMP R1, #255 		@ Compare the value loaded into R1 with 255, checking if all bits in the IDR are set to 1 (button is pressed)
	BEQ LED  		@ Branch to the label "LED" if the result of the comparison is equal to #255

	B program_loop 		@ Return to the program_loop label

LED:
	LDR R0, =GPIOE  @ load the address of the GPIOE register into R0
	STRB R4, [R0, #ODR + 1]   @ store this to the second byte of the ODR (bits 8-15)
	
	LSL R4, R4, #1       @ Left shift the value in R4 by 1, moving to the next LED in a sequence.
	ADD R4, R4, #1       @ Increment the value in R4 by 1, turning on the next LED.
	BL delay_function    @ Call a subroutine named 'delay_function' to introduce a delay.
	CMP R4, 0b11111111   @ Compare the value in R4 with #255 (all LEDs on) to check if all LEDs are turned on
	BEQ main             @ If R4 is equal to #255, branch to the 'main' function


	B program_loop @return to the program_loop label

delay_function:
    MOV R6, #0x0100000          @ Initialize R6 with a delay counter value

not_finished_yet:
    SUBS R6, R6, #0x01          @ Decrement the delay counter in R6 by 1
    BNE not_finished_yet        @ If R6 is not zero, branch back to continue the loop

    BX LR                       @ Return from the function call once the delay counter reaches zero


