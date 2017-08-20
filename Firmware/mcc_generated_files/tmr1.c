/**
  TMR1 Generated Driver File

  @Company
    Microchip Technology Inc.

  @File Name
    tmr1.c

  @Summary
    This is the generated driver implementation file for the TMR1 driver using MPLAB® Code Configurator

  @Description
    This source file provides APIs for TMR1.
    Generation Information :
        Product Revision  :  MPLAB® Code Configurator - v2.25.2
        Device            :  PIC12F1571
        Driver Version    :  2.00
    The generated drivers are tested against the following:
        Compiler          :  XC8 v1.34
        MPLAB             :  MPLAB X v2.35 or v3.00
 */

/*
Copyright (c) 2013 - 2015 released Microchip Technology Inc.  All rights reserved.

Microchip licenses to you the right to use, modify, copy and distribute
Software only when embedded on a Microchip microcontroller or digital signal
controller that is integrated into your product or third party product
(pursuant to the sublicense terms in the accompanying license agreement).

You should refer to the license agreement accompanying this Software for
additional information regarding your rights and obligations.

SOFTWARE AND DOCUMENTATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF
MERCHANTABILITY, TITLE, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE.
IN NO EVENT SHALL MICROCHIP OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER
CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR
OTHER LEGAL EQUITABLE THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES
INCLUDING BUT NOT LIMITED TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR
CONSEQUENTIAL DAMAGES, LOST PROFITS OR LOST DATA, COST OF PROCUREMENT OF
SUBSTITUTE GOODS, TECHNOLOGY, SERVICES, OR ANY CLAIMS BY THIRD PARTIES
(INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
 */

/**
  Section: Included Files
 */

#include <xc.h>
#include "tmr1.h"
#include "pulse.h"

#define LEVEL_DEFAULT   (0x1)//0V

uint8_t tick = 0;
uint8_t next_tick = 1;
uint8_t bit_count = 0;
uint8_t bit_wait = 0;

/**
  Section: Global Variables Definitions
 */
volatile uint16_t timer1ReloadVal;

/**
  Section: TMR1 APIs
 */

void TMR1_Initialize(void) {
    //Set the Timer to the options selected in the GUI

    //nT1SYNC synchronize; T1CKPS 1:1; TMR1CS FOSC; TMR1ON disabled; 
    T1CON = 0x40;

    //T1GVAL disabled; T1GSPM disabled; T1GSS T1G; T1GTM disabled; T1GPOL low; TMR1GE disabled; T1GGO done; 
    T1GCON = 0x00;

    //TMR1H 193; 
    TMR1H = 0xC1;

    //TMR1L 128; 
    TMR1L = 0x80;

    // Load the TMR value to reload variable
    timer1ReloadVal = (TMR1H << 8) | TMR1L;

    // Clearing IF flag before enabling the interrupt.
    PIR1bits.TMR1IF = 0;

    // Enabling TMR1 interrupt.
    PIE1bits.TMR1IE = 1;

    // Start TMR1
    TMR1_StartTimer();
}

void TMR1_StartTimer(void) {
    // Start the Timer by writing to TMRxON bit
    T1CONbits.TMR1ON = 1;
}

void TMR1_StopTimer(void) {
    // Stop the Timer by writing to TMRxON bit
    T1CONbits.TMR1ON = 0;
}

uint16_t TMR1_ReadTimer(void) {
    uint16_t readVal;

    readVal = (TMR1H << 8) | TMR1L;

    return readVal;
}

void TMR1_WriteTimer(uint16_t timerVal) {
    if (T1CONbits.nT1SYNC == 1) {
        // Stop the Timer by writing to TMRxON bit
        T1CONbits.TMR1ON = 0;

        // Write to the Timer1 register
        TMR1H = (timerVal >> 8);
        TMR1L = timerVal;

        // Start the Timer after writing to the register
        T1CONbits.TMR1ON = 1;
    } else {
        // Write to the Timer1 register
        TMR1H = (timerVal >> 8);
        TMR1L = timerVal;
    }
}

void TMR1_Reload(void) {
    //Write to the Timer1 register
    TMR1H = (timer1ReloadVal >> 8);
    TMR1L = timer1ReloadVal;
}

void TMR1_StartSinglePulseAcquisition(void) {
    T1GCONbits.T1GGO = 1;
}

uint8_t TMR1_CheckGateValueStatus(void) {
    return (T1GCONbits.T1GVAL);
}

void TMR1_ISR(void) {

    state_t x;
   
    tick++;
    
    if(tick == next_tick)
    {
        if (bit_wait)
        {
            PORTAbits.RA2 = 0;
            next_tick = UP_PERIOD;
            bit_wait = 0;
        }
        else
        {
            if (FF_Read(&x) == SUCCEED)
            {
                PORTAbits.RA2 = (x & 0x1);

                if (PILOT_POS)
                {
                    bit_count++;
                }
                
                if (PILOT_POS && bit_count == PILOT_POS)
                {
                    next_tick = PILOT_PERIOD;
                    bit_count = 0;
                    bit_wait = 1;
                }
                else
                {
                    if (x & 0x1)
                    {
                        next_tick = UP_PERIOD * 2;
                    }
                    else
                    {
                        next_tick = DOWN_PERIOD;
                        bit_wait = 1;
                    }
                }
            }
            else
            {
                PORTAbits.RA2 = LEVEL_DEFAULT;
                next_tick = 1;
            }
        }
        tick = 0;       
    }
    
    // Clear the TMR1 interrupt flag
    PIR1bits.TMR1IF = 0;

    TMR1H = (timer1ReloadVal >> 8);
    TMR1L = timer1ReloadVal;
}

/**
  End of File
 */
