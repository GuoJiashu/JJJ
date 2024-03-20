.syntax unified
.thumb

#include "initialise.s"

.global main


.data
@ define variables
on_time: .word 0x10000
period: .word 0x80000
ARPE: .byte 1
TIM_CEN: .byte 1




.text
@ define code


main:
    BL enable_timer2_clock
    BL enable_peripheral_clocks
    BL initialise_discovery_board

    LDR R0, =TIM2            @ Load the base address for the timer
 
    MOV R1, #0b1              @ Store a 1 in bit zero for the CEN flag
    STR R1, [R0, TIM_CR1]     @ Enable the timer

    @ Set auto-reload register (TIM_ARR) for the desired period
    LDR R1, =period           @ Load the period value
    LDR R2, [R1]              @ Load the value into R2
    STR R2, [R0, TIM_ARR]     @ Set the auto-reload register

    @ Store a value for the prescaler
    LDR R1, =7               @ Put a prescaler in R1
    STR R1, [R0, TIM_PSC]      @ Set the prescaler register

    BL trigger_prescaler

    B pwm_loop

pwm_loop:
	@ store the current light pattern (binary mask) in R7
	LDR R7, =0b01010101 @ load a pattern for the set of LEDs (every second one is on)

	LDR R1, =on_time
	LDR R1, [R1]

	LDR R2, =period
	LDR R2, [R2]


pwm_on_cycle:
	@ reset the counter
	LDR R0, =TIM2
	LDR R8, =0x00
	STR R8, [R0, TIM_CNT]

no_reset:
	LDR R0, =GPIOE  @ load the address of the GPIOE register into R0
	STRB R7, [R0, #ODR + 1]   @ store this to the second byte of the ODR (bits 8-15)

pwm_on_loop:
	LDR R0, =TIM2  @ load the address of the timer 2 base address
	LDR R6, [R0, TIM_CNT]	@ read current time

	@ compare current time to on_time (R1)
	CMP R6, R1
	BGT pwm_off_cycle

	B pwm_on_loop


@ turn off the LEDs and
pwm_off_cycle:
	LDR R0, =GPIOE  @ load the address of the GPIOE register into R0
	MOV R4, 0x00
	STRB R4, [R0, #ODR + 1]   @ store this to the second byte of the ODR (bits 8-15)

pwm_off_loop:
	LDR R0, =TIM2  @ load the address of the timer 2 base address
	LDR R6, [R0, TIM_CNT]	@ read current time

	@ compare current time to period (R2)
	CMP R6, R2
	BGT pwm_on_cycle

	B pwm_off_loop


trigger_prescaler:

	@ store a value for the prescaler
	LDR R0, =TIM2	@ load the base address for the timer

	LDR R1, = 1000
	STR R1, [R0, TIM_ARR] @ set the ARR register

	LDR R8, =0x00
	STR R8, [R0, TIM_CNT] @ reset the clock
	NOP
	NOP

	LDR R1, =0xffffffff @ set the ARR back to the default value
	STR R1, [R0, TIM_ARR] @ set the ARR register

	BX LR

