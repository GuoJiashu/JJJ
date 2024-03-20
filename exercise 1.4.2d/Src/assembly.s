.syntax unified
.thumb

#include "initialise.s"

.global main


.data

input_string: .asciz "AAbCccDDDDeeeffg\0"   @ Input string to analyze for capital and lowercase letters

.text



main:

    BL enable_peripheral_clocks    @ Call function to enable peripheral clocks

    BL initialise_discovery_board  @ Call function to initialize the discovery board

    LDR R0, =#GPIOE                @ Load address of GPIOE into R0
    LDR R1, =#GPIOA                @ Load address of GPIOA into R1
    LDR R2, =input_string          @ Load address of input string into R2
    LDR R3, =#0                    @ Load initial offset for string into R3
    LDRB R4, =#0                   @ Load initial count for capital letters into R4

    LDR R5, =#0x41                 @ Load ASCII value for 'A' into R5

    B count                        @ Branch to count subroutine

count:

    CMP R5, #0x5A                  @ Compare current letter with 'Z'
    BEQ end_loop                   @ If current letter is 'Z', end loop
    LDRB R6, [R2, R3]              @ Load byte from input string at offset R3 into R6

    CMP R6, #0                     @ Check if end of string is reached
    BEQ button_pressed             @ If end of string is reached, jump to button_pressed

    CMP R6, R5                     @ Compare current character with current capital letter
    BEQ capital_letter_found       @ If current character matches current capital letter, jump to capital_letter_found

    ADD R5, #0x20                  @ Convert current capital letter to lowercase
    CMP R6, R5                     @ Compare current character with lowercase version of current letter
    BEQ lower_letter_found         @ If current character matches lowercase version of current letter, jump to lower_letter_found
    SUB R5, #0x20                  @ Restore original value of R5 (capital letter)

    ADD R3, #1                     @ Increment offset for input string

    B count                        @ Branch back to count subroutine

capital_letter_found:

    MOV R4, R4, LSL 1              @ Shift left R4 by 1 bit, effectively multiplying by 2
    ADD R4, #1                     @ Increment count of capital letters
    ADD R3, #1                     @ Increment offset for input string

    B count                        @ Branch back to count subroutine

lower_letter_found:

    MOV R4, R4, LSL 1              @ Shift left R4 by 1 bit, effectively multiplying by 2
    ADD R4, #1                     @ Increment count of capital letters
    ADD R3, #1                     @ Increment offset for input string
    SUB R5, #0x20                  @ Restore original value of R5 (capital letter)

    B count                        @ Branch back to count subroutine

button_pressed:

    LDR R7, [R1, #IDR]              @ Load GPIOA IDR register into R7
    TST R7, 1 << 0x00               @ Test bit 0 of IDR register
    BEQ button_pressed              @ If bit 0 is not set, continue looping until it is set

    B led                           @ If button is pressed, jump to led subroutine

led:

    STRB R4, [R0, #ODR +1]          @ Store R4 value to GPIOE ODR register at bit 1

    BL delay                        @ Call delay subroutine

    ADD R5, #1                      @ Increment to the next letter ASCII value

    BL reset                        @ Call reset subroutine

    B count                         @ Branch back to count subroutine

delay:
    MOV R8, #0x00100000            @ Load delay value into R8

led_not_finish:

    SUBS R8, #0x01                 @ Decrement delay counter
    BNE led_not_finish             @ Loop until delay counter reaches 0

    BX LR                          @ Return from subroutine

reset:
    LDR R3, =#0                    @ Reset offset for input string
    LDRB R4, =#0                   @ Reset count of capital letters

    BX LR                          @ Return from subroutine

end_loop:
    B end_loop                     @ Infinite loop to end the main program
