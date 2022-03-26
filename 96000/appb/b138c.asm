; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.38.3	Unpack a 32 Bit Word Into Four Sign-extended Bytes  
;The following unpacks a 32 bit word into four 8 bit sign-extended bytes  in separate registers.  
;              Four 8 Bit Unpacks                        	Program	ICycles 
;                                                        	Words 
     move              #data,d3.l    ;get data 
    split  d3,d1                    ;d1=ssAB, d3=ABCD      1        1 
    splitb d1,d0                    ;d0=sssA, d1=ssAB      1        1 
    extb      d1                    ;d1=sssB               1        1 
    splitb d3,d2                    ;d2=sssC               1        1 
    extb      d3                    ;d3=sssD               1        1 
;                                                          ---      --- 
;                                                  Totals:  5        5 
