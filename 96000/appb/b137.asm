; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.37	Bezier Cubic Polynomial Evaluation  
;Bezier polynomials are used to represent curves and surfaces in  graphics.  The Bezier form requires 
;four points: two endpoints and  two points other points.  The four points define (in two dimen-
;sions)  a convex polygon.  The curve is bounded by the edges of the polygon.  
;A typical application of the Bezier cubic is generating character  fonts for laser printers using the 
;postscript notation.  
;Given the four sets of points, the cubic equation for the X  coordinate is:  
;x(t)=(P1x)*(1-t)**3 + (P2x)*3*t*(t-1)**2 + (P3x)*3*t*t*(1-t) + (P4x)t**3 
; 
;where: 
;    P1x = x coordinate of an endpoint 
;    P2x = a point used for defining the convex polygon 
;    P3x = a point used for defining the convex polygon 
;    P4x = x coordinate of an endpoint 
;    0.0 <= t <= 1.0 

;As t varies from zero to one, the x coordinate moves along the cubic  from one endpoint to the oth-
;er.  
;With a little inspiration, the equation can be factored as:  
;x(t)=-(t-1)**3*(P1X) + 3t(t-1)**2*(P2x) - 3t*t(1-t)*(P3x) + t**3*(P4x) 
;x(t)=(t-1)(-(t-1)**2*(P1x)+3t{(t-1)*(P2x)-t*(P3x)}) + t**3*(P4x) 
;
;Memory Map:               X	Y 
;             r4 ?  t                   1.0 
;                                       3.0 
; 
;                   P1x 
;                   P2x 
;             r0 ? P3x 
;                   P4x 
; 
;The P coefficients are accessed in the order: P3x,P2x,P1x,P4x. 
; 
;              Bezier Cubic Evaluation                   	Program	ICycles 
;                                                        	Words 
  move   #Ptable+2,r0 
  move   #2,n0 
  move   #TK,r4 
 
  move                          x:(r0)-,d4.s             ; 1        1 
  move                          x:(r4)+,d0.s y:,d5.s     ; 1        1 
  fmpy   d4,d0,d1 fsub.s d5,d0  x:(r0)-,d4.s d0.s,d5.s   ; 1        1 
  fmpy.s d4,d0,d2                            y:(r4)-,d4.s; 1        1 
  fmpy   d4,d5,d1 fsub.s d1,d2                           ; 1        1 
  fmpy.s d1,d2,d2                                        ; 1        1 
  fmpy.s d0,d0,d1               x:(r0)+n0,d4.s           ; 1        1 
  fmpy.s d1,d4,d1               d5.s,d4.s                ; 1        1 
  fmpy   d4,d4,d1 fsub.s d1,d2                           ; 1        1 
  fmpy.s d0,d2,d2                                        ; 1        1 
  fmpy.s d1,d4,d1               x:(r0)+n0,d5.s           ; 1        1 
  fmpy.s d1,d5,d1                                        ; 1        1 
  fadd.s d1,d2                                           ; 1        1 
                                                         ;---      --- 
                                                ; Totals:  13       13 

;The result x(t) is in d2.  The setup of the pointers is not included  because this is application depen-
;dent and does not have to be performed  for each evaluation of x(t).  The first two moves may also 
;be  application dependent and be merged with other data ALU operations  for a savings of two more 
;cycles and program steps.  
;Reference: "Fundamentals of Interactive Computer Graphics", 
;                  James D. Foley Andries Van Dam 
;                  Addison-Wesley 1982 
