#include "msp.h"
#include <stdio.h>


/**
 * main.c
 */
#define DELAY 50
#define PERIOD 20
#define ACLK_CYCLES_PER_MS 32
#define MIN_DUTY_CYCLE_MS 1
#define MAX_DUTY_CYCLE_MS 2

void configure_GPIO(void) {
    // Set P6.0 for ADC input (channel A15)
    P6->DIR = 0; // input
    P6->SEL0 = 1;
    P6->SEL1 = 1;

    // Output debug LED
    P2->DIR = 0xFF; // output
    P2->OUT = 0;

    // Output debug port
    P4->DIR = 0xFF; // Output
    P4->OUT = 0;

    // Output PWM for arm
    P3->DIR = 0xFF; // out direction
    P3->SEL1 = 0; // set to module function
    P3->SEL0 = 1;
    // P3.0 port mapping
    PMAPKEYID = PMAP_KEYID_VAL;
    P3MAP01 = PM_TA1CCR1A;
    PMAPKEYID = 0x0;
}

void configure_timer(void) {
    // Configure ACLK (reference manual p.378)
    // input password
    CS->KEY = CS_KEY_VAL;
    // enable REFOCLK, ACLK
    CS->CLKEN = 1 << 9 | 1;
    // Configure timer A0 (reference manual p.782)
    // up mode, select ACLK source, interrupt enable
    TIMER_A0->CTL = 1 << 4 | 1 << 8 | 1 << 1;
    // poll ACLK READY until 1
    while(!(CS->STAT & 1 << 24));

    // configure ACLK to use REFOCLK
    CS->CTL1 = 0b010 << 8;
    // poll ACLK READY until 1
    while(!(CS->STAT & 1 << 24));
    // poll REFO READY until 1
    while(!(CS->STAT & 1 << 7));
    // Lock clock config
    CS->KEY = 0x0;

    // TA0CCTL1:
    // set default value of OUT to high
    // set outmode 7 reset/set
    TIMER_A0->CCTL[1] = (1 << 2) | (0b111 << 5);

    // set trigger time in CCR1
    TIMER_A0->CCR[1] = 100;

    // compute and set delay value
    TIMER_A0->CCR[0] = ACLK_CYCLES_PER_MS * DELAY; // also starts timer
}

void configure_ADC(void) {
    // Sampling time, sample and hold, turn on
    ADC14->CTL0 = (1 << 4) | (1 << 26);
    // Set source to A15 (P6.0)
    ADC14->MCTL[0] = 0b01111;
    // Default voltage reference for up 3.3V, down GND
    // Select source for SHI (rising edge triggers conversion) with SHSx bits
    ADC14->CTL0 |= (1 << 27);
    // Select repeat-single-channel sequence mode
    ADC14->CTL0 |= (0b10 << 17);
    // Enable interrupt for ADC14MEM0
    ADC14->IER0 = 1;
    // Enable ADC conversion
    ADC14->CTL0 |= (1 << 1);

    // enable interrupts for this peripheral
    NVIC_EnableIRQ(ADC14_IRQn);
}

void capture(void) {
    // enable and start conversion
    ADC14->CTL0 |= 0b11;
}


void configure_PWM(void) {
    // Use timer A1 to generate PWM
    // up mode, select ACLK source
    TIMER_A1->CTL = 1 << 4 | 1 << 8;
    // compare mode, output mode reset/set
    TIMER_A1->CCTL[1] = 0 << 8 | 0b111 << 5;
    // compute and set delay values
    TIMER_A1->CCR[1] = 0;
    TIMER_A1->CCR[0] = ACLK_CYCLES_PER_MS * PERIOD;
}

void update_PWM(uint32_t duty_cycle) {
    // Convert duty_cycle to # number of cycles between min and max duty_cycle
    // I.e. duty_cycle <- [0, 0xFF] => [1ms, 2ms] interval relative to period
    uint16_t base = MIN_DUTY_CYCLE_MS * ACLK_CYCLES_PER_MS;
    uint16_t scaled = (MAX_DUTY_CYCLE_MS - MIN_DUTY_CYCLE_MS) * ACLK_CYCLES_PER_MS * duty_cycle / 0xFF;
    uint16_t new_period = base + scaled;
    TIMER_A1->CCR[1] = new_period;
}

void ADC14_IRQHandler(void) {
    // Read and display results on pins
    // Note: shift by 6 = 14 - 8 for MSB
    const uint32_t result = ADC14->MEM[0] >> 6;
    P2->OUT ^= 1;
    P4->OUT = result;
    // Update PWM duty cycle with result
    update_PWM(result);
}

void main(void)
{
	WDT_A->CTL = WDT_A_CTL_PW | WDT_A_CTL_HOLD;		// stop watchdog timer

	configure_GPIO();
	configure_timer();
	configure_ADC();
	configure_PWM();

	while(1) {
	    // wait for interrupts
	    __wfi();
	}
}
