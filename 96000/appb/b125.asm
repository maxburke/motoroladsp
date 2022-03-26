; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.25	Argument Reduction  
;Argument reduction (AR) is the problem of having a desired floating  point number range and an ar-
;gument that is outside of the range.  The  argument is placed inside of the desired range by adding or 
;subtracting  multiples of the desired number range.  Of course, adding and  subtracting multiples of a 
;number is inherently slow and requires  infinite precision. Some simple methods can be used with 
;some  assumptions on the precision of the data and relative argument sizes.  
;The following program performs AR when the desired range is arbitrary  and the input value is arbi-
;trary. This may be used to reduce an angle to  the range of -pi to pi.  
;The following variables are defined: 
; 
;           rmin = range minimum value, -pi in this example 
;           rmax = range maximum value, pi in this example 
;           range = rmax-rmin, 2*pi in this example 
;           o_range = 1.0/range 
;
;Assume the input is in d0.  
; 
;rmin      equ  -3.14159 
range     equ  2*3.14159 
o_range   equ  1.0/range 
 ;                                                      	Program	ICycles 
 ;                                                       	Words 
 
 move             #range,d7.s   ;load desired range 
 move             #rmin,d2.s    ;load range min 
 move             #o_range,d3.s ;load reciprocal of range 
 
 fadd.s  d2,d0                  ;adjust to rmin               1     1 
 fmpy.s  d0,d3,d0               ;scale the input              1     1 
 floor   d0,d1                  ;get integer part             1     1 
 fsub.s  d1,d0                  ;get fractional part          1     1 
 fmpy.s  d7,d0d0                ;spread out fraction to range 1     1 
 fadd.s  d2,d0                  ;adjust to rmin               1     1 
  ;                                                           ---   --- 
  ;                                                   Totals:  6     6 

;The output is in d0. Note that the constant initialization is not  included in the benchmark because it 
;does not need to be executed every  time argument reduction is desired and is therefore application  
;dependent.  
;If the desired range begins at zero (i.e. the desired range is zero to  two pi), then the first and last 
;fadd instructions can be deleted for a  four cycle argument reduction.  
;This is one possible method for AR and it is efficient.  This method  will not work when the argument 
;divided by the result range has no  fractional part (in the current precision).  This is obvious since it  
;is the fractional part that contains the information relating to how  far the scaled argument is in the 
;reduced range. The integer part tells  how many times the range has wrapped around.  Typically, a 
;good  programmer will keep the argument to a few multiples of the desired  range. In most practical 
;applications, the argument may exceed the  desired range by several integral values.  In this case, the 
;presented  algorithms work very well.  After the final reduced argument has been  obtained, any incre-
;ments should be made from the reduced argument to  prevent eventual overflow and maintain maxi-
;mum precision.  
