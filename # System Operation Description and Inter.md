# System Operation Description and Interpretation

## 1.3 Module 1 (Memory and Pointers)

### 1.3.1 Convert of upper and lower case of letter

### 1.3.2 

### 1.3.3 Encode and Decode
---
The idea of the task is to develop a system which is allowed to encode or decode each byte of a wide range of letter input to the expected output. This behaviour is done by the system through comparing the correspoding character in a stirng with the input character so that the system could be able to get the expected output. 

The basic operation theory of the system is that 

Hence, it is required to build a substitution table and place an input for which is needed to be encoded or decoded at the beginning of this module task.

```arm
.data
 prompt: .asciz "HZ!" 

 substitutionTable: .asciz "ZYXWVUTSRQPONMLKJIHGFEDCBA" 
```
As shown above, the input strings are defined after ".data". The string of prompt indicates the input which could be manually input a range of letters. Furthermore, the string of substitutionTable is the table of substition cipher which allows the system to compare with the codes that is required to encode/decode. 

```arm
main:

	LDR R1, =prompt @ Load the address of the prompt string into R1
	LDR R2, =substitutionTable @ Load the address of the substitution table into R2
	MOV R8, #1 @ Set R8 to 1 to indicate encoding operation

	BL applycipher @ Call the applycipher function to perform encoding/decoding
	B end @ Branch to end of program
```
In the main function, the prompt is setted to loarded into the register 1 and the substution cipher is loarded into the register 2. Besides, the register 8 represents the decisions of either encoding or decoding. 

```arm
encoder:
    @Part 1
	LDRB R5, [R1], #1 
	CMP R5, #'A'
	BLT encoder_done 
	CMP R5, #'Z'
	BGT next_char 

	SUBS R5, R5, #'A'
	LDRB R5, [R2,R5] 
	STRB R5, [R1, #-1]!
	B next_char
```
As shown above, the encoder module sperate with two parts for the function. It firstly store the input string into register 5 and minimise the range of elements because the system only accept to encode capital letters. It menas that any element would be jump to the function of "next_char", shift to next byte, if it is out of range by comparing their hexdecimal numbers. 

The second part starts to encode the input string into cipher. The system work out which posistion of the specific cipher for each letter by substrating 'A', hence, the system knows the hexdecmial number difference between the input character and ‘A’. After that, the line of code {LDRB R5, [R2,R5]} is used to load the corrspoinding substituion character from the table by shifting the difference value that it gets from the calculation. The new value update into the register 5 and jump to "next_char" function. 

```arm
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
```
Decoder function completely applies the same theories with the function of encoder. 

**Output:**






