;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;+ +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
;;+ +									  + +
;;+ +	   This is the beginning of the H221 transmit state machine       + +
;;+ +									  + +
;;+ +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

		;list		; enable transmit state listing

;;***************************************************************
;;*								*
;;*	transmit state 0  :  This state is the first in the 	*
;;*	H221 transmit sequence for each submultiframe and 	*
;;*	multiframe stage.					*
;;*								*
;;*	Date	:	20/9/90 & 15/10/90			*
;;*	Version	:	1.0 & 1.1				*
;;*								*
;;***************************************************************

;;	Data Storage structure required		; tx_ref_count_ptr ds	1
						; tx_0_val	   dc	15
						;		   dc	1120
						;		   dc	0
						; mf_count_store   ds	1
						; mf_count	   ds	1

tx_state_0	move	#tx_ref_count_ptr,r3	; restore current isdn count
						; compare pointer
		move	x:isdn_count_tx,b	; current transmit count in b
		
		move	x:(r3)+,r2		; restore count ptr for state
		move	x:(r3)+,y0		; mf max. count in y0 for later
		move	x:(r3)+,y1		; term. alarm ref. count in y1
		move	x:(r2)+n2,x1 x:(r3)+,x0	; mf count disabled tx in x0
						; submultiframe ref count in x1
		tst	b	x:(r3)+,a	; is the tx count zero
						; get last mf count value in a
		bne	<not_end_mf		; to allow first entry into
						; state machine					
		move	#tx_count,r2		; restore smf count pointer

		move	x:(r3),a		; recall last mf count value
		dec24	a	x:(r2)+n2,x1	; decrement multiframe count
		tmi	y0,a			; is result negative ? if yes
						; restore max. count. & update
		move	x:control_word,y0	; reference count value in x1
		bftstl	#$0004,y0		; store updated count
		tcs	x0,a			; multiframe counting enabled ?
						; no then load a with 0
		move	a1,x:(r3)		; store new mf count value
		
not_end_mf	cmp	x1,b			; end of odd smframe yet ?
		bne	<end_tx_0		; no, then finish state
		cmp	y1,b			; terminal alarm bit count in y1
		bne	<not_term_alarm		; if not same count then branch
		
		move	x:is_shft,b		; term alarm count true, remove
		ror	b			; current tx byte lsb & replace
		move	x:control_word,x0	; test terminal alarm bit in
		bftsth	#$0040,x0		; control word
		bra	<end_alarm_tx		; finish current state

not_term_alarm	move	x:is_shft,b		; H221 being enabled then remove
		ror	b			; current tx byte lsb and relace
		bftsth	#$0001,a1		; with H221 multiframe count bit

end_alarm_tx	rol	b			; rotate carry into b1 lsb	
		move	b1,x:is_shft		; store updated isdn byte
		asr	a	(r3)-		; shift mf word in preparation
		move	a1,x:(r3)		; for the next submultiframe
						; dec r3 to point at 
						; x:mf_count_store & store 
						; shifted count
		move	#faw_state_a,r1		; new next state
		move	r2,x:tx_ref_count_ptr	; store pointer

end_tx_0	rts
		
;;***************************************************************
;;*								*
;;*	Frame Alignment State	:	This state transmits	*
;;*	the frame alignment bits, in order, for each even 	*
;;* 	frame of the H221 recommendation.			*
;;*								*
;;*	Date	:	20/9/90	& 15/10/90			*
;;*	Version	:	1.0 & 1.1				*
;;*								*
;;***************************************************************

faw_state_a	move	#faw_state_0,r1
		move	#faw_state_1,x0
		move	x0,x:faw_state_ptr
		
faw_state_0	move	x:faw_state_ptr,r3	; restore faw tx ptr into r3
		move	#is_shft,r2		; current isdn tx byte
		jsr	r3			; next faw tx state
		move	r3,x:faw_state_ptr	; store next faw state ptr
		
		rts

faw_state_1	move	#faw_state_2,r3		; next faw state
		bfclr	#$0001,x:(r2)		; clear the current isdn lsb
		rts				

faw_state_2	move	#faw_state_3,r3		; next faw state
		bfclr	#$0001,x:(r2)		; clear the current isdn lsb
		rts					

