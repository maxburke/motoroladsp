; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.27	Multibit Rotates  
;This describes how to perform multibit rotates using the logical  barrel shifts. Both the static case 
;(rotate by a fixed constant)  and the dynamic case (rotate by a value in a register) are presented.  
;The following code assumes a rotating model of the form:  
;
;       
;
;
;
;In this type of rotate, the carry participates in the bit  rotations. Bits rotated out of the register go 
into the carry  bit; the previous value of the carry bit goes into the register.  
;1.	Static rotate left 1-32 bits.  The 32 bit integer to be rotated is in  d0.l.  The number of bits 
;to rotate is N.  The resulting carry is the  value of bit 32-N of the register.  For example, if 
;N=3 (three bit rotate  left), then the resulting carry will be the value of bit 29 of the  regis-
;ter.  
;
;                                                       	Program	ICycles
;                                                          		Words
;      rol    d0         d0.l,d1.l  ;shift in carry, copy input 1    1
;      lsl    #N-1,d0               ;shift up, pad with zeros   1    1
;      lsr    #33-N,d1              ;shift down, set carry      1    1
;      or     d1,d0                 ;put numbers back together  1    1
;                                                              ---  ---
 ;                                                     Totals:  4    4  
;
;2. 	Static rotate right 1-32 bits.  The 32 bit integer to be rotated is in  d0.l.  The number of 
;bits to rotate is N.  The resulting carry is the  value of bit N-1 of the register.  For exam-
;ple, if N=3 (three bit rotate  right), then the resulting carry will be the value of bit 2 of 
;the  register.  
;
;                                                       	Program	ICycles
;                                                          	Words 
      ror    d0         d0.l,d1.l  ;shift in carry, copy input 1     1
      lsr    #N-1,d0               ;shift up, pad with zeros   1     1
      lsl    #33-N,d1              ;shift down, set carry      1     1
      or     d1,d0                 ;put numbers back together  1     1
;                                                              ---   ---
;                                                      Totals:  4     4  
 
;3. 	Dynamic rotate left 0-32 bits.  The 32 bit integer to be rotated is in  d0.l.  The number of 
;bits to rotate is in d2.l.  In the following  example, the code for checking if the shift count 
;is zero may be eliminated  if it is known that the shift count is greater than zero.  
;
;                                                       	Program	ICycles
;                                                          	Words  
; 
      tst    d2                    ;see if shift count is zero  1    1
      jeq    _done                 ;yes, done                   2    2
      rol    d0         d0.l,d1.l  ;shift in carry, copy input  1    1
      dec    d2         #32,d3.l   ;dec shift count, get 32     2    2
      sub    d2,d3      d2.l,d0.h  ;get 32-shift, move count    1    1
      lsl    d0,d0      d3.l,d1.h  ;shift, move shift count     1    1
      lsr    d1,d1                 ;shift, set carry            1    1
      or     d1,d0                 ;or bits together            1    1  
_done                                                          ---  ---
;                                                      Totals:  10   10  

;4. 	Dynamic rotate right 0-32 bits.  The 32 bit integer to be rotated is in  d0.l.  The number 
;of bits to rotate is in d2.l.  In the following  example, the code for checking if the shift is 
;zero count may be eliminated  if it is known that the shift count is greater than zero.  
;                                                       	Program	ICycles
 ;                                                         	Words        
tst    d2                    ;see if shift count is zero  1    1      
jeq    _done                 ;yes, done                   2    2      
ror    d0         d0.l,d1.l  ;shift in carry, copy input  1    1      
dec    d2         #32,d3.l   ;dec shift count, get 32     2    2      
sub    d2,d3      d2.l,d0.h  ;get 32-shift, move count    1    1      
lsr    d0,d0      d3.l,d1.h  ;shift, move shift count     1    1      
lsl    d1,d1                 ;shift, set carry            1    1      
or     d1,d0                 ;or bits together            1    1  
_done                                                    ---  ---
;                                               Totals:   10   10  
; 
;The following code assumes a rotating model of the form:  








