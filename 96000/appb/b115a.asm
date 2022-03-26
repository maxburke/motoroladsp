; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.15	Fast Fourier Transforms  
; B.1.15.1	Radix 2 Decimation in Time FFT  
;metr2a      macro      points,data,coef,coefsize 
;metr2a      ident      1,4 
; 
;Radix 2 Decimation in Time In-Place Fast Fourier Transform Routine 
; 
;    Complex input and output data 
;        Real data in X memory 
;        Imaginary data in Y memory 
;    Normally ordered input data 
;    Bit reversed output data 
; 
;    Coefficient lookup table 
;        +Cosine value (1/2 cycle) in X memory 
;        +Sine value (1/2 cycle) in Y memory 
;    Table size can be i*points/2, i=1,2,... 
; 
; Macro Call - metr2a   points,data,coef,coefsize 
; 
;      points     number of points (2 - 2,147,483,648, power of 2) 
;      data       start of data buffer 
;      coef       start of 1/2 cycle sine/cosine table 
;      coefsize   number of table points in sine/cosine table 
;                  = i*points/2, i=1,2,...    (1 - 2,147,483,648) 
; 
;         
; ar         Radix 2         ar' 
; ai        Butterfly        ai' 
; br        A'=A+B*Wk        br' 
; bi        B'=A-B*Wk        bi' 
;       
;             
;                    
;              wr  wi 
; 
; wrk = cosine(k*pi/points) table 
; wik = sine(k*pi/points)   table 
; 
; ar' = ar + (wr*br + wi*bi) 
; ai' = ai + (wr*bi - wi*br) 
; br' = ar -  wr*br - wi*bi = ar - (wr*br + wi*bi) 
; bi' = ai -  wr*bi + wi*br = ai - (wr*bi - wi*br) 
; 

      move    #points,d1.l 
      move    #@cvi(@log(points)/@log(2)+0.5),n1 
      move    #data,r2 
      move    #coef,m2 
      move    #coefsize,d2.l 
 
      move    #0,m6 
      move    #-1,m0 
      clr     d0         m0,m1 
      inc     d0         m0,m4 
      lsr     d2         m0,m5 
      move    d2.l,n6 
 
      do      n1,_end_pass 
      move    r2,r0 
      move    d0.l,n2 
      lsr     d1      m2,r6 
      dec     d1      d1.l,n0 
      move    d1.l,n1 
      move    n0,n4 
      move    n0,n5 
      lea     (r0)+n0,r1 
      lea     (r0)-,r4 
      lea     (r1)-,r5 
 
      do      n2,_end_grp 
      move                              x:(r6)+n6,d9.s y:,d8.s 
      move                              x:(r1)+,d6.s   y:,d7.s 
      fmpy.s  d8,d7,d3                                 y:(r5),d2.s 
      fmpy.s  d9,d6,d0                                 y:(r4),d5.s 
      fmpy.s  d9,d7,d1                                 y:(r1),d7.s 
 
      do      n0,_end_bfy 
      fmpy    d8,d6,d2 fadd.s    d3,d0  x:(r0),d4.s    d2.s,y:(r5)+ 
      fmpy    d8,d7,d3 faddsub.s d4,d0  x:(r1)+,d6.s   d5.s,y:(r4)+ 
      fmpy    d9,d6,d0 fsub.s    d1,d2  d0.s,x:(r4)    y:(r0)+,d5.s 
      fmpy    d9,d7,d1 faddsub.s d5,d2  d4.s,x:(r5)    y:(r1),d7.s 
_end_bfy 
      move                              x:(r0)+n0,d7.s d2.s,y:(r5)+n5 
      move                              x:(r1)+n1,d7.s d5.s,y:(r4)+n4 
_end_grp 
      move    n2,d0.l 
      lsl     d0                        n0,d1.l 
_end_pass 