faw_state_3	move	#faw_state_4,r3		; next faw state
		bfset	#$0001,x:(r2)		; set the current isdn lsb
		rts					

faw_state_4	move	#faw_state_5,r3		; next faw state
		bfset	#$0001,x:(r2)		; set the current isdn lsb
		rts					

faw_state_5	move	#faw_state_6,r3		; next faw state
		bfclr	#$0001,x:(r2)		; clear the current isdn lsb
		rts				

faw_state_6	move	#faw_state_7,r3		; next faw state
		bfset	#$0001,x:(r2)		; set the current isdn lsb
		rts					

faw_state_7	move	#bas_state_a,r1		; next state
		bfset	#$0001,x:(r2)		; set the current isdn lsb
		rts					

;;***************************************************************
;;*								*
;;*	Bas State	:   This state takes the decoded	*
;;*	bit-rate-allocation signal and transmits the BAS	*
;;*	code into its relevant position within the H221		*
;;*	structure. The BAS data should be stored in the 	*
;;*	following format :					*
;;*								*
;;*				b b b b	b b b b 		*
;;*	MSB	0 0 0 0	0 0 0 0	a a a a	a a a a			*
;;*				s s s s	s s s s			*
;;*								*
;;*				7 6 5 4	3 2 1 0			*
;;*								*
;;*		<------- storage word -------->			*
;;*			   BAS_DATA				*
;;*								*
;;*	Date	:	21/9/90					*
;;*	Version	:	1.0					*
;;*								*
;;***************************************************************

bas_state_a	move	#bas_state_0,r1		; new next state
		move	#bas_state_1,x0		; set up subroutine pointers
		move	x0,x:bas_state_ptr

bas_state_0	move	x:bas_state_ptr,r3	; recall pointer
					
		move	x:is_shft,a		; current isdn byte in a
		ror	a			; rotate lsb into carry
		move	x:bas_data,x0		; get current BAS word
		
		jsr	r3			; jump to latest BAS tx state

		rol	a			; rotate test result into 
						; isdn data lsb
		move	a1,x:is_shft		; restore isdn byte
		move	r3,x:bas_state_ptr	; store next subroutine ptr
		rts

bas_state_1	move	#bas_state_2,r3		; new next state
		bftsth	#$0001,x0		; test BAS lsb
		rts

bas_state_2	move	#bas_state_3,r3		; new next state
		bftsth	#$0008,x0		; test BAS b3
		rts

bas_state_3	move	#bas_state_4,r3		; new next state
		bftsth	#$0004,x0		; test BAS b2
		rts

bas_state_4	move	#bas_state_5,r3		; new next state
		bftsth	#$0002,x0		; test BAS b1
		rts

bas_state_5	move	#bas_state_6,r3		; new next state
		bftsth	#$0020,x0		; test BAS b5
		rts

bas_state_6	move	#bas_state_7,r3		; new next state
		bftsth	#$0010,x0		; test BAS b4
		rts

bas_state_7	move	#bas_state_8,r3		; new next state
		bftsth	#$0040,x0		; test BAS b6
		rts

bas_state_8	move	#erc_calc_0,r1		; new next state
		bftsth	#$0080,x0		; test BAS msb
		rts
				
;;***********************************************************************
;;*									*
;;*	Erc Calc State 0 : this state takes the current BAS		*
;;*	data value and rearranges it for subsequent calculation		*
;;*	of the error correction bits which are to be transmitted	*
;;*	in the next H221 frame.	The BAS data is rearraged into the	*
;;*	following format :						*
;;*									*
;;*			b b b b	b b b b					*
;;*			a a a a	a a a a					*
;;*			s s s s	s s s s	0 0 0 0	0 0 0 0			*
;;*									*
;;*			0 1 2 3	4 5 6 7					*
;;*									*
;;*			<------ erc calc store ------->			*
;;*				BAS/ERC_store				*
;;*									*
;;*	Date	:	26/9/90						*
;;*	Version	:	1.0						*
;;*									*
;;***********************************************************************

erc_calc_0	move	x:bas_data,a		; get current BAS word
		clr	b			; prepare b acc. for store
		do	#8,bas_re_arrange			
		ror	a			; bas bit into carry
		rol	b			; carry into b1 lsb
