; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.14	N Cascaded Real Biquad IIR Filters  
;   w(n) = x(n) - a1 * w(n-1) - a2 * w(n-2) 
;   y(n) = w(n) + b1 * w(n-1) + b2 * w(n-2) 
; 
;       X Memory Organization            Y Memory Organization 
; 
;                                                  	b1N     Coef. + 4N-1 
;                                                  	b2N     
;                                                  	a1N     
;                                                  	a2N     
;           wN(n-1)   Data + 2N-1                	  .      
;           wN(n-2)                               	  .      
;             .                                    	b11     
;             .                                    	b21     
;           w1(n-1)                                	a11   
;     R1,R0 ?  w1(n-2)   Data                	R4 ?	a21     Coef. 
;                                                          
; 
;
;                      DSP56000 IMPLEMENTATION 
;                                                       	Program	ICycles 
;                                                       	Words 
;       move  #$ffffffff,m0                               	2      	2 
;       move  m0,m4                                       	1      	1 
;       move  #data,r0                                    	2      	2 
;       move  #coef,r4                                    	2      	2 
;       movep              x:input,a                      	1      	2 
;       move               x:(r0)+,x0    y:(r4)+,y0       	1      	1 
;       do     #n,end                                     	2      	3 
;       mac    -x0,y0,a    x:(r0)-,x1    y:(r4)+,y0       	1      	1 
;       macr   -x1,y0,a    x1,x:(r0)+    y:(r4)+,y0       	1      	1 
;       mac    x0,y0,a     a,x:(r0)+     y:(r4)+,y0       	1      	1 
;       mac    x1,y0,a     x:(r0)+,x0    y:(r4)+,y0       	1      	1 
;end 
;       rnd    a                                          	1      	1 
;       movep              a,x:output                     	1      	2 
;                                                 ------------------- 
;                                                  	Totals 17   	4N+16 
;                      DSP96002 IMPLEMENTATION 
                           	                              Program	ICycles
																	Words 
       move   #$ffffffff,m0                                  ; 2     2 
       move   m0,m4                                          ; 1     1 
       move   m0,m1                                          ; 1     1 
       move   #data,r0                                       ; 2     2 
       move   r0,r1                                          ; 1     1 
       move   #coef,r4                                       ; 2     2 
       movep                       x:input,d0.s              ; 1     2 
       fclr   d1                   x:(r0)+,d4.s y:(r4)+,d6.s ; 1     1 
       do     #n,end                                         ; 2     3 
       fmpy d4,d6,d1 fadd.s d1,d0  x:(r0)+,d5.s y:(r4)+,d6.s ; 1     1 
       fmpy d5,d6,d1 fsub.s d1,d0  d5.s,x:(r1)+ y:(r4)+,d6.s ; 1     1 
       fmpy d4,d6,d1 fsub.s d1,d0  x:(r0)+,d4.s y:(r4)+,d6.s ; 1     1 
       fmpy d5,d6,d1 fadd.s d1,d0  d0.s,x:(r1)+ y:(r4)+,d6.s ; 1     1 
end; 
                     fadd.s d1,d0                            ; 1     1 
       movep                       d0.s,x:output             ; 1     2 
;                                                            ; ---   --- 
;                                                     Totals: 	19   4N+18 
;                                                            (17   4N+16) 

