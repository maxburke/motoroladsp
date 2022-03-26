; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;

; B.1.21	 1x3  3x3  and  1x4  4x4  Matrix Multiply  
;                                               1x3  3x3  Matrix Multiply 
;                                                      	Program	ICycles
;                                                      	Words 
  move        #mat_a,r0       ;point to A matrix 
  move        #2,m0           ;mod 3 
  move        #mat_b,r4       ;point to B matrix 
  move        #-1,m4          ;set for linear addressing 
  move        #mat_c,r1       ;output C matrix 
 
  move                         x:(r0)+,d4.s y:(r4)+,d5.s ;a11,b11 1   1 
  fmpy.s d4,d5,d3              x:(r0)+,d4.s y:(r4)+,d5.s ;a12,b21 1   1 
  fmpy.s d4,d5,d0              x:(r0)+,d4.s y:(r4)+,d5.s ;a13,b31 1   1 
  fmpy   d4,d5,d3 fadd.s d3,d0 x:(r0)+,d4.s y:(r4)+,d5.s ;a11,b12 1   1 
  fmpy   d4,d5,d3 fadd.s d3,d0 x:(r0)+,d4.s y:(r4)+,d5.s ;a12,b22 1   1 
  fmpy.s d4,d5,d1              x:(r0)+,d4.s y:(r4)+,d5.s ;a13,b32 1   1 
  fmpy   d4,d5,d3 fadd.s d3,d1 x:(r0)+,d4.s y:(r4)+,d5.s ;a11,b13 1   1 
  fmpy   d4,d5,d3 fadd.s d3,d1 x:(r0)+,d4.s y:(r4)+,d5.s ;a12,b23 1   1 
  fmpy.s d4,d5,d2              x:(r0)+,d4.s y:(r4)+,d5.s ;a13,b33 1   1 
  fmpy   d4,d5,d3 fadd.s d3,d2              d0.s,y:(r1)+ ;save 1  1   1 
                  fadd.s d3,d2              d1.s,y:(r1)+ ;save 2  1   1 
  move                                      d2.s,y:(r1)+ ;save 3  1   1 
 ;                                                                --- --- 
 ;                                                        Totals:  12  12 
 
 
 ;                       1x4  4x4  Matrix Multiply 
 ;                                                     	Program 	ICycles
 ;                                                     	Words 
  move      #mata,r0  ;[1x4] matrix pointer, X memory 
  move      #matb,r4  ;[4x4] matrix pointer, Y memory 
  move      #matc,r1  ;output matrix, X memory 
 
  move                         x:(r0)+,d4.s y:(r4)+,d7.s ;a11,b11 1   1 
  fmpy.s d7,d4,d0              x:(r0)+,d3.s y:(r4)+,d7.s ;a12,b21 1   1 
  fmpy.s d7,d3,d1              x:(r0)+,d5.s y:(r4)+,d7.s ;a13,b31 1   1 
  fmpy   d7,d5,d1 fadd.s d1,d0 x:(r0)+,d6.s y:(r4)+,d7.s ;a14,b41 1   1 
  fmpy   d7,d6,d1 fadd.s d1,d0              y:(r4)+,d7.s ;b12     1   1 
  fmpy   d7,d4,d1 fadd.s d1,d0              y:(r4)+,d7.s ;b22     1   1 
  fmpy.s d7,d3,d2              d0.s,x:(r1)+ y:(r4)+,d7.s ;b32     1   1 
  fmpy   d7,d5,d2 fadd.s d2,d1              y:(r4)+,d7.s ;b42     1   1 
  fmpy   d7,d6,d2 fadd.s d2,d1              y:(r4)+,d7.s ;b13     1   1 
  fmpy   d7,d4,d0 fadd.s d2,d1              y:(r4)+,d7.s ;b23     1   1 
  fmpy.s d7,d3,d2              d1.s,x:(r1)+ y:(r4)+,d7.s ;b33     1   1 
  fmpy   d7,d5,d2 fadd.s d2,d0              y:(r4)+,d7.s ;b43     1   1 
  fmpy   d7,d6,d2 fadd.s d2,d0              y:(r4)+,d7.s ;b14     1   1 
  fmpy   d7,d4,d1 fadd.s d2,d0              y:(r4)+,d7.s ;b24     1   1 
  fmpy.s d7,d3,d0              d0.s,x:(r1)+ y:(r4)+,d7.s ;b34     1   1 
  fmpy   d7,d5,d0 fadd.s d0,d1              y:(r4)+,d7.s ;b44     1   1 
  fmpy   d7,d6,d0 fadd.s d0,d1                                    1   1 
                  fadd.s d0,d1                                    1   1 
  move                         d1.s,x:(r1)+                       1   1 
 ;                                                                --- --- 
 ;                                                        Totals: 19  19 

