.syntax unified
.thumb

.global main

#include "initialise.s"

.data


.align

incoming_buffer: .space 62

incoming_counter: .byte 62

terminating_char: .asciz "a"


.text


main:

	// Initialize power, peripheral clocks, and UART
	BL initialise_power
	BL enable_peripheral_clocks
	BL enable_uart

	// Load addresses of incoming_buffer and incoming_counter
	LDR R6, =incoming_buffer
	LDR R7, =incoming_counter

	// Load the value from incoming_counter into R7
	LDRB R7, [R7]

	// Initialize index counter R8
	MOV R8, #0x00

loop_forever:

	// Load the base address of USART1 into R0
	LDR R0, =USART1

	// Load the UART ISR register into R1
	LDR R1, [R0, USART_ISR]

	// Check for UART errors: overrun error or framing error
	TST R1, 1 << UART_ORE | 1 << UART_FE

	// If error flags are set, clear them and continue loop
	BNE clear_error

	// Check if UART has received data
	TST R1, 1 << UART_RXNE

	// If no data is received, continue loop
	BEQ loop_forever

	// Read the received character from USART_RDR into R3
	LDRB R3, [R0, USART_RDR]

	// Store the received character into the incoming_buffer
	STRB R3, [R6, R8]

	// Increment index counter R8
	ADD R8, #1

	// Check if the received character matches the terminating_char
	CMP R3, terminating_char

	// If received character matches terminating_char, exit loop
	BEQ end_loop

	// Check if the index counter R8 exceeds the buffer size
	CMP R7, R8

	// If index counter exceeds buffer size, reset index counter R8
	BGT no_reset
	MOV R8, #0

no_reset:

	// Request to reset the UART receiver
	LDR R1, [R0, USART_RQR]
	ORR R1, 1 << UART_RXFRQ
	STR R1, [R0, USART_RQR]

	// Continue loop
	BGT loop_forever

// Clear UART error flags and continue loop
clear_error:

	LDR R1, [R0, USART_ICR]
	ORR R1, 1 << UART_ORECF | 1 << UART_FECF
	STR R1, [R0, USART_ICR]
	B loop_forever

// End of loop, halt execution
end_loop:

	B end_loop
