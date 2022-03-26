; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
 ;B.1.13	2nd Order Real Biquad IIR Filter  
 ;  w(n) = x(n) - a1 * w(n-1) - a2 * w(n-2) 
 ;  y(n) = w(n) + b1 * w(n-1) + b2 * w(n-2) 
 ;
 ;  Input sample in d0. 
 ;  X Memory Order - w(n-2), w(n-1) 
 ;  Y Memory Order - a2, a1, b2, b1 
 ;                                             	             Program	ICycles
 ;                                                      	           Words 
   move                           x:(r0)+,d4.s  y:(r4)+,d6.s  ;	1      	1 
   fmpy.s d6,d4,d2                x:(r0)-,d5.s  y:(r4)+,d6.s  ;	1      	1 
   fmpy   d6,d5,d2 fsub.s d2,d0.s d5.s,x:(r0)+  y:(r4)+,d6.s  ;	1      	1 
   fmpy   d6,d4,d2 fsub.s d2,d0                 y:(r4),d6.s   ;	1      	1 
   fmpy   d6,d5,d2 fadd.s d2,d0   d0.s,x:(r0)                 ;	1      	1 
                   fadd.s d2,d0                               ;	1      	1 
   move                           d0.s,x:output               ;	1      	1 
 ;                                                            ;	---   	 --- 
 ;                                                    	Totals:  	7      	7 
 ;                                                            	(	7      	7) 
