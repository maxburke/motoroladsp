; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.34	Cascaded Five Coefficient Transpose IIR Filter  
;The cascaded transpose IIR filter has a filter section:  
;The filter equations are: 
;    y  = x*bi0 + w1 
;    w1 = x*bi1 + y*ai1 + w2 
;    w2 = x*bi2 + y*a2 
;                	Program	ICycles 
;                                                        	Words 
nsec equ   3 
 
    org    x:0 
coef 
    dc    .93622314E-04     ;/* section  1 B0 */ 
    dc    .18724463E-03     ;/* section  1 B1 */ 
    dc    .19625904E+01     ;/* section  1 A1 */ 
    dc    .93622314E-04     ;/* section  1 B2 */ 
    dc    -.96296486E+00    ;/* section  1 A2 */ 
 
    dc    .94089162E-04     ;/* section  2 B0 */ 
    dc    .18817832E-03     ;/* section  2 B1 */ 
    dc    .19723768E+01     ;/* section  2 A1 */ 
    dc    .94089162E-04     ;/* section  2 B2 */ 
    dc    -.97275320E+00    ;/* section  2 A2 */ 
 
    dc    .94908880E-04     ;/* section  3 B0 */ 
    dc    .18981776E-03     ;/* section  3 B1 */ 
    dc    .19895605E+01     ;/* section  3 A1 */ 
    dc    .94908880E-04     ;/* section  3 B2 */ 
    dc    -.98994009E+00    ;/* section  3 A2 */ 
 
    org    y:0 
w1    dsm    nsec 
w2    dsm    nsec 
 
    org    p:$100 
    move   #coef,r0 
    move   #5*nsec-1,m0 
    move   #w1,r4 
    move   #nsec-1,m4 
    move   #w2,r5 
    move   m4,m5 
; 
;    input in d7 
; 
    move   x:(r0)+,d4.s            ;get b0                    1      1 
    do     #nsec,tran                                        ; 2      3 
    fmpy   d7,d4,d0  fadd.s d1,d2 x:(r0)+,d4.s  y:(r4),d5.s  ; 1      1 
    fmpy   d7,d4,d1  fadd.s d5,d0 x:(r0)+,d4.s  y:(r5),d6.s ;  1      1 
    fmpy   d0,d4,d2  fadd.s d6,d1 x:(r0)+,d4.s  d2.s,y:(r5)+ ; 1      1 
    fmpy   d7,d4,d2  fadd.s d2,d1 x:(r0)+,d4.s  d0.s,d7.s    ; 1      1 
    fmpy.s d0,d4,d1               x:(r0)+,d4.s  d1.s,y:(r4)+ ; 1      1 
tran 
                     fadd.s d1,d2                            ; 1      1 
    move   d2.s,y:(r5)+                                      ; 1      1 
    move   d0.s,y:$ffff 
                                                            ; ---    --- 
                                                 ;   Totals:  10    5N+6 
