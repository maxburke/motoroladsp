; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;

; B.1.4	N Real Updates  
;   d(I) = c(I) + a(I) * b(I), I=1,2,...,N 
; 
;                                                      	Program	ICycles
	  org	p:$100
aaddr equ  120
baddr equ  100
caddr equ  300
daddr equ  300
N     equ  400
    move   #aaddr,r0                                       	;	1      	1 
    move   #baddr,r4                                       	;	1      	1 
    move   #caddr,r1                                       	;	1      	1 
    move   #daddr,r5                                       	;	1      	1 
    move                         x:(r0)+,d4.s	 y:(r4)+,d6.s ;	1      	1 
    fmpy.s   d4,d6,d1            x:(r1)+,d0.s              	;	1      	1 
    do     #N,_end                                         	;	2      	3 
                   fadd.s d1,d0  x:(r0)+,d4.s 	y:(r4)+,d6.s ;	1      	1 
    fmpy.s d4,d6,d1              x:(r1)+,d0.s 	d0.s,y:(r5)+ ;	1      	1 
_end                                                      ;	---   	 --- 
;                                                  	Totals: 	10    	2N+9 
;                                                         	(	10    	2N+9) 
