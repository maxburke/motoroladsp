; This program was originally published in the Motorola DSP96002 Users Manual
; and is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive West, Austin, Texas 78735-8598.  For
; more information, refer to the DSP96002 Users Manual, Appendix B, DSP
; Benchmarks.
;
; B.1.35	3-Dimensional Graphics Illumination  
;Illumination of objects in three dimensions consists of light from  three sources: diffuse lighting from 
;a point source, ambient light  and specular lighting.  Specular lighting is caused by an object  directly 
;reflecting the illumination source.  The following variables  describe the illumination process:  
;L     Direction vector to the point light source L={Lx,Ly,Lz} 
;N     Direction vector normal to the object N={Nx,Ny,Nz} 
;Ip    Intensity of the point source 
;;Kd    Diffuse reflection constant 0<= Kd <= 1.0 
;Ia    Intensity of ambient light 
;Ka    Ambient reflection constant 0<= Ka <= 1.0 
;R     Direction vector of reflection of the point source from the 
;      object R={Rx,Ry,Rz} 
;;V     Direction vector from the object to the viewpoint 
;Ks    Specular reflection constant 0<= Ks <= 1.0 
;
;It should be noted that all vectors are normalized to unit magnitude.  
;The illumination can be described several ways depending on the  complexity of the object and light 
;source:  
;I=Ip Kd L*N           Diffuse reflection 
; 
;I=Ia Ka + Ip Kd L*N   Ambient lighting and diffuse reflection 
; 
;I=Ia Ka + Ip(Kd L*N + Ks(R*V)**n) 
;                      Ambient lighting, diffuse reflection and 
;                      specular reflection (Phong model) 
;
;In the above equations, * represents a vector dot product such as  L*N = LxNx+LyNy+LzNz and ** 
;represents exponentiation.  
;Since the dot product of two normalized vectors is less than or equal  to one, the term Ks(R*V)**n is 
;less than one.  The value of this term  is found by using a 256 element lookup table with 256.0(R*V) 
;as an  index.  The value of n is an arbitrary term that is fixed for the  algorithm and depends on em-
;pirical conditions.  
;           X memory                     Y memory  
;  vec   R0 ?  Rx                  Vx 
;             Ry                  Vy 
;             Rz                  Vz 
;             Lx                  Nx 
;             Ly                  Ny 
;             Lz                  Nz 
;  ktbl  R4? 256.0 
;             address of spctbl 
;             Kd 
;             Ip 
;             Ia 
;             Ka 
;               3-D Graphics Illumination                 	Program	ICycles 
;                                                        	Words 
  move                         #vec,r0                 ; 2        2 
  move                         #ktbl,r4                ; 2        2 
  move                         x:(r0)+,d6.s y:,d7.s    ; 1        1 
  fmpy.s d6,d7,d0              x:(r0)+,d6.s y:,d7.s    ; 1        1 
  fmpy.s d6,d7,d1              x:(r0)+,d6.s y:,d7.s    ; 1        1 
  fmpy   d6,d7,d1 fadd.s d1,d0 x:(r0)+,d6.s y:,d7.s    ; 1        1 
  fmpy   d6,d7,d1 fadd.s d1,d0 x:(r4)+,d2.s            ; 1        1 
  fmpy.s d2,d0,d0              x:(r4)+,n1              ; 1        1 
  intrz  d0                    x:(r0)+,d6.s y:,d7.s    ; 1        1 
  fmpy.s d6,d7,d0              d0.l,r1                 ; 1        1 
  move                         x:(r0)+,d6.s y:,d7.s    ; 1        1 
  fmpy   d6,d7,d0 fadd.s d0,d1 x:(r1+n1),d2.s          ; 1        2 
  fadd.s d0,d1                 x:(r4)+,d0.s            ; 1        1 
  fmpy.s d0,d1,d1              x:(r4)+,d0.s            ; 1        1 
  fadd.s d1,d2                 x:(r4)+,d1.s            ; 1        1 
  fmpy.s d2,d0                 x:(r4),d2.s             ; 1        1 
  fmpy.s d1,d2,d1                                      ; 1        1 
  fadd.s d1,d0                                         ; 1        1 
                                                       ;---      --- 
                                            ;   Totals: 20       21 

;The illumination value I is in d0.  
;Reference: "Fundamentals of Interactive Computer Graphics", 
;           James D. Foley, Andries Van Dam 
;           Addison-Wesley 1982 
