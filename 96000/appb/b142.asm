; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
;                  Approximation of 1/d1                 	Program	ICycles 
;                     32 Bit Accuracy                    	Words 
  fseedd  d1,d6                                              ;  1     1 
  fmpy.s  d1,d6,d1        #2.0,d4.s                          ;  2     2 
  fsub.s  d1,d4           d4.s,d3.s                          ;  1     1 
  fmpy.s  d1,d4,d1                                           ;  1     1 
  fmpy    d6,d4,d1  fsub.s d1,d3                             ;  1     1 
  fmpy.s  d1,d3,d1                                           ;  1     1 
                                                             ; ---   --- 
                                                ;      Totals:  7     7 
