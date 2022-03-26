; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.30	Newton-Raphson Approximation for SQRT(x)  
;The approximation of sqrt(x) may be performed by using the  Newton-Raphson iteration to first find 
;1.0/sqrt(x).  The sqrt(x)  then can be approximated by x*(1.0/sqrt(x)).  
;
;
;              Newton-Raphson Approximation              	Program	ICycles 
;                     of SQRT(x)                           	Words 
 
    seedr   d5,d4                    ;y approx 1/sqrt(x)    1       1 
    fmpy.s  d4,d4,d2       #.5,d7.s  ;y*y, get .5           2       2 
    fmpy.s  d5,d2,d2       #3.0,d3.s ;x*y*y, get 3.0        2       2 
    fmpy    d4,d7,d2  fsub.s d2,d3  d3.s,d6.s ;y/2, 3-x*y*y 1       1 
    fmpy.s  d2,d3,d4       d6.s,d3.s ;y/2*(3-x*y*y)         1       1 
    fmpy.s  d4,d4,d2                 ;y*y                   1       1 
    fmpy.s  d5,d2,d2                 ;x*y*y                 1       1 
    fmpy    d4,d7,d2  fsub.s d2,d3  d3.s,d6.s ;y/2, 3-x*y*y 1       1 
    fmpy.s  d2,d3,d4                 ;y/2*(3-x*y*y)         1       1 
    fmpy.s  d5,d4,d4                 ;x*(1/sqrt(x))         1       1 
 ;                                                          ---     --- 
 ;                                                  Totals:  12      12 
