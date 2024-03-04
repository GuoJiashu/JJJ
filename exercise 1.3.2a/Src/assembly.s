.syntax unified
.thumb

.global main


.data
@ define variables

string1: .asciz "a!"
@ storing a string with null


.text
@ define text


@ this is the entry function called from the startup file
main:

    LDR R1, =string1 @ load address of string1 to R1
	MOV R2, #0 @ load a state in R2, 0 for lower-case mode, 1 for upper-case mode
	BL convert_case @ store current data to R14 and go to convert-case

	B end @ end

convert_case:

    CMP R2, #1 @ get the state
    BEQ to_lower @ if equal, change to to-lower mode
    B to_upper @ or change to to-upper mode

to_lower:

	LDRB R3, [R1], #1 @ load one byte from R3 and store to R1, offset is 1
	@ compare R3 to 'A'
    CMP R3, #'A'
    BLT lower_done @ if less than, then skip
    CMP R3, #'Z'
    BGT next_char @ if greater than, go to next character
    ADD R3, R3, #'a'-'A' @ convert to lower case
    STRB R3, [R1, #-1]! @ store the converted character and decrement R1
    B next_char @ go to the next character

 lower_done:

 	BX LR @ return

to_upper:

	LDRB R3, [R1], #1 @ load one byte from R3 and store to R1, offset is 1
    CMP R3, #'a'
    BLT upper_done
    CMP R3, #'z'
    BGT next_char
    SUB R3, R3, #'a'-'A' @ convert to upper case
    STRB R3, [r1, #-1]! @ store the converted character and decrement R1
    B next_char

 upper_done:

 	BX LR

next_char:

	LDRB R3, [R1], #1 @ load one byte from R3 and store to R1, offset is 1
    CMP R3, #0 @ check if end of string
    BEQ convert_done @ if end of string, conversion is done
    B convert_case @ otherwise, continue conversion

convert_done:

	B convert_done @ loop indefinitely until terminated

end:

    MOV R7, #1 @ prepare for system call exit
    MOV R0, #0 @ exit with success code
    SVC 0 @ perform system call
