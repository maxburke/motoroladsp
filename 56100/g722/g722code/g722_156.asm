	opt mu,cc
	page 60,60

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;										;
;; 	File		: g722_156.asm 				       	 	;
;;										;
;;	Date		: February 21 1992					;
;;										;
;;      Program for testing the encoder and decoder of G722. Including the QMF	;
;;	transmit and receive filters						;
;;										;
;;	Author(s)	: Jean-Pierre Petit					;
;;			  Speech Signal Processing Applications			;
;;			  Centre National d'Etudes des Telecommunications	;
;;			  LAA-TSS						;
;;			  Route de Tregastel - BP40				;
;;			  Lannion						;
;;			  France						;
;;										;
;;	Tel.		: N/A							;
;;										;
;;			  Phil Atherton						;
;;			  DSP Applications Group				;
;;			  Motorola Semiconductors Ltd				;
;;			  Colvilles Road					;
;;			  Kelvin Industrial Estate				;
;;			  East Kilbride						;
;;			  Scotland						;
;;										;
;;	Tel.		: (+44/0) 3552 40377					;
;;										;
;;	Target System	: DSP56156						;
;;			  16 bit Signal Processor				;
;;										;
;;	Registers used	: all							;
;;										;
;;	Inputs required	: Tx QMF & Encoder : Min. 14 bit 2's complement A/D	;
;;					     data @ 16 kHz sampling frequency	;
;;										;
;;			  Mode of G.722	   : from external file MODCOD.TST	;
;;			  Decoder						;
;;										;
;;	Outputs given	: Decoder & Rx QMF : 16 bit 2's complement D/A data	;
;;					     @ 16 kHz				;
;;										;
;;	Revision	: 1.02							;
;;										;										;
;;	Last Revision	: 14 February 1992					;
;;	Date									;
;;										;
;;      Notes: This version inludes the initialization of the data Ram on a	;
;;	hardware reset; this means that the program can be burned in a PROM.	;
;;										;
;; 	The mode of decoder is read in from a file by the Application system	;
;;	(file MODCOD.TST).							;
;;										;
;;	The ISDN network is simulated by looping ssi0 tx back to ssi0 rx	;
;;										;										;
;;	This version uses interrupts for the on chip codec board and polls	;
;;	the ssi0 rx rdf flag for ISDN data					;
;;										;
;;	This version requires a 32 MHz Extal frequency to generate the 16 kHz	;
;;	codec sampling frequency, 8 kHz ssi0 ISDN sampling frequency and the	;
;;	40 MHz core clock frequency.						;
;;		                                                                ;
;;       	    Copyright MOTOROLA and CNET France Telecom                  ;
;;                                                                   		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;      Interrupt equates
;;	=================
;;
a_ipl		equ $ffdf			; address of ipl reg
set_ipl		equ $00c0			; enable codec interrupts
set_mr		equ $fc				; no masked interrupt
;;
;;	Port C equates
;;	==============
;;
a_pcc		equ $ffc1			; port C control
set_pcc		equ $001f			; set port C as ssi0 
;;						; enable ssi0
;;
;;	SSI0 equates
;;	============
;;
a_txrx_0	equ $fff1			; address tx and rx
a_sr_0		equ $fff0			; address status reg. ssi0
a_crb_0		equ $ffd1			; address ssi0 crb
a_cra_0		equ $ffd0			; address ssi0 cra
;;
set_cra_0	equ $007d                       ; no ö 2 prescaler
						; 8 bits
						; normal operation
						; ö 125 gives 8 bits @ 8 kHz
						; clock rate for 32 MHz
						; crystal frequency
;;
set_crb_0a	equ $0430			; no rx or tx enable yet
set_crb_0	equ $3430                       ; rx & tx enable
						; normal mode
						; synchronous mode
						; active high frame sync.
						; word length frame sync.
						; msb first
						; data out rising clock edge
						; data in falling clock edge
						; internal clock
						; internal frame sync.
						; SC00 = tx frame sync output
;;
rdf_flag	equ $0008			; rdf flag bit position in
						; ssi0 
;;
;;	PLL Equates
;;	===========
;;
a_plcr		equ $ffdc			; PLL control register
;;
set_plcr	equ $404f			; Codec input clock = Extal/16
						; 56156 core clock  = Extal*(20ö16)
						; Clockout pin      = FExt/2 to Clk0
						; Not GSM mode
						; Not Low power mode
						; Enabled
;;
enable_pll	equ $4000			; PLL Enable bit
;;
;;
;;	Codec Equates
;;	=============
;;
a_codec_txrx	equ $ffe9			; Codec tx & rx register
;;
a_codec_cr	equ $ffc8			; Codec control register
a_codec_sr	equ $ffe8			; Codec status register 
;;
set_codec	equ $c404			; Enable codec interrupts
						; Enable codec
						; Microphone input
						; Microphone gain = -6 dB
						; Non-mute
						; Decimation/Interpolation
						; codec ratio = 125
						; Disable test bits
						; 0 dB gain
;;
;;****************************************************************
;;
;;	Simulation of hard reset
;;	========================
;;
	org	p:$00
	jmp 	prog
;;
;;	Interrupt Service routines
;;	==========================
;;
	org	p:$0010
	jsr 	roe_rx_0			; receive rx_0 execption
;;
	org	p:$0014
	jsr 	tue_tx_0			; transmit tx_0 exception
;;
	org	p:$002e			
	jsr	codec_data			; on-chip codec data ready
;;
;;
;;****************************************************************
;;
;;	Area of X RAM
;;	=============
;;
	org x:$00
;;
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;
;;	data for test
;;	=============
;;
temp_x0		ds	1	; temporary storage for x0
;;
mode		ds	1	; mode of decoder from MODCOD.TST file
;;
first_codec_tx	ds	1	; first G722 interpolated data to codec
second_codec_tx	ds	1	; second G722 interpolated data to codec
;;
first_codec_rx	ds	1	; first G722 data from codec
second_codec_rx	ds	1	; second G722 data from codec
;;
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;
;;	data for predictor in lower sub band coder
;;	==========================================
;;
dat_lsbcod 	ds 	23	; data ram for the lower sub band predictor
xl_cod 		ds 	1	; input of lsbcod
il_cod 		ds 	1	; output of lsbcod
;;
;;
;;	data for predictor in higher sub band coder
;;	===========================================
;;
dat_hsbcod 	ds 	23	; data ram for the higher sub band predictor
xh_cod 		ds 	1	; input of hsbcod
ih_cod 		ds 	1	; output of hsbcod
;;
;;	data for predictor in lower sub band decoder
;;	============================================
;;
dat_lsbdec 	ds 	23	; data ram for the lower sub band predictor
ilr_dec	 	ds 	1	; input of lsbdec
yl_dec 		ds 	1	; output of lsbdec
;;
;;;	data for predictor in higher sub band decoder
;;	=============================================
;;
dat_hsbdec 	ds 	23	; data ram for the higher sub band predictor
ihr_dec	 	ds 	1	; input of hsbdec
yh_dec 		ds 	1	; output of hsbdec
;;
;;	output of encoder
;;	=================
;;
is		ds 	1	; output code of encoder
;;
;;	input of decoder
;;	================
;;
ir		ds 	1	; receive code for input of decoder
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	============================================================
;;	This data ram area is initialized at reset by the init_const
;;	procedure
;;	============================================================
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Table for selection of decoder (mode)
;;	=====================================
;;
sel_mode	ds 	1	; for mode 1 = 64 kbit/s
		ds 	1	; for mode 2 = 56 kbit/s
		ds 	1	; for mode 3 = 48 kbit/s
