; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.9	Complex Update  
;   dr + jdi = ( cr + jci ) + ( ar + jai ) * ( br + jbi ) 
; 
;   dr = cr + ar * br - ai * bi      R0 ? a   R4 ? b    R1 ? c   R ? d 
;   di = ci + ar * bi + ai * br 
; 
;                                                       	Program	ICycles
;                                                       	Words 
       move                                      y:(r1),d1.s  ;	1  		1 
       move                          x:(r0),d5.s y:(r4),d6.s  ;	1  		1 
       fmpy.s d6,d5,d2               x:(r4),d4.s y:(r0),d7.s  ;	1  		1 
       fmpy d4,d7,d2  fadd.s d2,d1   x:(r1),d0.s              ;	1  		1 
       fmpy d4,d5,d2  fadd.s d2,d1                            ;	1  		1 
       fmpy d6,d7,d2  fadd.s d2,d0                d1.s,y:(r2) ;	1  		1 
                      fsub.s d2,d0                            ;	1  		1 
       move                          d0.s,x:(r2)              ;	1  		1 
;                                                             ;	---    	--- 
;                                                     	Totals:  	8      	8 
;                                                             	(	7      	7) 