bas_re_arrange	asr4	b			
		asr4	b			; shift re-arranged BAS bits
		move	b0,x:bas_store		; into b0 and store
		move	#erc_calc_1,r1		; new next state
		
		rts

;;**************************************************************************
;;*									   *
;;*	Erc Calc State 1	: 	This state takes the latest	   *
;;*	rearranged bas data and calculates the ERC error correction        *
;;*	bits for transmission in the next frame. The structure used	   *
;;*	is as indicated below :						   *
;;*									   *
;;*			  			   b b b b    b	b b b	   *
;;*			     			   a a a a    a	a a a	   *
;;*	0 0 0 0   0 0 0	0    y y y y	y y y y    s s s s    s	s s s	   *
;;*									   *
;;*			     8 7 6 5	4 3 2 1	   0 1 2 3    4	5 6 7	   *
;;*									   *
;;*	<---------------  a1  ---------------->    <-------------  a0  --  *
;;*									   *
;;*	For the correct polynomial division (i.e. generator polynomial     *
;;*	g(x) == x8 + x7 + x6 + x4 + x2 + x + 1) the equations required 	   *
;;*	are								   *
;;*	+  == modulo 2 addition		@ y1 == y8 + bas 0		   *
;;*	@  == next clock value		@ y2 == y8 + y1			   *
;;*	y8 == output			@ y3 == y8 + y2			   *
;;*					@ y5 == y8 + y4			   *
;;*					@ y7 == y8 + y6			   *
;;*					@ y8 == y8 + y7			   *
;;*									   *
;;**************************************************************************

erc_calc_1	move	#bas_store,r2
		move	#erc_calc_2,r1
		move	r2,x:(r2+7)		; store pointer
		move	x:(r2),a		; set up a accumulator for erc 
		move	a0,x:(r2+4)		; clear reference count
		move	a0,x:(r2+5)		; store a accumulator set-up
		move	a1,x:(r2+6)		; for next state
		
		rts
		
erc_calc_2	move	x:r2_temp,r2		; recall pointer
						; the storage structure used
						; for this routine is as below
						; ****************************
						;
						; bas_store	ds	1
						; mask		dc	$00d7
						; erc_ref_val	dc	0
						;		dc	16
						; count_check	ds	1
						; temp_erc	ds	2
						; r2_temp	ds	1
						; erc_store	ds	1
						;
						;*****************************
		clr	a			; clear accumulators for loop
		clr	b	x:(r2+1),x0	; load generator polynomial mask
						; into x0
		move	x:(r2+5),a		; restore crc division data into
		move	x:(r2+6),a0		; accumulator a
		
		bfclr	#$0080,a1		; test & clear last output bit,
		tcc	x0,b			; the result sets current mask 
		asl	a	b,y1		; in b. shift crc before eor'ing						; and new mask in y1
		eor	y1,a	x:(r2+4),b	; update crc storage bits and
						; get loop count value in b
		move	x:(r2+3),y0		; max. loop count of 16 in y0
		move	a1,x:(r2+5)		; store crc division data into
						; memory
		inc24	b	a0,x:(r2+6)	; increment loop count compare
		cmp	y0,b	b,x:(r2+4)	; with max and save new count
		blt	<end_erc_calc		; if not complete, repeat state
		
		move	a1,x:(r2+8)		; store calculated ERC bits
		move	#tx_odd_state,r1	; new next state pointer
		
end_erc_calc	rts
		
;;****************************************************************************
;;*									     *
;;*	Transmit Odd State	: 	This state tranmits the multiframe   *
;;*	alignment bits in their correct order in bit position 1 of every     *
;;*	odd frame							     *
;;*									     *
;;*	Date	:	26/9/90						     *
;;*	Version	:	1.0						     *
;;*									     *
;;****************************************************************************

