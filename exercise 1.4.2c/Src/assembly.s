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

program_loop:

	LDR R0, =GPIOA		@ Port for the input button. Load the base address of GPIO port A into register R0. 
	LDRB R1, [R0, #IDR] 	@ Load the byte value from the Input Data Register (IDR) of GPIO port A into register R1. LDRB loads a byte showing the current state of all pins in port A
	CMP R1, #255 		@ Compare the value loaded into R1 with 255, checking if all bits in the IDR are set to 1 (button is pressed)
	BEQ LED  		@ Branch to the label "LED" if the result of the comparison is equal to #255

	B program_loop 		@ return to the program_loop label

LED:
	LDR R0, =GPIOE  	 @ Load the address of the GPIOE register into R0
	STRB R4, [R0, #ODR + 1]  @ Store this to the second byte of the ODR (bits 8-15)
	LDR R4, =0b00000000      @ Load the value 0 into register R4

	BL delay_function        @ Call the delay_function to introduce a delay

	LDR R0, =GPIOA           @ Load the base address of GPIO port A into register R0 (for the input button)
	LDRB R1, [R0, #IDR]      @ Load the byte value from the IDR of GPIOA into R1
	CMP R1, #255             @ Compare the value in R1 with #255 (checks if all bits in IDR are set)
	BEQ LED_2                @ If R1 is equal to #255, branch to the LED_2 label

	B program_loop           @ Branch back to the program_loop label

LED_2:

	LDR R0, =GPIOE  	  @ load the address of the GPIOE register into R0
	STRB R4, [R0, #ODR + 1]   @ Store this to the second byte of the ODR (bits 8-15)
	LDR R4, =0b11111111	  @ Load the value binary 0b11111111 into register R4

	BL delay_function	  @ Call the delay_function to introduce a delay

	LDR R0, =GPIOA		  @ Load the base address of GPIO port A into register R0 (for the input button)
	LDRB R1, [R0, #IDR]	  @ Load the byte value from the IDR of GPIOA into R1
	CMP R1, #255		  @ Compare the value in R1 with #255 (checks if all bits in IDR are set)
	BEQ LED			  @ If R1 is equal to #255, branch to the LED label


	B program_loop		  @ Branch back to the program_loop label

delay_function:
    MOV R6, #0x0100000            @ Initialize R6 with a delay counter value

not_finished_yet:
    SUBS R6, R6, #0x01            @ Decrement the delay counter in R6 by 1
    BNE not_finished_yet          @ If R6 is not zero, branch back to continue the loop

    BX LR                         @ Return from the function call once the delay counter reaches zero