;;
;;	constant area for lower sub band predictor
;;	==========================================
;;
const_pr_l 	ds 	1	; inverse 4 bits quantizer
		ds 	1	; log adaptation (4 bits)
		ds 	1	; multiplicand factor
		ds 	1	; upper limit of p_nbl (low sub band)
		ds 	1	; to compute shift right
		ds 	1	; table of 32 values
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	constant area for higher sub band predictor
;;	===========================================
;;
const_pr_h 	ds 	1	; inverse 2 bits quantizer
		ds 	1	; log adaptation (2 bits)
		ds 	1	; multiplicand factor
		ds 	1	; upper limit of p_nbl (high sub band)
		ds 	1	; to compute shift right
		ds 	1	; table of 32 values
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	quantizer thresholds (Q6) for lower sub_band encoder
;	====================================================
;
level__1	ds 	1	; Q6(-1)
level_0		ds 	1	; Q6( 0)
level_1		ds 	1	; Q6( 1)
level_2		ds 	1	; Q6( 2)
level_3		ds 	1	; Q6( 3)
level_4		ds 	1	; Q6( 4)
level_5		ds 	1	; Q6( 5)
level_6		ds 	1	; Q6( 6)
level_7		ds 	1	; Q6( 7)
level_8		ds 	1	; Q6( 8)
level_9		ds 	1	; Q6( 9)
level_10	ds 	1	; Q6(10)
level_11	ds 	1	; Q6(11)
level_12	ds 	1	; Q6(19)
level_13	ds 	1	; Q6(13)
level_14	ds 	1	; Q6(14)
level_15	ds 	1	; Q6(15)
level_16	ds 	1	; Q6(16)
level_17	ds 	1	; Q6(17)
level_18	ds 	1	; Q6(18)
level_19	ds 	1	; Q6(19)
level_20	ds 	1	; Q6(20)
level_21	ds 	1	; Q6(21)
level_22	ds 	1	; Q6(22)
level_23	ds 	1	; Q6(23)
level_24	ds 	1	; Q6(24)
level_25	ds 	1	; Q6(25)
level_26	ds 	1	; Q6(26)
level_27	ds 	1	; Q6(27)
level_28	ds 	1	; Q6(28)
level_29	ds 	1	; Q6(29)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Coefficients for QMF TX and RX filters
;;	======================================
;;	Note: they must be seen as H[23],H[22] and so on
;;	------------------------------------------------
;;
q_coef		ds 	24	; for 24 coeffiecents
;;
;;=====================================================================
;;		QMF sections
;;		============
;;=====================================================================
;;
;;	address for modulo arithmetic of delay TX line
;;	==============================================
	org	x:$100
;;
dat_q_tx	ds	24	; delay line for QMF tx filter
ptr_q_tx	ds	1	; modulo pointer to dat_q_tx
;;
;;
;;	address for modulo arithmetic of delay RX line
;;	==============================================
	org	x:$200
;;
dat_q_rx	ds	24	; delay line for QMF rx filter
ptr_q_rx	ds	1	; modulo pointer to dat_q_rx
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Beginning of test program
;;	========================
;;
		org 	p:$40
;;
prog		reset			; reset on chip peripherals
		nop			; for the pipeline
		nop
;;
		ori 	#$30,omr	; saturation 32 bits,rounding 2s
		nop			; for the pipeline
		nop
;;
;;	Reset section
;;	=============
;;
		jsr 	init_const	; init const in ram
		jsr 	reset_cod	; encoder reset
		jsr 	reset_dec	; decoder reset
		jsr 	init_q_tx	; reset qmf tx
		jsr 	init_q_rx	; reset qmf rx
;;
;;	==============================================================
;;	read mode of decoder (not significant for encoder)
;;	mode 1, 2 or 3 is valid (64, 56 and 48 kbits/sec)
;;	==============================================================
;;
;;	Apps input: select mode of decoder
;;	==================================
;;
		move	#$0101,x0	; file #1 with 1 values input
		move	#1,r1		; data resides in x memory
		move	#mode,r0 	; in variable x:mode

		org p:			; for reference
DEBI_CDMO	debug
		nop			; for the pipeline
		nop
;;
;;	Initialise PLL
;;	==============
;;
		move	#set_plcr,x0	; set pll operating mode in x0
		move	x0,x:a_plcr	; write to PLL control reg
;;
;;	Initialise Codec
;;	================
;;
		move	#set_codec,x0	; Codec operating mode in x0
		move	x0,x:a_codec_cr	; Write to codec control register		 
;;
;;	Initialise SSI0
;;	===============
;;
		move 	#set_cra_0,b	; set mode cra in x
		move 	b1,x:a_cra_0	; set mode in cra0

		move 	#set_crb_0a,b	; set mode crb in x0
		move 	b1,x:a_crb_0	; set mode in crb_0

		move 	#set_pcc,b	; for ssi in port c
		move 	b1,x:a_pcc	; set port c ssi0/1

		move 	b0,x:a_txrx_0	; write 0 to ssi0 tx
					; for init
		move	#set_crb_0,b	; enable tx & rx in ssi0
		move	b1,x:a_crb_0
;;
;;	Set interrupt priority and mode register
;;	========================================
;;
		move 	#set_ipl,x0	; set x0 with ipl
		move 	x0,x:a_ipl	; write ipl to enable codec interrupts
		andi 	#set_mr,mr	; unmask all interrupts
;;
;;
;;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;;
;;	==========
;;	Main loop
;;	==========

		do 	forever,sequence	; forever i/o loop
		
		nop
		nop
		nop
		
sequence
;;
;;***********************************************************************
;;*									*
;;*			End of Main program loop			*
;;*									*
;;***********************************************************************
;;
;;*******************************************************************
;;
;; 	Interrupt routine
;;	=================
;;
codec_data	bftsth	#rdf_flag,x:a_sr_0	; test for ISDN network 
		bcs	<isdn_rx		; reception, if yes then
						; process G722 decoder
;;
;;	Get 2nd 16 kHz codec data for qmf_tx
;;	====================================
;;
		move	x:a_codec_txrx,x0	; get last qmf_tx input 
		move	x0,x:second_codec_rx	; before G722 encoding
;;
;;	Beginning of G722 encoder
;;	=========================
;;
;;	Call qmftx procedure
;;	====================
;;
		jsr 	qmf_tx			; transmit qmf
;;
;;	Call encoder procedure
;;	======================
;;
		jsr 	encoder			; call G722 encoder
;;
;;	Send 2nd interpolated G722 data to codec
;;	========================================
;;
		move	x:second_codec_tx,x0	; transmit the second
		move	x0,x:a_codec_txrx	; interpolated G722 o/p
;;
		bra	<end_interrupt		; 8 kHz section completed
;;
;;	Network transmission
;;	====================
;;
isdn_rx		move	x:is,x0			; Get latest G722 encode data
		move	x0,x:a_txrx_0		; and send to line
;;
		move	x:a_txrx_0,x0		; Get latest ssi0 reception
		move	x0,x:ir			; and store in "ir"
;;
;;	Get 1st 16 kHz Codec data for qmf_tx
;;	====================================
;;
		move	x:a_codec_txrx,x0	; get the first	16 kHz	
		move	x0,x:first_codec_rx	; input data for qmf_tx
;;
;;	Call decoder procedure
;;	======================
;;
		jsr 	decoder			; call G722 decoder
;;
;;	Call qmfrx procdeure
;;	====================
;;
		jsr 	qmf_rx			; receive qmf
;;
;;	Send 1st interpolated G722 data to codec
;;	========================================
;;
		move	x:first_codec_tx,x0	; transmit the first
		move	x0,x:a_codec_txrx	; interpolated G722 o/p
