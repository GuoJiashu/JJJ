.syntax unified
.thumb

.global main

.data
@ define variables

ascii_string: .asciz "XYSZ!" @ Define a null-terminated ASCII string

.text
@ define text

@
main:
    LDR R1, =ascii_string  @ Load the address of the ASCII string into R1
    LDR R2, =3             @ Load the Caesar Cipher shift value (positive or negative) into R2
    BL caesar_cipher       @ Apply Caesar Cipher
    B finished_everything  @ Jump to the end of the program

caesar_cipher:
    MOV R3, #0              @ Initialize index for string buffer
    MOV R5, #5				@ Length of string
string_loop:
    LDRB R4, [R1, R3]     @ Load a byte from the ASCII string
    SUBS R5, #1             @ Check if end of string
    CMP R5, #0	
    BEQ finished_cipher    @ If it's null (0), then jump out of the loop

    CMP R4, #'A'
    BLT next_char
    CMP R4, #'Z'
    BGT next_char          @ If greater than 'Z', skip shifting

    ADD R4, R4, R2         @ Apply Caesar Cipher shift
    CMP R4, #'Z'
    BLE store_char         @ If less than or equal to 'Z', store character
    SUB R4, R4, #26        @ Handle overflow by wrapping around from 'Z' to 'A'

store_char:
    STRB R4, [R1,R3]      @ Store the modified byte in the string buffer
    ADD R3, R3, #1         @ Increment the index
    B string_loop          @ Loop to the next byte

finished_cipher:
    BX LR                  @ Return to the caller

finished_everything:
    B finished_everything  @ Infinite loop here

next_char:
    B string_loop          @ Continue looping to the next character
