#include <xc.h>

.global m_multiplier
.global m_add
.global m_subtract

.data   
.text
.set noreorder

.ent m_multiplier
m_multiplier:
  //creating m_multiplier stack frame
  addiu sp, sp, -8  //making room for two things!
  sw ra, 4(sp)
  sw fp, 0(sp)
  //save parameters!
  //saved the a register parameters before moving the
  //frame pointer. There's no telling how much motion the stack
  //pointer saw before entering execution into this function
  sw a0, 0(fp)
  sw a1, 4(fp)
  //reached OUT of my frame, and saved off some data
  addu fp, sp, zero //sets the bottom of our frame
  //end of stack frame construction

  addu t0, a0, zero	    //x was passed in as a0
  addu t1, a1, zero     //y was passed in as a1
    
  addi t3, zero, 1	//placing a 1 into t3 as a conditional control
  addu t2, t0, zero	//taking a copy of x; let's call it temp
mult_loop:

  addu t2, t2, t0	// temp = temp + x
  addiu t1, t1, -1	// y = y - 1
  beq t1, t3, adding_done
  nop
  j mult_loop
  nop
adding_done:
  addu v0, t2, zero

  addu sp, fp, zero	//snap the sp back to the bottom of the frame
  lw fp, 0(sp)          //restore the fp of the calling function
  lw ra, 4(sp)          //restore the ra of the calling function
  addiu sp, sp, 8       //move the stack pointer back to *wherever* it was
  
  jr ra
  nop
  
.end m_multiplier
  
.ent m_add
m_add:
  addiu sp, sp, -8  //making room for two things (ra, fp)
  sw ra, 4(sp)
  sw fp, 0(sp)
  sw a0, 0(fp)      //note: the FP value here is still related to the calling function
  sw a1, 4(fp)
  addu fp, sp, zero //NOW we change the FP value. 
  
  addu v0, a0, a1

  addu sp, fp, zero	//snap the sp back to the bottom of the frame
  lw fp, 0(sp)          //restore the fp of the calling function
  lw ra, 4(sp)          //restore the ra of the calling function
  addiu sp, sp, 8       //move the stack pointer back to *wherever* it was
  
  jr ra
  nop
  
.end m_add
  
.ent m_subtract
  m_subtract:
    addiu sp, sp, -8  
    sw ra, 4(sp)
    sw fp, 0(sp)
    sw a0, 0(fp)      
    sw a1, 4(fp)
    addu fp, sp, zero 
  
    subu v0, a1, a0

    addu sp, fp, zero	     //snap the sp back to the bottom of the frame
    lw fp, 0(sp)           //restore the fp of the calling function
    lw ra, 4(sp)           //restore the ra of the calling function
    addiu sp, sp, 8        //move the stack pointer back to *wherever* it was
  
    jr ra
    nop

.end m_subtract
