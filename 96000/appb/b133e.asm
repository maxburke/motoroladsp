; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.33.5	Four Point Polygon Accept/Reject (looped)
;                   Polygon Accept/Reject
;                                                          Program  Icycles
;                                                          Words
  ori   #$e0,ccr          ;set accept/reject/overflow bits   1     1
  move         x:(r0)+n0,d0.s y:(r4)+,d1.s ;get x0,Xmin      1     1

  do    #3,clip                                              2     3
  fcmp  d1,d0  x:(r0)+n0,d0.s              ;d0-Dmin, get d1  1     1
  fcmp  d1,d0  x:(r0)+n0,d0.s              ;d1-Dmin, get d2  1     1
  fcmp  d1,d0  x:(r0)-n0,d0.s              ;d2-Dmin, get d3  1     1
  fcmpg d1,d0                 y:(r4)+,d1.s ;d3-Dmin, Dmax    1     1
  fcmp  d0,d1  x:(r0)-n0,d0.s              ;Dmax-x3, get d2  1     1
  fcmp  d0,d1  x:(r0)-n0,d0.s              ;Dmax-x2, get d1  1     1
  fcmp  d0,d1  x:(r0)+,d0.s                ;Dmax-x1, get d0  1     1
  fcmpg d0,d1  x:(r0)+n0,d0.s y:(r4)+,d1.s ;Dmax-x0, d0,Dmin 1     1
clip                                       ;                 ---   ---
                                           ;         Totals:  12    26
