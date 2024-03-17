.syntax unified
.thumb

.global main

#include "initialise.s"

.data
.align

<<<<<<< HEAD
incoming_buffer: .space 62               @ Define a buffer to store incoming data
incoming_counter: .byte 62               @ Counter for the incoming buffer
terminating_char: .byte 'a'              @ Define the terminating character for data reception
tx_string: .space 62                     @ Buffer for transmitting strings
=======
incoming_buffer: .space 62
incoming_counter: .byte 62
terminating_char: .byte 'a'
tx_string: .space 62
>>>>>>> ba9eec70274300d75b2fefac43b3686540fb666e

.text

main:

    BL initialise_power                  @ Call function to initialize power
    BL enable_peripheral_clocks          @ Call function to enable peripheral clocks
    BL enable_uart                       @ Call function to enable UART communication

    LDR R6, =incoming_buffer            @ Load the address of the incoming buffer into R6
    LDR R7, =incoming_counter            @ Load the address of the incoming counter into R7

    LDRB R7, [R7]                        @ Load the value of incoming_counter into R7

<<<<<<< HEAD
    MOV R8, #0x00                        @ Initialize R8 to 0

	LDR R0, =USART1                      @ Load the base address of USART1 into R0
	LDR R4, =terminating_char            @ Load the address of the terminating character into R4
	LDRB R4,[R4]                         @ Load the terminating character into R4

    BL receive_loop                      @ Branch to the receive_loop function

receive_loop:

    LDR R1, [R0, USART_ISR]              @ Load the USART_ISR register into R1
=======
	LDR R0, =USART1
	LDR R4, =terminating_char
	LDRB R4,[R4]
    // Call the function to read and retransmit
    BL receive_loop

receive_loop:

	// Load the base address of USART1 into R0
>>>>>>> ba9eec70274300d75b2fefac43b3686540fb666e

    TST R1, 1 << UART_ORE | 1 << UART_FE @ Test for UART overrun error (ORE) and framing error (FE)

    BNE clear_error                      @ Branch if either error is detected

    TST R1, 1 << UART_RXNE               @ Test for RXNE (Receive Data Register Not Empty) flag

    BEQ receive_loop                     @ If RXNE is not set, branch back to receive_loop

    LDRB R3, [R0, USART_RDR]             @ Load received data from USART_RDR into R3

    STRB R3, [R6, R8]                    @ Store received byte into incoming_buffer at offset R8

    ADD R8, #1                           @ Increment R8 to point to the next position in the buffer

    CMP R3, R4                           @ Compare received byte with terminating character

<<<<<<< HEAD
    BEQ transmit_string                  @ If received byte equals terminating character, branch to transmit_string

clear_error:

    LDR R1, [R0, USART_ICR]              @ Load the USART_ICR register into R1
    ORR R1, 1 << UART_ORECF | 1 << UART_FECF @ Set the overrun error clear flag and framing error clear flag
    STR R1, [R0, USART_ICR]              @ Store the modified value back to USART_ICR
    B receive_loop                       @ Branch back to receive_loop

transmit_string:

    BL enable_uart                       @ Call function to enable UART communication
    LDR R0, =USART1                      @ Load the base address of USART1 into R0

=======
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
>>>>>>> ba9eec70274300d75b2fefac43b3686540fb666e
transmit_loop:

    LDR R1, [R0, USART_ISR]              @ Load the USART_ISR register into R1

<<<<<<< HEAD
    TST R1, 1 << UART_TXE                @ Test for TXE (Transmit Data Register Empty) flag
    BEQ transmit_loop                    @ If TXE is not set, branch back to transmit_loop
=======
    // Load byte from tx_string into R5 and increment pointer
    LDRB R5, [R6], #1
>>>>>>> ba9eec70274300d75b2fefac43b3686540fb666e

    LDRB R5, [R6], #1                    @ Load a byte from the tx_string buffer and increment the buffer pointer

<<<<<<< HEAD
    STRB R5, [R0, USART_TDR]             @ Transmit the loaded byte via USART_TDR
=======
    // Compare current character with end character
    CMP R5, R4
>>>>>>> ba9eec70274300d75b2fefac43b3686540fb666e

    CMP R5, R4                           @ Compare transmitted byte with terminating character

<<<<<<< HEAD
    BNE transmit_loop                    @ If transmitted byte is not the terminating character, branch back to transmit_loop

	B receive_loop                       @ Branch back to receive_loop
    BX LR                                 @ Return from main function
=======
	B end_loop
    BX LR

end_loop:
	B end_loop
>>>>>>> ba9eec70274300d75b2fefac43b3686540fb666e