tx_odd_state	move	x:tx_ref_count_ptr,r2	; latest ref. count pointer
		move	x:isdn_count_tx,b	; current isdn count in b
		move	x:(r2+9),x0		; odd frame ref. count in x0
		cmp	x0,b			; compare ref. and actual and
		blt	<end_tx_odd_state	; if not odd frame yet repeat 
						; state
		move	x:mfaw_data,y0		; stored multiframe align word
		move	x:mfaw_store,a		; H221 loop variable multiframe 
						; word
		move	#80,x1			; are we at frame 1 again ?
		cmp	x1,b	x:(r2)+,y1	; compare and update pointer 
						; for next time
		teq	y0,a			; yes, refresh multiframe word 
						; in a
		move	x:is_shft,b		; current isdn byte in b
		ror	b			; shift lsb into carry
		bftsth	#$0001,a1		; test the current multiframe
		rol	b			; alignment bit and rotate carry
		move	b1,x:is_shft		; into isdn byte lsb, which sets
		asr	a			; or resets it accordingly
		move	a1,x:mfaw_store		; store the current multiframe 
						; variable
		move	r2,x:tx_ref_count_ptr	; store the update pointer
		move	#faw_end_state,r1	; next state pointer
		
end_tx_odd_state	rts
		
;;*****************************************************************************
;;*									      *
;;*	Faw Complete state	:	This state completes the frame 	      *
;;*	alignment word for the current submultiframe. All it has to do is     *
;;*	set the lsb of the current isdn transmit byte.			      *
;;*									      *
;;*	Date	:	26/9/90						      *
;;*	Version	:	1.0						      *
;;*									      *
;;*****************************************************************************

faw_end_state 	move	#is_shft,r2		; current isdn byte ptr in r2
		
		move	 #mfaw_faw_valid,r1	; next state	
		
		bfset	#$0001,x:(r2)		; set lsb of byte

		rts
		
;;*****************************************************************************
;;*									      *
;;*	MFAW FAW Valid State	:	This state checks whether the latest  *
;;*	multiframe and frame alignment signals have been received correctly.  *
;;*	The current isdn tx lsb will be set accordingly. This transmission    *
;;*	corresponds to bit A of the H221 protocol.			      *
;;*									      *
;;*	Date	:	27/9/90						      *
;;*	Version	:	1.0						      *
;;*									      *
;;*****************************************************************************

mfaw_faw_valid	move	#crc_tx_test,r1		; next state
		move	x:control_word,y0	; control word in x0
		move	x:is_shft,a		; current isdn byte
		inc	a			; set a0 lsb to '1'
		ror	a	a0,x0		; lsb in carry & eor mask in x0
		bftsth	#$6000,y0		; test for frame and
		rol	a			; multiframe alignment, new a1
		eor	x0,a			; change H221 lsb in a1		
		move	a1,x:is_shft		; and store new isdn lsb
		
		rts
		
;;****************************************************************************
;;*									     *
;;*	CRC Tx Test State	:	This state transmits the relevant    *
;;*	crc bits in their respective positions in the current frame	     *
;;*									     *
;;*	Date	:	26/9/90 & 14/10/90				     *
;;*	Version	:	1.0 & 1.1					     *
;;*									     *
;;****************************************************************************

crc_tx_test	move	#control_word,r2	; control word pointer in r2
		move	#is_shft,r3		; current isdn byte pointer in 
						; r3	
		bftsth	#$0002,x:(r2)		; test crc_tx enable in control
						; word, if disabled then send
		bcs	crc_tx_enabled		; appropriate H221 data
		
		bfclr	#$0001,x:(r3)		; bit E set to zero
		
		move	#disable_crc_0,r1	; next state
		move	#disable_crc_1,x0	; next crc disabled pointer
		move	x0,x:disable_crc_ptr

		rts
		
disable_crc_0	move	x:disable_crc_ptr,r3	; restore next disable crc ptr
		move	#is_shft,r2		; current isdn byte in x1
		jsr	r3			; jump to next disable crc state
		move	r3,x:disable_crc_ptr	; store pointer
		
		rts
		
disable_crc_1	move	#disable_crc_2,r3	; next disable state
		bfset	#$0001,x:(r2)		; crc bit set to '1'
		rts

disable_crc_2	move	#disable_crc_3,r3	; next disable state
		bfset	#$0001,x:(r2)		; crc bit set to '1'
		rts

disable_crc_3	move	#disable_crc_4,r3	; next disable state
		bfset	#$0001,x:(r2)		; crc bit set to '1'
		rts

disable_crc_4	move	#erc_tx_state,r1	; next disable state
		bfset	#$0001,x:(r2)		; crc bit set to '1'
		rts
		
