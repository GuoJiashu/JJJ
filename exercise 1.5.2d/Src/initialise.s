.syntax unified
.thumb

#include "definitions.s"



enable_peripheral_clocks:

	LDR R0, =RCC

	LDR R1, [R0, #AHBENR]
	ORR R1, 1 << GPIOE_ENABLE | 1 << GPIOD_ENABLE | 1 << GPIOC_ENABLE | 1 << GPIOB_ENABLE | 1 << GPIOA_ENABLE  @ enable GPIO
	STR R1, [R0, #AHBENR]

	BX LR

enable_uart:

	LDR R0, =GPIOC

	LDR R1, =0x77
	STRB R1, [R0, AFRL + 2]

	LDR R1, [R0, GPIO_MODER]
	ORR R1, 0xA00
	STR R1, [R0, GPIO_MODER]

	LDR R1, [R0, GPIO_OSPEEDR]
	ORR R1, 0xF00
	STR R1, [R0, GPIO_OSPEEDR]

	LDR R0, =RCC
	LDR R1, [R0, #APB2ENR]
	ORR R1, 1 << UART_EN
	STR R1, [R0, #APB2ENR]

	MOV R1, #0x46
	LDR R0, =USART1
	STRH R1, [R0, #USART_BRR]

	LDR R0, =USART1
	LDR R1, [R0, #USART_CR1]
	ORR R1, 1 << UART_TE | 1 << UART_RE | 1 << UART_UE

	STR R1, [R0, #USART_CR1]

	BX LR

initialise_power:

	LDR R0, =RCC

	LDR R1, [R0, #APB1ENR]
	ORR R1, 1 << PWREN
	STR R1, [R0, #APB1ENR]

	LDR R1, [R0, #APB2ENR]
	ORR R1, 1 << SYSCFGEN
	STR R1, [R0, #APB2ENR]

	BX LR
