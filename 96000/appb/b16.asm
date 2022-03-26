; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
 ;B.1.6	Real * Complex Correlation Or Convolution (FIR Filter)  
;   cr(n) + jci(n) = SUM(I=0,...,N-1) {( ar(I) + jai(I)) * b(n-I)} 
; 
;   cr(n) = SUM(I=0,...,N-1) { ar(I) * b(n-I) } 
;   ci(n) = SUM(I=0,...,N-1) { ai(I) * b(n-I) } 
;
;                                                       	Program	ICycles
;                                                       	Words 
       move          #aaddr,r0                                	;	1      	1 
       fclr   d0     #baddr+n,r4                              	;	1      	1 
       fclr   d1                    x:(r0),d4.s               	;	1      	1 
       fclr   d2                    x:(r4)-,d5.s 	y:(r0)+,d6.s ;	1      	1 
       do     #n,end                                          	;	2      	3 
       fmpy d4,d5,d2  fadd.s d2,d1  x:(r0),d4.s               	;	1      	1 
       fmpy d6,d5,d2  fadd.s d2,d0  x:(r4)-,d5.s 	y:(r0)+,d6.s ;	1      	1 
end 
                      fadd.s d2,d1                            ;	1      	1 
;                                                            ; 	---   	 --- 
;                                                      	Totals 	9  	    2N+8 
;                                                            	(10	    2N+9) 
