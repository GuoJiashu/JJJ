.syntax unified
.thumb

.global main

#include "initialise.s"

.data
.align

incoming_buffer: .space 62
incoming_counter: .byte 62
terminating_char: .byte 'a'
tx_string: .space 62

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

	LDR R0, =USART1
	LDR R4, =terminating_char
	LDRB R4,[R4]
    // Call the function to read and retransmit
    BL receive_loop

receive_loop:

	// Load the base address of USART1 into R0

    // Load the UART ISR register into R1
    LDR R1, [R0, USART_ISR]

    // Check for UART errors: overrun error or framing error
    TST R1, 1 << UART_ORE | 1 << UART_FE

    // If error flags are set, clear them and continue loop
    BNE clear_error

    // Check if UART has received data
    TST R1, 1 << UART_RXNE

    // If no data is received, continue loop
    BEQ receive_loop

    // Read the received character from USART_RDR into R3
    LDRB R3, [R0, USART_RDR]

    // Store the received character into the incoming_buffer
    STRB R3, [R6, R8]

    // Increment index counter R8
    ADD R8, #1

    // Check if the index counter R8 exceeds the buffer size

    // If index counter exceeds buffer size, reset index counter R8

    // Check if the received character matches the terminating_char
    CMP R3, R4

    // If received character matches terminating_char, exit loop
    BEQ transmit_string
clear_error:
    LDR R1, [R0, USART_ICR]
    ORR R1, 1 << UART_ORECF | 1 << UART_FECF
    STR R1, [R0, USART_ICR]
    B receive_loop

transmit_string:
    // Load the base address of USART1 into R0
    BL enable_uart
    LDR R0, =USART1

    // Load the address of incoming_buffer into R2
    //LDR R2, =incoming_buffer*/
    // Function to transmit the string stored in tx_string via UART
transmit_loop:
    // Load the UART ISR register into R1
    LDR R1, [R0, USART_ISR]

    // Check if UART transmitter is empty
    TST R1, 1 << UART_TXE
    BEQ transmit_loop

    // Load byte from tx_string into R5 and increment pointer
    LDRB R5, [R6], #1

    // Store byte into UART transmit data register
    STRB R5, [R0, USART_TDR]

    // Compare current character with end character
    CMP R5, R4

    // Continue transmission if length counter is not zero
    BNE transmit_loop

	B end_loop
    BX LR

end_loop:
	B end_loop
