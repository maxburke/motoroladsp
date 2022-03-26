; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.19	General Lattice Filter  
;                                                  GENERAL LATTICE 
; 
;              COEFFICIENT AND STATE VARIABLE STORAGE 
;       r0                         r4 
;                                    
;     
;    x: k3 k2 k1 w3 w2 w1 w0    y: s4 s3 s2 s1 
; 
;       m0=6 (=2*N, mod 7)     m4=3 (=N, mod 4) 
; 
;                                                SINGLE SECTION 
; 
;                                             EQUATIONS: 
;         
;                                          t'=t-k*s 
;                                          s'=s+k*t' 
;                                           t'?t 
                      
;                                          output= sum(s'*w) 
;                  
;                        
;            
          
              
               
             

;                                           DSP56000 IMPLEMENTATION 
;                                                                          	Program	ICycles
;                                                        	Words 
; move   #k,r0              ;point to coefficients 
; move   #2*N,m0            ;mod 2*(# of k's)+1 
; move   #state,r4          ;point to filter states 
; move   #N,m4              ;mod on filter states 
; movep  y:datin,a          ;get input sample 
; move          x:(r0)+,x0 y:(r4)-,y0 ;get first k, first s     1    1 
; do   #N,_el                         ;do filter                2    3 
; macr -x0,y0,a            b,y:(r4)+  ;t-k*s, save prev s       1    1 
; move          a,x1       y:(r4)+,b  ;copy t',get s again      1    1 
; macr  x1,x0,b x:(r0)+,x0 y:(r4)-,y0 ;t'*k+s,get k,get s       1    1 
;_el 
; move                     b,y:(r4)+  ;sv scnd to 1st st        1    1 
; clr   a                  a,y:(r4)+  ;save first state         1    1 
; move                     y:(r4)+,y0 ;get last state           1    1 
; rep   #N                                                      1    2 
; mac   x0,y0,a x:(r0)+,x0 y:(r4)+,y0 ;do fir taps              1    1 
; macr  x0,y0,a              (r4)+    ;finish, adj pointer      1    1 
; movep a,y:datout                    ;output sample 
;                                                             ---   --- 
;                                                                             Totals: 12  4N+10 
; 
;                                        DSP96002 IMPLEMENTATION 
;                                                        	Program	ICycles
;                                                        	Words 
; 
 move   #k,r0              ;point to coefficients 
 move   #2*N,m0            ;mod 2*(# of k's)+1 
 move   #state,r4          ;point to filter states 
 move   #N,m4              ;mod on filter states 
 
 move p  y:datin,d1         ;get input sample 
 
 move        #2,n4                                        ;  1       1 
 move                        x:(r0)+,d5.s y:(r4)-,d6.s    ;  1       1 
 do   #N,_elat                                            ;  2       3 
 fmpy d5,d6,d0  fadd.s d0,d3                              ;  1       1 
                fadd.s d0,d1 d6.s,d3.s    d3.s,y:(r4)+n4  ;  1       1 
 fmpy.s d5,d1,d0             x:(r0)+,d5.s y:(r4)-,d6.s    ;  1       1 
_elat 
                fadd.s d0,d3                              ;  1       1 
 fclr   d0                                d3.s,y:(r4)+    ;  1       1 
 fclr   d1                                d1.s,y:(r4)+    ;  1       1 
 move                                     y:(r4)+,d4.s    ;  1       1 
 rep   #N                                                 ;  1       2 
 fmpy d5,d4,d0  fadd.s d0,d1 x:(r0)+,d5.s y:(r4)+,d6.s    ;  1       1 
                fadd.s d2,d3              (r4)+           ;  1       1 
; 
 move p  d3.s,y:datout         ;output sample 
;                                                           ---     --- 
;                                                   Totals:  14    4N+12 

