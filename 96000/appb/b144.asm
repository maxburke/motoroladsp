; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.44	Wire-Frame Graphics Rendering  
;         WIRE-FRAME RENDITION OF A THREE DIMENSIONAL POLYLINE 
;                     ON THE MOTOROLA DSP96002  
;                         Version 1.00 
;
;OVERVIEW  
;This program displays a three dimensional polyline in two dimensions.  The points of the polyline, as 
;defined in the input list, are  projected into two dimensions using the perspective transformation.  
;The projected points are output to a display list that can be drawn  by a graphics engine or a fast 
;drawing program.  
;In order to maximize speed, two loops perform the graphics  transformations:  the trivial accept loop 
;and the trivial reject loop.  
;The trivial accept loop assumes that the last displayed point was  inside the viewing pyramid and thus 
;not clipped.  It pulls a new  point from the input list, converts it to clipping space and checks  if it is 
;inside the viewing pyramid.  If so, the routine performs  the perspective transformation, scales and 
;translates the point so  it lies within the viewing window, and finally adds it to the  display list.  
;If the point is found to lie outside the viewing pyramid, an  algorithm to clip a single point is per-
;formed and the program  enters the trivial reject loop.  
;The trivial reject loop assumes that the last displayed point was  outside the viewing pyramid.  It pulls 
;a new point from the input  list, converts it to clipping space and checks if the line joining  the new 
;point and the last point can be trivially rejected.  Trivial rejection occurs when both points of a line lie 
;outside of  a clipping plane.  When this occurs, the current point is saved  and the trivial reject loop 
;repeats.  
;Should the line not be trivially rejected but the current point  is accepted, an algorithm to clip a single 
;point is performed.  If  the current point is not accepted,  two-point clipping is  performed.  
;PERFORMANCE  
;All times are given in instruction cycles.  
;  Accept loop 
;    First point                       38 
;    Each additional point             39 
; 
;  Accept single point clip 
;    Minimum (single plane)            68 
;    Maximum (three planes)            94 
; 
;  Reject loop 
;    Each point                        37 
; 
;  Reject single point clip 
;    Minimum (single plane)            89 
;    Maximum (three planes)           115 
; 
;  Reject double clip line drawn 
;    Minimum (two single planes)      145 
;    Maximum (six planes)             206 
; 
;  Reject double clip line rejected 
;    Minimum (two single planes)      112 
;    Maximum (six planes)             173 
;
;The DSP96002 has an instruction cycle time of 74ns and will  transform 347K points/sec in the ac-
;cept loop.  In the reject loop,  365K points can be rejected each second.  
;INPUT  
;Before calling the polyline generator, address register r1 should  point to the area in X memory which 
;contains the X, Y and Z  coordinates of the input points.  Data register d7.l should  contain the num-
;ber of points in the polyline in the form of a  32-bit integer.  
;OUTPUT  
;Address register r5 should point to a display list data area when  the polyline generator is called.  Af-
;terwards, the display list will  be in the following format:  
;  Polygon1:  X1,Y1 
;             X2,Y2 
;             X3,Y3 
;                                       Xn,Yn 
; 
;  Delimiter  -1.0 
; 
;  Polygon2:  X1,Y1 
;             X2,Y2 
;                            Delimiter  -1.0 
;            PolygonM:  X1,Y1 
;              
;             Xn,Yn 
;             -2.0 
;
;All coordinates are in IEEE single-precision floating-point format to  speed up the DSP96002 float-
;ing-point incremental line drawing algorithm.  
;ADDRESS REGISTER USAGE  
;Four address registers are used:  
;  r0    input list 
;  r1    temporary coordinates 
;  r4    transformation matrix, scale and offset for 2D transformation 
;  r5    output list 
;  r6    miscellaneous scratchpad memory 
;
;The following memory map results:  
;                X Memory     Y Memory 
; 
;          r0   ?    Xobj0 
;          n0=0.0 Yobj0 
;                 Zobj0 
;                 Xobj1 
;                                     
;          r1 ?    Xnew         Znew 
;          n1=2   Ynew         Wnew 
;          m1=3   Xold         Zold 
;                 Yold         Wold 
; 
;          r4 ?                    Matrix1,1 
;          n4=2   Matrix4,1    Matrix2,1 
;          m4=13               Matrix3,1 
;                              Matrix1,2 
;                 Matrix4,2    Matrix2,2 
;                              Matrix3,2 
;                              Matrix1,3 
;                 Matrix4,3    Matrix2,3 
;                              Matrix3,3 
;                              Matrix1,4 
;                 Matrix4,4    Matrix2,4 
;                              Matrix3,4 
;                 Xscale       Xoffset 
;                 Yscale       Yoffset 
; 
;                              Xout0   ?  r5 
;                              Yout0     n5=-1.0 
;                              Xout1 
;                              Yout1 
;                                                             
;                 TempCount    TOld,Xtemp ? r6  (temporaries) 
;                              Ytemp 
;                              Wtemp 
;
;Several registers hold constants that speed up calculations.  These are:  
;  d8 =  1.0 for double point clipping 
;  d9 =  2.0 for division 
;  n0 =  0.0 for z limit test and double point clipping 
;  n5 = -1.0 for end of polyline marker 
;
;TRIVIAL ACCEPT LOOP  
;The transformation from object space to screen space is performed  in lines 19-33.  This is a 
;{1x4}{4x4} matrix multiplication but  because the W coordinate of the {1x4} input vector {X Y Z W} is  
;always equal to one, four multiplications can be eliminated.  
;Lines 39-47 determine if the point is within the viewing pyramid.  The FCMP s,d instruction is de-
;signed to clear the sticky accept  (A) bit (bit 7 in the CCR) whenever s > d.  By switching the order  
;of the operands, the FCMP instruction can be used to test both the  maximum and minimum bound-
;aries of a window.  To test acceptance,  the A bit is set in line 40 and the X and Y coordinates are  
;compared to the boundaries -W and W.  The Z coordinate is compared  to the boundaries 0 and W.  
;If the A bit remains set, the point is  within the viewing pyramid and is transformed to screen  coordi-
;nates.  
;If the A bit is clear, the reject loop is entered.  Note that the  A bit is only affected by the CMP, 
;CMPG, FCMP and FCMPG instructions.  
;The reciprocal 1/W is calculated in lines 53-58.  The result is  accurate to approximately 32 bits.  It is 
;multiplied by the X  coordinate and then by the X scale to scale the data to the output  screen.  The 
;coordinate is then translated to screen space.  The  procedure is repeated for the Y coordinate and 
;the coordinates  are added to the display list.  
;For additional points the accept loop code is almost identical to  the first point code except that if 
;the new point is not within  the viewing pyramid, a jump to a single point clipping routine is  per-
;formed.  
;ACCEPT LOOP SINGLE POINT CLIPPING CODE  
;The method used for clipping a line when one point is inside the  viewing pyramid and one point is 
;outside is a special case of a  general clipping algorithm presented in [1] and is used in the  double 
;point clipping code.  
;Suppose that the line between points P1 and P2 was rejected because  the x coordinate of P2, x2, 
;was larger than w2.  Then,  
;  y2 = y1 + t (y2 - y1) 
; 
;where 
; 
;  t  =         w1 - x1 
;        --------------------- 
;        (w1 - x1) - (w2 - x2) 
; 
;Substituting the value of t results in the determinant 
; 
;  y2 =   | y2  w2-y2 | 
;         | y1  w1-y1 | 
;      ------------------- 
;       (w1-x1) - (w2-x2) 
;
;The equations for z2 and w2 are analogous.  Since w2 has the same  denominator as x2, y2 and z2, 
;and these will be divided by w2 in the  perspective transformation, the division shown above does 
;not need  to be performed.  
;Lines 151-162 determine which planes that the point is outside and  call the appropriate clipping rou-
;tines.  These routines (lines 520-617)  calculate the determinants and return with the resulting coordi-
;nates in  the data registers.  
;The resulting point is transformed using the perspective  transformation, scaled and translated in 
;lines 168-186.  A code (-1.0)  is stored in the display list to indicate that the next line to be  drawn is 
;not joined with the current one.  Control is then transferred  to the trivial reject loop.  
;TRIVIAL REJECT LOOP  
;The trivial reject loop starts with the {1x4}{4x4} matrix  multiplication to transform the input point to 
;clipping space.  Next,  the line joining the current point and the previously rejected  point is tested 
;for trivial rejection.  As mentioned earlier,  trivial rejection occurs whenever both of the endpoints lie 
;outside  of one clipping plane.  
;A sticky bit called Local Reject (LR) is defined as bit 5 of the  CCR.  It is cleared by the FCMP s,d in-
;struction whenever s <= d.  In other words, the LR bit is cleared whenever the FCMP instruction  
;finds the coordinate inside of the boundary.  
;An additional instruction, FCMPG, is needed because trivial  rejection occurs when both points are 
;outside of any boundary  plane.  Thus, an additional sticky bit called Reject (R) (bit 6 of  the CCR) is 
;used to "remember" that a trivial reject has occurred  after comparisons against one boundary plane.  
;The FCMPG  instruction affects R and is performed as the last comparison to a  boundary plane.  
;When FCMPG s,d is executed, the R flag is cleared  if the previous point was outside of the bound-
;ary (LR is set) and  the current point is outside of the boundary (s > d).  The FCMPG  instruction al-
;so resets the LR bit to 1 for comparison to the next  boundary plane.  
;To perform the trivial reject test, the LR and R bits are set to 1.  The two points are tested against 
;the X = -W boundary plane and  then tested against the X = W plane etc.  The first point is tested  us-
;ing FCMP and the second point is tested using FCMPG to clear the  R bit if both comparisons were 
;outside of the boundary.  At the end  of these comparisons, if the R bit is 0, the line was trivially  re-
;jected.  With this definition, the trivial rejection test can be  generalized to a polygon with any number 
;of points.  The execution  time is of order 6N cycles where N is the number of points.  
;The lines 225-236 perform the trivial reject test.  Should the line  be trivially rejected, the new coordi-
;nates are stored for the next  comparison and the reject loop repeats.  
;If the line is not trivially rejected, a check is made to determine  if the current point is accepted.  If so, 
;control is transferred to  the reject loop single point clip routine.  Otherwise the double  point routine 
;is entered.  
;REJECT LOOP SINGLE POINT CLIPPING CODE  
;The reject loop single point clipping code is very similar to the  analogous code in the accept loop.  It 
;calls the same clipping  subroutines in lines 520-617.  Then the point that was just calculated  is trans-
;formed, scaled and translated and stored in the output list  (lines 305-321).  Finally, the new point 
;(which was accepted) is  transformed, scaled and translated (lines 327-345).  Control is  transferred 
;to the accept loop.  
;REJECT LOOP DOUBLE POINT CLIPPING CODE  
;Lines 359-492 are a direct implementation of a clipping algorithm  using endpoint coordinates given 
;in {1}.  The clipping method using  determinants is not powerful enough to handle the cases where 
;the  line is rejected but not trivially rejected.  Thus, the line  parameters t1 and t2 are calculated explic-
;itly.  The t1 parameter  is calculated based on the coordinates of the old point and the  t2 parameter 
;is calculated based on the current point.  
;These parameters are calculated by a set of double point clipping  subroutines in lines 631-853.  These 
;subroutines are called based  on the coordinates in lines 359-395.  
;The line is checked for rejection which occurs when t1 > t2.  If  the line is not rejected, the plane inter-
;sections are interpolated  based on t1 and t2 (lines 409-431).  Then the two new points are  trans-
;formed, scaled and translated in lines 437-478.  Control is  then transferred to the reject loop.  
;If the line is rejected, control is transferred to the reject loop  after some housekeeping is performed.  
;TERMINATION CODE  
;Lines 499-509 swallow the line delimiter code (-1.0) if it is the  last coordinate in the display list.  
;Then it adds the end of  display list code (-2.0) to the display list and exits.  
;REFERENCE  
;{1}  William M. Newman and Robert F. Sproull, Principles of Interactive 
;     Computer Graphics, (New York:  McGraw-Hill, 1979). 
;
; 
;; WIRE-FRAME RENDITION OF A THREE DIMENSIONAL POLYLINE 
;               ON THE MOTOROLA DSP96002 
; 
;           Version 1.00  18-Nov-88   
; 
; 
; 
;--------------------------------------------------------- 
; 
;                     First point 
; 
;--------------------------------------------------------- 
 
 
; Transform to clip space 
;                                                             	Words 	ICycles
wf3d 
  move                         x:(r0)+,d0.s                ;X       1  1 
  move                         x:(r0)+,d5.s   y:(r4)+,d4.s ;Y   M11 1  1 
  fmpy.s d4,d0,d2              x:(r4)+,d3.s   y:,d4.s      ;M41 M21 1  1 
  fmpy   d4,d5,d3 fadd.s d3,d2 x:(r0)+,d6.s   y:(r4)+,d4.s ;Z   M31 1  1 
  fmpy   d4,d6,d3 fadd.s d3,d2 x:(r1)+n1,d1.s y:(r4)+,d4.s ;r1+ M12 1  1 
  fmpy   d4,d0,d1 fadd.s d3,d2 x:(r4)+,d3.s   y:,d4.s      ;M42,M22 1  1 
  fmpy   d4,d5,d3 fadd.s d3,d1                y:(r4)+,d4.s ;    M32 1  1 
  fmpy   d4,d6,d3 fadd.s d3,d1 d2.s,x:(r1)+   y:(r4)+,d4.s ;Xo  M13 1  1 
  fmpy   d4,d0,d2 fadd.s d3,d1 x:(r4)+,d3.s   y:,d4.s      ;M43 M23 1  1 
  fmpy   d4,d5,d3 fadd.s d3,d2                y:(r4)+,d4.s ;    M33 1  1 
  fmpy   d4,d6,d3 fadd.s d3,d2 d1.s,x:(r1)-   y:(r4)+,d4.s ;Yo  M14 1  1 
  fmpy   d4,d0,d1 fadd.s d3,d2 x:(r4)+,d3.s   y:,d4.s      ;M44 M24 1  1 
  fmpy   d4,d5,d3 fadd.s d3,d1                y:(r4)+,d4.s ;    M34 1  1 
  fmpy   d4,d6,d3 fadd.s d3,d1                d2.s,y:(r1)  ;    Zo  1  1 
                  fadd.s d3,d1 x:(r1)+,d0.s                ;Xo      1  1 
 
 
