.syntax unified
.thumb

.global main

#include "initialise.s"

.data
.align

incoming_buffer: .space 62
incoming_counter: .byte 62
terminating_char: .asciz "a"
tx_buffer: .space 62  @ Buffer for transmitting received string

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
    BL receive_and_transmit

receive_and_transmit:
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
    BEQ receive_and_transmit

    // Read the received character from USART_RDR into R3
    LDRB R3, [R0, USART_RDR]

    // Store the received character into the incoming_buffer
    STRB R3, [R6, R8]

    // Increment index counter R8
    ADD R8, #1

    // Check if the index counter R8 exceeds the buffer size
    CMP R7, R8

    // If index counter exceeds buffer size, reset index counter R8
    BGT no_reset
    MOV R8, #0

    // Check if the received character matches the terminating_char
    CMP R3, #'a'  @ Assuming 'a' is the terminating character
    BEQ transmit_string

no_reset:
    // Request to reset the UART receiver
    LDR R1, [R0, USART_RQR]
    ORR R1, 1 << UART_RXFRQ
    STR R1, [R0, USART_RQR]

    // Continue loop
    BGT receive_and_transmit

transmit_string:
    // Load the base address of USART1 into R0
    LDR R0, =USART1

    // Load the address of incoming_buffer into R2
    LDR R2, =incoming_buffer

    // Load the length of incoming_buffer into R7
    LDRB R7, [R7]

    // Load the address of tx_buffer into R3
    LDR R3, =tx_buffer

    // Copy the received string to tx_buffer for retransmission
    MOV R8, #0          // Reset index counter
copy_loop:
    LDRB R4, [R2, R8]  // Load byte from incoming_buffer
    STRB R4, [R3, R8]  // Store byte to tx_buffer
    ADD R8, #1         // Increment index counter
    CMP R8, R7         // Compare index with length
    BNE copy_loop      // Repeat if not at end of string

    // Call function to transmit the string
    BL transmit_string_uart

    B receive_and_transmit

// Function to clear UART error flags and continue loop
clear_error:
    LDR R1, [R0, USART_ICR]
    ORR R1, 1 << UART_ORECF | 1 << UART_FECF
    STR R1, [R0, USART_ICR]
    B receive_and_transmit

// Function to transmit the string stored in tx_buffer via UART
transmit_string_uart:
    // Load the base address of USART1 into R0
    LDR R0, =USART1

    // Load the address of tx_buffer into R3
    LDR R3, =tx_buffer

    // Load the length of tx_buffer into R4
    LDRB R4, [R7]

    // Loop to transmit characters from the buffer
transmit_loop:
    // Load the UART ISR register into R1
    LDR R1, [R0, USART_ISR]

    // Check if UART transmitter is empty
    TST R1, 1 << UART_TXE
    BEQ transmit_loop

    // Load byte from tx_buffer into R5 and increment pointer
    LDRB R5, [R3], #1

    // Store byte into UART transmit data register
    STRB R5, [R0, USART_TDR]

    // Compare current character with end character
    CMP R5, #'a'  @ Assuming 'a' is the terminating character
    BNE transmit_loop

    BX LR

.end
