#include <xc.h>
 
    // PUSH and POP macros make room on the stack and move register onto it
.macro PUSH reg
    addiu sp, sp, -4
    sw \reg, 0(sp)
.endm
    
.macro POP reg
    lw \reg, 0(sp)
    addiu sp, sp, 4
.endm    
    
.global main

.data

EXPR: .word 3,4, 0x80000000 + '*',5, 0x80000000 + '-',6, 0x80000000 + '+', 0x80000000 + '='
    //((3 * 4) - 5) + 6 =
    
RESULT: .word 0
    
.text
.set noreorder
.ent main
main:

    //Stack Frame Preamble
    //made space for ra, fp, and a0-a3
    addiu sp, sp, -24
    sw ra, 20(sp)
    sw fp, 16(sp)
    addu fp, sp, zero
    //end of preamble; 
    /* current state of the stack frame
     /----------------------/
     |          ra          |
     /----------------------/
     |          fp          |
     /----------------------/ 
     |  room for a3         |
     /----------------------/ 
     |  room for a2         |
     /----------------------/ 
     |  room for a1         |
     /----------------------/ 
     |  room for a0         |     
     /----------------------/      
    */
    
  la s0, EXPR	//pull in the pointer to EXPR[i]
loop_top:
  lw s1, 0(s0)  //read the current value of EXPR[i]
  //is the current value of EXPR[i] a digit? 
  //really, we're going to have to try to determine if it is some other thing
  //and if it isn't one of those things, then it must be a digit.
  la t1, MULT_OP
  lw t1, 0(t1)
  beq s1, t1, do_a_mult
  nop
  
  //not a multiply operation? fall through.
  
  la t1, ADD_OP
  lw t1, 0(t1)
  beq s1, t1, do_an_add
  nop
  
  //not an addition operation? fall through
  
  la t1, SUB_OP
  lw t1, 0(t1)
  beq s1, t1, do_a_sub
  nop
  
  //not a subtraction operation? fall through
  
  la t1, EQU_OP
  lw t1, 0(t1)
  beq s1, t1, its_equal
  nop
  
  //if we got here, then EXPR[i] is a digit. Push it onto the stack
  
  PUSH s1
  j next_thing
  nop
  
  do_a_mult:
    POP a0
    POP a1
    jal m_multiplier
    nop
    PUSH v0
    j next_thing
    nop

  do_an_add:
    POP a0
    POP a1
    jal m_add
    nop
    PUSH v0
    j next_thing
    nop 
        
  do_a_sub:
    POP a0
    POP a1
    jal m_subtract
    nop
    PUSH v0
    j next_thing
    nop
    
  next_thing:
    //pointer arithmetic -> i++ for EXPR[i]
    addiu s0, s0, 4 //move to next byte in the EXPR array by adding 4 | s0 = (3) | s4 = (4) | s8 = (*) |...
    j loop_top
    nop
    
  its_equal:
    POP t1
    la t0, RESULT
    sw t1, 0(t0)
    
    endless:
	j endless
	nop

    addu sp, fp, zero
    lw ra, 20(sp)
    lw fp, 16(sp)
    addiu sp, sp, 24    
    
.end main
    
MULT_OP:  .word 0x80000000 + '*'
ADD_OP:   .word 0x80000000 + '+'
SUB_OP:   .word 0x80000000 + '-'
EQU_OP:   .word 0x80000000 + '='    