; Test if point is within viewing pyramid 
 
  fneg.s d1                    d1.s,d2.s                   ;        1  1 
  ori    #$80,ccr                                          ;        1  1 
  fcmp   d1,d0                                             ;        1  1 
  fcmp   d0,d2                 x:(r1)-,d5.s                ;Yo      1  1 
  fcmp   d1,d5                 n0,d4.s                     ;        1  1 
  fcmp   d5,d2                                y:(r1)+,d6.s ;    Zo  1  1 
  fcmp   d4,d6                                             ;        1  1 
  fcmp   d6,d2                                             ;        1  1 
  jclr   #7,sr,_reject_entry                               ;        2  3 
 

; Calculate reciprocal 1/W 
 
 
  fseedd d2,d6                                             ;        1  1 
  fmpy.s d2,d6,d1              d9.s,d4.s                   ;        1  1 
                  fsub.s d1,d4 d4.s,d3.s      d2.s,y:(r1)+ ;    Wo  1  1 
  fmpy.s d1,d4,d1                                          ;        1  1 
  fmpy   d6,d4,d1 fsub.s d1,d3                             ;        1  1 
  fmpy.s d1,d3,d1              x:(r4)+,d4.s   y:,d3.s      ;Xs  Xf  1  1 
 
 
; Multiply coordinates by 1/W, scale and add offset 
 
 
  fmpy.s d0,d4,d2                                          ;        1  1 
  fmpy.s d2,d1,d2              x:(r4)+,d4.s   y:,d6.s      ;Ys  Yf  1  1 
  fmpy   d5,d4,d3 fadd.s d3,d2                             ;        1  1 
  fmpy.s d3,d1,d3                             d2.s,y:(r5)+ ;        1  1 
                  fadd.s d6,d3 x:(r0)+,d0.s                ;        1  1 
  dec    d7                                   d3.s,y:(r5)+ ;    Y1  1  1 
 
 
 
 
