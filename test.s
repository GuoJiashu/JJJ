.syntax unified
.thumb

.global main

.data
prompt: .asciz "AA" @ Define a string
alphabets: .asciz "abcdefghijklmnopqrstuvwxyz"
substitutionTable: .asciz "zyxwvutsrqponmlkjihgfedcba" @ Define a substitution table for encoding/decoding

.text


main:
    LDR R1, =prompt
    LDR R2, =substitutionTable

    BL applycipher
    B end

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

end:
    MOV R7, #1
    MOV R0, #0
    SVC 0
