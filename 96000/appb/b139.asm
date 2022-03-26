; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.39	Nth Order Polynomial Evaluation for Two Points 

;An Nth order polynomial c1XN + c2XN-1 + ...cNX + cN+1 can be factored 
;and represented as ((c1X + c2)X + c3)X + ...) + cN+1. This routine 
;evaluates the polynomial at both X = s and X = t. 
; 
;Memory Map :   X             Y 
; 
;       r1 ->   s             t 
;               . 
;               . 
;       r0 ->   c1 
;               c2 
;               c3 
;               . 
;               . 
;               cN+1 
;  Setup N equ  order of polynomial 
move #coef,r0 
move #2_pts,r1 
move x:(r1)+,d5.s y:,d4.s                     ; s, t 
move x:(r0)+,d1.s                             ; c1 
move d1.s,d0.s 
; Inner loop for evaluating 2 consecutive points 
do #N,_loop 
fmpy.x d1,d5,d1  x:(r0)+,d2.s                 ; c(n)*s, c(n+1) 
fmpy   d0,d4,d0  fadd.x d2,d1                 ; c(n)*t, c(n)*s+c(n+1) 
fadd.x d2,d0                                  ; c(n)*t+c(n+1) _loop 
