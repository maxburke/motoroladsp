; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
;or 
;       d5 = ar    d4 = br    d6 = bi    d7 = ai 
; 
;       X Memory Organization            Y Memory Organization 
;              	  .	  .      
;             	dr2	di2     
;    R5?    dr1     DADDR               R2 ?    di1     DADDR 
;              	  .	  .      
;              	  .	  .      
;             	cr2                                  	ci2     
;    R1 ?    cr1     CADDR               R6 ?    ci1     CADDR 
;              	  .	  .      
;              	  .	  .      
;             	br2                                  	bi2     
;    R4 ?    br1     BADDR               R4 ?    bi1     BADDR 
;              	  .	  .      
;              	  .	  .      
;             	ar2                                  	ai2     
;    R0 ?    ar1     AADDR               R0 ?    ai1     AADDR 
;                                                                                          	Program	ICycles
;                                                       	Words 
    move  #aaddr,r0                                       ;   1      1 
    move  #baddr,r4                                       ;   1      1 
    move  #caddr,r1                                       ;   1      1 
    move  r1,r6                                           ;   1      1 
    move  #daddr,r5                                       ;   1      1 
    move  r5,r2                                           ;   1      1 
    move                          x:(r4),d6.s             ;   1      1 
    move                          x:(r0),d4.s             ;   1      1 
    fmpy.s d4,d6,d2                            y:(r0)+,d5.s ; 1      1 
    fmpy.s d5,d6,d3               x:(r1)+,d0.s y:(r4)+,d7.s ; 	1      1 
    fmpy   d5,d7,d2 fadd.s d2,d0  x:(r4),d6.s               ; 	1      1 
    do     #N,_end                                          ; 	2      3 
    fmpy   d4,d7,d2 fsub.s d2,d0  x:(r0),d4.s  y:(r6)+,d1.s ; 	1      1 
    fmpy   d4,d6,d2 fadd.s d2,d1  d0.s,x:(r5)+ y:(r0)+,d5.s ; 	1      1 
    fmpy   d5,d6,d3 fadd.s d3,d1  x:(r1)+,d0.s y:(r4)+,d7.s ; 	1      1 
    fmpy   d5,d7,d3 fadd.s d2,d0  x:(r4),d6.s  d1.s,y:(r2)+ ; 	1      1 
_end                                                        ;---    --- 
;                                                    Totals:  17   4N+14 
;                                                            (13   5N+9) 
