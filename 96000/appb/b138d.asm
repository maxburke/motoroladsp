; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.38.4	Unpack a 32 Bit Word Into Two Sign-extended 16 Bit Words  
;The following unpacks a 32 bit word into two 16 bit sign-extended 16 bit  words.  
;              Two 16 Bit Unpacks                        	Program	ICycles 
;                                                        	Words 
    move              #data,d0.l    ;get data 
    split  d0,d1                    ;d1=sX, d0=XY          1        1 
    ext       d1                    ;d1=sY                 1        1 
;                                                          ---      --- 
;                                                  Totals:  2        2 
