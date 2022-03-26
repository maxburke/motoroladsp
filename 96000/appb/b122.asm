; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.22	 NxN  NxN  Matrix Multiply  
;The matrix multiplications are for square NxN matrices. All the elements  are stored in "row major" for-
;mat. i.e. for the array A:  
;   a(1,1) ... a(1,N) 
;                                          a(N,1) ... a(N,N) 
;
;the elements are stored:  
;a(1,1), a(1,2), ..., a(1,N), a(2,1), a(2,2), ..., a(2,N), ... 
;
;The following code implements C=AB where A and B are square matrices.  
;
;                                      DSP56000 IMPLEMENTATION 
;                                                       	Program 	ICycles
;                                                        	Words 
; 
; move   #mat_a,r0                 ;point to A             1        1 
; move   #mat_b,r4                 ;point to B             1        1 
; move   #mat_c,r6                 ;output mat C           1        1 
; move   #N,n0                     ;array size             1        1 
; move   n0,n5                                             1        1 
; 
; do     #N,_rows                  ;do rows                2        3 
; do     #N,_cols                  ;do columns             2        3 
; move   r0,r1                     ;copy start of row A    1        1 
; move   r4,r5                     ;copy start of col B    1        1 
; clr    a                         ;clear sum and pipe     1        1 
; move             x:(r1)+,x0 y:(r5)+n5,y0                 1        1 
; rep    #N-1                      ;sum                    1        1 
; mac    x0,y0,a   x:(r1)+,x0 y:(r5)+n5,y0                 1        2 
; macr   x0,y0,a   (r4)+           ;finish, next column B  1        1 
; move   a,y:(r6)+                 ;save output            1        1 
;_ecols 
;; move   (r0)+n0                   ;next row A             1        1 
; move   #mat_b,r4                 ;first element B        1        1 
;_erows 
;                                                        -----    ----- 
;                                                         19          
;                               ((8+(N-1))N+5)N+8 = N3 +7*N2 +5N+8  ? 
;At a DSP56000/1 clock speed of 20.5 MHz, a [10x10][10x10] can be computed in .1715 ms.
;
;                                             DSP96002 IMPLEMENTATION 
; 
;                                                        	Program	ICycles 
;                                                        	Words 
; 
   move   #mat_a,r0                 ;point to A              1        1 
   move   #mat_c,r6                 ;output mat C            1        1 
   move   #N,n0                     ;array size              1        1 
   move   n0,n5                                              1        1 
 
   do     #N,_rows                                      ;    2        3 
   move   #mat_b,r4                 ;point to B              1        1 
   move   r0,r1                     ;copy start of row       1        1 
   do     #N,_cols                                      ;    2        3 
   move                         r4,r5                   ;    1        1 
   fclr   d0                    (r4)+                   ;    1        1 
   fclr   d1                    x:(r1)+,d4.s y:(r5)+n5,d5.s ;1        1 
   rep    #N                                                ;1        2 
   fmpy   d4,d5,d1 fadd.s d1,d0 x:(r1)+,d4.s y:(r5)+n5,d5.s ;1        1 
                   fadd.s d1,d0 r0,r1                       ;1        1 
   move                                     d0.s,y:(r6)+    ;1        1 
_cols 
   move                         (r0)+n0                     ;1        1 
_rows 
;                                                         ; -----    ----- 
;                                             Totals:       19          
                                                                       
;                                                ((N+7)N+6)N+7 = N3 +7*N2 +6N+7 ?
; At a DSP96002 clock speed of 26.66 MHz, a [10x10][10x10] can be computed in .1325 ms.
