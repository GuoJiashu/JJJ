.syntax unified
.thumb


.global main


.data
 prompt: .asciz "HZ!"

 substitutionTable: .asciz "ZYXWVUTSRQPONMLKJIHGFEDCBA"

.text
@define text

main:

	LDR R1, =prompt
	LDR R2, =substitutionTable
	MOV R8, #1

	BL applycipher
	B end

applycipher:

	CMP R8, #0
	BEQ encoder
	B decoder

encoder:

	LDRB R5, [R1], #1
	CMP R5, #'A'
	BLT encoder_done
	CMP R5, #'Z'
	BGT next_char

	SUBS R5, R5, #'A'
	LDRB R5, [R2,R5]
	STRB R5, [R1, #-1]!
	B next_char

encoder_done:

	BX LR

decoder:

	LDRB R5, [R1], #1
	CMP R5, #'A'
	BLT decoder_done
	CMP R5, #'Z'
	BGT next_char


	SUBS R5, R5, #'A'
	CMP R5, #26
	BGT next_char

	LDRB R5, [R2, R5]
	STRB R5, [R1, #-1]!
	B next_char

decoder_done:

	BX LR

next_char:

	LDRB R5, [R1], #1
	CMP R5, #0
	BEQ convert_done
	B applycipher

convert_done:

	B convert_done

end:

	MOV R7, #1
	MOV R0, #0
	SVC 0