crc_tx_enabled	move	#enable_crc_0,r1	; next state	
		move	x:is_shft,a		; current isdn byte in x1, lsb
		ror	a			; of current isdn byte in carry
						; test if the last received crc
		bftsth	#$0800,x:(r2)		; was in error. ( control word
						; pointer still in r2 )
		rol	a			; replace current isdn lsb with
		move	a1,x:is_shft		; result of test and store
		
		move	#enable_crc_1,x0	; set up next crc tx state ptr.
		move	x0,x:enable_crc_ptr
		
		rts				; updated isdn transmit byte
		
enable_crc_0	move	x:enable_crc_ptr,r3	; get crc tx state pointer	
		move	x:is_shft,a		; current isdn byte in x1
		ror	a			; lsb of current isdn byte
		move	x:tx_crc_data,x0	; in carry	
		jsr	r3
		rol	a			; replace current isdn lsb with
		move	a1,x:is_shft		; result of test and store 
		move	r3,x:enable_crc_ptr	; store next crc tx state ptr.

		rts
		
enable_crc_1	move	#enable_crc_2,r3	; set up next crc state pointer
		bftsth	#$0080,x0		; test crc msb
		rts
		
enable_crc_2	move	#enable_crc_3,r3	; set up next crc state pointer
		bftsth	#$0040,x0		; test crc bit
		rts
		
enable_crc_3	move	#enable_crc_4,r3	; set up next crc state pointer
		bftsth	#$0020,x0		; test crc bit
		rts
		
enable_crc_4	move	#erc_tx_state,r1	; set up next tx state pointer
		bftsth	#$0010,x0		; test crc lsb
		rts
		
;;*****************************************************************************
;;*									      *
;;*	ERC Transmit State	:	  This is the final state of the      *
;;*	odd frame transmit H221 sequence. It takes the result of the last     *
;;*	BAS division crc and transmits the calculated ERC bits in their       *
;;*	respective time slots within the H221 structure. The stucture of      *
;;*	the ERC storage is as below :					      *
;;*									      *
;;*					e e e e	e e e e			      *
;;*					r r r r	r r r r			      *
;;*			x x x x	x x x x	c c c c	c c c c			      *
;;*									      *
;;*					0 1 2 3	4 5 6 7			      *
;;*									      *
;;*			<-------- ERC Storage -------->			      *
;;*				   erc_store				      *
;;*									      *
;;*	Date	:	27/9/90	&12/10/90				      *
;;*	Version	:	1.0 & 1.1					      *
;;*									      *
;;*****************************************************************************

erc_tx_state	move	#erc_tx_0,r1		; set-up pointers and storage
		move	#erc_tx_1,x0
		move	x0,x:erc_state_ptr
		
erc_tx_0	move	x:erc_state_ptr,r3	; restore erc state pointer
		move	x:is_shft,a		; current isdn byte in a 
		ror	a			; lsb into carry
		move	x:erc_store,x0		; latest calc. ERC bits in x0 
		jsr	r3			; jump to latest erc tx state
		rol	a			; and shift result into a1
		move	a1,x:is_shft		; re-store modified isdn byte
		move	r3,x:erc_state_ptr	; store erc state pointer
		
		rts
		
erc_tx_1	move	#erc_tx_2,r3		; next erc tx state ptr in r3
		bftsth	#$0020,x0		; test bit in erc store
		rts

erc_tx_2	move	#erc_tx_3,r3		; next erc tx state ptr in r3
		bftsth	#$0040,x0		; test bit in erc store
		rts

erc_tx_3	move	#erc_tx_4,r3		; next erc tx state ptr in r3
		bftsth	#$0080,x0		; test bit in erc store
		rts

erc_tx_4	move	#erc_tx_5,r3		; next erc tx state ptr in r3
		bftsth	#$0008,x0		; test bit in erc store
		rts

erc_tx_5	move	#erc_tx_6,r3		; next erc tx state ptr in r3
		bftsth	#$0010,x0		; test bit in erc store
		rts

erc_tx_6	move	#erc_tx_7,r3		; next erc tx state ptr in r3
		bftsth	#$0004,x0		; test bit in erc store
		rts

erc_tx_7	move	#erc_tx_8,r3		; next erc tx state ptr in r3
		bftsth	#$0002,x0		; test bit in erc store
		rts

erc_tx_8	move	#tx_state_0,r1		; next tx state ptr in r1
		bftsth	#$0001,x0		; test bit in erc store
		rts
			