;--------------------------------------------------------- 
; 
;                    Accept loop 
; 
;--------------------------------------------------------- 
 
 
; Transform point to clip space 
 
 
_accept_loop 
  move                         x:(r0)+,d5.s   y:(r4)+,d4.s ;Y   M11 1  1 
  fmpy.s d4,d0,d2              x:(r4)+,d3.s   y:,d4.s      ;M41 M21 1  1 
  fmpy   d4,d5,d3 fadd.s d3,d2 x:(r0)+,d6.s   y:(r4)+,d4.s ;Z   M31 1  1 
  fmpy   d4,d6,d3 fadd.s d3,d2                y:(r4)+,d4.s ;    M12 1  1 
  fmpy   d4,d0,d1 fadd.s d3,d2 x:(r4)+,d3.s   y:,d4.s      ;M42,M22 1  1 
  fmpy   d4,d5,d3 fadd.s d3,d1                y:(r4)+,d4.s ;    M32 1  1 
  fmpy   d4,d6,d3 fadd.s d3,d1 d2.s,x:(r1)+   y:(r4)+,d4.s ;Xn  M13 1  1 
  fmpy   d4,d0,d2 fadd.s d3,d1 x:(r4)+,d3.s   y:,d4.s      ;M43 M23 1  1 
  fmpy   d4,d5,d3 fadd.s d3,d2                y:(r4)+,d4.s ;    M33 1  1 
  fmpy   d4,d6,d3 fadd.s d3,d2 d1.s,x:(r1)-   y:(r4)+,d4.s ;Yn  M14 1  1 
  fmpy   d4,d0,d1 fadd.s d3,d2 x:(r4)+,d3.s   y:,d4.s      ;M44 M24 1  1 
  fmpy   d4,d5,d3 fadd.s d3,d1                y:(r4)+,d4.s ;    M34 1  1 
  fmpy   d4,d6,d3 fadd.s d3,d1                d2.s,y:(r1)  ;    Zn  1  1 
                  fadd.s d3,d1 x:(r1)+,d0.s                ;Xn      1  1 
 

 
; Determine if point is within view volume 
 
 
  fneg.s d1                    d1.s,d2.s                   ;        1  1 
  ori    #$80,ccr                                          ;        1  1 
  fcmp   d1,d0                                d2.s,y:(r1)  ;    Wn  1  1 
  fcmp   d0,d2                 x:(r1)-,d5.s                ;Yn      1  1 
  fcmp   d1,d5                 n0,d4.s                     ;        1  1 
  fcmp   d5,d2                                y:(r1)-,d6.s ;    Zn  1  1 
  fcmp   d4,d6                 d7.l,x:(r6)                 ;        1  1 
  fcmp   d6,d2                 d6.s,d7.s                   ;        1  1 
  jclr   #7,sr,_accept_clip                                ;        2  3 
 
 
; Calculate reciprocal 1/W 
 
 
  fseedd d2,d6                                             ;        1  1 
  fmpy.s d2,d6,d1              d9.s,d4.s                   ;        1  1 
                  fsub.s d1,d4 d4.s,d3.s      d2.s,y:(r1)- ;    Wo  1  1 
  fmpy.s d1,d4,d1              d0.s,x:(r1)+   d7.s,y:      ;Xo  Zo  1  1 
  fmpy   d6,d4,d1 fsub.s d1,d3 d5.s,x:(r1)+                ;Yo      1  1 
  fmpy.s d1,d3,d1              x:(r4)+,d4.s   y:,d3.s      ;Xs  Xf  1  1 
 
 
; Multiply coordinates by 1/W, scale and add offset 
 
 
  fmpy.s d0,d4,d2                                          ;        1  1 
  fmpy.s d2,d1,d2              x:(r4)+,d4.s   y:,d6.s      ;Ys  Yf  1  1 
  fmpy   d5,d4,d3 fadd.s d3,d2 x:(r6),d7.l                 ;        1  1 
  fmpy.s d3,d1,d3                             d2.s,y:(r5)+ ;        1  1 
                  fadd.s d6,d3 x:(r0)+,d0.s                ;        1  1 
  dec    d7                                   d3.s,y:(r5)+ ;    Y1  1  1 
  jne    _accept_loop                                      ;        2  2 
  jmp    _end                                              ;        2  2 
 

