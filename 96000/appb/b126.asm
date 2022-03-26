; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.26	Non-IEEE floating-point Division  
;The following code segments perform the division of d0/d5.  The  resulting quotient is in d0.  These 
;code segments are used for  a fast division without the need to conform to the error checking  or er-
;ror bounds of the IEEE standard.  
;The code uses a "convergent division" algorithm.  The initial seed  obtained from the FSEEDD instruc-
;tion has 8 bits of accuracy.  Two  iterations of the convergent division algorithm provide approxi-
;mately 32  bits of accuracy.  For more information on the convergent division  algorithm, consult 
;"Computer Arithmetic, Principles, Architecture, and  Design" by Kai Hwang, 1979, John Wiley and 
;Sons, New York.  
;               Non-IEEE Division Algorithm 
;                                                        	Program	ICycles 
;                                                        	Words 
    fseedd d5,d4                                     ;     1       1 
    fmpy.s d5,d4,d5                    #2.0,d2.s     ;     2       2 
    fmpy   d0,d4,d0    fsub.s d5,d2    d2.s,d3.s     ;     1       1 
    fmpy.s d5,d2,d5                    d2.s,d4.s     ;     1       1 
    fmpy   d0,d4,d0    fsub.s d5,d3                  ;     1       1 
    fmpy.s d0,d3,d0                                  ;     1       1 
                                                     ;    ---     --- 
;                                                 Totals:  7       7 

;Operation table: 
;                         d0 (dividend) 
;                                      / 
;      0.0      number      infinity  /  d5 (divisor) 
;------------------------------------/ 
;      NaN      NaN         NaN             0.0 
;      0.0     number      infinity         number 
;      NaN      NaN         NaN             infinity 
; 