;;*****************************************************************************
;;*									      *
;;*	CRC performance check for the ISDN 64 kbps channel		      *
;;*	Data structure used ;					              *
;;*									      *
;;*  |	    a1	     |		 a1	        |	      a0           |  *
;;*									      *
;;*    0   0   0   y    x xd1xd2xd3xd4xd5xd6xd7    x xd1xd2xd3xd4xd5xd6xd7    *
;;*		 	*  	 *					      *
;;*    output states   	penultimate ISDN data	        last data rx 	      *
;;*	    y		       ir(N-1)		            ir(N)             *
;;*								              *
;;*		d 	== single state delay    			      *
;;*		* 	== bits to be x'ored				      *
;;*		y4	== output and crc result msb			      *
;;*		@	== after next clock i.e. next left shift	      *
;;*									      *
;;*	Equations governing the crc operation are as below :		      *
;;*									      *
;;*		@ x	== 	y + xd1					      *
;;*		@ xd3	==	y + xd4					      *
;;*									      *
;;*	The CRC equation for the ISDN line check is	:		      *
;;*									      *
;;*		y(d)/x(d) == g(d) == d4/(1+d+d4)			      *
;;*									      *
;;*		Date	:	27/9/90					      *
;;*				29/4/91					      *
;;*		Version	:	1.8					      *
;;*				1.9					      *
;;*								  	      *
;;*****************************************************************************

;;  Optimised storage set_up  :			isdn_count_tx	ds	1
;;						tx_crc_store	ds	1
;;								dc	0
;;								dc	8
;;						is		ds	1
;;						tx_crc_value_2	dc	12
;;								dc	$0090
;;						tx_crc_data	ds	1

crc_tx		move	#isdn_count_tx,r3	; optimised storage pointer
		move	x:tx_crc_cnt_ptr,r2	; crc count comparison pointer

		move	x:(r3)+,b		; current isdn count in b
		move	x:(r3)+,a		; last crc storage value in a
		move	x:(r3)+,y0		; zero reference in y0
		move	x:(r2)+n2,x1 x:(r3)+,x0	; current ref. count in x1
						; default loop count in x0
		cmp	x1,b	x:(r2+50),x1	; first byte of new 
						; submultiframe ?
						; last byte of smf, count in x1
		bne	<tx_smf_not_done
		cmp	y0,b	x:(r2)+,y1	; first byte of multiframe ?
						; update reference counter in y1
		bne	<tx_cnt_not_zero	; no, then branch
		
		move	#crc_count,r2		; yes, restore count pointer,
		
tx_cnt_not_zero	move	a1,x:tx_crc_data	; store final crc result,
		move	x:is_shft,a		; isdn data byte in a
						; this provides the d4 multiply
		bra	<crc_loop_tx		; function in crc generator eqn.
						; wait for next intrupt for crc
tx_smf_not_done	move	x:(r3)+,a0		; new isdn data in here to a0
		move	x:(r2+34),y1		; crc bit tx, lower window count
		cmp	y1,b	x:(r2+42),y1	; is current count in window
		blt	<out_window_tx		; less than, then branch
		cmp	y1,b			; upper window reference compare
		bgt	<out_window_tx		; greater than, then branch

		bfclr	#$0100,a0		; if in crc window clear latest
						; isdn lsb bit then perform crc
out_window_tx	cmp	x1,b	x:(r3)+,y0	; last count in present block ?
						; update pointer for next time.
		tne	x0,b			; appropriate loop count
		teq	y0,b			; in b1
		swap	b			; loop count in b0, b1 is clear
		tfr3	b,y0	x:(r3)+,x0	; clear y0 for crc loop,
						; crc mask 2 in x0
		do	b0,crc_loop_tx		; do loop b0 times

		bfclr	#$0080,a1		; test & clear last output,
		tcc	x0,b			; set mask as a result of test
		asl	a	b,y1		; new mask in y1, shift bits
		eor	y1,a	y0,b		; before eor, perform modulo 2
						; of a1 bits and clear b
crc_loop_tx	move	a1,x:tx_crc_store	; save CRC data for next rx
		move	r2,x:tx_crc_cnt_ptr	; save reference count pointer
		
		rts
	
		;nolist