; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.20	Normalized Lattice Filter  
;                                      
;                                         NORMALIZED LATTICE FILTER 
;                          COEFFICIENT AND STATE VARIABLE STORAGE 
; 
;          r0                                  r4 
;                                              
;       
;     X: q2 k2 q1 k1 q0 k0 w3 w2 w1 w0    Y: sx s2 s1 s0 
; 
;        m0=3*N (=9, mod 10)                 m4=N  (=3, mod 4) 
; 
 
;; 
;                                                  SINGLE SECTION 
; 
;                                           EQUATIONS: 
;                          
;                                          t'=t*q-k*s 
;                                          u'=t*k+s*q 
;                                          t'?t 
;                         
;                                          output=sum (w*u') 
;                            
;          
;           
;          
;
;                                       DSP56000 IMPLEMENTATION  
;                                                        	Program 	ICycles
;                                                        	Words 
;  move       #coef,r0        ;point to coefficients 
; move       #3*N,m0         ;mod on coefficients 
; move       #state,r4       ;point to state variables 
; move       #N,m4           ;mod on filter states 
; 
; movep      y:datin,y0      ;get input sample 
; 
; move           x:(r0)+,x1           ;get first Q in table     1     1 
; do    #order,_endnlat                                         2     3 
; mpy   x1,y0,a  x:(r0)+,x0 y:(r4),y1 ;q*t, get k, get s        1     1 
; macr -x0,y1,a  b,y:(r4)+            ;q*t-k*s, save new s      1     1 
; mpy   x0,y0,b             a,y0      ;k*t, set t'              1     1 
; macr  x1,y1,b  x:(r0)+,x1           ;k*t+q*s, get next q      1     1 
;_endnlat 
; move                      b,y:(r4)+ ;sv scnd lst st           1     1 
; move                      a,y:(r4)+ ;save last state          1     1 
; clr   a                   y:(r4)+,y0 ;clr acc, get fst st     1     1 
; rep   #order                         ;do fir taps             1     2 
; mac   x1,y0,a  x:(r0)+,x1 y:(r4)+,y0                          1     1 
; macr  x1,y0,a             (r4)+      ;rnd, adj pointer        1     1 
; 
; movep a,y:datout           ;output sample 
;                                                                            ---   ---
;                                                      Totals: 13   5N+10
;                                             DSP96002 IMPLEMENTATION 
; 
;                                                      	Program	ICycles
;                                                      	Words 
 move       #coef,r0        ;point to coefficients 
 move       #3*N,m0         ;mod on coefficients 
 move       #state,r4       ;point to state variables 
 move       #N,m4           ;mod on filter states 
 
 move p     y:datin,d5.s    ;get input sample 
 
 move                     x:(r0)+,d6.s ;get q                ;  1     1 
 do     #N,_elat                                             ;  2     3 
;      t*q       k*w+q*s     get k    get s 
 fmpy d5,d6,d2  fadd.s d1,d3 x:(r0)+,d4.s y:(r4)+,d7.s       ;  1     1 
;      k*s                            save s 
 fmpy.s d4,d7,d0                        d3.s,y:(r4)+         ;  1     1 
;      t*k       w*q-k*s; 
 fmpy d5,d4,d1  fsub.s d0,d2                                 ;  1     1 
;      q*s         t?t'   get q 
 fmpy.s d6,d7,d3             d2.s,d5.s    x:(r0)+,d6.s       ;  1     1 
_elat 
                fadd.s d1,d3           ;finish last t          1     1 
 move                                d3.s,y:(r4)+ ;save 2nd s  1     1 
 fclr   d2                           d5.s,y:(r4)+ ;save 1st s  1     1 
 fclr   d3                           y:(r4)+,d7.s ;get s       1     1 
 rep   #N                                                     ; 1     2 
 fmpy  d6,d7,d2 fadd.s d2,d3 x:(r0)+,d6.s y:(r4)+,d7.s  ;fir   1     1 
                fadd.s d2,d3              (r4)+   ;adj r4      1     1 
 
 move p  d3.s,y:datout 
;                                                            ; ---    --- 
;                                                     Totals:  14   5N+11 
