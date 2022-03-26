; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.33.2	Line Accept/Reject, floating-point Version  
;This determines if the line from (x0,y0,z0) to (x1,y1,z1) is within a  three-dimensional view cube.  If 
;the line is within the cube, the A  (accept) bit of the CCR will be set.  If the line is entirely outside of  
;the cube, then the R bit will be cleared.  If the line can not be  accepted or rejected, then further pro-
;cessing is required to clip the  line where it intersects with a boundary plane.  
;Registers: 
;   d0 = dimension  d4 = unused 
;   d1 = limit      d5 = unused 
;   d2 = unused     d6 = unused 
;   d3 = unused     d7 = unused 
;
;Memory Map: 
;               X Memory    Y Memory 
;(n0=3)  r0 ?   x0         Xmin  ? r4 
;                y0         Xmax 
;                z0         Ymin 
;                x1         Ymax 
;                y1         Zmin 
;                z1         Zmax 
;
;                                                        	Program	ICycles 
;                                                          	Words 
  ori    #$e0,ccr         ;set accept/reject/overflow bits   1     1 
  move         x:(r0)+n0,d0.s y:(r4)+,d1.s ;get x0,Xmin      1     1 
  fcmp  d1,d0  x:(r0)-n0,d0.s              ;x0-Xmin, get x1  1     1 
  fcmpg d1,d0                 y:(r4)+,d1.s ;x1-Xmin, Xmax    1     1 
  fcmp  d0,d1  x:(r0)+,d0.s                ;Xmax-x1, get x0  1     1 
  fcmpg d0,d1  x:(r0)+n0,d0.s y:(r4)+,d1.s ;Xmax-x0, y0,Ymin 1     1 
  fcmp  d1,d0  x:(r0)-n0,d0.s              ;y0-Ymin, get y1  1     1 
  fcmpg d1,d0                 y:(r4)+,d1.s ;y1-Ymin, Ymax    1     1 
  fcmp  d0,d1  x:(r0)+,d0.s                ;Ymax-y1, get y0  1     1 
  fcmpg d0,d1  x:(r0)+n0,d0.s y:(r4)+,d1.s ;Ymax-y0, z0,Zmin 1     1 
  fcmp  d1,d0  x:(r0)-n0,d0.s              ;z0-Zmin, get z1  1     1 
  fcmpg d1,d0                 y:(r4)+,d1.s ;z1-Zmin, Zmax    1     1 
  fcmp  d0,d1  x:(r0),d0.s                 ;Zmax-z1, get z0  1     1 
  fcmpg d0,d1                              ;Zmax-z0          1     1 
;                                                            ---   --- 
;                                                    Totals:  14    14 

;If the A bit is set, the line can be accepted.  If the R bit is  cleared, the line can be rejected.  