;--------------------------------------------------------- 
; 
;            Accept loop single-clip routine 
; 
;--------------------------------------------------------- 
 
 
; Dispatch to single-plane clipping routines 
 
 
_accept_clip 
  fsub.s d0,d2                 d2.s,d1.s                   ;        1  1 
  fjslt  _clip1_xp                                         ;        2  2 
  fadd.s d0,d1                 d1.s,d2.s                   ;        1  1 
  fjslt  _clip1_xn                                         ;        2  2 
  fsub.s d5,d2                 d2.s,d1.s                   ;        1  1 
  fjslt  _clip1_yp                                         ;        2  2 
  fadd.s d5,d1                 d1.s,d2.s                   ;        1  1 
  fjslt  _clip1_yn                                         ;        2  2 
  fsub.s d6,d2                 d2.s,d1.s                   ;        1  1 
  fjslt  _clip1_zp                                         ;        2  2 
  ftst   d6                                                ;        1  1 
  fjslt  _clip1_zn                                         ;        2  2 
 
 
; Calculate reciprocal 1/W 
 
 
  fseedd d1,d6                                             ;        1  1 
  fmpy.s d1,d6,d1              d9.s,d4.s                   ;        1  1 
                  fsub.s d1,d4 d4.s,d3.s      y:(r1)+n1,d2.s ; r1+2 1  1 
  fmpy.s d1,d4,d1              x:(r1)+n1,d2.s y:,d7.s      ;Yn  Wn  1  1 
  fmpy   d6,d4,d1 fsub.s d1,d3 d2.s,x:(r1)+   d7.s,y:      ;Yo  Wo  1  1 
  fmpy.s d1,d3,d1              x:(r4)+,d4.s   y:,d3.s      ;Xs  Xf  1  1 
 
 
; Multiply coordinates by 1/W, scale and add offset 
 
  fmpy.s d0,d4,d2              x:(r1)+n1,d0.s y:,d7.s      ;Xn  Zn  1  1 
  fmpy.s d2,d1,d2              x:(r4)+,d4.s   y:,d6.s      ;Ys  Yf  1  1 
  fmpy   d5,d4,d3 fadd.s d3,d2 d0.s,x:(r1)+n1 d7.s,y:      ;Xo  Zo  1  1 
  fmpy.s d3,d1,d3              x:(r6),d7.l                 ;Cnt     1  1 
                  fadd.s d6,d3 x:(r0)+,d0.s   d2.s,y:(r5)+ ;X       1  1 
  move                                        d3.s,y:(r5)+ ;    Y1  1  1 
  dec    d7                                   n5,y:(r5)+   ;   -1.0 1  1 
  jne    _reject_loop                                      ;        2  2 
  jmp    _end                                              ;        2  2 

;--------------------------------------------------------- 
; 
;                    Reject loop 
; 
;--------------------------------------------------------- 
 
 
; Transform point to clip space 
 
_reject_entry 
  dec    d7                                   d2.s,y:(r1)+ ;    Wo  1  1 
  move                         x:(r0)+,d0.s  y:(r4)+n4,d4.s ;X r4+2 1  1 
 
_reject_loop 
  move                         x:(r0)+,d5.s  y:(r4)+,d4.s  ;Y   M11 1  1 
  fmpy.s d4,d0,d2              x:(r4)+,d3.s  y:,d4.s       ;M41 M21 1  1 
  fmpy   d4,d5,d3 fadd.s d3,d2 x:(r0)+,d6.s  y:(r4)+,d4.s  ;    M31 1  1 
  fmpy   d4,d6,d3 fadd.s d3,d2               y:(r4)+,d4.s  ;    M12 1  1 
  fmpy   d4,d0,d1 fadd.s d3,d2 x:(r4)+,d3.s  y:,d4.s       ;M42 M22 1  1 
  fmpy   d4,d5,d3 fadd.s d3,d1               y:(r4)+,d4.s  ;    M32 1  1 
  fmpy   d4,d6,d3 fadd.s d3,d1 d2.s,x:(r1)+  y:(r4)+,d4.s  ;Xn  M13 1  1 
  fmpy   d4,d0,d2 fadd.s d3,d1 x:(r4)+,d3.s  y:,d4.s       ;M43 M23 1  1 
  fmpy   d4,d5,d3 fadd.s d3,d2               y:(r4)+,d4.s  ;    M33 1  1 
  fmpy   d4,d6,d3 fadd.s d3,d2 d1.s,x:(r1)-  y:(r4)+,d4.s  ;Yn  M14 1  1 
  fmpy   d4,d0,d1 fadd.s d3,d2 x:(r4)+,d3.s  y:,d4.s       ;M44 M24 1  1 
  fmpy   d4,d5,d3 fadd.s d3,d1               y:(r4)+,d4.s  ;    M34 1  1 
  fmpy   d4,d6,d3 fadd.s d3,d1               d2.s,y:(r1)-  ;    Zn  1  1 
                  fadd.s d3,d1                             ;        1  1 
 
 
; Determine trivial rejection 
 
  ori    #$e0,ccr                                          ;        1  1 
  fneg.s d1                    d1.s,d5.s      y:(r1)-,d2.s ;    Wo  1  1 
  fneg.s d2                    x:(r1)+n1,d6.s d2.s,d4.s    ;Xo      1  1 
  fcmp   d2,d6                 x:(r1)-,d0.s                ;Xn      1  1 
  fcmpg  d1,d0                 (r4)+n4                     ;r4+2    1  1 
  fcmp   d6,d4                                             ;        1  1 
  fcmpg  d0,d5                 x:(r1)+n1,d6.s              ;Yo      1  1 
  fcmp   d2,d6                 x:(r1)+,d3.s                ;Yn      1  1 
  fcmpg  d1,d3                                             ;        1  1 
  fcmp   d6,d4                                             ;        1  1 
  fcmpg  d3,d5                              y:(r1)+n1,d6.s ;Zo      1  1 
  fcmp   d6,d4                              y:(r1)+n1,d2.s ;Zn      1  1 
  fcmpg  d2,d5                 n0,d4.s                     ;        1  1 
  fcmp   d4,d6                                             ;        1  1 
  fcmpg  d4,d2                                             ;        1  1 
  jset   #6,sr,_reject_clip                                ;        2  3 

; Save new point 
 
  move                         d0.s,x:(r1)+   d2.s,y:      ;Xo Zo   1  1 
  move                         d3.s,x:(r1)+   d5.s,y:      ;Yo Wo   1  1 
  dec    d7                    x:(r0)+,d0.s                ;X       1  1 
  jne    _reject_loop                                      ;        2  2 
  jmp    _end                                              ;        2  2 
 
 
;--------------------------------------------------------- 
; 
;             Reject loop clipping routine 
; 
;--------------------------------------------------------- 
 
; Determine if new point is within view volume 
 
_reject_clip 
  ori     #$80,ccr                                         ;        1  1 
  fcmp    d1,d0                (r1)-                       ;r1-     1  1 
  fcmp    d1,d3                               d5.s,y:(r1)+ ;    Wn  1  1 
  fcmp    d4,d2                                            ;        1  1 
  fcmp    d0,d5                                            ;        1  1 
  fcmp    d3,d5                                            ;        1  1 
  fcmp    d2,d5                                            ;        1  1 
  jclr    #7,sr,_r_clip2                                   ;        2  3 
 
 
;--------------------------------------------------------- 
; 
;            Reject loop single-clip routine 
; 
;--------------------------------------------------------- 
 
