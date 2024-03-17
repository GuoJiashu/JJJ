.syntax unified
.thumb

#include "definitions.s"

#.global enable_timer2_clock
#.global enable_peripheral_clocks
#.global initialise_discovery_board

.text
@ define code

enable_timer2_clock:

	LDR R0, =RCC
	LDR R1, [R0, APB1ENR]
	ORR R1, 1 << TIM2EN
	STR R1, [R0, APB1ENR]
	BX LR

enable_peripheral_clocks:
	LDR R0, =RCC
	LDR R1, [R0, #AHBENR]
	ORR R1, 1 << 21 | 1 << 19 | 1 << 17
	STR R1, [R0, #AHBENR]
	BX LR

initialise_discovery_board:
	LDR R0, =GPIOE
	LDR R1, =0x5555
	STRH R1, [R0, #MODER + 2]
	BX LR
