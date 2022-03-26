; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
 ;B.1.33.3	Line Accept/Reject, Fixed Point Version  
 ;                                                       	Program	ICycles 
 ;                                                         	Words 
  ori    #e0,ccr          ;set accept/reject/infinity bits   1     1 
  move         x:(r0)+n0,d0.l y:(r4)+,d1.l ;get x0,Xmin      1     1 
  cmp  d1,d0   x:(r0)-n0,d0.l              ;x0-Xmin, get x1  1     1 
  cmpg d1,d0                  y:(r4)+,d1.l ;x1-Xmin, Xmax    1     1 
  cmp  d0,d1   x:(r0)+,d0.l                ;Xmax-x1, get x0  1     1 
  cmpg d0,d1   x:(r0)+n0,d0.l y:(r4)+,d1.l ;Xmax-x0, y0,Ymin 1     1 
  cmp  d1,d0   x:(r0)-n0,d0.l              ;y0-Ymin, get y1  1     1 
  cmpg d1,d0                  y:(r4)+,d1.l ;y1-Ymin, Ymax    1     1 
  cmp  d0,d1   x:(r0)+,d0.l                ;Ymax-y1, get y0  1     1 
  cmpg d0,d1   x:(r0)+n0,d0.l y:(r4)+,d1.l ;Ymax-y0, z0,Zmin 1     1 
  cmp  d1,d0   x:(r0)-n0,d0.l              ;z0-Zmin, get z1  1     1 
  cmpg d1,d0                  y:(r4)+,d1.l ;z1-Zmin, Zmax    1     1 
  cmp  d0,d1   x:(r0),d0.l                 ;Zmax-z1, get z0  1     1 
  cmpg d0,d1                               ;Zmax-z0          1     1 
;                                                            ---   --- 
;                                                    Totals:  14    14 

;If the A bit is set, the line can be accepted.  If the R bit is  cleared, the line can be rejected.  
