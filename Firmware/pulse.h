/* 
 * File:   
 * Author: 
 * Comments:
 * Revision history: 
 */

// This is a guard condition so that contents of this file are not included
// more than once.  
#ifndef PULSE_H
#define	PULSE_H

#define UP_PERIOD       (50)//ms

#define DOWN_PERIOD     (50)//ms

#define PILOT_PERIOD    (100)

#define PILOT_POS       8

typedef enum{OFF=0, ON} state_t;

typedef enum{FAILED=0,SUCCEED} result_t;
        
result_t FF_Write(state_t x);

result_t FF_Read(state_t* x);

#endif	/* PULSE_H */

