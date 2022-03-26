; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.1	Real Multiply  
;   c = a * b 
;                                                     	Program	ICycles 
;                                                      	Words 
    move                      x:(r0),d4.s   y:(r4),d6.s ;  1      1 
    fmpy.s d4,d6,d0                                    ;  1      1 
    move                      d0.s,x:(r1)              ;  1      1 
;                                                    ;    ---    --- 
;                                                Totals:  3      3 
;                                                        (3      3) 
