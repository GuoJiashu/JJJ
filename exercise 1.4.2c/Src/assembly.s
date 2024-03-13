.syntax unified
.thumb

.global main_func

#include "definitions.s"
#include "initialise.s"

.data
@ Define variables
.section .bss
led_state: .space 2
.text

@ this is the entry function called from the startup file
main_func:

	@ Branch with link to set the clocks for the I/O and UART
	BL enable_peripheral_clocks

	@ Once the clocks are started, need to initialise the discovery board I/O
	BL initialise_discovery_board

	@ store the current light pattern (binary mask) in R4
	@LDR R0, =GPIOE  @ load the address of the GPIOE register into R0
	@STRB R4, [R0, #ODR + 1]   @ store this to the second byte of the ODR (bits 8-15)
	@LDR R4, =0b11111111 @ load a pattern for the set of LEDs (every second one is on)


program_loop:

@ 	Look at the GPIOE offset ODR, display as hex, then as binary. Look at the manual page 239



@ 	Look at the GPIOA offset IDR, display as hex, then as binary. Look at the manual page 239

@	task: read in the input button !
	LDR R0, =GPIOA	@ port for the input button
	LDRB R1, [R0, #IDR]

	CMP R1, #255
	BEQ LED_2

	@ If you run the code, the LEDs will blink too fast, so fast you cannot tell they
	@ are turning off and on. Uncomment the next line to make a delay


@BL delay_function
	B program_loop @ return to the program_loop label
LED:
LDR R0, =GPIOE  @ load the address of the GPIOE register into R0
	STRB R4, [R0, #ODR + 1]   @ store this to the second byte of the ODR (bits 8-15)
	@BL delay_function
	LDR R4, =0b00000000
	@LSL R4,R4,#1@EOR R4, #0xFF	@ toggle all of the bits in the byte (1->0 0->1)

@ADD R4,R4,#254

BL delay_function
@CMP R4,0b00000000
@BEQ main_func
LDR R0, =GPIOA	@ port for the input button
	LDRB R1, [R0, #IDR]
CMP R1, #255
	BEQ LED_2


B program_loop

LED_2:
LDR R0, =GPIOE  @ load the address of the GPIOE register into R0
	STRB R4, [R0, #ODR + 1]   @ store this to the second byte of the ODR (bits 8-15)
	@BL delay_function
	LDR R4, =0b11111111
	@LSL R4,R4,#1@EOR R4, #0xFF	@ toggle all of the bits in the byte (1->0 0->1)

@ADD R4,R4,#254

BL delay_function
@CMP R4,0b11111111
@BEQ main_func
LDR R0, =GPIOA	@ port for the input button
	LDRB R1, [R0, #IDR]
CMP R1, #255
	BEQ LED

B program_loop


@ think about how you could make a delay such that the LEDs blink at a certain frequency
delay_function:
	MOV R6, #0x0100000

	@ we continue to subtract one from R6 while the result is not zero,
	@ then return to where the delay_function was called
not_finished_yet:
	SUBS R6, 0x01
	BNE not_finished_yet

	BX LR @ return from function call


