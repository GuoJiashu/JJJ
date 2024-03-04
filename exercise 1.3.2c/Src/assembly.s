.syntax unified
.thumb


.global main


.data
 prompt: .asciz "HZ!" @ Define a string

 substitutionTable: .asciz "ZYXWVUTSRQPONMLKJIHGFEDCBA" @ Define a substitution table for encoding/decoding

.text
@define text

main:

	LDR R1, =prompt @ Load the address of the prompt string into R1
	LDR R2, =substitutionTable @ Load the address of the substitution table into R2
	MOV R8, #1 @ Set R8 to 1 to indicate encoding operation

	BL applycipher @ Call the applycipher function to perform encoding/decoding
	B end @ Branch to end of program

applycipher:

	CMP R8, #0 @ Compare R8 with 0 to determine if encoding or decoding
	BEQ encoder @ If R8 is 0, branch to encoder
	B decoder @ If R8 is not 0, branch to decoder

encoder:

	LDRB R5, [R1], #1 @ Load a byte from memory pointed by R1 into R5 and increment R1
	@ Compare the byte with 'A'
	CMP R5, #'A'
	BLT encoder_done  @ If byte is less than 'A', encoding is done
	@ Compare the byte with 'Z'
	CMP R5, #'Z'
	BGT next_char @ If byte is greater than 'Z', move to next character

	@ Subtract 'A' from the byte to get its position in the alphabet
	SUBS R5, R5, #'A'
	LDRB R5, [R2,R5] @ Load the corresponding substitution character from the table
	STRB R5, [R1, #-1]! @ Store the substitution character back in memory and decrement R1
	B next_char @ Branch to process the next character

encoder_done:

	BX LR @ Return from the function

decoder:

	LDRB R5, [R1], #1 @ Load a byte from memory pointed by R1 into R5 and increment R1
	@ Compare the byte with 'A'
	CMP R5, #'A'
	BLT decoder_done @ If byte is less than 'A', decoding is done
	@ Compare the byte with 'Z'
	CMP R5, #'Z'
	BGT next_char @ If byte is greater than 'Z', move to next character


	@ Subtract 'A' from the byte to get its position in the alphabet
	SUBS R5, R5, #'A'
	CMP R5, #26 @ Compare the byte with 26
	BGT next_char @ If byte is greater than 26, move to next character

	LDRB R5, [R2, R5] @ Load the corresponding original character from the table
	STRB R5, [R1, #-1]! @ Store the original character back in memory and decrement R1
	B next_char @ Branch to process the next character

decoder_done:

	BX LR @ Return from the function

next_char:

	LDRB R5, [R1], #1 @ Load a byte from memory pointed by R1 into R5 and increment R1
	CMP R5, #0 @ Compare the byte with null terminator
	BEQ convert_done @ If byte is null terminator, conversion is done
	B applycipher @ Otherwise, branch back to applycipher to process the next character

convert_done:

	B convert_done @ Loop indefinitely (optional)

end:

	MOV R7, #1
	MOV R0, #0
	SVC 0
