; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
 ;B.1.38.2	Pack Two 16 Bit Words Into a 32 Bit Word  
;The following packs two 16 bit words into a single 32 bit word.  The  words to be packed are right jus-
;tified in two separate registers:  
;      d0 = xY       d1 = xZ  
;              Two 16 Bit Packs                          	Program	ICycles 
;                                                        	Words 
    join    d0,d1    ;d1 = YZ                              1        1 
;                                                          ---      --- 
                                                 Totals:  1        1 
