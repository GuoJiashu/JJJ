.syntax unified
.thumb

.global main

.data
incoming_buffer: .space 62
terminating_char: .byte 'a'
substitutionTable: .asciz "zyxwvutsrqponmlkjihgfedcba" @ Define a substitution table for encoding/decoding

.text

main:

    BL initialise_power                  @ Call function to initialize power
    BL enable_peripheral_clocks          @ Call function to enable peripheral clocks
    BL enable_usart1                     @ Call function to enable UART communication

    LDR R6, =incoming_buffer             @ Load the address of the incoming buffer into R6
    LDR R7, =incoming_counter            @ Load the address of the incoming counter into R7

    LDRB R7, [R7]                        @ Load the value of incoming_counter into R7

    MOV R8, #0x00                        @ Initialize R8 to 0

	LDR R0, =USART1                      @ Load the base address of USART1 into R0
	LDR R4, =terminating_char            @ Load the address of the terminating character into R4
	LDRB R4,[R4]                         @ Load the terminating character into R4

    BL receive_loop                      @ Branch to the receive_loop function

receive_loop:

    LDR R1, [R0, USART_ISR]              @ Load the USART_ISR register into R1

    TST R1, 1 << UART_ORE | 1 << UART_FE @ Test for UART overrun error (ORE) and framing error (FE)

    BNE clear_error                      @ Branch if either error is detected

    TST R1, 1 << UART_RXNE               @ Test for RXNE (Receive Data Register Not Empty) flag

    BEQ receive_loop                     @ If RXNE is not set, branch back to receive_loop

    LDRB R3, [R0, USART_RDR]             @ Load received data from USART_RDR into R3

    STRB R3, [R6, R8]                    @ Store received byte into incoming_buffer at offset R8

    ADD R8, #1                           @ Increment R8 to point to the next position in the buffer

    CMP R3, R4                           @ Compare received byte with terminating character

    BEQ lower_encode                  @ If received byte equals terminating character, branch to transmit_string

clear_error:

    LDR R1, [R0, USART_ICR]              @ Load the USART_ICR register into R1
    ORR R1, 1 << UART_ORECF | 1 << UART_FECF @ Set the overrun error clear flag and framing error clear flag
    STR R1, [R0, USART_ICR]              @ Store the modified value back to USART_ICR
    B receive_loop 
    
lower_encode:
    LDR R1, =incoming_buffer
    LDR R2, =substitutionTable

    BL applycipher
    B transmit_string

applycipher:
    LDRB R5, [R1], #1
	CMP R5, #0
    BEQ convert_done
    CMP R5, #'A'
    BLT encoder
    CMP R5, #'Z'
    BGT next_char
    ADD R5, R5, #'a' - 'A'

encoder:
    @ Encoding
    SUBS R5, R5, #'a'
    LDRB R5, [R2, R5]
    STRB R5, [R1, #-1]!
    B next_char

next_char:
    LDRB R5, [R1], #1
    CMP R5, #0
    BEQ convert_done
    B applycipher

convert_done:
    BX LR
    
transmit_string:

    BL enable_usart1                     @ Call function to enable UART communication
    LDR R0, =USART1                      @ Load the base address of USART1 into R0
    LDR R1, =incoming_buffer

transmit_loop:

    LDR R1, [R0, USART_ISR]              @ Load the USART_ISR register into R1

    TST R1, 1 << UART_TXE                @ Test for TXE (Transmit Data Register Empty) flag
    BEQ transmit_loop                    @ If TXE is not set, branch back to transmit_loop

    LDRB R5, [R1], #1                    @ Load a byte from the tx_string buffer and increment the buffer pointer

    STRB R5, [R0, USART_TDR]             @ Transmit the loaded byte via USART_TDR

    CMP R5, R4                           @ Compare transmitted byte with terminating character

    BNE transmit_loop                    @ If transmitted byte is not the terminating character, branch back to transmit_loop

    B end @ Return from main function
end:
	B end
