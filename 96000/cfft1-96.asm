;	Memory Size: Prog:  141 words ; Data:  5120 words
;	Number of clock cycles:	 41916 (20958 instruction cycles)   1024 pt.
;                             91626                              2048 pt.
;                            199194                              4096 pt.
;                            430666                              8192 pt.
;                            926330                             16384 pt.
;
;	Clock Frequency:	 40.0MHz
;	Instruction cycle time:	 50.0ns
;
;    
;**************************************************************************
; Motorola DSP Operations  28 February 1992                                
;**************************************************************************
;
; Complex, Radix 2 Cooley-Tukey Decimation in Time FFT
; Untested
CFFT1 	macro	 points,passes,data,coef,coefsize,odata
CFFT1 	ident 1,2
;
; Faster FFT using Programming Tricks found in Typical FORTRAN Libraries
;
;      First two passes combined as a four butterfly loop since
;            multiplies are trivial.
;            2.25 cycles internal (4 cycles external) per Radix 2 
;            butterfly.
;      Middle passes performed with traditional, triple-nested DO loop.
;            4 cycles internal (8 cycles external) per Radix 2 butterfly
;            plus overhead.  Note that a new pipelining technique is 
;            being used to minimize overhead.
;      Next to last pass performed with double butterfly loop.
;            4.5 cycles internal (8.5 cycles external) per Radix 2
;            butterfly.
;      Last pass has separate single butterfly loop.
;            5 cycles internal (9 cycles external) per Radix 2 
;            butterfly.
;
;      For 1024 complex points, average Radix 2 butterfly = 3.8 cycles
;      internal and 7.35 cycles external, assuming a single external
;      data bus.
;
;      Because of separate passes, minimum of 32 points using these
;      optimizations.  Approximately 150 program words required. 
;      Uses internal X and Y Data ROMs for twiddle factor coefficients
;      for any size FFT up to 1024 complex points.
;
;      Assuming internal program and internal data memory (or two
;      external data buses, 1024 point complex FFT is 1.57 msec at 
;      75 nsec instruction rate.  Assuming internal program and 
;      external data memory, 1024 point complex FFT is 2.94 msec 
;      at 75 nsec instruction rate.
;
; First two passes
;
;      9 cycles internal, 1.77X faster than 4 cycle Radix 2 bfy
;      16 cycles external, 2.0X faster than 4 cycle Radix 2 bfy
;
;      r0 = a pointer in & out
;      r6 = a pointer in at first two passes then points to twiddle factor
;      r4 = b pointer in & out
;      r1 = c pointer in & out
;      r5 = d pointer in & out
;      n5 = 2
;		 r2 = start base of input data of all passes, change at last pass
;
;      normally ordered input data
;      normally ordered output data
;
      move      #points,d1.l		;number of FFT input data
      move      #passes,d9.l		;passes=log2(points)
      move      #data,d0.l			;input data start location
      move      #coef,m2			;twiddle factor start location if DE=0
											;otherwise use internal sin and cos table 
      move      #coefsize,d2.l	;size of twiddle factor=points/2

      lsr      d1     d0.l,r0		;d1=points/2,     r0 points to base of input data 
      lsr      d1     r0,r2		;d1=points/4,		r2=base of input data
      add      d1,d0  d1.l,d8.l	;d0=point to b, 	d8=points/4
      add      d1,d0  d0.l,r4		;d0=pointer to c, r4 points to b
      add      d1,d0  d0.l,r1		;d0=pointer to d, r1 points to c
      lsr      d2     d0.l,r5		;d2=points/4,     r5 points to d
      lsr      d2     r0,r6		;d2=points/8,		r6 points to a
      move     #2,n5					;n5=2
      move     d2.l,n6				;n6=points/8
      move     #-1,m0				;linear address r0
      move     m0,m1			    	;linear address r1
      move     m0,m4			    	;linear address r4
      move     m0,m5				   ;linear address r5
      move     m0,m6				   ;linear address r6

      move     x:(r0),d1.s			;d1=ar
      move     x:(r1),d0.s       ;d0=cr      
      move     x:(r5)-,d2.s      ;d2=dr      
      move     y:(r5)+,d4.s      ;d4=the last data in ci,since di' is calculated at last, no slot for writing di' 
											;in current interation. See _twopass loop line 5 (l5) below.
      faddsub.s  d1,d0   x:(r4),d5.s  ;d5=br,d1=ar-cr,d0=ar+cr             
      faddsub.s  d5,d2   y:(r4),d7.s  ;d7=bi,d5=br-dr,d2=br+dr 
;
;      Combine first two passes with trivial multiplies.
;
      do      d8.l,_twopass

      faddsub.s  d0,d2                y:(r5),d6.s 		;d6=di,d0=ar+cr-(br+dr)=br',d2=ar+cr+br+dr=ar' 
      faddsub.s  d7,d6  d2.s,x:(r0)+  y:(r6)+,d3.s		;d3=ai,d7=bi-di,d6=bi+di,								 		PUT ar'
      faddsub.s  d1,d7  d0.s,x:(r4)   y:(r1)+,d2.s		;d2=ci,d1=ar-cr-(bi-di)=dr',d7=ar-cr+(bi-di)=cr',		PUT br' 
      faddsub.s  d3,d2  d1.s,x:(r5)-            		;d3=ai-ci,d2=ai+ci,										 		PUT dr' 
      faddsub.s  d2,d6  x:(r0)-,d1.s  d4.s,y:(r5)+n5	;d2=ai+ci-(bi+di)=bi',d6=ai+ci+bi+di=ai',d1=next ar,	PUT di'
																		;(l5) at first last ci move in,in next itera. di' was put in
      faddsub.s  d3,d5  x:(r1)-,d0.s  d2.s,y:(r4)+ 	;d3=ai-ci-(br-dr)=ci',d5=ai-ci+(br-dr)=di',d0=next cr,PUT bi' 
      faddsub.s  d1,d0  x:(r5),d2.s   d6.s,y:(r0)+ 	;d1=nar-ncr,d0=nar+ncr,d2=ndr,								PUT ai' 
      ftfr.s     d5,d4  x:(r4),d5.s   d3.s,y:(r1)  	;d4=di',d5=nbr,													PUT ci' 
      faddsub.s  d5,d2  d7.s,x:(r1)+  y:(r4),d7.s   	;d5=nbr-ndr,d7=nbi 												PUT cr' 
_twopass
      move                            d4.s,y:-(r5)		;PUT last di'			   
;
; Middle passes
;
      move     #4,d0.l											;d0=4=group per pass
      move     d9.l,d3.l										;d3=number of passes (log2(points))
      clr      d2         d8.l,d1.l							;d2=0,d1=points/4
      sub      d0,d3      d2.l,m6							;m6=0 bit reverse on r6!!!,d3-d0=remaining loop times

      do      d3.l,_end_pass				;do 6 times for 1024 points
      move    d0.l,n2						;n2=4=number of group in a pass, n2=n2*2 after each pass 
      move    r2,r0							;r0 points to first data A again 
      lsr     d1 r2,r1	    				;d1=input A and B offset=points/8 first time, then divided by 2 at each pass
		move 	  d1.l,n1						;n1=offset of input B,r1 inceased # of BF times in the _end_bfy loop
		inc	  d1	d1.l,d0.l 				;d1=offset of A,A' and B'=# of BF +1, 
      dec	  d0	m2,r6   					;r6 always points to 1st twidlle factor at each pass 	
		dec	  d0	d1.l,n0					;d1=BF-2=loop # of BF,because BF kernel only loops BF-2 times for 96k 	
		move 	  d0.l,n3											;n3=# of BF-2 in each group,n3=n3/2 after each pass
      move    n0,n4												;n0=offset of A, n4=offset of A'=# of BF +1,
      move    n0,n5												;n5=offset of B'
      move	  (r1)+n1   										;r1 points to B
      move    r0,r4												;r4 points to A'
      move    r1,r5												;r5 points to B'
      move               x:(r6)+n6,d9.s y:,d8.s			;d9=wr,d8=wi,twidlle with bit reverse addr. 
      move                              y:(r1),d7.s	;starts 3rd pass, all radix 2 BF,no c and d, d7=bi
      fmpy.s  d8,d7,d3   x:(r1)+,d6.s						;d6=br,d3=bi*wi
      fmpy.s  d9,d6,d0											;d0=br*wr
      fmpy.s  d9,d7,d1                  y:(r1),d7.s	;d1=bi*wr,d7=next bi
      fmpy    d8,d6,d2  fadd.s    d3,d0  x:(r0),d4.s	;d2=br*wi,d0=bi*wi+br*wr,d4=ar
      fmpy    d8,d7,d3  faddsub.s d4,d0  x:(r1)+,d6.s	;d3=nbi*wi,d4=ar-(bi*wi+br*wr)=br',d0=ar+(bi*wi+br*wr)=ar',d6=nbr

      do      n2,_end_grp										;do 4,8,16,.. groups in the pass

      do      n3,_end_bfy										;do (points/8)-2,points/16,points/32,... BFs in each pass

      fmpy    d9,d6,d0  fsub.s    d1,d2  d0.s,x:(r5)  y:(r0)+,d5.s 
																		;d0=nbr*wr,d1=bi*wr,d2=br*wi-bi*wr,d5=ai,				PUT ar' 
      fmpy    d9,d7,d1  faddsub.s d5,d2  d4.s,x:(r4)  y:(r1),d7.s  ;d1=nbi*wr,d5=ai-(br*wi-bi*wr)=ai'
																		;d2=ai+(br*wi-bi*wr)=bi',d7=nbi,							PUT br'
      fmpy    d8,d6,d2  fadd.s    d3,d0  x:(r0),d4.s  d2.s,y:(r4)+ 
																		;d2=nbr*wi,d0=nbr*wr+nbi*wi,d4=nar,						PUT bi'
      fmpy    d8,d7,d3  faddsub.s d4,d0  x:(r1)+,d6.s d5.s,y:(r5)+ ;  d6=nbr;d4=nar-(nbr*wr+nbi*wi)=nbr', 
																		;d3=nbi*wi,,d0=nar+(nbr*wr+nbi*wi)=nar',				PUT ai' 
_end_bfy

      move      (r1)+n1											;r1 points to b of the next group
      fmpy    d9,d6,d0  fsub.s     d1,d2  d0.s,x:(r5)    y:(r0)+,d5.s
																		;d0=nbr*wr,d1=nbi*wr,d2=nbr*wi-nbi*wr,d5=nai,	  PUT nar' 
      fmpy    d9,d7,d1  faddsub.s d5,d2  d4.s,x:(r4)    y:(r1),d7.s ;   d7=next group bi=ngbi,
																		;d1=nbi*wr,d5=ai-(br*wi-bi*wr)=ai',d2=ai+(br*wi-bi*wr)=bi',  PUT nbr'
      fmpy    d8,d6,d2  fadd.s     d3,d0  x:(r0),d4.s    d2.s,y:(r4)+
																		;d2=nbr*wi,d0=nbr*wr+nbi*wi,d4=nar,								PUT nbi'
      move                     x:(r6)+n6,d9.s y:,d8.s ;get another twiddle factor for next group, d9=wr,d8=wi
      fmpy    d8,d7,d3  faddsub.s d4,d0  x:(r1)+,d6.s   d5.s,y:(r5)+ ;	d4=nar-(nbr*wr+nbi*wi)=nbr',
																		;d3=nbi*wi,d0=nar+(nbr*wr+nbi*wi)=nar',						PUT nai' 
      fmpy    d9,d6,d0  fsub.s     d1,d2  d0.s,x:(r5)    y:(r0)+n0,d5.s
																		;d0=nbr*wr,d1=nbi*wr,d2=nbr*wi-nbi*wr,d5=nai,				PUT ngar' 
      fmpy    d9,d7,d1  faddsub.s d5,d2  d4.s,x:(r4)    y:(r1),d7.s
																		;d1=nbi*wr,d5=ai-(br*wi-bi*wr)=ai',d2=ai+(br*wi-bi*wr)=bi', PUT ngbr'
      fmpy    d8,d6,d2  fadd.s     d3,d0  x:(r0),d4.s    d2.s,y:(r4)+n4 ; inc B output pointer
																		;d2=nbr*wi,d0=nbr*wr+nbi*wi,d4=nar,							  PUT ngbi'
      fmpy    d8,d7,d3  faddsub.s d4,d0  x:(r1)+,d6.s   d5.s,y:(r5)+n5 ; inc A output pointer,d4=nar-(nbr*wr+nbi*wi)=nbr'  
																		;d3=nbi*wi,d0=nar+(nbr*wr+nbi*wi)=nar',						PUT ngai' 
_end_grp
      move     n2,d0.l											;n2 is # of group -> d0
      lsl      d0      n0,d1.l  								;double n2 # of group,d1=offset of A or B
_end_pass
;
; next to last pass
;
      move      d0.l,n2											;n2= # of group/2
      move      r2,r0											;r0 pointer of A, points to the first data
      move      r0,r4											;r4 pointer of A',points to the first data 
      lea      (r0+2),r1										;r1 pointer of B
      move      r1,r5											;r5 pointer of B'
      move      m2,r6											;the first twiddle factor
      move      #3,n0	                              ;offset of A
      move      n0,n1											;offset of B  
      move      n0,n4											;offset of A'
      move      n0,n5											;offset of B'
      move                              x:(r6)+n6,d9.s  y:,d8.s
      move                                              y:(r1),d7.s
      fmpy.s    d8,d7,d3                  x:(r1)+,d6.s
      fmpy.s    d9,d6,d0
      fmpy.s    d9,d7,d1                                  y:(r1),d7.s
      fmpy    d8,d6,d2  fadd.s     d3,d0  x:(r0),d4.s
      fmpy    d8,d7,d3  faddsub.s d4,d0  x:(r1)+n1,d6.s

      do      n2,_end_next
      fmpy    d9,d6,d0  fsub.s     d1,d2  d0.s,x:(r5)     y:(r0)+,d5.s
      fmpy    d9,d7,d1  faddsub.s d5,d2  d4.s,x:(r4)     y:(r1),d7.s
      fmpy    d8,d6,d2  fadd.s     d3,d0  x:(r0),d4.s     d2.s,y:(r4)+
      move                              x:(r6)+n6,d9.s  y:,d8.s
      fmpy    d8,d7,d3  faddsub.s d4,d0  x:(r1)+,d6.s    d5.s,y:(r5)+
      fmpy    d9,d6,d0  fsub.s     d1,d2  d0.s,x:(r5)     y:(r0)+n0,d5.s
      fmpy    d9,d7,d1  faddsub.s d5,d2  d4.s,x:(r4)     y:(r1),d7.s
      fmpy    d8,d6,d2  fadd.s     d3,d0  x:(r0),d4.s     d2.s,y:(r4)+n4
      fmpy    d8,d7,d3  faddsub.s d4,d0  x:(r1)+n1,d6.s  d5.s,y:(r5)+n5
_end_next
;
; last pass
;
      move      n2,d0.l											;# previous groups ->d0
      lsl       d0      r2,r0									;update # groups, r0 points to input data A
      move      d0.l,n2											;# stages ->n2
      move      #odata,r4	               				;r4 points to A' 
      lea       (r0)+,r1                    				;r1 points to B 
      move      r4,r2											;r2 points to A' 
		move      m2,r6                       				;r6 points to twiddle factors  
      move      #2,n0                       				;offset is 2 for A input pointer
      move      n0,n1											;offset is 2 for B input pointer
      lea	    (r2)+n2,r5	               				;r5 points to B' 
      move 	    #points/4,n4	               			;offset is #points/4 for A output pointer
      move      n4,n5											;offset is #points/4 for B output pointer
      move 	    #0,m4											;bit reversed addressing for A output pointer
		;move	    (r5)-n5											;predecrement pointer of B'
      move 	    m4,m5											;bit reversed addressing for B output pointer

      move                              x:(r6)+n6,d9.s  y:,d8.s 			;d9=wr,d8=wi
      move                                              y:(r1),d7.s		;d7=bi
      fmpy.s    d8,d7,d3                  x:(r1)+n1,d6.s						;d6=br,d3=bi*wi
      fmpy.s    d9,d6,d0																;d0=br*wr
      fmpy.s    d9,d7,d1                                  y:(r1),d7.s	;d1=bi*wr,d7=nbi
      fmpy    d8,d6,d2  fadd.s     d3,d0  x:(r0),d4.s							;d2=br*wi,d0=bi*wi+br*wr,d4=ar
      move                              x:(r6)+n6,d9.s  y:,d8.s			;d9=nwr,d8=nwi
      fmpy    d8,d7,d3  faddsub.s d4,d0  x:(r1)+n1,d6.s						;d3=nbi*wi,d4=br',d0=ar',d6=nbr

      do      n2,_end_last
      fmpy    d9,d6,d0  fsub.s     d1,d2  d0.s,x:(r5)   y:(r0)+n0,d5.s  ;PUT ar'
      fmpy    d9,d7,d1  faddsub.s d5,d2  d4.s,x:(r4)    y:(r1),d7.s		;PUT br'
      fmpy    d8,d6,d2  fadd.s     d3,d0  x:(r0),d4.s   d2.s,y:(r4)+n4	;PUT bi'
      move                              x:(r6)+n6,d9.s  y:,d8.s			;d9=wr,d8=wi
      fmpy    d8,d7,d3  faddsub.s d4,d0  x:(r1)+n1,d6.s  d5.s,y:(r5)+n5 ;PUT ai'
_end_last

    	endm 
