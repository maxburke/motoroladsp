; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.15.2	Faster Radix 2 Decimation in Time FFT  
; Complex, Radix 2 Cooley-Tukey Decimation in Time FFT 
; This program has not been exhaustively tested and may contain errors. 
; 
; Faster FFT using Programming Tricks found in Typical FORTRAN Libraries 
; 
;      First two passes combined as a four butterfly loop since 
;            multiplies are trivial. 
;            2.25 cycles internal (4 cycles external) per Radix 2 
;            butterfly. 
;      Middle passes performed with traditional, triple-nested DO loop. 
;            4 cycles internal (8 cycles external) per Radix 2 butterfly 
;            plus overhead.  Note that a new pipelining technique is 
;            being used to minimize overhead. 
;      Next to last pass performed with double butterfly loop. 
;            4.5 cycles internal (8.5 cycles external) per Radix 2 
;            butterfly. 
;      Last pass has separate single butterfly loop. 
;            5 cycles internal (9 cycles external) per Radix 2 
;            butterfly. 
; 
;      For 1024 complex points, average Radix 2 butterfly = 3.8 cycles 
;      internal and 7.35 cycles external, assuming a single external 
;      data bus. 
; 
;      Because of separate passes, minimum of 32 points using these 
;      optimizations.  Approximately 150 program words required. 
;      Uses internal X and Y Data ROMs for twiddle factor coefficients 
;      for any size FFT up to 1024 complex points. 
; 
;      Assuming internal program and internal data memory (or two 
;      external data buses), 1024 point complex FFT is 1.57 msec at 
;      75 nsec instruction rate.  Assuming internal program and 
;      external data memory, 1024 point complex FFT is 2.94 msec 
;      at 75 nsec instruction rate. 
; 
; First two passes 
; 
;      9 cycles internal, 1.77X faster than 4 cycle Radix 2 bfy 
;      16 cycles external, 2.0X faster than 4 cycle Radix 2 bfy 
; 
;      r0 = a pointer in and out 
;      r6 = a pointer in 
;      r4 = b pointer in and out 
;      r1 = c pointer in and out 
;      r5 = d pointer in and out 
;      n5 = 2 
; 

      move      #points,d1.l 
      move      #passes,d9.l 
      move      #data,d0.l 
      move      #coef,m2 
      move      #coefsize,d2.l 
 
      lsr       d1         d0.l,r0 
      lsr       d1         r0,r2 
      add       d1,d0      d1.l,d8.l 
      add       d1,d0      d0.l,r4 
      add       d1,d0      d0.l,r1 
      lsr       d2         d0.l,r5 
      lsr       d2         r0,r6 
      move      #2,n5 
      move      d2.l,n6 
      move      #-1,m0 
      move      m0,m1 
      move      m0,m4 
      move      m0,m5 
      move      m0,m6 
 
      move                              x:(r0),d1.s 
      move                              x:(r1),d0.s 
      move                              x:(r5)-,d2.s 
      move                                           y:(r5)+,d4.s 
      faddsub.s d1,d0                    x:(r4),d5.s 
      faddsub.s d5,d2                                 y:(r4),d7.s 
; 
;      Combine first two passes with trivial multiplies. 
; 
      do      d8.l,_twopass 
 
      faddsub.s  d0,d2                                 y:(r5),d6.s 
      faddsub.s  d7,d6                   d2.s,x:(r0)+  y:(r6)+,d3.s 
      faddsub.s  d1,d7                   d0.s,x:(r4)   y:(r1)+,d2.s 
      faddsub.s  d3,d2                   d1.s,x:(r5)- 
      faddsub.s  d2,d6                   x:(r0)-,d1.s  d4.s,y:(r5)+n5 
      faddsub.s  d3,d5                   x:(r1)-,d0.s  d2.s,y:(r4)+ 
      faddsub.s  d1,d0                   x:(r5),d2.s   d6.s,y:(r0)+ 
      ftfr.s     d5,d4                   x:(r4),d5.s   d3.s,y:(r1) 
      faddsub.s  d5,d2                   d7.s,x:(r1)+  y:(r4),d7.s 
_twopass 
      move                                             d4.s,y:(r5)+ 

; 
; Middle passes 
; 
      tfr     d9,d3      #4,d0.l 
      clr     d2         d8.l,d1.l 
      sub     d0,d3      d2.l,m6 
 
      do      d3.l,_end_pass 
      move    d0.l,n2 
      move    r2,r0 
      lsr     d1         m2,r6 
      dec     d1         d1.l,n0 
      dec     d1         d1.l,n1 
      move    d1.l,n3 
      move    n0,n4 
      move    n0,n5 
      lea     (r0)+n0,r1 
      move    r0,r4 
      move    r1,r5 
      move                              x:(r6)+n6,d9.s y:,d8.s 
      move                                             y:(r1),d7.s 
      fmpy.s d8,d7,d3                   x:(r1)+,d6.s 
      fmpy.s d9,d6,d0 
      fmpy.s d9,d7,d1                                  y:(r1),d7.s 
      fmpy   d8,d6,d2  fadd.s    d3,d0  x:(r0),d4.s 
      fmpy   d8,d7,d3  faddsub.s d4,d0  x:(r1)+,d6.s 
 
      do      n2,_end_grp 
 
      do      n3,_end_bfy 
      fmpy  d9,d6,d0   fsub.s    d1,d2  d0.s,x:(r4)    y:(r0)+,d5.s 
      fmpy  d9,d7,d1   faddsub.s d5,d2  d4.s,x:(r5)    y:(r1),d7.s 
      fmpy  d8,d6,d2   fadd      d3,d0  x:(r0),d4.s    d2.s,y:(r5)+ 
      fmpy  d8,d7,d3   faddsub.s d4,d0  x:(r1)+,d6.s   d5.s,y:(r4)+ 
