# MTRX 2700 Wednesday 2PM-5PM Group 3
This is the Git site for MTRX 2700 in every Wednesday 2PM-5PM Group 3

1. Detail about the project:
     group member: Jiashu Guo, Junhao Fu, Marco
     1) Jiashu Guo: 1.3.2a, d of task 2, task 3, task 5
     2) Junhao Fu: 1.3.2c, task 4, documentation, README file
     3) Marco: 1.3.2b, a,b,c of task 2

# System Operation Description and Interpretation

## 1.3 Module 1 (Memory and Pointers)

## Task A
Task A aims to convert the letter either from lower case to upper case or in the opposite way by defining the ASCII string memory. 
```arm
.data
@ define variables

string1: .asciz "A!"
@ storing a string with null


.text
@ define text

main:

    LDR R1, =string1 @ load address of string1 to R1
	MOV R2, #0 @ load a state in R2, 0 for lower-case mode, 1 for upper-case mode
	BL convert_case @ store current data to R14 and go to convert-case

	B end @ end

convert_case:

    CMP R2, #1 @ get the state
    BEQ to_lower @ if equal, change to to-lower mode
    B to_upper @ or change to to-upper mode
```
An input of string, 'A!', is defined and load into register 1. R2 is used to let the system to make decision which the system should jump to lower case conversion function or upper case conversion. 

---
---

```arm
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
```
{to_lower} function initially define the range of letter that it should include and exclude elements which is not required to be converted. Then, the system will gets the difference/gap of hexdecimal number of capital letter 'A' and lower case of 'a'. The difference between them should be 20 in hex number according to the ACSII table. Also, it is known that the hex number of capital letter is always 20 hex number smaller than the its corresponding letter in lower case. Hence, the system could only add that particular byte of character with its hex number so that it could get the right lower case value for the particular letter. After finishing conversion, it jump to the function of {next_char} which would reads its next byte of the string. 

---
---

```arm 
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
```

