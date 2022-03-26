; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.10	N Complex Updates  
;   dr(I)+jdi(I) = {cr(I)+jci(I)}+{ar(I)+jai(I)}*{br(I)+jbi(I)}, I=1,...,N 
; 
;   dr(I) = cr(I) + ar(I) * br(I) - ai(I) * bi(I) 
;   di(I) = ci(I) + ar(I) * bi(I) + ai(I) * br(I) 
; 
;       D5 = ar    D4 = ai    D6 = br    D7 = bi 
; 
;       X Memory Organization            Y Memory Organization 
;             	 .                                  	  .      
;             	ci2                                  	di2     
;             	cr2                                  	dr2     
;             	ci1                                  	di1     
;    	R1 ? 	cr1     CADDR	R5 ? 	dr1     	DADDR 
;             	 .                                   	 .      
;             	 .                                   	 .      
;             	ai2                                  	bi2     
;             	ar2                                  	br2     
;    	R0 ?	ai1                                  	bi1     
;             	ar1     	AADDR	R4 ?	br1     BADDR 
;                                                                     	Program	ICycles
;                                                       	Words 
     move   #aaddr+1,r0                                       ;	1      	1 
     move   #3,n0                                             ;	1      	1 
     move   #baddr,r4                                         ;	1      	1 
     move   #caddr,r1                                         ;	1      	1 
     move   #daddr-1,r5                                       ;	1      	1 
     move                        x:(r0)-,d4.s   y:(r4)+,d6.s  ;	1      	1 
     fclr   d2                   x:(r0)+n0,d5.s y:(r5),d0.s   ;	1      	1 
     do #n,end                      	                      ; 2      	3 
     fmpy d5,d6,d2 fadd.s d2,d0  x:(r1)+,d1.s   y:(r4)+,d7.s  ;	1      	1 
     fmpy d4,d7,d2 fadd.s d2,d1  x:(r1)+,d0.s   d0.s,y:(r5)+  ;	1      	1 
     fmpy d4,d6,d2 fsub.s d2,d1  x:(r0)-,d4.s   y:(r4)+,d6.s  ;	1      	1 
     fmpy d5,d7,d2 fadd.s d2,d0  x:(r0)+n0,d5.s d1.s,y:(r5)+  ;	1      	1 
end
                   fadd.s d2,d0                               ;	1     	1 
     move                                       d0.s,y:(r5)+  ;	1      	1 
;                                    	                	-------------------
; 
;                                                    	Totals: 15	    4N+12
;                                                            	(13    	4N+10)

