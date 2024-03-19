.syntax unified
.thumb

.global main

.data
substitutionTable: .asciz "zyxwvutsrqponmlkjihgfedcba" @ Define a substitution table for encoding/decoding

.align
incoming_buffer: .space 62               @ Define a buffer to store incoming data
incoming_counter: .byte 62               @ Counter for the incoming buffer
terminating_char: .byte 'a'              @ Define the terminating character for data reception
tx_string: .space 62                     @ Buffer for transmitting strings

.text

main:
    BL initialise_power                  @ Call function to initialize power
    BL enable_peripheral_clocks          @ Call function to enable peripheral clocks
    BL enable_usart1                     @ Call function to enable UART communication

    LDR R6, =incoming_buffer             @ Load the address of the incoming buffer into R6
    LDR R7, =incoming_counter            @ Load the address of the incoming counter into R7

    LDRB R7, [R7]                        @ Load the value of incoming_counter into R7

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

    STRB R3, [R6, R7]                    @ Store received byte into incoming_buffer at offset R7

    ADD R7, #1                           @ Increment R7 to point to the next position in the buffer

    CMP R3, R4                           @ Compare received byte with terminating character

    BEQ encode_transmit_string           @ If received byte equals terminating character, branch to encode_transmit_string

    B receive_loop                       @ Branch back to receive_loop

clear_error:
    LDR R1, [R0, USART_ICR]              @ Load the USART_ICR register into R1
    ORR R1, 1 << UART_ORECF | 1 << UART_FECF @ Set the overrun error clear flag and framing error clear flag
    STR R1, [R0, USART_ICR]              @ Store the modified value back to USART_ICR
    B receive_loop                       @ Branch back to receive_loop

encode_transmit_string:
    BL encode_string                     @ Call function to encode the received string
    B transmit_encoded_string            @ Branch to transmit the encoded string

encode_string:
    LDR R1, =incoming_buffer             @ Load the address of the incoming buffer into R1
    LDR R2, =substitutionTable           @ Load the address of the substitution table into R2

encode_loop:
    LDRB R5, [R1], #1                    @ Load a byte from the incoming buffer and increment the buffer pointer
    CMP R5, #0                           @ Check if end of string is reached
    BEQ encode_done                      @ If end of string, exit loop
    CMP R5, #'A'                         @ Compare current byte with 'A'
    BLT next_char                        @ If current byte is less than 'A', go to next character
    CMP R5, #'Z'                         @ Compare current byte with 'Z'
    BGT next_char                        @ If current byte is greater than 'Z', go to next character
    ADD R5, R5, #'a' - 'A'               @ Convert uppercase letter to lowercase
    SUBS R5, R5, #'a'                   @ Convert character to index
    LDRB R5, [R2, R5]                    @ Lookup substitution from table
    STRB R5, [R1, #-1]!                  @ Store substituted byte and decrement the buffer pointer
    B encode_loop                        @ Repeat for next character

next_char:
    B encode_loop                        @ Continue to next character

encode_done:
    BX LR                                @ Return

transmit_encoded_string:
    LDR R0, =USART1                      @ Load the base address of USART1 into R0
    LDR R1, =incoming_buffer             @ Load the address of the incoming buffer into R1

transmit_loop:
    LDR R2, [R1], #1                     @ Load a byte from the encoded string buffer and increment the buffer pointer
    CMP R2, #0                           @ Check if end of string is reached
    BEQ end_transmission                 @ If end of string, exit loop
    BL transmit_byte                     @ Transmit the byte
    B transmit_loop                      @ Repeat for next character

transmit_byte:
    LDR R3, [R0, USART_ISR]              @ Load the USART_ISR register into R3
    TST R3, 1 << UART_TXE                @ Test for TXE (Transmit Data Register Empty) flag
    BEQ transmit_byte                    @ If TXE is not set, wait
    STRB R2, [R0, USART_TDR]             @ Transmit the loaded byte via USART_TDR
    BX LR                                @ Return

end_transmission:
    BL disable_usart1                    @ Call function to disable UART communication
    B main                               @ Branch back to main

end:
    MOV R7, #1                           @ Set R7 to indicate end of program
    MOV R0, #0                           @ Set R0 to indicate success
    SVC 0                                @ Trigger software interrupt to exit program

