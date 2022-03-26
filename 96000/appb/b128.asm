; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.28	Bit Field Extraction/Insertion  
;The process of bit field extraction is performed on a 32 bit integer in  the lower part of a register. A 
;bit field of length FSIZE starting at  bit position FOFF is extracted and right justified with zero or 
;sign  extension. The value of FSIZE ranges from 1-32 and the field offset  ranges from 0-31.  Bit 
;field extraction and insertion operations are  used in high level languages such as "structures" in C. 
;Both the static  case (extraction based on fixed constants) and the dynamic case  (extraction based 
;on the values in registers) are given.  In the  examples, the field to be extracted is in d0.l.  
;The process of bit field insertion is performed on two 32 bit integer  registers.  A bit field of length 
;FSIZE from one register is shifted  left by an offset FOFF and the field is then inserted into the sec-
;ond  register. The field size FSIZE ranges from 1-32 and the field offset  from the right of the regis-
;ter ranges from 0-31.  For meaningful  results, FSIZE+FOFF is less than or equal to 32. The bit field 
;to  insert is right justified in the register with zero extension to 32  bits. Both the static case 
;(extraction based on fixed constants) and  the dynamic case (extraction based on the values in regis-
;ters) are  given.  In the examples, the field in d1.l is inserted into d0.l.  
;1. 	Static bit field extraction, zero extend.  
;
;                                                       	Program	ICycles
;                                                          	Words      
lsl    #32-(foff+fsize),d0   ;shift off upper bits    1       1      
lsr    #32-fsize,d0          ;right justify           1       1
 ;                                                    ---     ---
 ;                                            Totals:  2       2  

 
;2. 	Static bit field extraction, sign extend.  
;
;                                                       	Program	ICycles
;                                                          	Words
lsl    #32-(foff+fsize),d0   ;shift off upper bits    1       1
asr    #32-fsize,d0          ;right justify, sign ext 1       1
;                                                     ---     ---
;                                             Totals:  2       2  

 
;3. 	Dynamic bit field extraction, zero extend.  Register d1.l contains 
;FOFF,  d2.l contains FSIZE.  


;                                                       	Program	ICycles
;                                                          	Words
move             #32,d3.l    ;register size           1       1      
sub    d2,d3                 ;32-fsize                1       1      
sub    d1,d3     d3.l,d4.h   ;32-fsize-foff, 32-fsize 1       1      
move             d3.l,d0.h   ;move 32-fsize-foff      1       1      
lsl    d0,d0     d4.h,d0.h   ;shift off upper bits    1       1      
lsr    d0,d0                 ;right justify           1       1
;                                                     ---     ---
;                                             Totals:  6       6  

 
;4. 	Dynamic bit field extraction, sign extend. Register d1.l  contains 
;FOFF, d2.l contains FSIZE.  


;                                                       	Program	ICycles
;                                                          	Words
move             #32,d3.l    ;register size           1       1      
sub    d2,d3                 ;32-fsize                1       1      
sub    d1,d3     d3.l,d4.h   ;32-fsize-foff, 32-fsize 1       1      
move             d3.l,d0.h   ;move 32-fsize-foff      1       1      
lsl    d0,d0     d4.h,d0.h   ;shift off upper bits    1       1      
asr    d0,d0                 ;right justify           1       1
 ;                                                    ---     ---
 ;                                            Totals:  6       6  

 
;5. 	Static bit field insertion.  
;
;
;                                                       	Program	ICycles
;                                                          	Words
move            #-1,d2.l        ;get all ones mask       1      1     
lsl     #32-fsize,d2            ;keep field fsize long   1      1     
lsr     #32-(fsize+foff),d2     ;move to insertion       1      1     
andc    d2,d0                   ;clear field             1      1     
lsl     #foff,d1                ;move field to insert    1      1     
or      d1,d0                   ;insert bit field        1      1
;                                                        ---    ---
;                                                Totals:  6      6  

 
;6. 	Dynamic bit field insertion.  Register d2.l contains FOFF, d3.l con-
;tains  FSIZE.  
;

;                                                       	Program	ICycles
;                                                          	Words
move           #32,d4.l        ;get 32                  1     1      
sub    d3,d4   #-1,d5.l        ;32-fsize, load 1's mask 2     2      
sub    d2,d4   d4.l,d5.h       ;32-(fsize+foff)         1     1      
lsl    d5,d5   d4.l,d5.h       ;shift one's mask up     1     1      
lsr    d5,d5                   ;shift one's mask down   1     1      
andc   d5,d0   d2.l,d1.h       ;invert mask and clear   1     1      
lsl    d1,d1                   ;move bits to field      1     1      
or     d1,d0                   ;insert bit field        1     1
;                                                       ---   ---
;                                               Totals:  9     9  

;7. 	Static bit field clear.  

;                                                       	Program	ICycles
;                                                          	Words
move               #-1,d1.l    ;mask of all 1s        1       1      
lsr    #32-fsize,d1            ;make 1s size of foff  1       1      
lsl    #foff,d1                ;align field           1       1      
andc   d1,d0                   ;invert mask and clear 1       1
;                                                     ---     ---
;                                             Totals:  4       4  

 
;8. 	Static bit field set.  
;

;                                                       	Program	ICycles
;                                                          	Words
;move               #-1,d1.l    ;mask of all 1s        1       1      
lsr    #32-fsize,d1            ;make 1s size of foff  1       1      
lsl    #foff,d1                ;align field           1       1      
or     d1,d0                   ;clear field           1       1
 ;                                                    ---     ---
 ;                                            Totals:  4       4  

 
;9. 	Dynamic bit field clear. Register d1.l contains FOFF, d2.l contains  
;FSIZE.  


;                                                       	Program	ICycles
;                                                          	Words
move                #32,d3.l    ;register size          1     1      
sub     d2,d3       #-1,d2.l    ;32-fsize, get 1s mask  2     2      
move                d3.l,d3.h   ;move shift count       1     1      
lsr     d3,d2       d1.l,d1.h   ;trim mask, get foff    1     1      
lsl     d1,d2                   ;align mask             1     1      
andc    d2,d0                   ;invert mask and clear  1     1
;                                                       ---   ---
;                                               Totals:  7     7  

 
;10. 	Dynamic bit field set. Register d1.l contains FOFF, d2.l contains 
;FSIZE.  


;                                                       	Program	ICycles
;                                                          	Words
move                #32,d3.l    ;register size          1     1      
sub     d2,d3       #-1,d2.l    ;32-fsize, get 1s mask  2     2      
move                d3.l,d3.h   ;move shift count       1     1      
lsr     d3,d2       d1.l,d1.h   ;trim mask, get foff    1     1      
lsl     d1,d2                   ;align mask             1     1      
or      d2,d0                   ;clear bit field        1     1
;                                                       ---   ---
;                                               Totals:  7     7  
