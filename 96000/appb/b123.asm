; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.23	N Point 3x3 2-D FIR Convolution  
;The two dimensional FIR uses a 3x3 coefficient mask:  
;      c(1,1) c(1,2) c(1,3) 
;      c(2,1) c(2,2) c(2,3) 
;      c(3,1) c(3,2) c(3,3) 
;
;Stored in Y memory in the order:  
;c(1,1), c(1,2), c(1,3), c(2,1), c(2,2), c(2,3), c(3,1), c(3,2), c(3,3) 
;
;The image is an array of 512x512 pixels.  To provide boundary conditions  for the FIR filtering, the 
;image is surrounded by a set of zeros such  that the image is actually stored as a 514x514 array. i.e.  
;                  514                          
;                                               
;         ...       0          ...                 
;                                                  
;                                           .      
;   .             512                       .      
;   .                                       .    514 
;   0                                       0      
;   .      Image Area               512     .      
;   .                                       .      
;                                                  
;                                                  
;                                                  
;         ...       0          ...                 
;                                                  
;
;The image (with boundary) is stored in row major storage.  The first  element of the array image(,) is 
;image(1,1) followed by image(1,2).  The last element of the first row is image(1,514) followed by the  
;beginning of the next column image(2,1).  These are stored sequentially  in the array "im" in X memo-
;ry.  
;Image(1,1) maps to index 0, image(1,514) maps to index 513,  Image(2,1) maps to index 514 (row 
;major storage).  
;Although many other implementations are possible, this is a realistic  type of image environment 
;where the actual size of the image may not be  an exact power of 2.  Other possibilities include stor-
;ing a 512x512  image but computing only a 511x511 result, computing a 512x512 result  without 
;boundary conditions but throwing away the pixels on the border,  etc.  
;    r0  ?image(n,m)        image(n,m+1)       image(n,m+2) 
;    r1  ?image(n+514,m)    image(n+514,m+1)   image(n+514,m+2) 
;    r2  ?image(n+2*514,m)  image(n+2*514,m+1) image(n+2*514,m+2) 
; 
;    r4  ?FIR coefficients 
;    r5  ?output image 
;
;                                          DSP56000 IMPLEMENTATION 
; 
;                                                        	Program	ICycles
;                                                        	Words 
;  move     #mask,r4            ;point to coefficients        1      1 
;  move     #8,m4               ;mod 9                        1      1 
;  move     #image,r0           ;top boundary                 1      1 
;  move     #image+514,r1       ;left of first pixel          1      1 
;  move     #image+2*514,r2     ;left of first pixel 2nd row  1      1 
; 
;  move     #2,n1               ;adjustment for end of row    1      1 
;  move     n1,n2                                             1      1 
; 
;  move     #imageout,r5        ;output image                 1      1 
; 
;  move     x:(r0)+,x0   y:(r4)+,y0 ;first element, c(1,1)    1      1 
;  do       #512,_rows                                        2      3 
;  do       #512,_cols                                        2      3 
;  mpy  x0,y0,a  x:(r0)+,x0  y:(r4)+,y0 ;c(1,2)               1      1 
;  mac  x0,y0,a  x:(r0)-,x0  y:(r4)+,y0 ;c(1,3)               1      1 
;  mac  x0,y0,a  x:(r1)+,x0  y:(r4)+,y0 ;c(2,1)               1      1 
;  mac  x0,y0,a  x:(r1)+,x0  y:(r4)+,y0 ;c(2,2)               1      1 
;  mac  x0,y0,a  x:(r1)-,x0  y:(r4)+,y0 ;c(2,3)               1      1 
;  mac  x0,y0,a  x:(r2)+,x0  y:(r4)+,y0 ;c(3,1)               1      1 
;  mac  x0,y0,a  x:(r2)+,x0  y:(r4)+,y0 ;c(3,2)               1      1 
;  mac  x0,y0,a  x:(r2)-,x0  y:(r4)+,y0 ;c(3,3)               1      1 
;  macr x0,y0,a  x:(r0)+,x0  y:(r4)+,y0 ;preload, get c(1,1)  1      1 
;  move                      a,y:(r5)+  ;output image sample  1      1 
;_rows 
;; adjust pointers for frame boundary 
;  move   x:(r0)+,x0   y:(r5)+,y1 ;adj r0,r5 w/dummy loads    1      1 
;  move   x:(r1)+n1,x0 y:(r5)+,y1 ;adj r1,r5 w/dummy loads    1      1 
;  move   (r2)+n2                 ;adj r2                     1      1 
;  move   x:(r0)+,x0              ;preload for next pass      1      1 
;_cols 
;                                                            ---    --- 
;                                                             28       
;                                      (Kernel=10N),  10N2 +7N+12   ? 
;
;                                      DSP96002 IMPLEMENTATION 
; 
;                                                        	Program	ICycles
;                                                        	Words 
  move     #mask,r4            ;point to coefficients             1    1 
  move     #8,m4               ;mod 9                             1    1 
  move     #image,r0           ;top boundary                      1    1 
  move     #image+514,r1       ;left of first pixel               1    1 
  move     #image+2*514,r2     ;left of first pixel 2nd row       1    1 
 
  move     #2,n1               ;adjustment for end of row         1    1 
  move     n1,n2                                              ;    1    1 
 
  move     #imageout,r5        ;output image                      1    1 
 
  move             x:(r0)+,d4.s y:(r4)+,d5.s ;preload, get c(1,1); 1    1 
  fmpy.s d4,d5,d0  x:(r0)+,d4.s y:(r4)+,d6.s ;get c(1,2)         ; 1    1 
  do    #512,_rows                                               ; 2    3 
  do    #512,_cols                                               ; 2    3 
  fmpy.s d4,d6,d1              x:(r0)-,d4.s y:(r4)+,d5.s ;c(1,3) ; 1    1 
  fmpy   d4,d5,d0 fadd.s d0,d1 x:(r1)+,d4.s y:(r4)+,d5.s ;c(2,1) ; 1    1 
  fmpy   d4,d5,d0 fadd.s d0,d1 x:(r1)+,d4.s y:(r4)+,d5.s ;c(2,2) ; 1    1 
  fmpy   d4,d5,d0 fadd.s d0,d1 x:(r1)-,d4.s y:(r4)+,d5.s ;c(2,3) ; 1    1 
  fmpy   d4,d5,d0 fadd.s d0,d1 x:(r2)+,d4.s y:(r4)+,d5.s ;c(3,1) ; 1    1 
  fmpy   d4,d5,d0 fadd.s d0,d1 x:(r2)+,d4.s y:(r4)+,d5.s ;c(3,2) ; 1    1 
  fmpy   d4,d5,d0 fadd.s d0,d1 x:(r2)-,d4.s y:(r4)+,d5.s ;c(3,3) ; 1    1 
  fmpy   d4,d5,d0 fadd.s d0,d1 x:(r0)+,d4.s y:(r4)+,d5.s ;c(1,1) ; 1    1 
  fmpy   d4,d5,d0 fadd.s d0,d1 x:(r0)+,d4.s y:(r4)+,d6.s ;c(1,2) ; 1    1 
  move                                      d1.s,y:(r5)+ ;output ; 1    1 
_cols 
  move                      x:(r0)+,d4.s y:(r5)+,d7.s ;adj r0,r5 ; 1    1 
  move                      x:(r0)+,d4.s y:(r5)+,d7.s ;load,aj r5; 1    1 
  fmpy.s d4,d5,d0             (r1)+n1                            ; 1    1 
  move                        (r2)+n2                            ; 1    1 
  move                      x:(r0)+,d4.s          ;load          ; 1    1 
_rows 
;                                                              ; ----------
; 
;                                                      Totals:    29      
;                                                 (Kernel=10N), 10N2 +8N+13   ? 
;