; Dispatch to clipping routines 
 
  move                         x:(r1)+,d0.s   y:,d6.s      ;Xo  Zo  1  1 
  move                         x:(r1)+n1,d5.s y:,d2.s      ;Yo  Wo  1  1 
  move                         d7.l,x:(r6)                 ;Cnt     1  1 
  fsub.s d0,d2                 d2.s,d1.s                   ;        1  1 
  fjslt  _clip1_xp                                         ;        2  2 
  fadd.s d0,d1                 d1.s,d2.s                   ;        1  1 
  fjslt  _clip1_xn                                         ;        2  2 
  fsub.s d5,d2                 d2.s,d1.s                   ;        1  1 
  fjslt  _clip1_yp                                         ;        2  2 
  fadd.s d5,d1                 d1.s,d2.s                   ;        1  1 
  fjslt  _clip1_yn                                         ;        2  2 
  fsub.s d6,d2                 d2.s,d1.s                   ;        1  1 
  fjslt  _clip1_zp                                         ;        2  2 
  ftst   d6                                                ;        1  1 
  fjslt  _clip1_zn                                         ;        2  2 

; Calculate reciprocal 1/W (old point) 
 
 
  fseedd d1,d6                                             ;        1  1 
  fmpy.s d1,d6,d1              d9.s,d4.s                   ;        1  1 
                  fsub.s d1,d4                d4.s,d3.s    ;        1  1 
  fmpy.s d1,d4,d1                             (r4)-n4      ;   r4-2 1  1 
  fmpy   d6,d4,d1 fsub.s d1,d3                             ;        1  1 
  fmpy.s d1,d3,d1              x:(r4)+,d4.s   y:,d3.s      ;Xs  Xf  1  1 
 
 
; Multiply coordinates by 1/W, scale and add offset (old point) 
 
 
  fmpy.s d0,d4,d2                                          ;        1  1 
  fmpy.s d2,d1,d2              x:(r4)-,d4.s y:,d6.s        ;Ys  Yf  1  1 
  fmpy   d5,d4,d3 fadd.s d3,d2                             ;        1  1 
  fmpy.s d3,d1,d3                           d2.s,y:(r5)+   ;    X1  1  1 
                  fadd.s d6,d3              y:(r1)+n1,d2.s ;    Wn  1  1 
  move                                      d3.s,y:(r5)+   ;    Y1  1  1 
 
 
; Calculate reciprocal 1/W (new point) 
 
 
  fseedd d2,d6                                             ;        1  1 
  fmpy.s d2,d6,d1              d9.s,d4.s                   ;        1  1 
                  fsub.s d1,d4 d4.s,d3.s      d2.s,y:(r1)+ ;    Wo  1  1 
  fmpy.s d1,d4,d1              x:(r1)+n1,d0.s y:,d2.s      ;Xn  Zn  1  1 
  fmpy   d6,d4,d1 fsub.s d1,d3 d0.s,x:(r1)-   d2.s,y:      ;Xo  Zo  1  1 
  fmpy.s d1,d3,d1              x:(r4)+,d4.s   y:,d3.s      ;Xs  Xf  1  1 
 
 
; Multiply coordinates by 1/W, scale and add offset (new point) 
 
 
  fmpy.s d0,d4,d2              x:(r1)+n1,d5.s              ;Yn      1  1 
  fmpy.s d2,d1,d2              x:(r4)+,d4.s   y:,d6.s      ;Ys  Yf  1  1 
  fmpy   d5,d4,d0 fadd.s d3,d2 d5.s,x:(r1)+                ;Yo      1  1 
  fmpy.s d0,d1,d5              x:(r0)+,d0.s   d2.s,y:(r5)+ ;X   X1  1  1 
                  fadd.s d5,d3 x:(r6),d7.l                 ;Cnt     1  1 
  dec    d7                                   d3.s,y:(r5)+ ;    Y1  1  1 
  jne    _accept_loop                                      ;        2  2 
  jmp    _end                                              ;        2  2 
 

;--------------------------------------------------------- 
; 
;            Double point clipping routine 
; 
;--------------------------------------------------------- 
 
 
; Dispatch to old point clipping routines 
 
 
_r_clip2 
  move                         d7.l,x:(r6)    y:(r1)+,d1.l ;Cnt r1+ 1  1 
  move                                        y:(r1)-,d1.s ;    Wo  1  1 
  move                         x:(r1)+,d5.s                ;Xo      1  1 
  move                         n0,d7.s                     ;        1  1 
                  fsub.s d1,d5 d5.s,d6.s                   ;        1  1 
  fjsgt  _clip2_xop                                        ;        2  2 
                  fadd.s d1,d6 x:(r1)-,d5.s                ;Yo      1  1 
  fjslt  _clip2_xon                                        ;        2  2 
                  fsub.s d1,d5 d5.s,d6.s                   ;        1  1 
  fjsgt  _clip2_yop                                        ;        2  2 
                  fadd.s d1,d6              y:(r1)+n1,d5.s ;Zo      1  1 
  fjslt  _clip2_yon                                        ;        2  2 
                  fsub.s d1,d5 d5.s,d6.s                   ;        1  1 
  fjsgt  _clip2_zop                                        ;        2  2 
  ftst   d6                    x:(r1)+,d5.s                ;Xn      1  1 
  fjslt  _clip2_zon                                        ;        2  2 
  move                                      d7.s,y:(r6)    ;    to  1  1 
 
 
; Dispatch to new point clipping routines 
 
 
  move                                      y:(r1),d1.s    ;    Wn  1  1 
  move                         d8.s,d7.s                   ;    tn  1  1 
                  fsub.s d1,d5 d5.s,d6.s                   ;        1  1 
  fjsgt  _clip2_xnp                                        ;        2  2 
                  fadd.s d1,d6 x:(r1)-,d5.s                ;Yn      1  1 
  fjslt  _clip2_xnn                                        ;        2  2 
                  fsub.s d1,d5 d5.s,d6.s                   ;        1  1 
  fjsgt  _clip2_ynp                                        ;        2  2 
                  fadd.s d1,d6              y:(r1)+n1,d5.s ;Zn      1  1 
  fjslt  _clip2_ynn                                        ;        2  2 
                  fsub.s d1,d5 d5.s,d6.s                   ;        1  1 
  fjsgt  _clip2_znp                                        ;        2  2 
  ftst   d6                                                ;        1  1 
  fjslt  _clip2_znn                                        ;        2  2 

; Check for rejection 
 
 
  move                         x:(r1)+n1,d3.s y:(r6),d5.s  ;Xo  to  1  1 
  fcmp   d5,d7                 d7.s,d4.s                   ;        1  1 
  fjlt   _clip2_reject                                     ;        2  2 
 
 
; Calculate end point coordinates: X 
 
 
  move                         x:(r1)+n1,d6.s              ;Xn      1  1 
                  fsub.s d3,d6 d6.s,x:(r1)-                ;Xo      1  1 
  fmpy.s d4,d6,d1                                          ;        1  1 
  fmpy   d5,d6,d2 fadd.s d3,d1 x:(r1)+n1,d6.s              ;Yn      1  1 
                  fadd.s d3,d2 x:(r1),d3.s                 ;Yo      1  1 
 
 
