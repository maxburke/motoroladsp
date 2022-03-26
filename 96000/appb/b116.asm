; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.16	LMS ADAPTIVE FILTER  
;l      
;Notation and symbols: 
;;  x(n)  - Input sample at time n. 
;  d(n)  - Desired signal at time n. 
;  f(n)  - FIR filter output at time n. 
;  H(n)  - Filter coefficient vector at time n.    H={h0,h1,h2,h3} 
;  X(n)  - Filter state variable vector at time n. X={x0,x1,x2,x3} 
;  u     - Adaptation gain. 
;  ntaps - Number of coefficient taps in the filter. For this 
;          example, ntaps=4. 
; 
; Exact LMS Algorithm: 
; e(n)=d(n)-H(n)X(n)    (FIR filter and error) 
; H(n+1)=H(n)+uX(n)e(n) (Coefficient update) 
; 
; Delayed LMS Algorithm: 
; e(n)=d(n)-H(n)X(n)        (FIR filter and error) 
; H(n+1)=H(n)+uX(n-1)e(n-1) (Coefficient update) 

;In the exact LMS algorithm, the output of the FIR filter is first  calculated (f(n)) and then the coeffi-
;cients are updated using the  current error signal and coefficients.  In the delayed LMS algorithm,  
;the FIR filter and coefficient update is performed at the same time. The  coefficients are updated with 
;the error value and coefficients from the  previous sample.  
;References: 
;  "Adaptive Digital Filters and Signal Analysis", Maurice G. Bellanger 
;      Marcel Dekker, Inc. New York and Basel 
; 
;  "The DLMS Algorithm Suitable for the Pipelined Realization of Adaptive 
;      Filters", Proc. IEEE ASSP Workshop, Academia Sinica, Beijing, 1986 
;
;The sections of code shown describe how to initialize all registers,  filter an input sample and do the 
;coefficient update.  Only the  instructions relating to the filtering and coefficient update are shown  as 
;part of the benchmark.  Instructions executed only once (for  initialization) or instructions that may 
;be user application dependent  are not included in the benchmark.  
;                                                    Exact LMS Algorithm 
; 
ntaps    equ     4 
u        equ     .01 
 
         org     x:0 
sbuf     ds      ntaps 
 
         org     y:0 
cbuf     ds      ntaps 
 
         org     y:10 
dsig     ds      1 
xsig     ds      1 
 
         org     p:$50 
start 
  move      #sbuf,r0            ;point to state buffer 
  move      #cbuf,r4            ;point to coefficient buffer 
  move      r4,r5               ;extra pointer 
  move      #ntaps-1,m0         ;mod on pointers 
  move      #ntaps-1,m4 
  move      #ntaps-1,m5 
  move      #-3,n0              ;final adjustment 
  move      #u,d7.s             ;adaptation constant 
 
main 
  fclr    d1                            y:xsig,d4.s 
  fclr    d0            d4.s,x:(r0)+    y:(r4)+,d5.s 
  rep     #ntaps 
  fmpy    d4,d5,d1  fadd.s d1,d0  x:(r0)+,d4.s  y:(r4)+,d5.s 
  fadd.s  d1,d0         x:(r0)-,d4.s    y:(r4)-,d5.s 
 
  move                                  y:dsig,d1.s 
  fsub.s  d0,d1 
  fmpy.s  d7,d1,d1      x:(r0)+,d4.s 
 
  fmpy.s  d4,d1,d3                      y:(r4)+,d5.s 
  fadd.s  d3,d5         x:(r0)+,d4.s 
  do      #ntaps,cup 
  fmpy.s  d4,d1,d3      d5.s,d0.s       y:(r4)+,d5.s 
  fadd.s  d3,d5         x:(r0)+,d4.s    d0.s,y:(r5)+ 
cup 
  move                  x:(r0)+n0,d4.s  y:(r4)-,d0.s 
  jmp     main 
  end 

;The FIR filter requires 1N/coefficient and the coefficient update  requires 2N/coefficient for a total of 
;3N/coefficient.  
;On the delayed LMS algorithm, the coefficients are updated with the  error from the previous itera-
;tion while the FIR filter is being computed  for the current iteration.  In the following implementation, 
;two  coefficients are updated with each pass of the loop.  
;                                            Delayed LMS Algorithm 
 
iter      equ   50              ;Number of LMS iterations 
conv_fact equ   0.01            ;Convergence factor 
 
          org   x:$0 
state     ds    11              ;State of lms fir 
 
          org   y:$0 
coef      ds    10              ;LMS coefficients 
 
e         dc    0.0             ;Signal error 
xin       ds    1               ;Input to system 
dsig      ds    1               ;Desired signal 
 
          org   p:$100 
lmstest 
  move   #state,r0          ;Set up address generators 
  move   #10,m0 
  move   #xstate,r1 
  move   #9,m1 
  move   #coef,r4 
  move   #9,m4 
  move   #coef,r5 
  move   #9,m5 
  move   #xcoef,r6 
  move   #9,m6 
 
  move   #iter,d0.l 
  do     d0.l,lms 
  ; LMS algorithm setup 
  move                                         y:e,d0.s 
  move                           #conv_fact,d1.s 
  fmpy.s d0,d1,d0                              y:xin,d6.s 
  move                           d0.s,d9.s 
  move                           d6.s,x:(r0) 
  ; LMS algorithm loop 
  move                           x:(r0)+,d6.s  y:(r4)+,d7.s 
  fmpy.s d7,d6,d1                x:(r0)+,d4.s  y:(r4)+,d5.s 
  fmpy.s d9,d4,d2 
  fmpy   d5,d4,d0  fadd.s d7,d2  x:(r0)+,d6.s 
  do #4,_lms_loop 
  fmpy   d9,d6,d3  fadd.s d0,d1                y:(r4)+,d7.s 
  fmpy   d7,d6,d0  fadd.s d5,d3  x:(r0)+,d4.s  d2.s,y:(r5)+ 
  fmpy   d9,d4,d2  fadd.s d0,d1                y:(r4)+,d5.s 
  fmpy   d5,d4,d0  fadd.s d7,d2  x:(r0)+,d6.s  d3.s,y:(r5)+ 
_lms_loop 

  fmpy   d9,d6,d3  fadd.s d0,d1                d2.s,y:(r5)+ 
                   fadd.s d5,d3  (r0)- 
  move                                         d3.s,y:(r5)+ 
  move                                         y:dsig,d2.s 
  fsub.s                         d1,d2 
  move                                         d2.s,y:e 
lms 
  nop 
  nop 
  end 

;The inner loop updates the coefficients and performs the FIR filtering  for a speed of 2N per coeffi-
;cient.  
