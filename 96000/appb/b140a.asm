; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.40	Graphics BITBLT (Bit Block Transfer)  
;The bit block transfer (BITBLT) is an operation that transfers  a bit field from one area of memory to 
;another.  Four parameters  describe the BITBLT operation:  
;SOURCE - The source address of the block to be transferred.  Data transferred from  the source 
;starts at the lsb of the first data word.  
;COUNT    - 	The number of words to transfer from the source field.  This must be  greater than zero.  
;DEST       - 	Destination starting address.  
;OFFSET   - 	The starting bit number of the destination word that the transfer is to  start.  The offset 
;is in the range of 0-31.  
;Note that the source data starts at the lsb of the first word whereas  the destination starts at an ar-
;bitrary offset from the lsb.  
; B.1.40.1	32 Bit Block Transfer  
;              32 Bit Block Transfer                     	Program	ICycles 
;                     BITBLT                             	Words 
       org   x:0 
source ds      1      ;source address 
dest   ds      1      ;destination address 
offset ds      1      ;bit number start (0-31) 
count  ds      1      ;number of 32 bit source words 
 
  org  p:$50 
  move          x:offset,d0.l ;get output bit position         2     2 
  move          #32,d1.l      ;get 32                          1     1 
  sub  d0,d1    x:source,r0   ;32-offset, point to source      2     2 
  move          x:dest,r1     ;point to destination address    2     2 
  move          d1.l,d1.h     ;move shift factor               1     1 
  move          y:(r1),d4.l   ;get first bits of dest          1     1 
  lsl  d1,d4    d0.l,d0.h     ;shift bits, move shift fact     1     1 
  move          x:count,n0    ;get source word count           2     2 
 
  do   n0,bitblt              ;do transfer                     2     3 
  lsr  d1,d4    y:(r0)+,d5.l  ;shift old bits, get source bits 1     1 
  lsl  d0,d5    d5.l,d3.l     ;shift new bits, save new bits   1     1 
  or   d4,d5    d3.l,d4.l     ;merge bits, save new as old bit 1     1 
  move          d5.l,y:(r1)+  ;save new dest field             1     1 
bitblt 
  lsr  d1,d4    y:(r1),d5.l   ;shift old bits, get dest bits   1     1 
  lsr  d0,d5                  ;shift dest bits                 1     1 
  lsl  d0,d5                  ;shift dest bits back            1     1 
  or   d4,d5                  ;part of dest with source bits   1     1 
  move          d5.l,y:(r1)   ;save new destination bits       1     1 
                                                         ;     ---   --- 
                                                     ; Totals: 24   4N+20 

;Where N represents 32 bits transferred.  At a 13.5 MIPS, a total of  (13.5/4)*32 = 108 
;MBits/Second transfer rate is possible.  
