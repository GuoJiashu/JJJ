.syntax unified
.thumb

.global main

#include "initialise.s"

.data

on_time: .word 0x00F00000
period: .word 0x80000

.align

incoming_buffer: .space 62               @ Define a buffer to store incoming data
terminating_char: .byte '-'              @ Define the terminating character for data reception
substitutionTable: .asciz "zyxwvutsrqponmlkjihgfedcba" @ Define a substitution table for encoding/decoding

.text

main:

    BL initialise_power                  @ Call function to initialize power
    BL enable_peripheral_clocks          @ Call function to enable peripheral clocks
    BL enable_uart4                      @ Call function to enable UART communication

    LDR R6, =incoming_buffer             @ Load the address of the incoming buffer into R6

    MOV R8, #0x00                        @ Initialize R8 to 0

	LDR R0, =UART4                       @ Load the base address of USART1 into R0
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

    BEQ decode                  @ If received byte equals terminating character, branch to transmit_string

clear_error:

    LDR R1, [R0, USART_ICR]              @ Load the USART_ICR register into R1
    ORR R1, 1 << UART_ORECF | 1 << UART_FECF @ Set the overrun error clear flag and framing error clear flag
    STR R1, [R0, USART_ICR]              @ Store the modified value back to USART_ICR
    B receive_loop                       @ Branch back to receive_loop

decode:
    @LDR R1, =incoming_buffer
    LDR R2, =#substitutionTable
	MOV R7, #0	@counter

    BL decipher
    B alphabeta_count

decipher:
    LDRB R5, [R6]

    CMP R5, #'a'
    BLT store
    CMP R5, #'z'
    BGT store

search_loop:
	LDRB R3, [R2, R7]	@load the R3th bit from sub table
	CMP R5, R3
	BEQ decoder

	ADD R7, #1
	B search_loop

decoder:
	ADD R7, #'a'
	MOV R5, R7

store:
    STRB R5, [R6], #1

next_char:
    CMP R5, R4
    BEQ convert_done
    MOV R7, #0
    B decipher

convert_done:
    BX LR

alphabeta_count:

    BL enable_peripheral_clocks    @ Call function to enable peripheral clocks
	BL enable_timer2_clock
    BL initialise_discovery_board  @ Call function to initialize the discovery board
	BL trigger_prescaler

    LDR R0, =#GPIOE                @ Load address of GPIOE into R0
    LDR R2, =incoming_buffer          @ Load address of input string into R2
    LDR R3, =#0                    @ Load initial offset for string into R3
    LDRB R4, =#0                   @ Load initial count for capital letters into R4

    LDR R5, =#0x41                 @ Load ASCII value for 'A' into R5

    B count                        @ Branch to count subroutine

count:

    CMP R5, #0x5A                  @ Compare current letter with 'Z'
    BEQ end_loop                   @ If current letter is 'Z', end loop
    LDRB R6, [R2, R3]              @ Load byte from input string at offset R3 into R6

    CMP R6, #0                     @ Check if end of string is reached
    BEQ led             @ If end of string is reached, jump to button_pressed

    CMP R6, R5                     @ Compare current character with current capital letter
    BEQ letter_found       @ If current character matches current capital letter, jump to capital_letter_found

    ADD R3, #1                     @ Increment offset for input string

    B count                        @ Branch back to count subroutine

letter_found:

    MOV R4, R4, LSL 1              @ Shift left R4 by 1 bit, effectively multiplying by 2
    ADD R4, #1                     @ Increment count of capital letters
    ADD R3, #1                     @ Increment offset for input string
    SUB R5, #0x20                  @ Restore original value of R5 (capital letter)

    B count                        @ Branch back to count subroutine

led:

    STRB R4, [R0, #ODR +1]          @ Store R4 value to GPIOE ODR register at bit 1

    BL timer                       @ Call delay subroutine

    ADD R5, #1                      @ Increment to the next letter ASCII value

    BL reset                        @ Call reset subroutine

    B count                         @ Branch back to count subroutine

reset:
    LDR R3, =#0                    @ Reset offset for input string
    LDRB R4, =#0                   @ Reset count of capital letters

    BX LR                          @ Return from subroutine

timer:


    LDR R12, =TIM2            @ Load the base address for the timer

    MOV R11, #0b1              @ Store a 1 in bit zero for the CEN flag
    STR R11, [R12, TIM_CR1]     @ Enable the timer

    @ Set auto-reload register (TIM_ARR) for the desired period
    LDR R11, =period           @ Load the period value
    LDR R10, [R11]              @ Load the value into R10
    STR R10, [R12, TIM_ARR]     @ Set the auto-reload register

    @ Store a value for the prescaler
    MOV R11, #15             @ Put a prescaler in R11
    STR R11, [R12, TIM_PSC]      @ Set the prescaler register

    B pwm_loop

pwm_loop:
 @ store the current light pattern (binary mask) in R4

 	LDR R11, =on_time
 	LDR R11, [R11]

 	LDR R10, =period
 	LDR R10, [R10]


pwm_on_cycle:
 	@ reset the counter
 	LDR R12, =TIM2
 	LDR R8, =0x00
 	STR R8, [R12, TIM_CNT]

no_reset:
 	LDR R12, =GPIOE  @ load the address of the GPIOE register into R12
 	STRB R4, [R12, #ODR + 1]   @ store this to the second byte of the ODR (bits 8-15)

pwm_on_loop:
 	LDR R12, =TIM2  @ load the address of the timer 2 base address
 	LDR R9, [R12, TIM_CNT] @ read current time

 @ compare current time to on_time (R1)
 	CMP R9, R11
 	BGT count

	B pwm_on_loop
trigger_prescaler:

 	@ store a value for the prescaler
 	LDR R12, =TIM2 @ load the base address for the timer

 	LDR R11, = 1@ make the timer overflow after counting to only 1
 	STR R11, [R12, TIM_ARR] @ set the ARR register

 	LDR R8, =0x00
 	STR R8, [R12, TIM_CNT] @ reset the clock
 	NOP
 	NOP

 	LDR R11, =0xffffffff @ set the ARR back to the default value
 	STR R11, [R12, TIM_ARR] @ set the ARR register

 	BX LR

end_loop:
    B end_loop                     @ Infinite loop to end the main program
