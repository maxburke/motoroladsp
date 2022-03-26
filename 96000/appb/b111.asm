; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.11	Complex Correlation Or Convolution (FIR Filter)  
;   cr(n) + jci(n) = SUM(I=0,...,N-1) { ( ar(I) + jai(I) ) * 
;                                       ( br(n-I) + jbi(n-I) ) } 
; 
;   cr(n) = SUM(I=0,...,N-1) { ar(I) * br(n-I) - ai(I) * bi(n-I) } 
;   ci(n) = SUM(I=0,...,N-1) { ar(I) * bi(n-I) + ai(I) * br(n-I) } 
;                                                       	Program 	ICycles
;                                                       	Words 
       move   #aaddr,r0                                      ;	1      1 
       fclr    d2                  #baddr,r4                 ;	1      1 
       fclr    d0                                            ;	1      1 
       fclr    d1                  x:(r0),d5.s  y:(r4),d6.s  ;;	1      1 
       do      #N,end                                       ;	2      3 
       fmpy d6,d5,d2 fsub.s d2,d0  x:(r4)+,d4.s y:(r0)+,d7.s ;	1      1 
       fmpy d4,d7,d2 fadd.s d2,d1                           ;	1      1 
       fmpy d4,d5,d2 fadd.s d2,d1                            ;	1      1 
       fmpy d6,d7,d2 fadd.s d2,d0  x:(r0),d5.s  y:(r4),d6.s  ;	1      1 
end 
                     fsub.s d2,d0                            ;	1      	1 
;                                                          ;  ---    --- 
;                                                    Totals:  11    4N+8
;															 (11	4N+8)
