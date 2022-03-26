	page 132,60,1,1
	opt mex
;*******************************************
;Motorola Austin DSP Operation  28 Feb. 1992
;*******************************************
;DSP96002
;Benchmarks for EDN  : 	Test for CFFT1-96
;File name: CFFT1T.asm  1024 complex number FFT
;**************************************************************************
;	Maximum sample rate:  1.0479 ms at 40.0 MHz
;	Memory Size: Prog:  141 words ; Data:  5120 words
;	Number of clock cycles:	 41916 (20958 instruction cycles)
;	Clock Frequency:	 40.0MHz
;	Instruction cycle time:	 50.ns
;**************************************************************************
;
; CFFT1-96  Complex, Radix 2 Cooley-Tukey Decimation in Time FFT
;
;
;      normally ordered input data
;      normally ordered output data
;



;****************************************************************************
; Equates Section
;****************************************************************************

RESET   equ     $00000000               ; reset isr
MAIN    equ     $00000100               ; main routine

points      equ    1024 
passes      equ    10 
data        equ    $e00
odata       equ    $2000
coef        equ    $600      				 ; cos and sin table 
coefsize    equ    1024 

BCRA    equ     $FFFFFFFE               ; port a bus control reg
BCRB    equ     $FFFFFFFD               ; port b bus control reg
PSR     equ     $FFFFFFFC               ; port select reg

		  include 'sincos.asm'				 ;using external cos and sin table, if use internal ROM, delete this line
		  include 'cfft1-96.asm'


;*****************************************************************************
;  1) 
;  2) all P,X,Y,I/O external acesses from port B with no wait states
;  3)      except Y:$20000000-$3FFFFFFF which is upstream DSP's aHI
;*****************************************************************************
	  sincos	 points,coef				 ;  if use internal data ROM, delete this line

     org     p:MAIN
     movep   #$0,x:BCRA              ; no wait states for portb P,X,Y,I/O
     movep   #$0,x:BCRB              ; ...don't care about page fault
     movep   #$00FF00FF,x:PSR        ; external X:memory on Port-B
                                     ;          Y:memory on Port-A
     ;bset    #$3,omr                 ; enable the internal data ROMs
     bclr    #$3,omr                 ; disable the internal data ROMs

     
     CFFT1  points,passes,data,coef,coefsize,odata
     nop
     nop
     jmp   *

     END
