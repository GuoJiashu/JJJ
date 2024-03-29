.syntax unified
.thumb

.global main

#include "initialise.s"

.data
@ define variables


.align

@ Define a string
tx_string: .asciz "hello?\r\n"
tx_length: .byte 10


.text
@ define text


main:

	BL initialise_power          @ Call function to initialise power
	BL enable_peripheral_clocks  @ Call function to enable peripheral clocks
	BL enable_uart               @ Call function to enable UART

	B program_loop               @ Branch to program loop

program_loop:

	LDR R0, =GPIOA      @ Load address of GPIOA into R0
	LDRB R1, [R0, #0x10]@ Load byte from memory address GPIOA + 0x10 into R1
	CMP R1, #255        @ Compare R1 with 255
	BEQ tx_loop         @ Branch to tx_loop if equal

	B program_loop      @ Branch back to program_loop if not equal

tx_loop:

	LDR R0, =USART1     	@ Load address of USART1 into R0

	LDR R1, =tx_string  	@ Load address of tx_string into R1
	LDR R3, =tx_length  	@ Load address of tx_length into R3

	LDR R4, [R3]        	@ Load value from memory address stored in R3 into R4


tx_uart:

	LDR R2, [R0, USART_ISR]   	@ Load USART ISR register into R2
	ANDS R2, 1 << UART_TXE    	@ Perform bitwise AND operation to check UART_TXE flag

	BEQ tx_uart               	@ Branch back to tx_uart if UART_TXE flag is not set

	LDRB R5, [R1], #1         	@ Load byte from memory address pointed to by R1 into R5 and increment R1
	STRB R5, [R0, USART_TDR]  	@ Store byte from R5 into USART transmit data register

	SUBS R4, #1          		@ Subtract 1 from R4 (tx_length)

	                     		@ Compare R5 with ASCII code for '?'
	CMP R5, #'?'
	BEQ end_transmission 		@ Branch to end_transmission if equal

	BGT tx_uart          		@ Keep looping while there are more characters to send

	BL delay_loop        		@ Call delay_loop subroutine

end_transmission:

	BL delay_loop        @ Call delay_loop subroutine
	B program_loop       @ Branch back to program_loop

delay_loop:
	LDR R9, =0xfffff     @ Load maximum delay value into R9

delay_inner:

	SUBS R9, #1          @subtract 1 from R9
	BGT delay_inner      @ Branch back to delay_inner if R9 is greater than 1
	BX LR                @ Return from subroutine
