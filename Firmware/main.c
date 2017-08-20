#include "mcc_generated_files/mcc.h"
#include "pulse.h"

void sendChar(const char c)
{
    /* This will 'output' the binary representation of 'inputChar' 
       as 8 characters of '1's and '0's, MSB first. */
    for (uint8_t bitMask = 64; bitMask != 0; bitMask = bitMask >> 1) 
    {
        if (c & bitMask)
        {
            FF_Write(ON);
        }
        else
        {
            FF_Write(OFF);
        }
    }
}

void sendStr(const char* str, int len)
{
    for (int x = 0; x < len; ++x)
    {
        sendChar(str[x]);
    }
}

void main(void)
{
    const char text_str[] = "CAPN";
    uint8_t text_str_len = 4;
    
    // initialize the device
    SYSTEM_Initialize();
   
    // Enable the Global Interrupts
    INTERRUPT_GlobalInterruptEnable();

    // Enable the Peripheral Interrupts
    INTERRUPT_PeripheralInterruptEnable();
    
    while (1)
    {
        sendStr(text_str, text_str_len);
    }
}