; Calculate end point coordinates: Y 
 
 
                  fsub.s d3,d6 d6.s,x:(r1)+n1 d1.s,y:(r6)+ ;Yo  Xnd 1  1 
  fmpy.s d4,d6,d1              d2.s,d0.s                   ;        1  1 
  fmpy   d5,d6,d2 fadd.s d3,d1              y:(r1)+n1,d6.s ;    Wn  1  1 
                  fadd.s d3,d2              y:(r1)+n1,d3.s ;    Wo  1  1 
 
 
; Calculate end point coordinates: W 
 
 
                  fsub.s d3,d6              d1.s,y:(r6)+   ;Ynd     1  1 
  fmpy.s d4,d6,d1              d2.s,d7.s    y:(r1)+n1,d4.s ;    Wn  1  1 
  fmpy   d5,d6,d2 fadd.s d3,d1              d4.s,y:(r1)+   ;    Wo  1  1 
                  fadd.s d3,d2              d1.s,y:(r6)    ;Wnd     1  1 
 
 
; Calculate reciprocal 1/W (old point) 
 
 
  fseedd d2,d6                                             ;        1  1 
  fmpy.s d2,d6,d1              d9.s,d4.s                   ;        1  1 
                  fsub.s d1,d4 d4.s,d3.s                   ;        1  1 
  fmpy.s d1,d4,d1                             (r4)-n4      ;   r4-2 1  1 
  fmpy   d6,d4,d1 fsub.s d1,d3                             ;        1  1 
  fmpy.s d1,d3,d1              x:(r4)+,d4.s   y:,d3.s      ;Xs  Xf  1  1 
 

 
; Multiply coordinates by 1/W, scale and add offset (old point) 
 
 
  fmpy.s d0,d4,d2                                          ;        1  1 
  fmpy.s d2,d1,d2              x:(r4)-,d4.s y:,d6.s        ;Ys  Yf  1  1 
  fmpy   d7,d4,d3 fadd.s d3,d2              y:(r1)+n1,d4.s ;    Zn  1  1 
  fmpy.s d3,d1,d3                           d4.s,y:(r1)+n1 ;    Zo  1  1 
                  fadd.s d6,d3              d2.s,y:(r5)+   ;    X1  1  1 
  move                                      y:(r6)-,d1.s   ;    Wnd 1  1 
  move                                      d3.s,y:(r5)+   ;    Y1  1  1 
 
 
; Calculate reciprocal 1/W (new point) 
 
 
  fseedd d1,d6                                             ;        1  1 
  fmpy.s d1,d6,d1              d9.s,d4.s                   ;        1  1 
                  fsub.s d1,d4 d4.s,d3.s     y:(r6)-,d5.s  ;    Ynd 1  1 
  fmpy.s d1,d4,d1                            y:(r6),d0.s   ;    Xnd 1  1 
  fmpy   d6,d4,d1 fsub.s d1,d3                             ;        1  1 
  fmpy.s d1,d3,d1              x:(r4)+,d4.s  y:,d3.s       ;Xs  Xf  1  1 
 
 
; Multiply coordinates by 1/W, scale and add offset (old point) 
 
 
  fmpy.s d0,d4,d2                                          ;        1  1 
  fmpy.s d2,d1,d2              x:(r4)+,d4.s   y:,d6.s      ;Ys  Yf  1  1 
  fmpy   d5,d4,d3 fadd.s d3,d2                             ;        1  1 
  fmpy.s d3,d1,d3              x:(r6),d7.l                 ;        1  1 
                  fadd.s d6,d3 x:(r0)+,d0.s   d2.s,y:(r5)+ ;X   X1  1  1 
  move                                        d3.s,y:(r5)+ ;    Y1  1  1 
  dec    d7                                   n5,y:(r5)+   ;   -1.0 1  1 
  jne    _reject_loop                                      ;        2  2 
  jmp    _end                                              ;        2  2 
 
 

; Reject double-clipped line 
 
_clip2_reject 
  move                         x:(r6),d7.l                 ;        1  1 
  move                         x:(r1)+n1,d0.s y:,d1.s      ;Xn  Zn  1  1 
  move                         d0.s,x:(r1)-   d1.s,y:      ;Xo  Zo  1  1 
  move                         x:(r1)+n1,d0.s y:,d1.s      ;Yn  Wn  1  1 
  move                         d0.s,x:(r1)+   d1.s,y:      ;Yo  Wo  1  1 
  dec    d7                    x:(r0)+,d0.s                ;        1  1 
  jne    _reject_loop                                      ;        2  2 
 
 
; Terminate endpoint list and exit 
 
_end 
  move                         n5,d0.s                     ;-1.0    1  1 
  move                         (r5)-                       ;        1  1 
  move                                        y:(r5),d1.s  ;        1  1 
  fcmp   d0,d1                                             ;        1  1 
  fjeq  _end1                                              ;        2  2 
  move                         (r5)+                       ;        1  1 
 
_end1 
  move                         #-2.0,d0.s                  ;        2  2 
  move                                        d0.s,y:(r5)+ ;        1  1 
  rts                                                      ;        2  2 
 
 
;--------------------------------------------------------- 
; 
;            Single point clipping routines 
; 
;--------------------------------------------------------- 
 
; x = w boundary 
 
_clip1_xp 
  move                                        y:(r1)-,d4.s ;W1      1  1 
  fmpy.s d2,d4,d3              x:(r1)+,d0.s   d2.s,d7.s    ;X1      1  1 
                  fsub.s d0,d4 x:(r1)-,d0.s                ;Y1      1  1 
  fmpy.s d1,d4,d1                                          ;        1  1 
  fmpy   d4,d5,d2 fsub.s d3,d1 d0.s,d5.s                   ;        1  1 
  fmpy.s d5,d7,d3                                          ;        1  1 
  fmpy   d4,d6,d3 fsub.s d3,d2                y:(r1)+,d4.s ;Z1      1  1 
  fmpy.s d4,d7,d2              d2.s,d5.s                   ;        1  1 
                  fsub.s d2,d3 d1.s,d0.s                   ;        1  1 
  move                         d3.s,d6.s                   ;        1  1 
  rts                                                      ;        2  2 

 
; x = -w boundary 
 
 
_clip1_xn 
  move                                        y:(r1)-,d4.s ;W1      1  1 
  fmpy.s d1,d4,d3              x:(r1)+,d0.s   d1.s,d7.s    ;X1      1  1 
                  fadd.s d0,d4 x:(r1)-,d0.s                ;Y1      1  1 
  fmpy.s d2,d4,d2                                          ;        1  1 
  fmpy   d4,d5,d1 fsub.s d3,d2 d0.s,d5.s                   ;        1  1 
  fmpy.s d5,d7,d3                                          ;        1  1 
  fmpy   d4,d6,d3 fsub.s d3,d1                y:(r1)+,d4.s ;Z1      1  1 
  fmpy.s d4,d7,d1              d1.s,d5.s                   ;        1  1 
                  fsub.s d1,d3 d2.s,d0.s                   ;        1  1 
  fneg.s d0                    d3.s,d6.s                   ;        1  1 
  rts                                                      ;        2  2 
 
 
