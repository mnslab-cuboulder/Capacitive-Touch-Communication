/*
 * File:   pulse.c
 * Author: Dang
 *
 * Created on November 16, 2015, 2:54 PM
 */


#include "pulse.h"
#include <stdint.h>

#define FIFO_LENGTH (160)

typedef struct fifo{
    uint8_t iByte;
    uint8_t iBit;
    uint8_t oByte;
    uint8_t oBit;
    uint8_t buff[FIFO_LENGTH>>3];
} fifo_t;

fifo_t FIFO;

result_t FF_Write(state_t x){
    
    uint16_t in, out;
    
    in = (FIFO.iByte<<3) + FIFO.iBit;
    out = (FIFO.oByte<<3) + FIFO.oBit;
        
    if((in+1)==out){
        
        return FAILED;
    }
    else{
        
        x = x & 0x1;
        
        if(x){
            FIFO.buff[FIFO.iByte] |= (uint8_t)(0x1<<FIFO.iBit);
        }
        else{
            FIFO.buff[FIFO.iByte] &= ~(uint8_t)(0x1<<FIFO.iBit);
        }
        
        FIFO.iBit++;        
        if(FIFO.iBit==8){
            
            FIFO.iBit = 0;
            FIFO.iByte++;
            
            if(FIFO.iByte==(FIFO_LENGTH>>3)){
                FIFO.iByte = 0;
            }
        }
        
        return SUCCEED;
    }
}

result_t FF_Read(state_t* x){    
    
    uint16_t in, out;
    
    in = (FIFO.iByte<<3) + FIFO.iBit;
    out = (FIFO.oByte<<3) + FIFO.oBit;
    
    if(in == out){
        
        return FAILED;
    }
    else{
        
        *x = (state_t)((FIFO.buff[FIFO.oByte]>>(FIFO.oBit)) & 0x1);        
        
        FIFO.oBit++;        
        if(FIFO.oBit==8){
            
            FIFO.oBit = 0;
            FIFO.oByte++;
            
            if(FIFO.oByte==(FIFO_LENGTH>>3)){
                FIFO.oByte = 0;
            }
        }
                
        return SUCCEED;
    }
}
