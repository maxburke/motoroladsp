; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.38.1	Pack Four Bytes Into a 32 Bit Word  
;The following packs four 8 bit bytes into a single 32 bit word.  The  bytes to be packed are right justi-
;fied in four separate registers:  
;      d0 = xxxA         d2 = xxxC 
;      d1 = xxxB         d3 = xxxD 
; 
; 
;              Four 8 Bit Packs                          	Program	ICycles 
;                                                        	Words 
    joinb   d0,d1    ;d1 = xxAB                            1        1 
    joinb   d2,d3    ;d3 = xxCD                            1        1 
    join    d1,d3    ;d3 = ABCD                            1        1 
;                                                          ---      --- 
;                                                  Totals:  3        3 
