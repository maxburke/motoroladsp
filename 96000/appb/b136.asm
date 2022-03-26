; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.36	Pseudorandom Number Generation  
;This pseudorandom number generator requires a 32 bit seed and returns an  unsigned 32 bit random 
;number.  There are no restrictions on the value  of the seed.  The equation for the seed is:  
;    seed = (69069*seed + 1) mod 2**32 
;
;              Pseudorandom Number Generation            	Program	ICycles 
;                                                        	Words 
    move                x:seed,d0.l  ;get seed            2        2 
    move                #69069,d1.l  ;get constant        2        2 
    mpyu   d0,d1,d0                  ;multiply            1        1 
    inc    d0                        ; +1                 1        1 
    move                d0.l,x:seed  ;mod 2**32, new seed 2        2 
;                                                         ---      --- 
;                                                 Totals:  8        8 

;The resulting unsigned pseudorandom integer number is in d0.l.  
;Reference: VAX/VMS Run-Time Library Routines Reference Manual, 
;           Volume 8C, p. RTL-433. 