_end_bfy 
      move      (r1)+n1 
      fmpy  d9,d6,d0   fsub.s    d1,d2  d0.s,x:(r4)    y:(r0)+,d5.s 
      fmpy  d9,d7,d1   faddsub.s d5,d2  d4.s,x:(r5)    y:(r1),d7.s 
      fmpy  d8,d6,d2   fadd.s    d3,d0  x:(r0),d4.s    d2.s,y:(r5)+ 
      move                              x:(r6)+n6,d9.s y:,d8.s 
      fmpy  d8,d7,d3   faddsub.s d4,d0  x:(r1)+,d6.s   d5.s,y:(r4)+ 
      fmpy  d9,d6,d0   fsub.s    d1,d2  d0.s,x:(r4)    y:(r0)+n0,d5.s 
      fmpy  d9,d7,d1   faddsub.s d5,d2  d4.s,x:(r5)    y:(r1),d7.s 
      fmpy  d8,d6,d2   fadd.s    d3,d0  x:(r0),d4.s    d2.s,y:(r5)+n5 
      fmpy  d8,d7,d3   faddsub.s d4,d0  x:(r1)+,d6.s   d5.s,y:(r4)+n4 
_end_grp 
      move     n2,d0.l 
      lsl      d0      n0,d1.l 
_end_pass 

; 
; next to last pass 
; 
      move      d0.l,n2 
      move      r2,r0 
      move      r0,r4 
      lea      (r0)+2,r1 
      move      r1,r5 
      move      m2,r6 
      move      #3,n0 
      move      n0,n1 
      move      n0,n4 
      move      n0,n5 
      move                              x:(r6)+n6,d9.s  y:,d8.s 
      move                                              y:(r1),d7.s 
      fmpy.s d8,d7,d3                   x:(r1)+,d6.s 
      fmpy.s d9,d6,d0 
      fmpy.s d9,d7,d1                                   y:(r1),d7.s 
      fmpy   d8,d6,d2  fadd.s    d3,d0  x:(r0),d4.s 
      fmpy   d8,d7,d3  faddsub.s d4,d0  x:(r1)+n1,d6.s 
 
      do      n2,_end_next 
      fmpy   d9,d6,d0  fsub.s    d1,d2  d0.s,x:(r4)     y:(r0)+,d5.s 
      fmpy   d9,d7,d1  faddsub.s d5,d2  d4.s,x:(r5)     y:(r1),d7.s 
      fmpy   d8,d6,d2  fadd.s    d3,d0  x:(r0),d4.s     d2.s,y:(r5)+ 
      move                              x:(r6)+n6,d9.s  y:,d8.s 
      fmpy   d8,d7,d3  faddsub.s d4,d0  x:(r1)+,d6.s    d5.s,y:(r4)+ 
      fmpy   d9,d6,d0  fsub.s    d1,d2  d0.s,x:(r4)     y:(r0)+n0,d5.s 
      fmpy   d9,d7,d1  faddsub.s d5,d2  d4.s,x:(r5)     y:(r1),d7.s 
      fmpy   d8,d6,d2  fadd.s    d3,d0  x:(r0),d4.s     d2.s,y:(r5)+n5 
      fmpy   d8,d7,d3  faddsub.s d4,d0  x:(r1)+n1,d6.s  d5.s,y:(r4)+n4 
_end_next 

; 
; last pass 
; 
      move      n2,d0.l 
      lsl       d0      r2,r0 
      move      d0.l,n2 
      move      r0,r4 
      lea      (r0)+,r1 
      move      r1,r5 
      move      m2,r6 
      move      #2,n0 
      move      n0,n1 
      move      n0,n4 
      move      n0,n5 
      move                              x:(r6)+n6,d9.s  y:,d8.s 
      move                                              y:(r1),d7.s 
      fmpy.s d8,d7,d3                   x:(r1)+n1,d6.s 
      fmpy.s d9,d6,d0 
      fmpy.s d9,d7,d1                                   y:(r1),d7.s 
      fmpy   d8,d6,d2  fadd.s    d3,d0  x:(r0),d4.s 
      move                              x:(r6)+n6,d9.s  y:,d8.s 
      fmpy   d8,d7,d3  faddsub.s d4,d0  x:(r1)+n1,d6.s 
 
      do      n2,_end_last 
      fmpy   d9,d6,d0  fsub.s    d1,d2  d0.s,x:(r4)     y:(r0)+n0,d5.s 
      fmpy   d9,d7,d1  faddsub.s d5,d2  d4.s,x:(r5)     y:(r1),d7.s 
      fmpy   d8,d6,d2  fadd.s    d3,d0  x:(r0),d4.s     d2.s,y:(r5)+n5 
      move                              x:(r6)+n6,d9.s  y:,d8.s 
      fmpy   d8,d7,d3  faddsub.s d4,d0  x:(r1)+n1,d6.s  d5.s,y:(r4)+n4 
_end_last 
