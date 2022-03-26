; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.24	Table Lookup with Linear Interpolation Between Points  
;This performs a table lookup and linear interpolation between points in  the table.  It is assumed that 
;the spacing between the known values  (breakpoints) is a constant.  No range checking is  per-
;formed on the input number because it is assumed that previous  calculations may have limiting and 
;range checking.  This can be used to  approximate arbitrary functions given a set of known points 
;(such as  digital sine wave generation) or to interpolate linearly between values  of a set of data such 
;as an image.  
;The function to be approximated is shown below:  
; 
;                                 o           ? known values of function 
;                          o             o 
;   Y(i)            o 
;         
;            o 
;        ----+------+------+------+------+ 
;  X(i)?   1.0    6.0   11.0   16.0   21.0   ? indexes 
;            ^         / spacing between indexes is INDSPC, 5.0 
;                         in this example 
;              
;           FIRSTINDEX - value of the first index in the table, 1.0 
;                        in this example 
;
;Given an input value "x", the linearly interpolated value "y"  from the tabulated known values is:  
;        Y(i+1)-Y(i) 
;   y = --------------(x-X(i)) + Y(i) 
;        X(i+1)-X(i) 
;
;                                                        	Program	ICycles
;                                                        	Words 
; 
;     Approximate d4=exp(d0) for 1.0 <= x <= 21.0 
; 
     page     132,60,1,1 
     org     x:0 
table     dc     2.7182818e+00          ;exp(1.0) 
          dc     4.0342879e+02          ;exp(6.0) 
          dc     5.9874141e+04          ;exp(11.0) 
          dc     8.8861105e+06          ;exp(16.0) 
          dc     1.3188157e+09          ;exp(21.0) 
 
     org     p:$50 
firstindex equ    1.0         ;value of first table index 
indspc     equ    5.0         ;index spacing 
rindspc    equ    1.0/indspc  ;reciprocal of index spacing 
 
  move    #table,n0        ;point to start of table 
  move    #firstindex,d6.s ;value of first index 
  move    #rindspc,d7.s    ;reciprocal of index spacing 
 
  fsub.s  d6,d0          ;adjust input relative to index      1     1 
  fmpy.s  d7,d0,d0       ;reduce range and create index       1     1 
  floor   d0,d1          ;get index                           1     1 
  int     d1   d1.s,d2.s ;convert index to int,copy int part  1     1 
  fsub.s  d2,d0  d1.l,r0 ;x-X(i), get ptr to table            1     1 
  nop                    ;clear address ALU pipe              1     1 
  move    (r0)+n0        ;point to Y(i)                       1     1 
  move    x:(r0)+,d4.s   ;get Y(i)                            1     1 
  move    x:(r0),d5.s    ;get Y(i+1)                          1     1 
  fsub.s  d4,d5          ;Y(i+1)-Y(i)                         1     1 
  fmpy.s  d0,d5,d5       ; *(x-X(i))                          1     1 
  fadd.s  d5,d4          ;+Y(i)                               1     1 
;                                                             ---   --- 
;                                                     Totals:  12    12 
 

