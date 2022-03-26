; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.40.2	64 Bit Block Transfer  
;A more efficient implementation of BITBLT may be performed by  transferring 64 bits at a time.  Thus, 
;the value of COUNT specifies  the number of 64 bit transfers (two 32 bit words).  
;              64 Bit Block Transfer                     	Program	ICycles 
;                     BITBLT                             	Words 
       org   x:0 
source ds      1      ;source address 
dest   ds      1      ;destination address 
offset ds      1      ;bit number start (0-31) 
count  ds      1      ;number of 64 bit source words 
 
  org  p:$50 
  move          x:offset,d0.l ;get output bit position         2     2 
  move          x:offset,d0.l ;get output bit position         2     2 
  move          #32,d1.l      ;get 32                          2     2 
  sub   d0,d1   x:source,r0   ;32-offset, get source address   2     2 
  move          x:dest,r1     ;point to destination address    2     2 
  move          d1.l,d1.h     ;move shift factor               1     1 
  lsl   d1,d4   d0.l,d0.h     ;shift bits, move shift factor   1     1 
  move          x:count,n0    ;get source word count           2     2 
  move          (r1)-         ;backup pointer                  1     1 
  move          y:(r1)+,d6.l  ;init pipe                       1     1 
  move          y:(r1)-,d4.l  ;get first bits of dest          1     1 
  move          y:(r0)+,d5.l  ;get source bits                 1     1 
  do    n0,bitblt             ;do transfer                     2     3 
  lsr   d1,d4   d6.l,y:(r1)+                                   1     1 
  lsl   d0,d5   d5.l,d3.l                                      1     1 
  or    d4,d5   y:(r0)+,d6.l                                   1     1 
  lsr   d1,d3   d5.l,y:(r1)+                                   1     1 
  lsl   d0,d6   d6.l,d4.l                                      1     1 
  or    d3,d6   y:(r0)+,d5.l                                   1     1 
bitblt 
  move          d6.l,y:(r1)+                                   1     1 
  lsr   d1,d4   y:(r1),d5.l   ;shift old bits, get dest bits   1     1 
  lsr   d0,d5                 ;shift dest bits                 1     1 
  lsl   d0,d5                 ;shift dest bits back            1     1 
  or    d4,d5                 ;part of dest with source bits   1     1 
  move          d5.l,y:(r1)   ;save new destination bits       1     1 
                                                       ;       ---   --- 
                                                     ; Totals:  32  6N+27 

;Where N represents 64 bits transferred.  At a 13.5 MIPS, a total of  (13.5/6)*64 = 144 
;MBits/Second transfer rate is possible.  
