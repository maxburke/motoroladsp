; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
 ;B.1.2	N Real Multiplies  
;  c(I) = a(I) * b(I) , I=1,...,N 
;                                                     	Program	ICycles 
;                                                      	Words 
	  org	p:$100
aaddr equ  120
baddr equ  100
caddr equ  300
n     equ  400
       move #aaddr,r0  	                                  ;     1 	  	1 
       move #baddr,r4                         	          ; 	1      	1 
       move #caddr,r1                       	          ;   	1      	1 
       move               x:(r0)+,d4.s  	y:(r4)+,d6.s  ;   	1      	1 
       do #n,lend                                 	      ;  	2      	3 
       fmpy.s  d4,d6,d0   x:(r0)+,d4.s  	y:(r4)+,d6.s  ;   	1      	1 
       move               d0.s,x:(r1)+     	              ;	    1      	1 
lend                                                     ;	---   	 --- 
;                                                	Totals:  	8     	2N+7 
;                                                        	(	8     	2N+7) 
