; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.43.2	Integer Incremental Line Drawing Algorithm  
;This implementation of line drawing uses Bresenham's algorithm. This  algorithm uses only integer op-
;erations to generate the points.  
;  Bresenham Line Drawing Implementation 
; 
;  When entering subroutine, the registers must 
;  be set as follows: 
; 
;    d0 =          d4 = 
;    d1 =          d5 = 
;    d2 = x1       d6 = x0 
;    d3 = y1       d7 = y0 
; 
;  When entering a line drawing loop, the registers 
;  are set as follows: 
; 
;    d6 = x0 
;    d7 = y0 
;    d4 = dmajor 
;    d5 = n0 = dminor 
;    r0 = dmajor/2 
;    m0 = dmajor - 1 
  org    p:$50 
; Calculate dx and dy 
_line 
  sub    d6,d2    d2.l,d4.l 
  sub    d7,d3    d3.l,d5.l 
; Determine whether to increment x or y 
  tst    d2       d2.l,d0.l 
  neg    d2       iflt 
  tst    d3       d3.l,d1.l 
  neg    d3       iflt 
  cmp    d3,d2 
  jge    _inc_x 
; Increment y case 
; If dy is negative, switch endpoints and sign of dx and dy 
_inc_y 
  tst    d1 
  tfr    d4,d6    iflt 
  tfr    d5,d7    iflt 
  neg    d1       iflt 
  neg    d0       iflt 
  tst    d0 
  jlt    _set_y_xn 

; Increment y, dx positive case 
; Set up registers 
_set_y_xp 
  lsr    d1       d1.l,d2.l 
  dec    d2       d2.l,d4.l 
  move            d1.l,r0 
  move            d2.l,m0 
  move            d0.l,n0 
  move            d0.l,d5.l 
; Draw first point 
  jsr   _draw_point 
; Draw additional points 
  do    d4.l,_line_y_xp 
  inc   d7       r0,d2.l 
  add   d5,d2    (r0)+n0 
  cmp   d4,d2 
  inc   d6       ifge 
  jsr   _draw_point 
_line_y_xp 
  rts 
; Increment y, dx negative case 
; Set up registers 
_set_y_xn 
  lsr    d1       d1.l,d2.l 
  dec    d2       d2.l,d4.l 
  neg    d0       d1.l,r0 
  move            d2.l,m0 
  move            d0.l,n0 
  move            d0.l,d5.l 
; Draw first point 
  jsr   _draw_point 
; Draw additional points 
  do    d4.l,_line_y_xn 
  inc   d7       r0,d2.l 
  add   d5,d2    (r0)+n0 
  cmp   d4,d2 
  dec   d6       ifge 
  jsr   _draw_point 
_line_y_xn 
  rts 

; Increment x case 
; If dx is negative, switch endpoints and sign of dx and dy 
_inc_x 
  tst    d0 
  jeq    _draw1 
  tfr    d4,d6    iflt 
  tfr    d5,d7    iflt 
  neg    d0       iflt 
  neg    d1       iflt 
  tst    d1 
  jlt    _set_x_yn 
; Increment x, dy positive case 
; Set up registers 
_set_x_yp 
  lsr    d0       d0.l,d2.l 
  dec    d2       d2.l,d4.l 
  move            d0.l,r0 
  move            d2.l,m0 
  move            d1.l,n0 
  move            d1.l,d5.l 
; Draw first point 
  jsr   _draw_point 
; Draw additional points 
  do    d4.l,_line_x_yp 
  inc   d6       r0,d2.l 
  add   d5,d2    (r0)+n0 
  cmp   d4,d2 
  inc   d7       ifge 
  jsr   _draw_point 
_line_x_yp 
  rts 
; Increment x, dy negative case 
; Set up registers 
_set_x_yn 
  lsr    d0       d0.l,d2.l 
  dec    d2       d2.l,d4.l 
  neg    d1       d0.l,r0 
  move            d2.l,m0 
  move            d1.l,n0 
  move            d1.l,d5.l 

; Draw first point 
  jsr   _draw_point 
; Draw additional points 
  do    d4.l,_line_x_yn 
  inc   d6       r0,d2.l 
  add   d5,d2    (r0)+n0 
  cmp   d4,d2 
  dec   d7       ifge 
_draw1 
  jsr   _draw_point 
_line_x_yn 
  rts 
; Draw a single point 
_draw_point 
  move           d6.l,x:(r1)+   d7.l,y: 
  rts 

