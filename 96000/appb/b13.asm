; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;

; B.1.3	Real Update  
;   d = c + a * b 
; 
;                                                      	Program	ICycles 
;                                                      	Words 
	org p:$100
     move                      x:(r0),d4.s 	y:(r4),d6.s ;  	1      	1 
     fmpy.s  d4,d6,d1          x:(r1),d0.s              ; 		1      	1 
                   fadd.s      d1.s,d0.s                ; 		1      	1 
     move                      d0.s,x:(r2)              ; 		1      	1 
;                                                       	---    	--- 
;                                               	Totals:  	4      	4 
;                                                       	(	4      	4) 
