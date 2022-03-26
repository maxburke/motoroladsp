; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.41	64x64 Bit Unsigned Multiply  
;This performs a double precision unsigned integer multiply.  The  64 bit integer is formed by the con-
;catenation of two 32 bit registers.  
;Let X = A:B and Y = C:D, then X*Y can be written as:  
;                        A   B 
;                     *  C   D 
;           ------------------ 
;            +           B * D 
;            +       A * D 
;            +       B * C 
;            +   A * C 
;           ------------------ 
;            =   W   X   Y   Z 
 
; 
;            64x64 Bit Unsigned Multiply                 	Program	ICycles 
;            d3:d7:d6:d4 = d0:d1 * d2:d3                 	Words 
 
  mpyu  d0,d2,d7                                             ;  1     1 
  mpyu  d0,d3,d5                                             ;  1     1 
  mpyu  d1,d3,d4    d7.h,d3.l                                ;  1     1 
  mpyu  d1,d2,d6    d4.h,d0.l                                ;  1     1 
  move              d6.h,d2.l                                ;  1     1 
  add   d0,d5       d5.h,d1.l                                ;  1     1 
  addc  d1,d2                                                ;  1     1 
  inc   d3          ifcs                                     ;  1     1 
  add   d5,d6                                               ;   1     1 
  addc  d2,d7                                                ;  1     1 
  inc   d3          ifcs                                     ;  1     1 
                                                             ; ---   --- 
                                               ;       Totals:  11    11 

