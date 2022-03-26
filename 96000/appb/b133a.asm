; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.33	Graphics Accept/Reject Of Polygons  
;In graphics applications, checks are made to determine if objects are  within a viewing window.  Initial 
;checks are made to see if the object  can be trivially accepted or trivially rejected.  If the object can 
;not  be trivially accepted/rejected, then a clipping algorithm is used.  
;The following code segments perform the trivial accept/reject of a  point, line or 4 point polygon with-
;in a cube.  
; B.1.33.1	One Point Accept/Reject  
;This determines if the point (x,y,z) is within a three-dimensional view  cube.  If the point is within the 
;cube, the A (accept) bit of the CCR  will be set.  Single point accept/reject for plotting is useful for  
;plotting of stochastic images such as fractals.  
;Registers: 
;   d0 = x          d4 = limit 
;   d1 = y          d5 = unused 
;   d2 = z          d6 = unused 
;   d3 = unused     d7 = unused 
;
;Memory Map: 
;               X Memory    Y Memory 
;                             Xmin   ? r0 
;                             Xmax 
;                             Ymin 
;                             Ymax 
;                             Zmin 
;                             Zmax 
;                    Single Point Accept/Reject 
;                                                      	Program	ICycles 
;                                                        	Words 
  ori    #$80,ccr                        ;set accept bit      1     1 
  move                   y:(r0)+,d4.s    ;get window minimum  1     1 
  fcmp   d4,d0           y:(r0)+,d4.s    ;x-Xmin              1     1 
  fcmp   d0,d4           y:(r0)+,d4.s    ;Xmax-x              1     1 
  fcmp   d4,d1           y:(r0)+,d4,s    ;y-Ymin              1     1 
  fcmp   d1,d4           y:(r0)+,d4.s    ;Ymax-y              1     1 
  fcmp   d4,d2           y:(r0)+,d4.s    ;z-Zmin              1     1 
  fcmp   d2,d4                           ;Zmax-z              1     1 
;                                                             ---   --- 
                                                                                                  Totals:	8	8 

;If the point is within the limits, then the A bit of the CCR is  equal to one, otherwise, the point can 
;be rejected.  