; y = w boundary 
 
 
_clip1_yp 
  move                                        y:(r1),d4.s  ;W1      1  1 
  fmpy.s d2,d4,d3              x:(r1)-,d5.s   d2.s,d7.s    ;Y1      1  1 
                  fsub.s d5,d4 x:(r1),d5.s                 ;X1      1  1 
  fmpy.s d1,d4,d1                                          ;        1  1 
  fmpy   d0,d4,d2 fsub.s d3,d1                             ;        1  1 
  fmpy.s d5,d7,d3                                          ;        1  1 
  fmpy   d4,d6,d3 fsub.s d3,d2                y:(r1)+,d4.s ;Z1      1  1 
  fmpy.s d4,d7,d2              d2.s,d0.s                   ;        1  1 
                  fsub.s d2,d3 d1.s,d5.s                   ;        1  1 
  move                         d3.s,d6.s                   ;        1  1 
  rts                                                      ;        2  2 
 
 
; y = -w boundary 
 
 
_clip1_yn 
  move                                        y:(r1),d4.s  ;W1      1  1 
  fmpy.s d1,d4,d3              x:(r1)-,d5.s   d1.s,d7.s    ;Y1      1  1 
                  fadd.s d5,d4 x:(r1),d5.s                 ;X1      1  1 
  fmpy.s d2,d4,d2                                          ;        1  1 
  fmpy   d0,d4,d1 fsub.s d3,d2                             ;        1  1 
  fmpy.s d5,d7,d3                                          ;        1  1 
  fmpy   d4,d6,d3 fsub.s d3,d1                y:(r1)+,d4.s ;Z1      1  1 
  fmpy.s d4,d7,d1              d1.s,d0.s                   ;        1  1 
                  fsub.s d1,d3 d2.s,d5.s                   ;        1  1 
  fneg.s d5                    d3.s,d6.s                   ;        1  1 
  rts                                                      ;        2  2 

 
; Clip at z = w boundary 
 
 
_clip1_zp 
  move                                        y:(r1)-,d4.s ;W1      1  1 
  fmpy.s d2,d4,d3              d2.s,d7.s      y:(r1),d6.s  ;Z1      1  1 
                  fsub.s d6,d4 x:(r1)+,d6.s                ;X1      1  1 
  fmpy.s d1,d4,d1                                          ;        1  1 
  fmpy   d0,d4,d2 fsub.s d3,d1                             ;        1  1 
  fmpy.s d6,d7,d3                                          ;        1  1 
  fmpy   d4,d5,d3 fsub.s d3,d2 x:(r1),d4.s                 ;Y1      1  1 
  fmpy.s d4,d7,d2              d2.s,d0.s                   ;        1  1 
                  fsub.s d2,d3 d1.s,d6.s                   ;        1  1 
  move                         d3.s,d5.s                   ;        1  1 
  rts                                                      ;        2  2 
 
 
; Clip at z = 0 boundary 
 
 
_clip1_zn 
  move                                        y:(r1)-,d2.s ;W1      1  1 
  fmpy.s d2,d6,d2                             y:(r1),d4.s  ;Z1      1  1 
  fmpy.s d1,d4,d1              x:(r1)+,d7.s                ;X1      1  1 
  fmpy   d0,d4,d2 fsub.s d2,d1                             ;        1  1 
  fmpy.s d6,d7,d0              x:(r1),d7.s                 ;Y1      1  1 
  fmpy   d6,d7,d3 fsub.s d0,d2                             ;        1  1 
  fmpy.s d4,d5,d5              d2.s,d0.s                   ;        1  1 
                  fsub.s d3,d5 n0,d6.s                     ;        1  1 
  rts                                                      ;        2  2 
 
 

;--------------------------------------------------------- 
; 
;             Double point clipping routines 
; 
;--------------------------------------------------------- 
 
 
; XOld = WOld boundary 
 
 
_clip2_xop 
  move                         (r1)+n1                     ;        1  1 
  move                                        y:(r1)-,d3.s ;Wn      1  1 
                  fadd.s d3,d5 x:(r1)-,d3.s   d5.s,d0.s    ;Xn      1  1 
                  fsub.s d3,d5                             ;        1  1 
  fseedd d5,d4                                             ;        1  1 
  fmpy.s d5,d4,d5              d9.s,d2.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d5,d2 d2.s,d3.s                   ;        1  1 
  fmpy.s d5,d2,d5              d2.s,d4.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d5,d3                             ;        1  1 
  fmpy.s d0,d3,d0                                          ;        1  1 
  fcmp   d7,d0                                             ;        1  1 
  ftfr.s d0,d7    ffgt                                     ;        1  1 
  rts                                                      ;        2  2 
 
 
; XOld = -WOld boundary 
 
 
_clip2_xon 
  move                         (r1)-                       ;        1  1 
  move                                        y:(r1)-,d3.s ;Wn      1  1 
                  fsub.s d3,d6 x:(r1)+n1,d3.s d6.s,d0.s    ;Xn      1  1 
                  fsub.s d3,d6                             ;        1  1 
  fseedd d6,d4                                             ;        1  1 
  fmpy.s d6,d4,d6              d9.s,d2.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d6,d2 d2.s,d3.s                   ;        1  1 
  fmpy.s d6,d2,d6              d2.s,d4.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d6,d3                             ;        1  1 
  fmpy.s d0,d3,d0                                          ;        1  1 
  fcmp   d7,d0                                             ;        1  1 
  ftfr.s d0,d7    ffgt                                     ;        1  1 
  rts                                                      ;        2  2 

 
; YOld = WOld boundary 
 
 
_clip2_yop 
  move                         (r1)-                       ;        1  1 
  move                                        y:(r1),d3.s  ;Wn      1  1 
                  fadd.s d3,d5 x:(r1)+,d3.s   d5.s,d0.s    ;Yn      1  1 
                  fsub.s d3,d5                             ;        1  1 
  fseedd d5,d4                                             ;        1  1 
  fmpy.s d5,d4,d5              d9.s,d2.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d5,d2 d2.s,d3.s                   ;        1  1 
  fmpy.s d5,d2,d5              d2.s,d4.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d5,d3                             ;        1  1 
  fmpy.s d0,d3,d0                                          ;        1  1 
  fcmp   d7,d0                                             ;        1  1 
  ftfr.s d0,d7    ffgt                                     ;        1  1 
  rts                                                      ;        2  2 
 
 
; YOld = -WOld boundary 
 
 
_clip2_yon 
  move                         (r1)+                       ;        1  1 
  move                                        y:(r1),d3.s  ;Wn      1  1 
                  fsub.s d3,d6 x:(r1)-,d3.s   d6.s,d0.s    ;Yn      1  1 
                  fsub.s d3,d6                             ;        1  1 
  fseedd d6,d4                                             ;        1  1 
  fmpy.s d6,d4,d6              d9.s,d2.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d6,d2 d2.s,d3.s                   ;        1  1 
  fmpy.s d6,d2,d6              d2.s,d4.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d6,d3                             ;        1  1 
  fmpy.s d0,d3,d0                                          ;        1  1 
  fcmp   d7,d0                                             ;        1  1 
  ftfr.s d0,d7    ffgt                                     ;        1  1 
  rts                                                      ;        2  2 
 
 

