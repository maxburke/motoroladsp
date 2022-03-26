; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.17	FIR Lattice Filter  
;N refers to the number of 'k' coefficients in the lattice filter.  Some  filters may have other coeffi-
;cients other than the 'k' coefficients but  their number may be determined from k.  
;                                          FIR LATTICE FILTER 
;       
;     COEFFICIENT AND STATE VARIABLE STORAGE 
; 
;       R0                 R4 
;                            
;                          
;   x:  S1 S2 S3 Sx     y: k1 k2 k3 
; 
;        M0=3 (mod 4)       M4=2 (mod 3) 
; 
; 
;                                  SINGLE SECTION 
; 
;                
;                    t                t'     equations: 
;                                            t'=s*k+t, t'?t 
;                           k                 s'=t*k+s 
;                         
;                        
;                       
;                      
;                     
;                             k
;                            
;               
;                   s             s' 
;                                            DSP56000 IMPLEMENTATION 
; 
;                                                          	Program		ICycles
;                                                          	Words 
; move      #state,r0     ;point to state variable storage 
; move      #N,m0         ;N=number of k coefficients 
; move      #k,r4         ;point to k coefficients 
; move      #N-1,m4       ;mod for k's 
; 
; movep     y:datin,b     ;get input 
; 
; move      b,x:(r0)+  y:(r4)+,y0  ;save 1st state, get k    1       1 
; do        #N,_elat               ;do each section          2       3 
; move          x:(r0),a   b,y1    ;get s, copy t for mul    1       1 
; macr y1,y0,a             a,y0    ;t*k+s, copy s            1       1 
; macr x0,y0,b  a,x:(r0)+  y:(r4)+,y0 ;s*k+t, sv st, nxt k   1       1 
;_elat 
; move       x:(r0)-,x0 y:(r4)-,y0 ;adj r0,r4 w/dummy loads  1       1 
; 
; movep      b,y:datout    ;output sample                  -----   ----- 
;                                                   Totals:  7      3N+5 
; 
; 
;                                            DSP96002 IMPLEMENTATION 
; 
;                                                        	Program	ICyc
;                                                        	Words 
 move     #state,r0     ;point to state variable storage 
 move     #N,m0         ;N=number of k coefficients 
 move     #k,r4         ;point to k coefficients 
 move     #N-1,m4       ;mod for k's 
 
 move      y:datin,d5.s  ;get input 
 
 move                      d5.s,x:(r0)+ y:(r4)+,d4.s ;sv s,get k  1    1 
 do        #N,_elat                                  ;do filter   2    3 
 fmpy d5,d4,d3             x:(r0),d0.s               ;t*k, get s  1    1 
 fmpy d0,d4,d1 fadd.s d3,d0                          ;s*k,t*k+s   1    1 
               fadd.s d1,d5 d0.s,x:(r0)+ y:(r4)+,d4.s ;s*k+t; s,k 1    1 
_elat 
 move         x:(r0)-,d0.s y:(r4)-,d7.s ;adj r0,r4 w/dummy loads  1    1 
 
 movep        d5,y:datout            ;output sample 
;                                                                ---  --- 
;                                                        Totals:  7  3N+5 
