; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.43	Line Drawing  
; B.1.43.1	Floating-Point Incremental Line Drawing Algorithm  
;This algorithm generates points along a line given the endpoints. As the  coordinate along one axis is 
;incremented in fixed point, the other  coordinate is incremented in floating-point and then converted 
;to fixed  point.  A full line drawing algorithm which draws lines in all  directions is given below.  
;Registers: 
; 
;  d0 = temporary      d4 = temporary x1     d8 = 
;  d1 = temporary      d5 = temporary y1     d9 = 2.0 
;  d2 = x1 (dx)        d6 = x0 and xScreen 
;  d3 = y1 (dy)        d7 = y0 and yScreen 
; 
;                                                       	Program	ICycles 
                                                         	Words 
; Calculate dx and dy 
  fsub.s d6,d2  d2.s,d4.s                                ;  1    1 
  fsub.s d7,d3  d3.s,d5.s                                ;  1    1 
; Determine whether to increment x or y 
  fcmpm  d3,d2                                           ;  1    1 
  fjge   _inc_x                                          ;  2    2 
; Switch endpoints if necessary 
_inc_y 
  ftst   d3                    d2.s,d0.s                 ;  1    1 
  ftfr.s d4,d6                 fflt                      ;  1    1 
  ftfr.s d5,d7                 fflt                      ;  1    1 
; Fix y0 and dy 
  int    d7                    d3.s,d1.s                ;   1    1 
  int    d1                                              ;  1    1 
  neg    d1                    iflt                      ;  1    1 
  jeq    _draw1_y                                        ;  2    2 
; Calculate dx/dy 
  fseedd d3,d4                                           ;  1    1 
  fmpy.s d3,d4,d5              d9.s,d2.s                 ;  1    1 
  fmpy   d0,d4,d0 fsub.s d5,d2 d2.s,d3.s                 ;  1    1 
  fmpy.s d5,d2,d5              d2.s,d4.s                 ;  1    1 
  fmpy   d0,d4,d0 fsub.s d5,d3                           ;  1    1 
  fmpy.s d0,d3,d0              d6.s,d2.s                 ;  1    1 
; Draw first point                                       ;
  int    d6                                              ;  1    1 
  jsr    _draw_point                        ;  application dependent 
; d0 = dx/dy  d1 = dy  d6 = x0  d7 = y0 
  do     d1.l,_end_y                                     ;  2    3 
  fadd.x d0,d2                                           ;  1    1 
  inc    d7                    d2.s,d6.s                 ;  1    1 
  int    d6                                              ;  1    1 
  jsr    _draw_point                        ;  application dependent 
_end_y 
  rts                                                    ;  2    2 

_draw1_y 
  int d6                                                 ;  1    1 
  jsr    _draw_point                        ;  application dependent 
  rts                                                    ;  2    2 
; Switch endpoints if necessary 
_inc_x 
  ftst   d2                    d3.s,d0.s                 ;  1    1 
  ftfr.s d4,d6                 fflt                      ;  1    1 
  ftfr.s d5,d7                 fflt                      ;  1    1 
; Fix x0 and dx                                          ;
  int    d6                    d2.s,d1.s                 ;  1    1 
  int    d1                                              ;  1    1 
  neg    d1                    iflt                      ;  1    1 
  jeq                          _draw1_x                  ;  2    2 
; Calculate dy/dx                                        ;
  fseedd d2,d4                                           ;  1    1 
  fmpy.s d2,d4,d5              d9.s,d2.s                 ;  1    1 
  fmpy   d0,d4,d0 fsub.s d5,d2 d2.s,d3.s                 ;  1    1 
  fmpy.s d5,d2,d5              d2.s,d4.s                 ;  1    1 
  fmpy   d0,d4,d0 fsub.s d5,d3                           ;  1    1 
  fmpy.s d0,d3,d0              d7.s,d2.s                 ;  1    1 
; Draw first point                                       ;
  int    d7                                              ;  1    1 
  jsr    _draw_point                        ;  application dependent 
; d0 = dy/dx  d1 = dx  d6 = x0  d7 = y0 
  do     d1.l,_end_x                                     ;  2    3 
  fadd.x d0,d2                                           ;  1    1 
  inc    d6                    d2.s,d7.s                 ;  1    1 
  int    d7                                              ;  1    1 
  jsr    _draw_point                        ;  application dependent 
_end_x                                                   ;
  rts                                                    ;  2    2 
_draw1_x                                                 ;
  int d7                                                 ;  1    1 
  jsr    _draw_point                        ;  application dependent 
  rts                                                    ;  2    2 
 
 
;Performance: 
;  Trivial case: (single point)  16      cycles 
;  Other cases:                  25 + 3n cycles 