; ZOld = WOld boundary 
 
_clip2_zop 
  move                         (r1)+                       ;        1  1 
  move                                        y:(r1)-,d3.s ;Wn      1  1 
                  fadd.s d3,d5 d5.s,d0.s      y:(r1),d3.s  ;Zn      1  1 
                  fsub.s d3,d5                             ;        1  1 
  fseedd d5,d4                                             ;        1  1 
  fmpy.s d5,d4,d5              d9.s,d2.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d5,d2 d2.s,d3.s                   ;        1  1 
  fmpy.s d5,d2,d5              d2.s,d4.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d5,d3                             ;        1  1 
  fmpy.s d0,d3,d0                                          ;        1  1 
  fcmp   d7,d0                                             ;        1  1 
  ftfr.s d0,d7    ffgt                                     ;        1  1 
  rts                                                      ;        2  2 
 
 
; ZOld = 0 boundary 
 
_clip2_zon 
  move                         (r1)-                       ;        1  1 
  move                                        y:(r1)+,d3.s ;Zn      1  1 
                  fsub.s d3,d6 d6.s,d0.s                   ;        1  1 
  fseedd d6,d4                                             ;        1  1 
  fmpy.s d6,d4,d6              d9.s,d2.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d6,d2 d2.s,d3.s                   ;        1  1 
  fmpy.s d6,d2,d6              d2.s,d4.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d6,d3                             ;        1  1 
  fmpy.s d0,d3,d0                                          ;        1  1 
  fcmp   d7,d0                                             ;        1  1 
  ftfr.s d0,d7    ffgt                                     ;        1  1 
  rts                                                      ;        2  2 
 
 
; XNew = WNew boundary 
 
_clip2_xnp 
  move                         (r1)+n1                     ;        1  1 
  move                                        y:(r1)-,d0.s ;Wo      1  1 
  move                         x:(r1)-,d2.s                ;Xo      1  1 
                  fsub.s d2,d0                             ;        1  1 
                  fadd.s d0,d5                             ;        1  1 
  fseedd d5,d4                                             ;        1  1 
  fmpy.s d5,d4,d5              d9.s,d2.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d5,d2 d2.s,d3.s                   ;        1  1 
  fmpy.s d5,d2,d5              d2.s,d4.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d5,d3                             ;        1  1 
  fmpy.s d0,d3,d0                                          ;        1  1 
  fcmp   d7,d0                                             ;        1  1 
  ftfr.s d0,d7    fflt                                     ;        1  1 
  rts                                                      ;        2  2 

; XNew = -WNew boundary 
 
_clip2_xnn 
  move                         (r1)-                       ;        1  1 
  move                                        y:(r1)-,d3.s ;Wo      1  1 
  move                         x:(r1)+n1,d2.s              ;Xo      1  1 
                  fadd.s d3,d2                             ;        1  1 
                  fsub.s d6,d2 d2.s,d0.s                   ;        1  1 
  fseedd d2,d4                                             ;        1  1 
  fmpy.s d2,d4,d6              d9.s,d2.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d6,d2 d2.s,d3.s                   ;        1  1 
  fmpy.s d6,d2,d6              d2.s,d4.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d6,d3                             ;        1  1 
  fmpy.s d0,d3,d0                                          ;        1  1 
  fcmp   d7,d0                                             ;        1  1 
  ftfr.s d0,d7    fflt                                     ;        1  1 
  rts                                                      ;        2  2 
 
 
; YNew = WNew boundary 
 
_clip2_ynp 
  move                         (r1)-                       ;        1  1 
  move                         x:(r1)+,d2.s   y:,d0.s      ;Yo  Wo  1  1 
                  fsub.s d2,d0                             ;        1  1 
                  fadd.s d0,d5                             ;        1  1 
  fseedd d5,d4                                             ;        1  1 
  fmpy.s d5,d4,d5              d9.s,d2.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d5,d2 d2.s,d3.s                   ;        1  1 
  fmpy.s d5,d2,d5              d2.s,d4.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d5,d3                             ;        1  1 
  fmpy.s d0,d3,d0                                          ;        1  1 
  fcmp   d7,d0                                             ;        1  1 
  ftfr.s d0,d7    fflt                                     ;        1  1 
  rts                                                      ;        2  2 
 
 
; YNew = -WNew boundary 
 
_clip2_ynn 
  move                         (r1)+                       ;        1  1 
  move                         x:(r1)-,d2.s   y:,d3.s      ;Yo  Wo  1  1 
                  fadd.s d3,d2                             ;        1  1 
                  fsub.s d6,d2 d2.s,d0.s                   ;        1  1 
  fseedd d2,d4                                             ;        1  1 
  fmpy.s d2,d4,d6              d9.s,d2.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d6,d2 d2.s,d3.s                   ;        1  1 
  fmpy.s d6,d2,d6              d2.s,d4.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d6,d3                             ;        1  1 
  fmpy.s d0,d3,d0                                          ;        1  1 
  fcmp   d7,d0                                             ;        1  1 
  ftfr.s d0,d7    fflt                                     ;        1  1 
  rts                                                      ;        2  2 

; ZNew = WNew boundary 
 
 
_clip2_znp 
  move                         (r1)+                       ;        1  1 
  move                                        y:(r1)-,d0.s ;Wo      1  1 
  move                                        y:(r1),d2.s  ;Zo      1  1 
                  fsub.s d2,d0                             ;        1  1 
                  fadd.s d0,d5                             ;        1  1 
  fseedd d5,d4                                             ;        1  1 
  fmpy.s d5,d4,d5              d9.s,d2.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d5,d2 d2.s,d3.s                   ;        1  1 
  fmpy.s d5,d2,d5              d2.s,d4.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d5,d3                             ;        1  1 
  fmpy.s d0,d3,d0                                          ;        1  1 
  fcmp   d7,d0                                             ;        1  1 
  ftfr.s d0,d7    fflt                                     ;        1  1 
  rts                                                      ;        2  2 
 
 
; ZNew = 0 boundary 
 
 
_clip2_znn 
  move                         d6.s,d0.s      y:(r1),d6.s  ;Zo      1  1 
                  fsub.s d0,d6 d6.s,d0.s                   ;        1  1 
  fseedd d6,d4                                             ;        1  1 
  fmpy.s d6,d4,d6              d9.s,d2.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d6,d2 d2.s,d3.s                   ;        1  1 
  fmpy.s d6,d2,d6              d2.s,d4.s                   ;        1  1 
  fmpy   d0,d4,d0 fsub.s d6,d3                             ;        1  1 
  fmpy.s d0,d3,d0                                          ;        1  1 
  fcmp   d7,d0                                             ;        1  1 
  ftfr.s d0,d7    fflt                                     ;        1  1 
  rts                                                      ;        2  2 