The function {to_upper} has the similar operation theory with the module of {to_lower}. The only thing which is necessary to be changed is that it is required to change the line of code from {ADD R3, R3, #'a' - 'A'} to {SUB R3, R3, #'a' - 'A'} because the lower-case English letters has a higher hexdecmial number than upper-case characters.
After all this, the final result will appear on R1, we need to check memory, monitor the address of R1, select ASCII, and we will see the string after transfer.

### Output
All of the letters should be converted the either upper or lower case of characters which depends on the what the expected result that we want to. 


## Task B

The purpose of building Task B is to allow the amount function module to shift value to be either negative or positive, which enable the decoding and encoding operation. 

```arm 
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
```
As following the request of the task, the string loaded in R1 and the value that requires to shift stored load by R2. 
```arm
string_loop:
    LDRB R4, [R1, R3]  @ Load a byte from the ASCII string
    CMP R4, #0  @ Check if end of string
    BEQ finished_cipher  @ If it's null (0), then jump out of the loop

    ADD R4, R4, R2  @ Apply Caesar Cipher shift
    STRB R4, [R1, R3]  @ Store the modified byte in the string buffer

    ADD R3, R3, #1  @ Increment the index
    B string_loop  @ Loop to the next byte
```

The main idea of this part is to add the amount of value which needs to be shift with the specific byte in the input string. After adding the setting shift value, the hexdecimal number of that particular byte increases and convert the expected character. R3 would have the increment of index of 1 which prepares one byte of space for the next converted value in byte. 
After all this, the final result will appear on R1, we need to check memory, monitor the address of R1, select ASCII, and we will see the string after transfer.

### Output 
All the input string is shifted by setting shift value of 3, which is stored in the address of 0x200000000 in hex number. Beyond this, all the the last three element of 'X''Y''Z' should corresponding to the letter of 'A''B''C' for each one independently.  

## Task C

The idea of the task is to develop a system which is allowed to encode or decode each byte of a wide range of letter input to the expected output. This behaviour is done by the system through comparing the correspoding character in a stirng with the input character so that the system could be able to get the expected output. 

Hence, it is required to build a substitution table and place an input for which is needed to be encoded or decoded at the beginning of this module task.

```arm
.data
 prompt: .asciz "HZ!" 

 substitutionTable: .asciz "ZYXWVUTSRQPONMLKJIHGFEDCBA" 
```
As shown above, the input strings are defined after ".data". The string of prompt indicates the input which could be manually input a range of letters. Furthermore, the string of substitutionTable is the table of substition cipher which allows the system to compare with the codes that is required to encode/decode. 

---
---

```arm
main:

	LDR R1, =prompt @ Load the address of the prompt string into R1
	LDR R2, =substitutionTable @ Load the address of the substitution table into R2
	MOV R8, #1 @ Set R8 to 1 to indicate encoding operation

	BL applycipher @ Call the applycipher function to perform encoding/decoding
	B end @ Branch to end of program
```
In the main function, the prompt is setted to loarded into the register 1 and the substution cipher is loarded into the register 2. Besides, the register 8 represents the decisions of either encoding or decoding. 

---
---

```arm
encoder:
    @Part 1
	LDRB R5, [R1], #1 
	CMP R5, #'A'
	BLT encoder_done 
	CMP R5, #'Z'
	BGT next_char 

	@Part 2
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

The following figures provides an input and output for the system separately. It is clear that the input of "HZ!" which stored in the register 1 that has the address of hexdecimal number of 0x200000000.
![image](https://github.com/GuoJiashu/JJJ/assets/160695086/1b05b641-dbce-4ac6-b385-05e5cce4ef9d)

The output change into the corresponding cipher character after encoding. However, the symbol "!" is not converted because it is out of the range that the system could be able to encode, hence, it just skip the process of encoding and directly go through the {end_loop}. 
![image](https://github.com/GuoJiashu/JJJ/assets/160695086/2f1b5f5b-6cc7-43a0-aaf6-251a1649ac9f)



After all this, the final result will appear on R1, we need to check memory, monitor the address of R1, select ASCII, and we will see the string after transfer.

## 1.4 Exercise 2 (Digital I/O)

## Task A

The objective of task A is to enable the LED pattern. 

```arm 
main:
	
	LDR R4, = 0b00110011	@ Toad a pattern for the set of LEDs (every second one is on)
	LDR R0, =GPIOE 		@ Load the address of the GPIOE register into R0
	STRB R4, [R0, #ODR + 1]	@ Store this to the second byte of the ODR (bits 8-15)
	EOR R4, #0xFF		@ Toggle all of the bits in the byte (1->0 0->1)
```
To enable the LED pattern, the light pattern in binary is stored by R4 for later using. After that, it only needs to load the address of GPIOE and store it to the second byte of ODR. The LED pattern would be ON after toggling all of the bits in byte. 

## Output
Four LEDs will light up, two blue and two red on the board of STM32.

## Task B

```arm
main:

	@ Branch with link to set the clocks for the I/O and UART
	BL enable_peripheral_clocks

	@ Once the clocks are started, need to initialise the discovery board I/O
	BL initialise_discovery_board

	@ store the current light pattern (binary mask) in R4
	LDR R4, =0b00000000 @ load a pattern for the set of LEDs (every second one is on)
```
Enabling the peripheral clocks, initialising the discovery board and storing the pattern of light into R4 is the first thing which needs be specified. 

---
---

```arm 
program_loop:

	LDR R0, =GPIOA		@ Port for the input button. Load the base address of GPIO port A into register R0. 
	LDRB R1, [R0, #IDR] 	@ Load the byte value from the Input Data Register (IDR) of GPIO port A into register R1. LDRB loads a byte showing the current state of all pins in port A
	CMP R1, #255 		@ Compare the value loaded into R1 with 255, checking if all bits in the IDR are set to 1 (button is pressed)
	BEQ LED  		@ Branch to the label "LED" if the result of the comparison is equal to #255

	B program_loop 		@ Return to the program_loop label
```
Enable the port(GPIOA) for the input button and ensure it is ON, which the system goes to the next module function after testing. 

---
---

```arm 
LED:
	LDR R0, =GPIOE  	  @ load the address of the GPIOE register into R0
	STRB R4, [R0, #ODR + 1]   @ store this to the second byte of the ODR (bits 8-15)
	
	LSL R4, R4, #1       @ Left shift the value in R4 by 1, moving to the next LED in a sequence.
	ADD R4, R4, #1       @ Increment the value in R4 by 1, turning on the next LED.
	BL delay_function    @ Call a subroutine named 'delay_function' to introduce a delay.
	CMP R4, 0b11111111   @ Compare the value in R4 with #255 (all LEDs on) to check if all LEDs are turned on
	BEQ main             @ If R4 is equal to #255, branch to the 'main' function


	B program_loop 	     @return to the program_loop label
```
Enable the port of LED (GPIOE) and make the LED shifts next one by increment of 1. To ensure the system could be able to loop forever for every time the button is pressed, a reset function is setted while all of LED is ON after eight times of the button is pressed. 

---
---

```arm
delay_function:
    MOV R6, #0x0100000          @ Initialize R6 with a delay counter value

not_finished_yet:
    SUBS R6, R6, #0x01          @ Decrement the delay counter in R6 by 1
    BNE not_finished_yet        @ If R6 is not zero, branch back to continue the loop

    BX LR                       @ Return from the function call once the delay counter reaches zero
```
Additionally, a delay function is imported to this system to increase the time of the operation of system, which prevents from fast transmitting from the system to the board while pressing the button. Furthermore, it increases the stability of the system and protect it from crashing or error occuring during running process. 
Every time we press the button, one LED will be enabled untill all leds are enabled, then it will unenabled last time.

##Output
The light patterns would light one by one by pressing the button each time. 

## Limitation
The system could not loop forever while the button button is pressed all the time. It would go to the inifinity loop becasue of missing the function of turning off the LED. 

## Task C

Task C requests to turn the LEDs off by pressing the button each time based on the previous assembly code in Task B. 

The whole main body of functions are same with the code in previous function. The only differences is that it stores a binary value of 00000000 in 0 byte into R4 which controls the status of LED to be either ON or OFF that depends on the binary value it stores.

```arm 
LED:
	LDR R0, =GPIOE  	 @ Load the address of the GPIOE register into R0
	STRB R4, [R0, #ODR + 1]  @ Store this to the second byte of the ODR (bits 8-15)
	LDR R4, =0b00000000      @ Load the value 0 into register R4

	BL delay_function        @ Call the delay_function to introduce a delay

	LDR R0, =GPIOA           @ Load the base address of GPIO port A into register R0 (for the input button)
	LDRB R1, [R0, #IDR]      @ Load the byte value from the IDR of GPIOA into R1
	CMP R1, #255             @ Compare the value in R1 with #255 (checks if all bits in IDR are set)
	BEQ LED_2                @ If R1 is equal to #255, branch to the LED_2 label

	B program_loop           @ Branch back to the program_loop label

```
## Output 
The pattern of light would be ON one by one as the button is pressing, and it would be turned off in sequence by pressing the button again if all the LEDs light up.

## Task D

This part we will check how many centain alphabeta appears in a given string, when we run the code, every time we press button, the corresspond numbers of LED will light up, "AAbCccDDDDeeeffg", this is our string, the code will check from a to z, when we first press the button, check the number of "a/A", there are two "a/A", so two leds will light up, and will loop to letter "z/Z".

## 1.5 Exercise 3 (Serial communication)

## Task A
Task A is requested to build a function which allows to transmit a strings of characters from R1 to another function while the button on the STM 32 board is pressed. 

By following the task, it should enable all the basic functions that it needs, which is shown as below.
```arm
main:

	BL initialise_power          
	BL enable_peripheral_clocks  
	BL enable_uart              

	B program_loop              
program_loop:

	LDR R0, =GPIOA      
	LDRB R1, [R0, #0x10]
	CMP R1, #255        
	BEQ tx_loop         

	B program_loop      
tx_loop:

	LDR R0, =USART1     	

	LDR R1, =tx_string  	
	LDR R3, =tx_length  	

	LDR R4, [R3]        
```
---
---

```arm
tx_uart:

	LDR R2, [R0, USART_ISR]   	@ Load USART ISR register into R2
	ANDS R2, 1 << UART_TXE    	@ Perform bitwise AND operation to check UART_TXE flag

	BEQ tx_uart               	@ Branch back to tx_uart if UART_TXE flag is not set

	LDRB R5, [R1], #1         	@ Load byte from memory address pointed to by R1 into R5 and increment R1
	STRB R5, [R0, USART_TDR]  	@ Store byte from R5 into USART transmit data register

	SUBS R4, #1          		@ Subtract 1 from R4 (tx_length)

	                     		@ Compare R5 with ASCII code for '?'
	CMP R5, #'?'
	BEQ end_transmission 		@ Branch to end_transmission if equal

	BGT tx_uart          		@ Keep looping while there are more characters to send

	BL delay_loop        		@ Call delay_loop subroutine
```
To achieve the target, the function of {tx_uart} should firstly load the USART ISR register to enable the board to recieve message. After that, the input message stored in the register needs to be transmitted into transmit data register. For each of time of button is pressed, a byte of character is transmitted into R5 through data transmitt register. Moreover, all the end of string put a "?" to tell the system which the message finishes so that the system would not loop again and again even though the message is finished transmitted. Everytime we press the button, we will see message appeas on terminal progam like PuTTY

## Output 
The function module would start to transmit the data, which stores in register 1, to another function by pressing the button each time. 

## Limitation
* Each end of string is required to have an '?', otherwise, the system does not know what is the end of the string it reads. It would keep looping forever.

## Task B
```arm 
.data
.align

incoming_buffer: .space 62

incoming_counter: .byte 62

terminating_char: .asciz "a"

main:
    LDR R6, =incoming_buffer
	LDR R7, =incoming_counter

	// Load the value from incoming_counter into R7
	LDRB R7, [R7]

	// Initialize index counter R8
	MOV R8, #0x00
```
Before transmitting the input message of the function, a buffer address in 62 spaces is build for the data which should be transmistted later on. Also, the terminating character is set as an 'a'. 

```arm
loop_forever:

	LDR R0, =USART1

	LDR R1, [R0, USART_ISR]

	TST R1, 1 << UART_ORE | 1 << UART_FE

	BNE clear_error

clear_error:

	LDR R1, [R0, USART_ICR]
	ORR R1, 1 << UART_ORECF | 1 << UART_FECF
	STR R1, [R0, USART_ICR]
	B loop_forever
```
The front part of the {loop_forever} function is set to check the error, such as overrun error or framing error, which may occur during the operation process. Therefore, a reset function is used to re-enable those registers to ensure it runs properly. 

```arm
loop_forever:
   
	LDRB R3, [R0, USART_RDR]
	STRB R3, [R6, R8]
	ADD R8, #1
	CMP R7, R8
	BGT no_reset
	MOV R8, #0
	CMP R3, terminating_char
	BEQ end_loop

no_reset:

	// Request to reset the UART receiver
	LDR R1, [R0, USART_RQR]
	ORR R1, 1 << UART_RXFRQ
	STR R1, [R0, USART_RQR]

	// Continue loop
	BGT loop_forever
```
This code above is main part of {loop_forever} after enabling the USART1, load {USART_ISR} and error checking to this function. For receiving the characters from computer, the port of USART_RDR is enable and stored into the R3. However, it should consider whether the buffer is full or not, the {incoming_counter} is used to check if the received data stored into buffer exceed the size of buffer. It would automatically jump to reset function to UART receiver while the string of character is oversizing. After that, the system would stop to loop if the receved character matche the {terminating_char}, otherwise, it will loop forever until the expected character matches with the string of data received. We will see the data we input from PuTTY appears on the address 0x20000000

## Output 
The function received the string characters, it would keep looping until the terminated characters are defined. 

## Limitation 
* The function would occur the error of framing and overrun error which is requested to put a clear error function to reset and re-enable those register.
  
## Task C
For this part, we just enabled the clock and change the baud rate, we use formula 8m/expected baud rate, we choose 57600, and we will have result 0x8C, then if we use PuTTY, we just need to turn to the right baud rate, we will see the transmission.

## Task D
This task is the combination of pervious first two tasks of this exercise. The function below is used to receive the input message of string through the port of {USART_RDR} which stored by R3. The system would keep storing the value until the terminate character is detected.

```arm
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

    BEQ transmit_string                  @ If received byte equals terminating character, branch to transmit_string
```

The {transmit_loop} receives the output of a string from the function of {tx_string}, which would store the received data into the {USART_TDR}. The data would be transmitted back to received loop after ensuring the terminating character is within the string. 

```arm
    transmit_loop:

    LDR R1, [R0, USART_ISR]              @ Load the USART_ISR register into R1

    TST R1, 1 << UART_TXE                @ Test for TXE (Transmit Data Register Empty) flag
    BEQ transmit_loop                    @ If TXE is not set, branch back to transmit_loop

    LDRB R5, [R6], #1                    @ Load a byte from the tx_string buffer and increment the buffer pointer

    STRB R5, [R0, USART_TDR]             @ Transmit the loaded byte via USART_TDR

    CMP R5, R4                           @ Compare transmitted byte with terminating character

    BNE transmit_loop                    @ If transmitted byte is not the terminating character, branch back to transmit_loop

	B receive_loop                       @ Branch back to receive_loop
    BX LR                                 @ Return from main function
```

## Output
This part, we use UART4 and USART1, one board recieve the input data from pc and the transmit to another board via UART4 and also transmit to PC via USART1, if we input message on one computer, when the terminal character is recieved, the PuTTY on another computer will simutanueouly show the message just entered on another computer.


## 1.6.2 Module 4 (Hardware Timer)

The hardware timer is used to produce frequency output which is visulise through frequency flashes of LED. The system applies the timer of TIM2. 

### Task A
In task A, it is required to build a delay function which is able to be achieve by changing the value of prescalar so as to change the frequency of the output. 

```arm
main:

    LDR R1, =7               
    STR R1, [R0, TIM_PSC]      

    BL trigger_prescaler

trigger_prescaler:

	LDR R0, =TIM2

	BX LR
```
The lines of code indicates the prescalar of 7 is stored into R1 with the setting of TIM_PSC. The code would immediately jump to the function of {triiger_prescalar} and link back to the main function after it stores the prescalar into TIM2. The frequency of the timer could be able to change by selecting and adjusting the appropriate value of prescalar. 

### Limitation 
* The delay function need to check and compare to the count value in TIM_CNT and also it is required to set set the TIM_CNT to 0 manually. 

## Task B
According to the data sheet, the formula of desired output frequency for STM32 is 

        				Desired Output Frequency = TIM_CLK/((TIM_PSC + 1)/(TIM_ARR+1))

The desired output frequency is 0.1ms, which equals to the frequency of 1*10^-4Hz.It is known that the TIM_CLK is 32MHz because the timer that used in the task is 32 bits timer. The value for the TIM_ARR is set as 100.

    					Desired Output Frequency = TIM_CLK/((TIM_PSC + 1)/(TIM_ARR+1))

                        				8*10^8Hz = 32MHz * 100/TIM_PSC + 1

                            					P= 3

Hence, the prescalar that is require to reach a 0.1ms for the prescalar is 3200. However, by considering the use of PWM function, the actual output of the function is required to be worked out. 

    						Actual Output Frequency = Timer Frequency/(period+1)
                            						= 8*10^8/8*10^4
                           							=8*10^4Hz
                            						= 0.1 millionsecond. 
## Output
The LED of the board should be able to flases with a frequency of 8*10^4 Hz. 

## Task C

```arm
main:

    @ Set auto-reload register (TIM_ARR) for the desired period
    LDR R1, =period           @ Load the period value
    LDR R2, [R1]              @ Load the value into R2
    STR R2, [R0, TIM_ARR]     @ Set the auto-reload register

    LDR R1, =7             
    STR R1, [R0, TIM_PSC]     

    BL trigger_prescaler

trigger_prescaler:

	@ store a value for the prescaler
	LDR R0, =TIM2	@ load the base address for the timer

	LDR R1, = 1000@ make the timer overflow after counting to only 1
	STR R1, [R0, TIM_ARR] @ set the ARR register

	LDR R8, =0x00
	STR R8, [R0, TIM_CNT] @ reset the clock
	NOP
	NOP

	LDR R1, =0xffffffff @ set the ARR back to the default value
	STR R1, [R0, TIM_ARR] @ set the ARR register

	BX LR
```

Task C requires to build a preload function to increase the stability of the timer system so as to decrease the possibility of crash of system. Hence, {TIMX_ARR} and APSE = 1 are required to used to allow the timer to preceed auto-reload function. In detail, the count in TIM_CNT automatically gets set back to 0, and a signal is generated which sets a flag to demonstrate that the overflow happened when the count in the TIM_CNT register reaches the value stored in the TIM_ARR register and the count in TIM_CNT automatically get set back to 0. 

Furthermore, PWM function, generating a more appropriate frequency output, is built to increase the reliability of the function. 
```arm
pwm_on_loop:
	LDR R0, =TIM2  
	LDR R6, [R0, TIM_CNT]	@ read current time

	@ compare current time to on_time (R1)
	CMP R6, R1
	BGT pwm_off_cycle

	B pwm_on_loop

pwm_off_loop:
	LDR R0, =TIM2  @ load the address of the timer 2 base address
	LDR R6, [R0, TIM_CNT]	@ read current time

	@ compare current time to period (R2)
	CMP R6, R2
	BGT pwm_on_cycle

	B pwm_off_loop
```

The PWM provide an almost absoluate square wave through reading the current time of TIM2 and compare it with the expected setting value. The loop continues to loop until the current value of time is greater than the setting value, and it produces an output after looping finishes. Similarly, the output from the function {pwm_on_loop} will be not generated only when the looping of {pwm_off_loop} is finished after comparing the current time. 

### Output
![image](https://github.com/GuoJiashu/JJJ/assets/160695086/24736331-ba70-4b0d-ac8f-c5f908dfb1d2)

The discovered kit board outputs an frequency in 1.17 seconds by seleting the value of prescalar of 8 with a value of counter overflow of 1.
### Limitation

* The output frequency of the discover board becomes hard to work out because of adding a PWM function to loop again and agagin. It increases the difficulty of calculations which not only needs to work out the prescalar value and value of counter overflow, it still needs to consider the element of period and on_time. 

## Exercise 5
the basic operation theory of the task is to combine the pervious four tasks to perform exptect output. It should firstly connect using wires to connect the port between stm32 discovery board and another one. 

### Output 
The PC should send it input a message string into the port of UART to the first board. The first board that received encodes the message by comparing with the substitution cipher. After that, the message of the first board sends to the second board which should be able to decode the message. The specific LED pattern will be lighten while the system detect the letter of alphabet, which would be able to flashes in 500ms interval. 

### Limitations
* There are too many module of tasks to combine with. It would greatly increase the possibility of error occruing in the tramitting process between the boards.
* Furthermore, there are few registers to store the value for either each value or port addresss, which is not enough to be used. 
