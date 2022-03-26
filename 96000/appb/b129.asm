; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
 
; B.1.29	Newton-Raphson Approximation for 1.0/SQRT(x)  
;The Newton-Raphson iteration can be used to approximate the function:  
;        1.0 
;           y= ------- 
;              sqrt(x) 
;
;by minimizing the function:  
;                             1.0 
;           F(y) = x  -   ------- 
;                           y*y 
;
;Given an initial approximate value y=1/sqrt(x), the Newton-Raphson  iteration for refining the esti-
;mate is:  
;    y(n+1)=y(n)*(3.0-x*y*y)/2.0 
;
;              Newton-Raphson Approximation              	Program	ICycles 
;                     of 1.0/SQRT(x)                     	Words 
; 
    seedr   d5,d4                    ;y approx 1/sqrt(x)    1       1 
    fmpy.s  d4,d4,d2       #.5,d7.s  ;y*y, get .5           2       2 
    fmpy.s  d5,d2,d2       #3.0,d3.s ;x*y*y, get 3.0        2       2 
    fmpy    d4,d7,d2  fsub.s d2,d3  d3.s,d6.s ;y/2, 3-x*y*y 1       1 
    fmpy.s  d2,d3,d4       d6.s,d3.s ;y/2*(3-x*y*y)         1       1 
    fmpy.s  d4,d4,d2                 ;y*y                   1       1 
    fmpy.s  d5,d2,d2                 ;x*y*y                 1       1 
    fmpy    d4,d7,d2  fsub.s d2,d3  d3.s,d6.s ;y/2, 3-x*y*y 1       1 
    fmpy.s  d2,d3,d4                 ;y/2*(3-x*y*y)         1       1 
 ;                                                          ---     --- 
 ;                                                  Totals:	11	11 

