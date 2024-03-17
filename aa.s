.syntax unified
.thumb

.global main

#include "initialise.s"

.data
.align

incoming_buffer: .space 62
incoming_counter: .byte 62
terminating_char: .asciz "a"
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

    // Call the function to read and retransmit
    BL read_and_retransmit

loop_forever:
    B loop_forever

read_and_retransmit:
    // Load the base address of USART1 into R0
    LDR R0, =USART1

receive_loop:
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

    // Check if the received character matches the terminating_char
    CMP R3, terminating_char

    // If received character matches terminating_char, exit loop
    BEQ transmit_string

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
    BGT receive_loop

transmit_string:
    // Load the base address of USART1 into R0
    LDR R0, =USART1

    // Load the address of incoming_buffer into R2
    LDR R2, =incoming_buffer

    // Load the value from incoming_counter into R7
    LDRB R7, [R7]

    // Load the address of tx_string into R3
    LDR R3, =tx_string

    // Copy the received string to tx_string for retransmission
copy_loop:
    LDRB R4, [R2], #1    // Load byte from incoming_buffer and increment R2
    STRB R4, [R3], #1    // Store byte to tx_string and increment R3
    SUBS R7, #1          // Decrement counter R7
    BNE copy_loop        // Continue copying if counter is not zero

    // Call function to transmit the string
    BL transmit_string_uart

    B read_and_retransmit

// Function to clear UART error flags and continue loop
clear_error:
    LDR R1, [R0, USART_ICR]
    ORR R1, 1 << UART_ORECF | 1 << UART_FECF
    STR R1, [R0, USART_ICR]
    B receive_loop

// Function to transmit the string stored in tx_string via UART
transmit_string_uart:
    // Load the base address of USART1 into R0
    LDR R0, =USART1

    // Load the address of tx_string into R3
    LDR R3, =tx_string

    // Load the length of tx_string into R4
    LDR R4, =62

transmit_loop:
    // Load the UART ISR register into R1
    LDR R1, [R0, USART_ISR]

    // Check if UART transmitter is empty
    TST R1, 1 << UART_TXE
    BEQ transmit_loop

    // Load byte from tx_string into R5 and increment pointer
    LDRB R5, [R3], #1

    // Store byte into UART transmit data register
    STRB R5, [R0, USART_TDR]

    // Compare current character with end character
    CMP R5, terminating_char

    // Continue transmission if length counter is not zero
    BNE transmit_loop

    BX LR

.end
