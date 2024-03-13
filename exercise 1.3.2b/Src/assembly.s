.syntax unified
.thumb

.global main

.data
@ define variables

ascii_string: .asciz "Hello, World!\n" @ Define a null-terminated ASCII string

.text
@ define text

@ this is the entry function called from the startup file
main:
    LDR R1, =ascii_string  @ Load the address of the ASCII string into R1
    LDR R2, =3  @ Load the Caesar Cipher shift value (positive or negative) into R2
    BL caesar_cipher_counter  @ Apply Caesar Cipher
    B finished_everything  @ Jump to the end of the program

caesar_cipher_counter:
    MOV R3, #0  @ Initialize a counter for the string index

string_loop:
    LDRB R4, [R1, R3]  @ Load a byte from the ASCII string
    CMP R4, #0  @ Check if end of string
    BEQ finished_cipher  @ If it's null (0), then jump out of the loop

    ADD R4, R4, R2  @ Apply Caesar Cipher shift
    STRB R4, [R1, R3]  @ Store the modified byte in the string buffer

    ADD R3, R3, #1  @ Increment the index
    B string_loop  @ Loop to the next byte

finished_cipher:
    BX LR  @ Return to the caller

finished_everything:
    B finished_everything  @ Infinite loop here