;;
end_interrupt	rti
;;
;;***********************************************************************
;;*									*
;;*			End of interrupt routine			*
;;*									*
;;***********************************************************************
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;									;;
;; structure of variables for predictor in lower sub band coder       	;;
;;                                      in higher sub band coder      	;;
;;                                      in lower sub band decoder     	;;
;;                                      in higher sub band decoder    	;;
;; the address of this structure is passed to the subroutine predictor	;;
;; in the r2 address register                                         	;;
;; this structure need 23 words of ram that must be initialized for   	;;
;; correct oprationof the g722 algorithm (digital test sequence       	;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
delt 		equ 	0		;
sl    		equ 	1		; signal predicted
szl   		equ 	2		; output of the zero predictor
p_nbl 		equ 	3		; nabla of the predictor
al1   		equ 	4		; first pole predictor coefficient
al2   		equ 	5		; first pole predictor coefficient
bl1   		equ 	6		; zero predictor coefficient
bl2   		equ 	7		; zero predictor coefficient
bl3   		equ 	8		; zero predictor coefficient
bl4   		equ 	9		; zero predictor coefficient
bl5  		equ 	10		; zero predictor coefficient
bl6  		equ 	11		; zero predictor coefficient
rlt0 		equ 	12		; pole signal predictor
rlt1 		equ 	13		; pole signal predictor
dlt0 		equ 	14		; zero signal predictor
dlt1 		equ 	15		; zero signal predictor
dlt2 		equ 	16		; zero signal predictor
dlt3 		equ 	17		; zero signal predictor
dlt4 		equ 	18		; zero signal predictor
dlt5 		equ 	19		; zero signal predictor
dlt6 		equ 	20		; zero signal predictor
plt0 		equ 	21		; pole partial signal predictor
plt1 		equ 	22		; pole partial signal predictor
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
;   Encoder: G722 encoder                                           ;
;            Compute the output, is, from inputs, xl_cod and xh_cod ;
;            First compute il_cod from xl_cod (lsbcod procedure)    ;
;            Then compute ih_cod from xh_cod (hsbcod procedure)     ;
;            Finally compute is from il_cod and ih_cod              ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
;   Lsbcod : lower sub band coder                                   ;
;            Compute the output code il_cod from input xl_cod       ;
;            First compute el then quantize on 6 bits               ;
;								    ;
;   NOTE: entry point of encoder = lsbcod                           ;
;   =====================================                           ;
; 								    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
encoder		move 	x:xl_cod,a		; read xl_cod in a
		move 	x:(dat_lsbcod+sl),b	; read prediction
		sub 	b,a			; compute el in a
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
;   Quantl : lower sub band 6 bits quantizer                        ;
;            el in a                                                ;
;            This procedure use a mixed tree and direct search      ;
;            to minimize speed and size of code                     ;
;            A full binary search procedure would save 20 cycles    ;
;            (10 instructions) but at the expense of 100 words      ;
;            of program.                                            ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
quantl	move 	#cod_6_mi,b		; select table for el <0
	move 	#cod_6_pl,x0		; select table for el >0
	move 	#level_0,r2		; offset of table level in ram
	tst 	a			; test if sign of el <0
	tpl 	x0,b			; select table >0
	move 	b,r0			; save table in r0
	tfr 	a,b 	x:(r2+14),x0	; level 14 in x0
	move 	x:dat_lsbcod,y0		; y0 = detl
	inc24 	b			; to compute |el| of G722
	abs 	b  	x:(r2+6),x1	; level 6 in x1
	tst 	a			; test if a >=0
	tmi 	b,a			; a = |el| = wd
;
;;	Beginning of the tree search
;;	============================
;;
test_14	mpy 	y0,x0,b x:(r2+22),x0	; level 22 in x0
	move	b,b			; set lsp of b to 0
	cmp 	b,a			; test wd with level 14
	bpl 	<test_22		; if >0 go test_22
;
test_6	mpy 	y0,x1,b			; level 6 * detl
	move 	b,b			; set lsp of b to 0
	cmp 	b,a			; test wd with level 6
	bpl 	<init_7			; if >0 go to init_7
;
init__1	move 	#-1,n0			; set init of r0 index to -1
	move 	#level__1,r3		; set r3 to level__1
	move 	x:(r0)+n0,b		; dummy read to update r0 to r0-1
	bra 	<end_q6			; direct branch to end of procedure
;
init_7	move 	#7,n0			; set init of r0 index to 7
	move 	#level_7,r3		; set r3 to level_7
	move 	x:(r0)+n0,b		; dummy read to update r0 to r0+7
	bra 	<end_q6			; direct branch to end of procedure
;;
test_22	mpy 	y0,x0,b			; level 22 * detl
	move 	b,b			; set lsp to b 0
	cmp 	b,a			; test wd with level 22
	bpl 	<init_23		; if >0 go ro init_23
;
init_15	move 	#15,n0			; set init of r0 index to 15
	move 	#level_15,r3		; set r3 to level_15
	move 	x:(r0)+n0,b		; dummy read to update r0 to r0+15
	bra 	<end_q6			; direct branch to end of procedure
;
init_23	move 	#23,n0			; set init of r0 index to 23
	move 	#level_23,r3		; set r3 to level_23
	move 	x:(r0)+n0,b		; dummy read to update r0 to r0+23
	bra 	<end_q6			; direct branch to end of procedure
;
;;
;;	Beginning of direct search for 7 values of index
;;	================================================
;;
end_q6	move 	r0,r1			; set r1 to init of r0
	move 	x:(r3)+,x0		; read level -1,7,15,23
	mpy 	y0,x0,b  x:(r3)+,x0	; read level  0,8,16,24
	move 	b,y1			; set lsp of b to 0 (x1)
;
	mpy 	y0,x0,b x:(r0)+,x1 x:(r3)+,x0 	; r0++, read level 1,9,17,25
	cmp 	y1,a  	b,y1			; compare level -1,7,15,23
	tpl 	b,b  	r0,r1			; increment r1 if >0
;
	mpy 	y0,x0,b x:(r0)+,x1 x:(r3)+,x0 	; r0++, read level 2,10,18,26
	cmp 	y1,a  	b,y1			; compare level 0,8,16,24
	tpl 	b,b  	r0,r1			; increment r1 if >0
;
	mpy 	y0,x0,b x:(r0)+,x1 x:(r3)+,x0 	; r0++, read level 3,11,19,27
	cmp 	y1,a  	b,y1			; compare level 1,9,17,25
	tpl 	b,b  	r0,r1			; increment r1 if >0
;
	mpy 	y0,x0,b x:(r0)+,x1 x:(r3)+,x0 	; r0++, read level 4,12,20,28
	cmp 	y1,a  	b,y1			; compare level 2,10,18,26
	tpl 	b,b  	r0,r1			; increment r1 if >0
;
	mpy 	y0,x0,b x:(r0)+,x1 x:(r3)+,x0 	; r0++, read level 5,13,21,29
	cmp 	y1,a  	b,y1			; compare level 3,11,19,27
	tpl 	b,b  	r0,r1			; increment r1 if >0
;
	mpy 	y0,x0,b x:(r0)+,x1 x:(r3)+,x0 	; r0++, read level 6,14,22,30
	cmp 	y1,a  	b,y1			; compare level 4,12,20,28
	tpl 	b,b  	r0,r1			; increment r1 if >0
;
	cmp 	y1,a  	x:(r0)+,x1		; compare level 5,13,21,29
	tpl 	b,b  	r0,r1			; increment r1 if >0
;
	move 	#dat_lsbcod,r2		; set offset for lsbcod
	move 	p:(r1),a		; code il_cod in a
	move 	a,x:il_cod		; save code for lower sub_band
;;
;;	We must call subroutine pred_l
;;	==============================
;;
	move 	#const_pr_l,r3		; set constant table for low band
	jsr 	pred_l			; call subroutine pred_l
					; with il_cod in a
	move	 a,x:(r2+sl)		; save sl in lsbcod
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
;   Hsbcod : higher sub band coder                                  ;
;            Compute the output code ih_cod from input xh_cod       ;
;            First compute eh then quantize on 2 bits               ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
hsbcod	move 	#dat_hsbcod,r2		; set offset of data hsbcod
	move 	x:xh_cod,b		; read xh_cod in b
	move 	x:(r2+sl),a		; read prediction
	sub 	a,b  x:(r2+delt),y0	; compute eh in a
;					; read deth in y0
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                   ;
;   Quanth : higher sub band 2 bits quantizer                       ;
;            eh in a                                                ;
;                                                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
quanth	move 	#4512,x0		; level of quantization
	mpy 	y0,x0,a			; compute wd,save eh
	tst 	b  a,x1			; test for sign of eh
	bmi 	<cod_hi_mi		; if neg bra cod_hi_mi
	move 	#3,x0			; lower limit
	move 	#2,y0			; upper limit
	cmp 	x1,b  x0,a		; set a with lower limit
	tpl 	y0,a			; if plus =>upper limit
	bra 	<end_q2			; end of quant_h
;					; with ih in a
cod_hi_mi inc24 b
	abs 	b			; compute |eh|
	move 	#1,x0			; lower limit
	move 	#0,y0			; upper limit
	cmp 	x1,b  x0,a		; set a with lower limit
	tpl 	y0,a			; ih in a
;
end_q2	move a,x:ih_cod			; save code for higher sub_band
;;
;;	We must call subroutine pred_h
;;	==============================
;;
	move 	#const_pr_h,r3		; constant table for high band
	jsr 	pred_h			; call subrouinte pred_h
					; with ih_cod in a
	move 	a,x:(r2+sl)		; save sh in hsbcod
;;
;;	Computation of is code from il_cod and ih_cod
;;	=============================================
;;
	move 	x:il_cod,a		; read il in RAM
	move 	x:ih_cod,x0		; read ih in RAM
	move 	#64,y0			; for << 6
	imac 	y0,x0,a			; to compute cod
	move 	a,x:is			; save is code in RAM
	rts				; return of encoder
;;
;;	End of encoder procedure
;;	========================
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;									;;
;;	Subroutine decoder : compute yl_dec and yh_dec from ir     	;;
;;	                     First compute ilr_dec and ihr_dec     	;;
;;	                     Then execute lsbdec and hsbdec        	;;
;;                                                                 	;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
decoder	move 	x:ir,a			; read receive code ir
	move 	#63,x0			; set mask for ilr_dec
	move 	#3,y0			; set mask for ihr_dec
	asr 	a 	a,b		; shift a save a in b
	asr4 	a			; to compute ihr_dec
	asr 	a			; final shift of 6 shifts
	and 	y0,a			; mask ihr_dec
	and 	x0,b			; mask for ilr_dec
	move 	b,x:ilr_dec		; save ilr_dec
	move 	a,x:ihr_dec		; save ihr_dec
;;
;;	lsbdec
;;	======
;;
;;	Select mode of operation of lower sub band decoder
;;	==================================================
;;
	move 	#dat_lsbdec,r2		; set data ram
	move 	#sel_mode,r0		; load table sel_mode in r0
	move 	x:mode,a		; read mode of decoder
	and 	y0,a  	a0,x0		; mask mode bits, x0 == 0 (#3 still in y0)
	dec24 	a	b,y1		; compute modified mode, ilr_dec in y1
	tmi 	x0,a			; select default mode ==1
;;
;;	read table sel_mode
;;	===================
;;
	rep 	a1			; repeat 0 1 or 2 times
	asr 	b  x:(r0)+,x1		; shift and dummy read
	move 	b,n1			; offset for table QQ6,QQ5 or QQ4
	move 	x:(r0),r1		; selected table in r1
	move 	x:(r2+sl),b		; read prediction in b
	move 	x:(r1)+n1,x0		; dummy read to compute r1+n1
	move 	x:(r2),y0		; read detl in ram
	move 	p:(r1),x0		; read table of inverse quantizer
	mac 	y0,x0,b  y1,a		; compute yl, a = ilr_dec
	asl 	b			; limit yl to 16384
	asr 	b			; end of limiting
	move 	#const_pr_l,r3		; for lower predictor
	move 	b,x:yl_dec		; save reconstructed signal
;;
;;	call pred_l
;;	===========
;;
	jsr 	pred_l			; lower predictor
	move 	a,x:(r2+sl)		; save next prediction
;;
;;	hsbdec
;;	======
;;
	move 	#dat_hsbdec,r2		; select ram
	move 	#const_pr_h,r3		; select higher constant
	move 	x:ihr_dec,a		; read ih in a
;;
;;	call pred_h
;;	===========
;;
	jsr 	pred_h			; higher predictor
	move	x:(r2+dlt0),b		; reconstructed signal
	move 	x:(r2+sl),y1		; last prediction
	add 	y1,b  a,x:(r2+sl)	; compute yh, save new sl
	asl 	b			; limit yh
	asr 	b			; end of limiting
	move	b,x:yh_dec		; save yh_dec
;;
;;	end of decoder
;;	==============
;;
	rts
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	                                                               ;;
;;	Subroutine pred_l: compute invqal, logscl, scalel              ;;
;;	                   then compute the adaptive predictor         ;;
;;	Input : il in a (lower subband code)                           ;;
;;	        r3 must point on const_pr_l (constant for lower band)  ;;
;;	        r2 must point on data ram for lower band               ;;
;;	                                                               ;;
;;	Subroutine pred_h: compute invqah, logsch, scaleh              ;;
;;	                                                               ;;
;;	Input : ih in a (higher subband code)                          ;;
;;	        r3 must point on const_pr_h (constant for higher band) ;;
;;	        r2 must point on data ram for higher band              ;;
;;	                                                               ;;
;;	NOTE: pred_l and pred_h are the same but the entry point of    ;;
;;	      pred_h skip the >> 2 of input code                       ;;
;;	                                                               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Invaqal/h: inverse quantizer on 4/2 bits
;;	========================================
;;
;;	assume a = il/ih (level of quantizer)
;;
pred_l	lsr 	a
	lsr 	a			; to compute ilr = il >>2
pred_h	move 	a1,n0			; offset for table QQ4/QQ2
	move 	x:(r3)+,r0		; to address table QQ4/QQ2
	move 	n0,n1			; for table W4/W2
	move 	x:(r3)+,r1		; to address table W4/W2
	move 	x:(r0)+n0,x1		; table QQ4/QQ2 (dummy read)
	move 	x:(r2),x0		; detl =first data in structure
	move 	p:(r0),x1		; read inverse quantizer output
	mpy 	x1,x0,b x:(r1)+n1,x0	; b=detl*IQ4/IQ2, dummy read->r1+n1
	clr 	b   b,x:(r2+dlt0)	; b=0, save new dlt0 in ram
;;
;;	Begin Logscl/h
;;	==============
;;
	move 	x:(r3)+,x0		; x0 =32512
	move 	x:(r2+p_nbl),y1		; read old p_nbl
	mpy 	y1,x0,a  x:(r3)+,y0	; a= p_nbl*32512; y0=18432/22528)
	move 	p:(r1),y1		; read table W4/W2
	add 	y1,a			; compute p_nbl*32512 + wl in a
	tmi 	b,a			; limit to 0 if < 0
	cmp 	y0,a			; test if > 18432/22528
	tpl 	y0,a			; limit to 18432/22528
;;
;;	Begin Scalel/h
;;	==============
;;
	asr 	a  a,x:(r2+p_nbl)	; save new p_nbl
	asr 	a  x:(r3)+,x0		; to compute 9/11-wd2 = 1 +(8/10-wd2)
	asr4 	a			; a = p_nbl >> 6
	move 	x:(r3)+,r0		; to address the ILB table
	move 	#31,y1			; for mask
	and 	y1,a  a,b		; b = p_nbl >> 6
	move 	a1,n0			; offset of table ILB
	asr4 	b
	asr 	b   x:(r0)+n0,y1	; b = p_nbl>>11, dummy read,r0->
	tfr 	x0,b  b,y1		; b= 9/11, y1 = wd2 (lsp set to 0)
	sub 	y1,b			; b1 = 9/11 - wd2 (always >=0)
	move 	p:(r0),a		; read table ILB*2 (ie 9-wd2)
	rep 	b1			; b1 must be >=0
	asr 	a			; a = a >> (9/11-wd2)
	move 	a,a			; set lsp of a  to 0
	asl 	a
	asl 	a			; a = a << 2
	move 	a,x:(r2)		; save new detl
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                   	;;
;;            Predictor : compute the following equations of the     	;;
;;            ========= : G722 predictor (see detailed recommendation	;;
;;                      : and 'C' program)                     		;;
;;                      :          upzero(dlt,bl);                   	;;
;;                      :          plt[0]=parrec(dlt[0],szl);        	;;
;;                      :          rlt[0]=recons(sl,dlt[0]);         	;;
;;                      :          uppol2(al,plt);                   	;;
;;                      :          uppol1(al,plt);                   	;;
;;                      :          szl=filtez(dlt,bl);               	;;
;;                      :          spl=filtep(rlt,al);               	;;
;;                      :          sl=predic(spl,szl);               	;;
;;                                                                   	;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
predictor clr b  x:(r2+dlt0),a	; a = dlt0, b=0
	move 	#64,x0		; x0 = 128/2
	move 	#-64,y0		; y0 = -128/2
	tst 	a		; set flag
	tgt 	x0,b		; if >0 b =64
	tlt 	y0,b		; if < 0 b=-64 (else b=0)
	asl 	b  b0,y1	; b=2*b; y1 = 0
	move 	b,y0		; sign suppressed in y
;;
;;	address computation
;;	===================
;;
	move 	#dlt6,n2	; for address computation
	move 	#-2,n0		; for updating the delay line
	lea 	(r2)+n2,r0	; r0 = address of dlt6
	move 	#bl6,n2		; for adress computation
	move 	n0,n3		; idem
	lea 	(r2)+n2,r3	; r3 = address of bl6
;;
;;	upzero
;;	======
;;
	move 	#32640,x1		; fixed coefficient for bli
	move 	x:(r0)+,a x:(r3)+,x0	; a= dlt6, x0 = bl6
	add 	y,a	(r0)+n0		; a= dlt6+wd1, r0 = &dlt5
	abs 	a	(r3)+n3		; set sign of a0, r3 =&bl5
	mpy 	x1,x0,b	a0,x0		; x0 = wd2, b= 32640*bl6
	add 	x0,b x:(r0)+,a x:(r3)+,x0 ; b = new bl6, a= dlt5,x0= bl5
;;
;;	loop for the following bli
;;	==========================
;;
	do 	#5,end_upzero
	add 	y,a	a,x:(r0)+n0	;save dlti in dlti-1,r0 =&dlti+1
	abs 	a	b,x:(r3)+n3	; save bli
	mpy 	x1,x0,b	a0,x0		; x0 = wd2, b= 32640*bli-1
	add 	x0,b	x:(r0)+,a x:(r3)+,x0	;b =new bli-1
end_upzero
;;
;;	We must compute the new plt0 and the rlt0 and save 2*dlt0 in dlt1
;;	for the filtez computation
;;	Also we must save the new bl1 coefficients in ram
;;	=================================================
;;
	tfr 	a,x0  b,x:(r3)+		; x0=a=dlt0, save bl1 in ram
	asl 	a  x:(r2+szl),b		; a=2*dlt0, b= szl
	add 	x0,b x:(r2+plt1),x1	; b= plt0, x1=plt1 (ie plt2)
	tfr 	b,y1  a,x:(r0)+		; save 2*dlt0 in dlt1
	eor 	x1,b  x:(r2+sl),a	; sg0^sg2=b, a= sl
	add 	x0,a  x:(r2+plt0),x0	; a= rlt0, x0 = plt0 (ie plt1)
	asl 	a     x0,x:(r2+plt1)	; a=2*rlt0, save new plt1
	tfr 	y1,a  a,x:(r2+rlt0)	; a= plt0, save 2*rlt0 in ram
	eor 	x0,a  y1,x:(r2+plt0)	; sg0^sg1=a, save new plt0

;;	uppol2 and uppol1
;;	=================
;;
;;	uppol2
;;	======
;;
	move 	a1,x1			; x1 = sg0 ^ sg1
	move 	b1,y1			; y1 = sg0 ^ sg2
	move 	x:(r2+al1),a		; a= al1
	move 	#-192,b			; b=-192
	neg 	b	b,y0		; b =192, y0 = -192
	asl 	a			; to compute wd1
	asl 	a			; for limiting and fixe a0 to 0
	neg 	a	a,x0		; a= -wd1 , x0 = wd1 (4*al1)
	tst 	x1			; test if sg0 ^ sg1 == 1 or 0
	tlt 	x0,a			; if 1 a= wd1 ==>wd2
	tlt 	y0,b			; if 1 b = -192 (wd1 of uppol1)
	asr4 	a			; wd2 >>4
	asr4 	a			; wd2 >>4
	asl 	a	b,y0		; wd2 <<1
					; y0 = wd1_uppol1
	move 	#128,b			; for wd3
	move 	#-128,x0		; for -wd3
	tst 	y1			; test sg0 ^ sg2
	tlt 	x0,b			; set b to wd3
	add 	a,b	x:(r2+al2),x0	; b= wd4, read al2 in x0
	move 	#32512,y1		; set 32512 in y1
	move 	b,b			; limit wd4
	mac 	y1,x0,b			; b= apl2
	move 	#-12288,a		; set lower limit in a
	move 	b,b			; limit apl2
	neg 	a	a,x0		; a= 12288, x0=-12288
	cmp 	a,b			; compare apl2 with +12288
	tpl 	a,b			; set b to 12288 if gt
	cmp 	x0,b			; compare apl2 with -12288
	tmi 	x0,b			; set b to -12288 if lt
	tfr 	y0,a b,x:(r2+al2)	; y0 = wd1, save new al2
;;
;;	uppol1
;;	======
;;
	move 	#15360,x0		; to compute wd3
	sub 	x0,b	x:(r2+al1),x0	; b = -wd3, x0 = al1
	neg 	b	b,y0		; b = wd3 , y0 = -wd3
	move 	#32640,x1		; factor of al1
	mac 	x0,x1,a			; a= apl1
	move 	a,a			; limit apl1
	cmp 	b,a			; test if a > wd3
	tpl 	b,a			; set a to wd3 if gt
	cmp 	y0,a			; test if a < wd3
	tmi 	y0,a			; set to -wd3 if lt
;;
;;	filtez
;;	======
;;
	move 	#dlt6,n2		; for computation updating
	move 	#-1,n0			; n0 = -1
	lea 	(r2)+n2,r0		; r0 = address of dlt6
	move 	#bl6,n2			;
	move 	n0,n3			; n3 =-1
	lea 	(r2)+n2,r3		; r3 = address of bl6
;;
	move 	a,x:(r2+al1)		; save new al1
;;
	move 	x:(r0)+n0,y1 x:(r3)+n3,x1		; y1 =dlt6, x1 = bl6
	mpy 	x1,y1,a x:(r0)+n0,y1 x:(r3)+n3,x1	; y1 =dlt5, x1 = bl5
	move 	a,a					; limit partial product
	mac 	x1,y1,a x:(r0)+n0,y1 x:(r3)+n3,x1	; y1 =dlt4, x1 = bl4
	move 	a,a					; limit partial product
	mac 	x1,y1,a x:(r0)+n0,y1 x:(r3)+n3,x1	; y1 =dlt3, x1 = bl3
	move 	a,a					; limit partial product
	mac 	x1,y1,a x:(r0)+n0,y1 x:(r3)+n3,x1	; y1 =dlt2, x1 = bl2
	move 	a,a					; limit partial product
	mac 	x1,y1,a x:(r0)+n0,y1 x:(r3)+n3,x1	; y1 =dlt1, x1 = bl1
	move 	a,a					; limit partial product
	mac 	x1,y1,a x:(r0)+n0,y1 x:(r3)+n3,x1	; y1 =dlt0, x1 = al2
;;							; a = szl then limit in x0
;;
;;	filtep
;;	======
;;

	tfr 	a,x0	x:(r0)+n0,y1			; y1 =rlt1, x0 =szl
	mpy 	x1,y1,a x:(r0)+,y1 x:(r3)+n3,x1		; y1 =rlt0, x1 = al1
	move 	a,a					; limit al2 * rlt2
	mac 	x1,y1,a x0,x:(r2+szl)			; save szl
	add 	x0,a    y1,x:(r0)+			; rlt0 in rlt1
                        				; prediction in accu a
;;
;;	return of subroutine pred_l or pred_h
;;
;;	===============================================================
;;	WARNING: the prediction sl or sh is in accu A and must be saved
;;	         in the calling procedure
;;	===============================================================
;;
	rts
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								    ;
;  reset_cod: subroutine to reset the encoder (lower and higher)    ;
;             state variables                                       ;
;             We must call this subroutine in order to pass the     ;
;             digital test sequences of the CCITT G722              ;
;								    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
reset_cod move 	#dat_lsbcod,r0		; pointer to data of l_coder
	move 	#32,x0			; set detl for reset
	move 	x0,x:(r0)+		; save in memory
	clr 	a			; set a to 0
	rep 	#22			; set 22 state variables to 0
	move 	a,x:(r0)+		; end for coder_low
;
	move 	#dat_hsbcod,r0		; pointer to data of h_coder
	move 	#8,x0			; set deth for reset
	move 	x0,x:(r0)+		; save in memory
	rep 	#22			; set 22 state variables to 0
	move 	a,x:(r0)+		; end for coder_high
;
	rts				; return of subroutine
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								    ;
;  reset_dec: subroutine to reset the decoder (lower and higher)    ;
;             states variables                                      ;
;             We must call this subroutine in order to pass the     ;
;             digital test sequences of CCITT G722                  ;
;								    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
reset_dec move 	#dat_lsbdec,r0		; pointer to data of l_decoder
	move 	#32,x0			; set detl for reset
	move 	x0,x:(r0)+		; save in memory
	clr 	a			; set a to 0
	rep 	#22			; set 22 state variables to 0
	move	a,x:(r0)+		; end for decoder_low
;
	move 	#dat_hsbdec,r0		; pointer to data of h_decoder
	move 	#8,x0			; set deth for reset
	move 	x0,x:(r0)+		; save in memory
	rep 	#22			; set 22 state variables to 0
	move 	a,x:(r0)+		; end for decoder_low
;
	rts				; return of subroutine
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Subroutine to initialise qmf TX filter
;;	======================================
;;	Set to 0 all the delay line and initialize the pointer
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
init_q_tx move #dat_q_tx,r0		; adress of delay line
	clr 	a			; a to 0
	move 	r0,x:ptr_q_tx		; save pointer value
	rep 	#24			; for 24 elements
	move 	a,x:(r0)+		; set all the line to 0
	rts				; end of subprogram
;;
;;	end of init_q_tx
;;	================
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Subroutine to initialise qmf RX filter
;;	======================================
;;	Set to 0 all the delay line and initialize the pointer
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
init_q_rx move 	#dat_q_rx,r0		; address of delay line
	clr 	a			; a to 0
	move 	r0,x:ptr_q_rx		; save pointer value
	rep 	#24			; for 24 elements
	move	a,x:(r0)+		; set all the line to 0
	rts				; end of subprogram
;;
;;	end of init_q_rx
;;	================
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Subroutine to initialise constant in data ram
;;	=============================================
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
init_const move #pr_sel_mode,r0		; start of sel_mode
	move 	#sel_mode,r3		; in ram
	rep 	#3			; for 3 values
	move 	p:(r0)+,x:(r3)+		; prom_ram
;;
	move 	#pr_const_pr_l,r0	; start of const_pr_l
	move 	#const_pr_l,r3		; in ram
	rep 	#6			; for 3 values
	move 	p:(r0)+,x:(r3)+		; prom_ram
;;
	move 	#pr_const_pr_h,r0	; start of const_pr_h
	move 	#const_pr_h,r3		; in ram
	rep 	#6			; for 3 values
	move 	p:(r0)+,x:(r3)+		; prom_ram
;;
	move 	#pr_level__1,r0		; start of level__1
	move 	#level__1,r3		; in ram
	rep 	#31			; for 3 values
	move 	p:(r0)+,x:(r3)+		; prom_ram
;;
	move 	#pr_q_coef,r0		; start of q_ceof
	move 	#q_coef,r3		; in ram
	rep 	#24			; for 3 values
	move 	p:(r0)+,x:(r3)+		; prom_ram
;;

	rts				; end of subprogram
;;
;;	end of init_const
;;	=================
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Subroutine qmf_tx: 	transmit QMF filter operating at 8 kHz
;;				input two samples at 16 kHz and output 
;;				a low_band value and a high_band value
;;
;;	The input values are first_codec_rx and second_codec_rx
;;	The ouput values are xl_cod and xh_cod
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
qmf_tx	move 	x:ptr_q_tx,r0		; recall pointer
	move 	m0,x:ptr_q_tx		; save m0 value
	move 	#23,m0			; modulo 24 for the delay line
	move 	#q_coef,r3		; for QMF TX and RX coefficients
;;
;;	Read the two values from ADC converter and scale them
;;	ADC is supposed to be 16 bits (left justfified,14 bits precison)
;;	================================================================
;;
	move 	x:first_codec_rx,b	; the first codec reception
	move 	x:second_codec_rx,a	; the second codec reception
	move 	b,x:(r0)+		; save first in modulo delay line
	move 	a,x:(r0)+		; save second in modulo delay line
					; r0 points on H[23]
;;
;;	Begin mac operation: ACCUMA in a and ACCUMB in b
;;	================================================
;;
	clr 	a	x:(r0)+,y0	; read xin[23]
	clr 	b	x:(r3)+,x0	; read h[23]

	do 	#12,end_q_tx			; for 12 values
	mac 	x0,y0,b  x:(r0)+,y1  x:(r3)+,x1 ; mac and read next values
	mac 	x1,y1,a  x:(r0)+,y0  x:(r3)+,x0 ; mac and read next values
end_q_tx					; end of do loop
;;
;;	Now save updated pointer and end the computation of xl_cod an xh
;;	===============================================================
;;
	tfr 	b,x			; save 32 bit result in x
	add 	a,b	(r0)-		; compute xl_cod
	sub 	x,a			; compute xh_cod
;;
;;	Limiting the output values
;;	==========================
;;
	asl 	a			; times 2
	asr 	a			; linited to -16384 and +16383
	asl 	b			; times 2
	asr 	b			; linited to -16384 and +16383
	move 	b,x:xl_cod		; for input of lsbcod
	move 	a,x:xh_cod		; for input of hsbdec
	move 	x:ptr_q_tx,m0		; recall m0 value
	move 	r0,x:ptr_q_tx		; save modulo pointer
;;
;;	end of qmf_tx subroutine
;;	========================
;;
	rts
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Subroutine for RX QMF filter
;;	Compute two values from yl_dec and yh_dec (output of lsbdec and
;;	hsbdec); the outputs are first_codec_tx and second_codec_tx.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
qmf_rx	move 	x:ptr_q_rx,r0		; recall saved pointer
	move 	m0,x:ptr_q_rx		; save old value of m0
	move 	#23,m0			; modulo 24 pointer
	move 	#q_coef,r3		; address of coefficients
;;
;;	Compute XS and XD (RECB and RECA) G722 procedure
;;	================================================
;;
	move 	x:yl_dec,a		; recall yl = rl G722
	move 	x:yh_dec,b		; recall yh = rh G722
	add 	a,b	b,y0		; xs in b, x0 = rh
	sub 	y0,a	b,x:(r0)+	; xd in a, save xs
	move 	a,x:(r0)+		; save xd in delay line
					; now r0 points on xs11
;;
;;	Begin mac computation
;;	=====================
;;
	clr 	a	x:(r0)+,y0	; read xs11
	clr 	b	x:(r3)+,x0	; read H[23]
;;
	do 	#12,end_q_rx			; for 12 values
	mac 	x0,y0,b  x:(r0)+,y1  x:(r3)+,x1 ; mac and read next values
	mac 	x1,y1,a  x:(r0)+,y0  x:(r3)+,x0 ; mac and read next values
end_q_rx					; end of do loop
;;
;;	Scaling for output
;;	==================
;;
	asl 	a	(r0)-		; for times 2
	asl 	b			; for times 2
	asl 	a			; for coefficients scaling
	asl 	a			; 
	asl 	b			; for coefficients scaling
	asl 	b			; 
	move 	b,x:second_codec_tx	; the second DAC output
	move 	a,x:first_codec_tx	; the first DAC output
	move 	x:ptr_q_rx,m0		; recall m0 value
	move 	r0,x:ptr_q_rx		; save modulo pointer
;;
;;	End of subroutine qmf_rx
;;	========================
;;
	rts
;;
;;
;;	SSIO interrupt with exception section
;;	=====================================
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;		transmit underrun error 
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
roe_rx_0 	nop				; follows the normal interrupt
	 	move 	x0,x:temp_x0		; save register x0
;;
		rep	#2
	 	move 	x:a_sr_0,x0		; clear execption
;;
		move 	x:a_txrx_0,x0		; read received word
;;
		move 	x:temp_x0,x0		; restore x0
;;
		rti
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;		transmit underrun error 
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
tue_tx_0 	nop				; follows the normal interrupt
	 	move 	x0,x:temp_x0		; save register x0
;;
		rep	#2
	 	move 	x:a_sr_0,x0		; clear execption
;;
		move 	x0,x:a_txrx_0		; write transmit word
;;
		move 	x:temp_x0,x0		; restore x0
;;
		rti
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	Table for coding il in lower sub band
;	=====================================
;
cod_6_mi	dc 	%0000000000111111
		dc 	%0000000000111111
		dc 	%0000000000111110
		dc 	%0000000000011111
		dc 	%0000000000011110
		dc 	%0000000000011101
		dc 	%0000000000011100
		dc 	%0000000000011011
		dc 	%0000000000011010
		dc 	%0000000000011001
		dc 	%0000000000011000
		dc 	%0000000000010111
		dc 	%0000000000010110
		dc 	%0000000000010101
		dc 	%0000000000010100
		dc 	%0000000000010011
		dc 	%0000000000010010
		dc 	%0000000000010001
		dc 	%0000000000010000
		dc 	%0000000000001111
		dc 	%0000000000001110
		dc 	%0000000000001101
		dc 	%0000000000001100
		dc 	%0000000000001011
		dc 	%0000000000001010
		dc 	%0000000000001001
		dc 	%0000000000001000
		dc 	%0000000000000111
		dc 	%0000000000000110
		dc 	%0000000000000101
		dc 	%0000000000000100
		dc 	%0000000000000100
		dc 	%0000000000000100
;	
;
cod_6_pl	dc 	%0000000000111101
		dc 	%0000000000111101
		dc 	%0000000000111100
		dc 	%0000000000111011
		dc 	%0000000000111010
		dc 	%0000000000111001
		dc 	%0000000000111000
		dc 	%0000000000110111
		dc 	%0000000000110110
		dc 	%0000000000110101
		dc 	%0000000000110100
		dc 	%0000000000110011
		dc 	%0000000000110010
		dc 	%0000000000110001
		dc 	%0000000000110000
		dc 	%0000000000101111
		dc 	%0000000000101110
		dc 	%0000000000101101
		dc 	%0000000000101100
		dc 	%0000000000101011
		dc 	%0000000000101010
		dc 	%0000000000101001
		dc 	%0000000000101000
		dc 	%0000000000100111
		dc 	%0000000000100110
		dc 	%0000000000100101
		dc 	%0000000000100100
		dc 	%0000000000100011
		dc 	%0000000000100010
		dc 	%0000000000100001
		dc 	%0000000000100000
		dc 	%0000000000100000
		dc 	%0000000000100000
;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Table ILB for scalel
;;	====================
;;	Note: table ILB is scaled by 2 to avoid check of 8-wd2 <0
;;	====  in the shift operation
;;
;;
ILB		dc 	2048*2
		dc 	2093*2
		dc 	2139*2
		dc 	2186*2
		dc 	2233*2
		dc 	2282*2
		dc 	2332*2
		dc 	2383*2
		dc 	2435*2
		dc 	2489*2
		dc 	2543*2
		dc 	2599*2
		dc 	2656*2
		dc 	2714*2
		dc 	2774*2
		dc 	2834*2
		dc 	2896*2
		dc 	2960*2
		dc 	3025*2
		dc 	3091*2
		dc 	3158*2
		dc 	3228*2
		dc 	3298*2
		dc 	3371*2
		dc 	3444*2
		dc 	3520*2
		dc 	3597*2
		dc 	3676*2
		dc 	3756*2
		dc 	3838*2
		dc 	3922*2
		dc 	4008*2
;;	
;;	end of table ILB
;;	================
;
;	quantiser thresholds (Q6) for lower sub_band encoder
;	====================================================
;
INICOD		dc	   0*8		; Q6( 0)
		dc	  35*8		; Q6( 1)
		dc	  72*8		; Q6( 2)
		dc	 110*8		; Q6( 3)
		dc	 150*8		; Q6( 4)
		dc	 190*8		; Q6( 5)
		dc	 233*8		; Q6( 6)
		dc	 276*8		; Q6( 7)
		dc	 323*8		; Q6( 8)
		dc	 370*8		; Q6( 9)
		dc	 422*8		; Q6(10)
		dc	 473*8		; Q6(11)
		dc	 530*8		; Q6(19)
		dc	 587*8		; Q6(13)
		dc	 650*8		; Q6(14)
		dc	 714*8		; Q6(15)
		dc	 786*8		; Q6(16)
		dc	 858*8		; Q6(17)
		dc	 940*8		; Q6(18)
		dc	1023*8		; Q6(19)
		dc	1121*8		; Q6(20)
		dc	1219*8		; Q6(21)
		dc	1339*8		; Q6(22)
		dc	1458*8		; Q6(23)
		dc	1612*8		; Q6(24)
		dc	1765*8		; Q6(25)
		dc	1980*8		; Q6(26)
		dc	2195*8		; Q6(27)
		dc	2557*8		; Q6(28)
		dc	2919*8		; Q6(29)
		dc	2919*8		; Q6(30)
		dc	2919*8		; Q6(31)
;
;
;	Inverse quantizer (Q6)
;	======================
;
QQ6		dc	  -17*8		; code 000000
		dc	  -17*8		; code 000001
		dc	  -17*8		; code 000010
		dc	  -17*8		; code 000011
		dc 	-3101*8		; code 000100
		dc	-2738*8		; code 000101
		dc	-2376*8		; code 000110
		dc	-2088*8		; code 000111
		dc	-1873*8		; code 001000
		dc	-1689*8		; code 001001
		dc	-1535*8		; code 001010
		dc	-1399*8		; code 001011
		dc	-1279*8		; code 001100
		dc	-1170*8		; code 001101
		dc	-1072*8		; code 001110
		dc	 -982*8		; code 001111
		dc	 -899*8		; code 010000
		dc	 -822*8		; code 010001
		dc	 -750*8		; code 010010
		dc	 -682*8		; code 010011
		dc	 -618*8		; code 010100
		dc	 -558*8		; code 010101
		dc	 -501*8		; code 010110
		dc	 -447*8		; code 010111
		dc	 -396*8		; code 011000
		dc	 -347*8		; code 011001
		dc	 -300*8		; code 011010
		dc	 -254*8		; code 011011
		dc	 -211*8		; code 011100
		dc	 -170*8		; code 011101
		dc	 -130*8		; code 011110
		dc	  -91*8		; code 011111
		dc	 3101*8		; code 100000
		dc	 2738*8		; code 100001
		dc	 2376*8		; code 100010
		dc	 2088*8		; code 100011
		dc	 1873*8		; code 100100
		dc	 1689*8		; code 100101
		dc	 1535*8		; code 100110
		dc	 1399*8		; code 100111
		dc	 1279*8		; code 101000
		dc	 1170*8		; code 101001
		dc	 1072*8		; code 101010
		dc	  982*8		; code 101011
		dc	  899*8		; code 101100
		dc	  822*8		; code 101101
		dc	  750*8		; code 101110
		dc	  682*8		; code 101111
		dc	  618*8		; code 110000
		dc	  558*8		; code 110001
		dc	  501*8		; code 110010
		dc	  447*8		; code 110011
		dc	  396*8		; code 110100
		dc	  347*8		; code 110101
		dc	  300*8		; code 110110
		dc	  254*8		; code 110111
		dc	  211*8		; code 111000
		dc	  170*8		; code 111001
		dc	  130*8		; code 111010
		dc	   91*8		; code 111011
		dc	   54*8		; code 111100
		dc	   17*8		; code 111101
		dc	  -54*8		; code 111110
		dc	  -17*8		; code 111111
;;	
;
;	Inverse quantizer (Q5)
;	======================
;
QQ5		dc	  -35*8		; code 00000
		dc	  -35*8		; code 00001
		dc	-2919*8		; code 00010
		dc	-2195*8		; code 00011
		dc	-1765*8		; code 00100
		dc	-1458*8		; code 00101
		dc	-1219*8		; code 00110
		dc	-1023*8		; code 00111
		dc	 -858*8		; code 01000
		dc	 -714*8		; code 01001
		dc	 -587*8		; code 01010
		dc	 -473*8		; code 01011
		dc	 -370*8		; code 01100
		dc	 -276*8		; code 01101
		dc	 -190*8		; code 01110
		dc	 -110*8		; code 01111
		dc	 2919*8		; code 10000
		dc	 2195*8		; code 10001
		dc	 1765*8		; code 10010
		dc	 1458*8		; code 10011
		dc	 1219*8		; code 10100
		dc	 1023*8		; code 10101
		dc	  858*8		; code 10110
		dc	  714*8		; code 10111
		dc	  587*8		; code 11000
		dc	  473*8		; code 11001
		dc	  370*8		; code 11010
		dc	  276*8		; code 11011
		dc	  190*8		; code 11100
		dc	  110*8		; code 11101
		dc	   35*8		; code 11110
		dc	  -35*8		; code 11111
;;	
;	
;	Inverse quantizer (Q4)
;	======================
;
QQ4		dc	    0*8		; code 0000
		dc	-2557*8		; code 0001
		dc	-1612*8		; code 0010
		dc	-1121*8		; code 0011
		dc	 -786*8		; code 0100
		dc	 -530*8		; code 0101
		dc	 -323*8		; code 0110
		dc	 -150*8		; code 0111
		dc	 2557*8		; code 1000
		dc	 1612*8		; code 1001
		dc	 1121*8		; code 1010
		dc	  786*8		; code 1011
		dc	  530*8		; code 1100
		dc	  323*8		; code 1101
		dc	  150*8		; code 1110
		dc	    0*8		; code 1111
;;	
;	Inverse quantizer (Q2)
;	======================
;
QQ2		dc	 -926*8		; code   00
		dc	 -202*8		; code   01
		dc	  926*8		; code   10
		dc	  202*8		; code   11
;	
;	Multiplication factor
;	=====================
;
W4		dc	  -60		; code 0000
		dc	 3042		; code 0001
		dc	 1198		; code 0010
		dc	  538		; code 0011
		dc	  334		; code 0100
		dc	  172		; code 0101
		dc	   58		; code 0110
		dc	  -30		; code 0111
		dc	 3042		; code 1000
		dc	 1198		; code 1001
		dc	  538		; code 1010
		dc	  334		; code 1011
		dc	  172		; code 1100
		dc	   58		; code 1101
		dc	  -30		; code 1110
		dc	  -60		; code 1111
;;	
;;
W2 		dc	  798		; code   00
    		dc	 -214		; code   01
    		dc	  798		; code   10
    		dc	 -214		; code   11
;;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; 	Tables of constants that must be loaded in data RAM at reset
;;	============================================================
;;
;;	Note: they have the same name but with a pr_ prefix (prom)
;;	==========================================================
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Table for selection of decoder (mode)
;;	=====================================
;;
pr_sel_mode	dc 	QQ6		; for mode 1 = 64 kbit/s
		dc 	QQ5		; for mode 2 = 56 kbit/s
		dc 	QQ4		; for mode 3 = 48 kbit/s
;;
;;	constant area for lower sub band predictor
;;	==========================================
;;
pr_const_pr_l 	dc 	QQ4		; inverse 4 bits quantizer
		dc 	W4		; log adaptation (4 bits)
		dc 	32512		; multiplicand factor
		dc 	18432		; upper limit of p_nbl (low sub band)
		dc 	9		; to compute shift right
		dc 	ILB		; table of 32 values
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	constant area for higher sub band predictor
;;	===========================================
;;
pr_const_pr_h 	dc 	QQ2		; inverse 2 bits quantizer
		dc 	W2		; log adaptation (2 bits)
		dc 	32512		; multiplicand factor
		dc 	22528		; upper limit of p_nbl (high sub band)
		dc 	11		; to compute shift right
		dc 	ILB		; table of 32 values
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	quantiser thresholds (Q6) for lower sub_band encoder
;	====================================================
;
pr_level__1	dc	  0*8		; Q6(-1)
pr_level_0	dc	  0*8		; Q6( 0)
pr_level_1	dc	  35*8		; Q6( 1)
pr_level_2	dc	  72*8		; Q6( 2)
pr_level_3	dc	 110*8		; Q6( 3)
pr_level_4	dc	 150*8		; Q6( 4)
pr_level_5	dc	 190*8		; Q6( 5)
pr_level_6	dc	 233*8		; Q6( 6)
pr_level_7	dc	 276*8		; Q6( 7)
pr_level_8	dc	 323*8		; Q6( 8)
pr_level_9	dc	 370*8		; Q6( 9)
pr_level_10	dc	 422*8		; Q6(10)
pr_level_11	dc	 473*8		; Q6(11)
pr_level_12	dc	 530*8		; Q6(19)
pr_level_13	dc	 587*8		; Q6(13)
pr_level_14	dc	 650*8		; Q6(14)
pr_level_15	dc	 714*8		; Q6(15)
pr_level_16	dc	 786*8		; Q6(16)
pr_level_17	dc	 858*8		; Q6(17)
pr_level_18	dc	 940*8		; Q6(18)
pr_level_19	dc	1023*8		; Q6(19)
pr_level_20	dc	1121*8		; Q6(20)
pr_level_21	dc	1219*8		; Q6(21)
pr_level_22	dc	1339*8		; Q6(22)
pr_level_23	dc	1458*8		; Q6(23)
pr_level_24	dc	1612*8		; Q6(24)
pr_level_25	dc	1765*8		; Q6(25)
pr_level_26	dc	1980*8		; Q6(26)
pr_level_27	dc	2195*8		; Q6(27)
pr_level_28	dc	2557*8		; Q6(28)
pr_level_29	dc	2919*8		; Q6(29)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Coefficients for QMF TX and RX filters
;;	======================================
;;	Note: they must be seen as H[23],H[22] and so on
;;	------------------------------------------------
;;
pr_q_coef	dc 	3*2,-11*2,-11*2,53*2,12*2,-156*2
		dc 	32*2,362*2,-210*2,-805*2,951*2,3876*2
		dc 	3876*2,951*2,-805*2,-210*2,362*2,32*2
		dc 	-156*2,12*2,53*2,-11*2,-11*2,3*2
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	end