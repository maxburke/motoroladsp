; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.33.4	Four Point Polygon Accept/Reject  
;This determines if the polygon consisting of the points (x0,y0,z0),  (x1,y1,z1), (x2,y2,z2), 
;(x3,y3,z3) is within a three-dimensional view  cube.  If the polygon is within the cube, the A (accept) 
;bit of the CCR  will be set.  If the polygon is entirely outside of the cube, then the R  bit will be 
;cleared.  If the polygon can not be accepted or  rejected, then further processing is required to clip 
;the polygon.  
;Registers: 
;   d0 = dimension  d4 = unused 
;   d1 = limit           d5 = unused 
;   d2 = unused      d6 = unused 
;   d3 = unused      d7 = unused 
;
;Memory Map: 
;                        X Memory          Y Memory 
;  (n0=3)  r0 ?   x0         Xmin  ? r4 
;                y0         Xmax 
;                z0         Ymin 
;                x1         Ymax 
;                y1         Zmin 
;                z1         Zmax 
;                x2 
;                y2 
;                z2 
;                x3 
;                y3 
;                z3 
;
;                   Polygon Accept/Reject 
;                                                        	Program	ICycles 
;                                                          	Words 
  ori   #$e0,ccr          ;set accept/reject/overflow bits   1     1 
  move         x:(r0)+n0,d0.s y:(r4)+,d1.s ;get x0,Xmin      1     1 
 
  fcmp  d1,d0  x:(r0)+n0,d0.s              ;x0-Xmin, get x1  1     1 
  fcmp  d1,d0  x:(r0)+n0,d0.s              ;x1-Xmin, get x2  1     1 
  fcmp  d1,d0  x:(r0)-n0,d0.s              ;x2-Xmin, get x3  1     1 
  fcmpg d1,d0                 y:(r4)+,d1.s ;x3-Xmin, Xmax    1     1 
  fcmp  d0,d1  x:(r0)-n0,d0.s              ;Xmax-x3, get x2  1     1 
  fcmp  d0,d1  x:(r0)-n0,d0.s              ;Xmax-x2, get x1  1     1 
  fcmp  d0,d1  x:(r0)+,d0.s                ;Xmax-x1, get x0  1     1 
  fcmpg d0,d1  x:(r0)+n0,d0.s y:(r4)+,d1.s ;Xmax-x0, y0,Ymin 1     1 
 
  fcmp  d1,d0  x:(r0)+n0,d0.s              ;y0-Ymin, get y1  1     1 
  fcmp  d1,d0  x:(r0)+n0,d0.s              ;y1-Ymin, get y2  1     1 
  fcmp  d1,d0  x:(r0)-n0,d0.s              ;y2-Ymin, get y3  1     1 
  fcmpg d1,d0                 y:(r4)+,d1.s ;y3-Ymin, ymax    1     1 
  fcmp  d0,d1  x:(r0)-n0,d0.s              ;Ymax-y3, get y2  1     1 
  fcmp  d0,d1  x:(r0)-n0,d0.s              ;Ymax-y2, get y1  1     1 
  fcmp  d0,d1  x:(r0)+,d0.s                ;Ymax-y1, get y0  1     1 
  fcmpg d0,d1  x:(r0)+n0,d0.s y:(r4)+,d1.s ;Ymax-y0, z0,Zmin 1     1 
 
  fcmp  d1,d0  x:(r0)+n0,d0.s              ;z0-Zmin, get z1  1     1 
  fcmp  d1,d0  x:(r0)+n0,d0.s              ;z1-Zmin, get z2  1     1 
  fcmp  d1,d0  x:(r0)-n0,d0.s              ;z2-Zmin, get z3  1     1 
  fcmpg d1,d0                 y:(r4)+,d1.s ;z3-Zmin, Zmax    1     1 
  fcmp  d0,d1  x:(r0)-n0,d0.s              ;Zmax-z3, get z2  1     1 
  fcmp  d0,d1  x:(r0)-n0,d0.s              ;Zmax-z2, get z1  1     1 
  fcmp  d0,d1  x:(r0)+,d0.s                ;Zmax-z1, get z0  1     1 
  fcmpg d0,d1                              ;Zmax-z0          1     1 
;                                                                   ---   --- 
;                                                   Totals:  26    26 

;If the A bit is set, the polygon can be accepted, if the R bit is  cleared, the polygon can be rejected.  