;In this model, the carry does not participate in the rotations.  The carry assumes the value of the bit 
;that was rotated around  the end of the register.  
;1. 	Static rotate left 0-32 bits.  The 32 bit integer to be rotated is in  d0.l.  The number of bits 
;to rotate is N.  The resulting carry is the  value of bit 32-N of the register.  For example, if 
;N=3 (three bit rotate  left), then the resulting carry will be the value of bit 29 of the  regis-
;ter.  The resulting carry is the value of the least significant bit  of the register after rota-
;tion.  
;In the special case of a zero shift count, the resulting carry is the  most significant bit.  In 
;the special case of a 32 shift count, the  resulting carry is the least significant bit.  In both 
;cases, the  register shifted is unchanged.  
;
;
;                                                       	Program	ICycles
;                                                          	Words      
move               d0.l,d1.l  ;copy input            1       1      
lsr    #32-N,d0               ;shift first part      1       1      
lsl    #N,d1                  ;shift other part      1       1      
or     d1,d0                  ;merge bits together   1       1
;                                                    ---     ---
;                                            Totals:  4       4  

 
;2. 	Static rotate right 0-32 bits.  The 32 bit integer to be rotated is in  d0.l.  The number of 
;bits to rotate is N.  The resulting carry is the  value of bit N-1 of the register.  For exam-
;ple, if N=3 (three bit rotate  right), then the resulting carry will be the value of bit 2 of 
;the  register.  The resulting carry is the value of the most significant bit  of the register af-
;ter rotation.  
;In the special case of a zero shift count, the resulting carry is the  least significant bit.  In 
;the special case of a 32 shift count, the  resulting carry is the most significant bit.  In both 
;cases, the register  shifted is unchanged.  
;

;                                                       	Program	ICycles
;                                                          	Words       
move               d0.l,d1.l  ;copy input             1      1      
lsl    #32-N,d0               ;shift first part       1      1      
lsr    #N,d1                  ;shift other part       1      1      
or     d1,d0                  ;merge bits together    1      1
;                                                     ---    ---
;                                            Totals:   4      4  

 
;3. 	Dynamic rotate left 0-32 bits.  The 32 bit integer to be rotated is in  d0.l.  The number of 
;bits to rotate is in d2.l.  
;In the special case of a zero shift count, the resulting carry is the  most significant bit.  In 
;the special case of a 32 shift count, the  resulting carry is the least significant bit.  In both 
;cases, the  register shifted is unchanged.  
;
;
;                                                       	Program	ICycles
;                                                          	Words       
move    #32,d1.l              ;get 32                 1      1      
sub     d2,d1      d2.l,d1.h  ;32-shift, move shift   1      1      
move               d1.l,d0.h  ;move other shift       1      1      
lsr     d0,d0      d0.l,d1.l  ;shift, copy input      1      1      
lsl     d1,d1                 ;shift other part       1      1      
or      d1,d0                 ;merge bits together    1      1
;                                                     ---    ---
;                                            Totals:   6      6 
; 
;4. 	Dynamic rotate right 0-32 bits.  The 32 bit integer to be rotated is in  d0.l.  The number 
;of bits to rotate is in d2.l.  
;In the special case of a zero shift count, the resulting carry is the  least significant bit.  In 
;the special case of a 32 shift count, the  resulting carry is the most significant bit.  In 
;both cases, the register  shifted is unchanged.  
;

;                                                       	Program	ICycles
;                                                          	Words       
move    #32,d1.l              ;get 32                 1      1      
sub     d2,d1      d2.l,d1.h  ;32-shift, move shift   1      1      
move               d1.l,d0.h  ;move other shift       1      1      
lsl     d0,d0      d0.l,d1.l  ;shift, copy input      1      1      
lsr     d1,d1                 ;shift other part       1      1      
or      d1,d0                 ;merge bits together    1      1
;                                                     ---    ---
;                                            Totals:   6      6  
