; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.32	Signed Integer Divide  
;The signed integer divide operation divides two 32 bit signed two's  complement integers.  The divide 
;operation uses a one quadrant restoring divide iteration to divide the operands. The following code 
;divides  d5/d2 with the resulting quotient in d0.  
;
;             Signed 32 Bit Integer                      	Program	ICycles 
             Division of d0 = d5/d2                     	Words 
    eor    d2,d5   d5.l,d0.l  ;determine final sign        1        1 
    abs    d2      d0.l,d3.l  ;make divisor positive       1        1 
    abs    d0                 ;make dividend positive      1        1 
    do     #32,dloop          ;32 quotient bits            2        3 
    rol    d0                 ;dividend bit out, q bit in  1        1 
    rol    d1                 ;put in temp                 1        1 
    cmp    d2,d1              ;check for q bit             1        1 
    sub    d2,d1    ifcc      ;update if less              1        1 
dloop 
    rol    d0                 ;last q bit                  1        1 
    not    d0                 ;complement q bits           1        1 
    tst    d5                 ;check sign of result        1        1 
    neg    d0       iflt      ;negate if needed            1        1 
    tst    d3
    neg    dl       iflt
;                                                          ---      --- 
;                                                  Totals:  13      138 

;The final remainder is destroyed in the generation of the quotient.  This  program may calculate only 
;the number of quotient bits required and has  variable execution time.  

;              Signed 32 Bit Integer                     	
;        Division of d0 = d0/d1,  d0 >= d1               	
	abs	d1	d1.l,d2.l
	eor	d0,d2
	abs	d0	d2.l,d1.m
	cmp	d1,d0	d0.l,d2.m
	eor	d0,d0	iflo
	jlo	divdone
	bfind	d0,d0	d3.l,d8.l
	bfind	d1,d2	d0.h,d0.l
	movei	#32,d3
	move		d2.h,d2.l
	sub	d0,d2	d2.m,d0.l
	inc	d2	d2.l,d2.h
	sub	d2,d3
	lsl	d2,d1	d3.l,d2.h
	do	d2.l,divloop_fast
	cmp	d1,d0
	sub	d1,d0	ifhs
	rol	d0
divloop_fast 	not	d0	d8.l,d3.l
	lsl	d2,d0
	lsr	d2,d0	d1.m,d2.l
	tst	d2
	neg	d0	ifmi
divdone

;The final quotient is destroyed in the generation of the  remainder.  This program calculates only the 
;number of quotient bits  required and has variable execution time.  

;               Signed 32 Bit Integer                    	
;        Remainder of d0 = d0 rem d1,  d0 >= d1          	
	abs	d1	d0.l,d2.l
	abs	d2	d0.l,d1.m
	cmp	d1,d2	d2.l,d2.m
	jlo	divdone
	bfind	d2,d0
	bfind	d1,d2	d0.h,d0.l
	move		d2.h,d2.l
	sub	d0,d2	d2.m,d0.l
	inc	d2	d2.l,d2.h
	lsl	d2,d1	d2.l,d2.h
	do	d2.l,remloop_fast
	cmp	d1,d0
	sub	d1,d0	ifhs
	rol	d0
remloop_fast	lsr	d2,d0	d1.m,d2.l
	tst	d2
	neg	d0	ifmi
divdone
