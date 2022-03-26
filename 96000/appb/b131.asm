; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.31	Unsigned Integer Divide
;The unsigned integer divide operation divides two 32 bit unsigned  integers.  The following code di-
;vides d0/d2 with  the resulting quotient in d0 and the remainder in d1.  
; 
;              Unsigned 32 Bit Integer                   	Program	ICycles
;                Division of d0 = d0/d2                  	Words
    eor    d1,d1              ; clear d1
    do     #32,dloop          ;32 quotient bits            2        3 
    rol    d0                 ;dividend bit out, q bit in  1        1 
    rol    d1                 ;put in temp                 1        1 
    cmp    d2,d1              ;check for q bit             1        1 
    sub    d2,d1    ifcc      ;update if less              1        1 
dloop 
    rol    d0                 ;last q bit                  1        1 
    not    d0                 ;complement q bits           1        1 
;                                                          ---      --- 
;                                                  Totals:  8       133 


;The final  remainder is not produced.  This program  may calculate only the number of quotient bits re-
;quired and has variable  execution time.  

;              Unsigned 32 Bit Integer                   	
;            Division of d0 = d0/d1, d0>=d1              	
	cmp	d1,d0	d0.l,d2.m
	eor	d0,d0	iflo
	jlo	divdone		; divisor > dividend
	bfind	d0,d0	d3.l,d8.l
	jmi	dive2big		;dividend has 
				;32 significant bits
	bfind	d1,d2	d0.h,d0.l	;find # of quotient bits
	movei	#32,d3
	move		d2.h,d2.l
	sub	d0,d2	d2.m,d0.l
	inc	d2	d2.l,d2.h	;compute loop iteration count
	sub	d2,d3
	lsl	d2,d1	d3.l,d2.h	;align divisor
	do	d2.l,divloop_fast
	cmp	d1,d0		;perform test subtract
	sub	d1,d0	ifhs	;if no borrow, do subtract
	rol	d0		;mult remx2, save quo. bit (borrow)
divloop_fast
	not	d0	d8.l,d3.l	;flip inverted quotient
	lsl	d2,d0		;clean off any remainder
	lsr	d2,d0
	jmp	divdone		;done
dive2big	eor	d2,d2
	do	#32,divloop_slow		;same algorithm as 1st routine
	rol	d0
	rol	d2
	cmp	d1,d2
	sub	d1,d2	ifhs
divloop_slow 	rol	d0
	not	d0

divdone	end

;The final quotient is not produced.  This program may calculate only the number of quotient bits re-
;quired and has variable  execution time.  
;              Unsigned 32 Bit Integer                   	
;            Remainder of d0 = d0 rem d1, d0>=d1         	
	cmp	d1,d0	d0.l,d2.m
	jlo	divdone		;divisor > dividend
	bfind	d0,d0	#0,d2.l
	jmi	dive2big		;dividend has 
				;32 significant bits
	bfind	d1,d2	d0.h,d0.l	;find # of remainder bits
	move		d2.h,d2.l
	sub	d0,d2	d2.m,d0.l
	inc	d2	d2.l,d2.h	;compute loop count
	lsl	d2,d1	d2.l,d2.h	;align divisor
	do	d2.l,remloop_fast
	cmp	d1,d0		;perform test subtract
	sub	d1,d0	ifhs	;if no borrow, perform subtract
	rol	d0		;adjust remainder
remloop_fast 	lsr	d2,d0		;align remainder
	jmp	remdone		;done
dive2big	do	#32,remloop_slow		;same algorithm as 1st routine
	rol	d0
	rol	d2
	cmp	d1,d2
	sub	d1,d2	ifhs
remloop_slow 	tfr	d2,d0
remdone	end
