; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
 ;B.1.12	Nth Order Power Series (Real)  
 ;;        c = SUM (I=0,...,N) { a(I) * bI }       c = aNbN + aN-1bN-1 + ... + a1b1 + a0        
 ;                                                      	Program	ICycles
 ;                                                      	Words 
    move   #baddr,r4                                       	 ;	1      	1 
    move   #aaddr,r0                                        ;	1      	1 
    move                                       y:(r4),d7.s  ;	1      	1 
    fclr   d2                     x:(r0)+,d0.s y:(r4),d6.s  ;	1      	1 
    do     #N,end                                           ;	2      	3 
    fmpy   d6,d7,d1 fadd.s d2,d0  x:(r0)+,d4.s         	     ;	1      	1 
    fmpy.s d6,d4,d2               d1.s,d6.s               	  ;	1      	1 
end 
    fadd.s d2,d0                                         	  ;	1      	1 
 ;                                                          ;	---    	--- 
 ;                                                  	Totals:  9     	2N+8 
 ;                                                          	(9     	2N+8) 
