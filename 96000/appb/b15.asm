; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.5	FIR Filter with Data Shift  
;          N-1 
;   c(n) = SUM {a(I) * b(n-I)} 
;          I=0 
;                                                      	Program	ICycles 
;                                                      	Words 
	org p:$100
    move     #data,r0                                       ;		1      	1 
    move     #coef,r4                                        ;		1      	1 
    move     #n-1,m0                                         ;		1      	1 
    fclr     d1                 m0,m4                        ;		1      	1 
    movep                       x:input,x:(r0)               ;		1      	2 
    fclr     d0                 x:(r0)-,d4.s y:(r4)+,d6.s    ;		1      	1 
    rep #N                                                   ;		1      	2 
    fmpy   d4,d6,d1 fadd.s d1,d0  x:(r0)-,d4.s 	y:(r4)+,d6.s ;	    1      	1 
                    	fadd.s d1,d0  (r0)+  ;	                    1      	1 
    movep                         d0.s,x:output ;             		1 		2 
;                                               ;             	---    	--- 
;                                                   	Totals:  	10  1N+12 
;                                                           	(	10 	1N+12) 
