; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.8	N Complex Multiplies  
;   cr(I) + jci(I) = ( ar(I) + jai(I) ) * ( br(I) + jbi(I) ), I=1,...,N 
; 
;   cr(I) = ar(I) * br(I) - ai(I) * bi(I) 
;   ci(I) = ar(I) * bi(I) + ai(I) * br(I) 
; 
;       R1 ? cr,ci      R0 ?  ar,ai     R4 ? br,bi 
;       D5 = ar  D6 = bi  D4 = br  D7 = ai 
;                                                        	Program	ICycles
;                                                        	Words 
    move   #aaddr,r0                                 	         ;	1      	1 
    move   #baddr,r4                            	              ;	1      	1 
    move   #caddr-1,r1                             	           ;	1      	1 
    move                           x:(r0),d5.s  	y:(r4),d6.s   ;	1      	1 
    fmpy.s  d6,d5,d1               x:(r4)+,d4.s 	y:(r0)+,d7.s  ;	1      	1 
    fmpy.s  d4,d7,d2                                      	    ;	1      	1 
    do    #N,_end                                         	    ;	2      	3 
    fmpy    d6,d7,d2 fadd.s d2,d1               	y:(r0),d7.s   ;	1      	1 
    fmpy.s  d4,d5,d0               x:(r0)+,d5.s 	y:(r4),d6.s   ;	1      	1 
    fmpy    d6,d5,d1 fsub.s d2,d0  x:(r4)+,d4.s 	d1.s,y:(r1)   ;	1      	1 
    fmpy.s  d4,d7,d2               d0.s,x:(r1)+	               ;	1      	1 
_end                                                         ;	---    	--- 
;                                                    	Totals:  	12 	4N+9 
;                                                            	(	12 	4N+9) 

