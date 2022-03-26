;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;+ +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
;;+ +									    + +
;;+ +	   Here starts the receive section of the H221 state machine	    + +
;;+ +									    + +
;;+ +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ +
;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

		list			; receive state machine

;;***********************************************************************
;;*									*
;;*	Bit Field State 0  :  This state is used when searching for 	*
;;*	frame alignment either for the first time or when frame		*
;;* 	alignment has been lost. As the data is being fed into		*
;;*	a0 MSB the frame alignment data will take the following		*
;;*	format :							*
;;*									*
;;*		    |		     a0		      |			*
;;*	   ----->     1	1 0 1 1	0 0 0 0	0 0 0 0	0 0 0			*
;;*									*
;;*	The 7 MSB bits represent the correct frame alignment		*
;;*	sequence, i.e in hex 'd' and '8' for positive logic		*
;;*	and '2' and '6' for negative logic.				*
;;*									*
;;*	Date	:	1/10/90						*
;;*	Version	:	1.0						*
;;*									*
;;*									*
;;***********************************************************************

bf_state_0	move	#control_word,r2	; control word ptr in r2
		move	x:ir,a			; latest receive byte in a1

		bfclr	#$ff00,x:(r2)		; disable the receive CRC
						; clear frame and multiframe
						; alignment bits
						; reset terminal alarm
						; reset odd/even frame receive
						; reset crc error
						; enable rx

		move	a0,x:isdn_count_rx	; reset isdn receive count
		move	a0,x:crc_enable_cnt	; crc enable & disable counts
		move	a0,x:crc_disable_cnt
		move	a0,x:mf_error_count	; reset multiframe error count
		move	a0,x:faw_error_count	; reset frame error count

		move	x:bas_faw_0,a0		; read next apps channel bit
		asr	a			; into previous word before test
		move	a0,x:bas_faw_0		; for frame alignment

		bftsth	#$d800,a0		; test frame alignment high bits
		bcc	<end_bf_0

		bftstl	#$2600,a0		; and low bits
		bcc	<end_bf_0

		move	#bf_state_1,r0		; if faw word is detected
						; prepare next state
		movei	#7,x0			; set isdn receive count to 7
		move	x0,x:isdn_count_rx

end_bf_0	rts

;;***********************************************************************
;;*									*
;;*	Bit field state 1  :  Once the initial frame alignment		*
;;*	has been achieved this routine is used to verify this		*
;;*	alignment, to store the BAS error correcting code and.		*
;;*	the first bit of the multiframe alignment word.			*
;;*	For correct frame alignment bit 2 of the current H221		*
;;*	word must be set						*
;;*									*
;;*	Date	:	1/10/90						*
;;*	Version	:	1.0						*
;;*									*
;;***********************************************************************

bf_state_1 	move	x:ir,a			; continue reading AC data into
		move	x:erc_faw_0,a0		; erc_faw word until count
		asr	a			; indicates completion
		move	a0,x:erc_faw_0

		move	x:isdn_count_rx,b	; compare receive byte count
		move	#95,x0			; with 95 to ensure all 16 bits
		cmp	x0,b			; of erc_faw_0 data are present
		blt	<end_bf_1

		move	#bf_state_0,r0		; default, frame alignment not
						; verified start search again
		bftsth	#$0002,a0		; test bit 2 of new faw to check
		bcc	<end_bf_1		; for frame alignment

		move	a0,b			; move a0 into b for right shift
		asr	b			; read first bit of mf alignment
		move	b0,x:mf_align_wrd	; test word into its storage

		move	#bf_state_2,r0		; next state of state machine
						; is prepared
end_bf_1	rts

;;***********************************************************************
;;*									*
;;*	Bit field state 2  :  This routine is used to finally		*
;;*	verify the correct reception of the frame alignment 		*
;;*	word. The alignment test is the same as that used in		*
;;*	bf_state_1							*
;;*									*
;;*	Date	:	1/10/90						*
;;*	Version	:	1.0						*
;;*									*
;;***********************************************************************

bf_state_2 	move	x:ir,a			; keep reading AC data until
		move	x:bas_faw_0,a0		; receive byte count indicates
		asr	a			; completion
		move	a0,x:bas_faw_0

		move	x:isdn_count_rx,b	; compare receive byte count
		move	#175,x0			; with 175 to ensure all 16 bits
		cmp	x0,b			; of bas_faw_0 data are present
		blt	<end_bf_2

		move	#bf_state_0,r0		; default, frame alignment not
		move	#control_word,r3	; verified then start search
						; again
		bftsth	#$00d8,a0		; check for reception of new
		bcc	<end_bf_2		; alignment word.
						; control word pointer in r3
		bftstl	#$0026,a0
		bcc	<end_bf_2
						; correct faw received then
		bfset	#$2000,x:(r3)		; set appropriate bit in
						; control word
		move	#bf_state_3,r0

end_bf_2	rts

;;***********************************************************************
;;*									*
;;*	Bit field state 3 routine : This routine is the last in		*
;;* 	the bit field test subroutines. It is used to validate		*
;;*	the multiframe alignment word as a final synchronisation	*
;;*	check for the H.221 protocol.					*
;;*									*
;;*	Date	:	1/10/90						*
;;*	Version	:	1.0						*
;;*									*
;;***********************************************************************

bf_state_3	move	#rx_count_0,x1		; memory store of mf alignment
		move	x1,x:rx_count_ptr	; odd frame counts. first word

state_3a	move	x:rx_count_ptr,r2
		move	#bf_state_0,r0		; default next state

		move	x:isdn_count_rx,a	; check complete multiframe has
		move	#1279,x0		; passed. yes, then no mf
		cmp	x0,a	x:(r2+1),x0	; alignment in this position ==>
		bge	<end_bf_3		; begin frame alignment search
						; again.
		move	#state_3a,r0		; new next state
						; compare isdn count with mf
		cmp	x0,a			; bit position count, different
		bne	<end_bf_3		; then end state

		move	x:ir,a
		move	x:mf_align_wrd,a0	; move next bit of multiframe
		asr	a	x:(r2)+,x0	; alignment to store and update
		move	a0,x:mf_align_wrd	; reference count pointer

		bftsth	#$d000,a0		; test correct bit format for
		bcc	<end_bf_3		; multiframe alignment

		bftstl	#$2c00,a0
		bcc	<end_bf_3

		move	#smf_state_0,r0		; new submultiframe state
		move	#control_word,r3	; control word pointer in r3
		move	#first_rx,r2		; set up ref. count for H221
						; first pass
		bfset	#$4000,x:(r3)		; set multiframe alignment
						; flag in control word
		move	#880,x0			; multiframe word successfully
		move	x0,x:isdn_count_rx	; detected, reset receive count
						; to correct value
		move	#bas_erc_faw,x0		; set up initial ISDN receive
		move	x0,x:bas_erc_faw_ptr	; word pointer

end_bf_3	move	r2,x:rx_count_ptr

		rts

		list

;;***********************************************************************
;;*									*
;;*	Submultiframe processing routine even : This routine is 	*
;;*	used as a common starting point for every even			*
;;*	frame. For the initial frame 0 the routine re_initialises	*
;;*	the pointers and counts for the current multiframe.		*
;;*									*
;;*	Date 	: 3/9/90						*
;;*	Version	: 1.0							*
;;*									*
;;***********************************************************************

smf_state_0	move	x:isdn_count_rx,b	; test for end of previous
		tst	b			; multiframe, if not then			
		bne	<smf_state_even		; end
		
		move	#bas_erc_faw_ptr,r3	; state pointer memory storage
		move	#bas_erc_faw,x1		; memory storage required for 
		move	#rx_count,x0		;
						; +++++++++++++++++++++++++++++
						;
		move	x1,x:(r3)+		; decoded_bas_ptr  ds	1
		move	x0,x:(r3)		; bas_erc_faw_ptr  ds	1
						; rx_count_ptr	   ds	1
						;
						; and ;
						;
						; decoded_bas	   ds	8
						; bas_erc_faw	   ds	16
						; 
						;+++++++++++++++++++++++++++++++
smf_state_even	move	x:rx_count_ptr,r2	; restore pointers
		move	x:bas_erc_faw_ptr,r3
		
		move	x:ir,a			; read new isdn data
		move	x:(r3),a0		; H221 bit into a0 msb
		asr	a	x:(r2)+n2,x0	; and the current even frame
						; H221 end count
		cmp	x0,b	a0,x:(r3)+n3	; compare count with preset 
		blt	<end_state_even		; value & finish if not complete
						; and save new bas/erc/faw word
		move	#control_word,r2	; control word ptr in r2
		move	#mf_count_state,r0	; new next state
		bfclr	#$1000,x:(r2)		; clear even smf bit in control
						; word
end_state_even	rts

;;***********************************************************************
;;*									*
;;*	Multiframe count state  :  This routine uses the H221 data	*
;;*	acquired during the last submultiframe even routine to 		*
;;*	provide the latest multiframe count stored in bit 1 of 		*
;;*	frames 0, 2, 4, 6, and bit 1 of frame 8 to indicate 		*
;;*	whether multiframe counting is turned on or off.		*
;;*									*
;;*	Date 	: 3/9/90						*
;;*	Version	: 1.0							*
;;*									*
;;***********************************************************************

mf_count_state	move	x:bas_erc_faw_ptr,r3	; restore pointers
		move	#bas_sort_state,r0	; next state
		
		move	x:(r3),a		; current H221 word pointer
		move	x:mf_count_rx,a0	; move latest multiframe count
		asr	a			; bit into storage word
		move	a0,x:mf_count_rx
		
		rts

;;***********************************************************************
;;*									*
;;*	Bit-rate Allocation Signal sort routine  : This routine uses	*  
;;*	the H221 data acquired during the last even state to sort the	*
;;* 	BAS code for storage. The position of the bits are  ;		*
;;*									*
;;*	msb	<--------------------  a0  ------------------->		*
;;*									*
;;*		b  b  b  b  b  b  b  b	 f  f  f  f  f 	f  f  m		*
;;*		a  a  a  a  a  a  a  a	 a  a  a  a  a	a  a  f		*
;;*		s  s  s  s  s  s  s  s	 w  w  w  w  w  w  w		*
;;*		   					      c		*
;;*		b  b  b  b  b  b  b  b 	 b  b  b  b  b 	b  b  o		*
;;*		i  i  i  i  i  i  i  i	 i  i  i  i  i 	i  i  u		*
;;*		t  t  t  t  t  t  t  t 	 t  t  t  t  t 	t  t  n		*
;;*							      t		*
;;*		7  6  4  5  1  2  3  0	 6  5  4  3  2	1  0  #		*
;;*									*
;;*	# 	== 	count bits for frames 0,2,4,6			*
;;*		 	count enable bit frame 8			*
;;*									*
;;*	The position of the BAS bits after state execution will be :	*
;;*									*
;;*		     <---------  Bas  Storage  --------->		*
;;*									*
;;*				        b b b b	b b b b			*
;;*		      0 0 0 0 0 0 0 0   a a a a	a a a a			*
;;*					s s s s	s s s s			*
;;*									*
;;*					7 6 5 4	3 2 1 0			*
;;*									*
;;*	Date	: 	3/9/90						*
;;*	Version	:	1.0						*
;;*									*
;;***********************************************************************

bas_sort_state	move	x:bas_erc_faw_ptr,r3
		move	x:decoded_bas_ptr,r2	; restore pointers

		clr	a	x:(r3)+,x0
		bftsth	#$8000,x0		; bas bit 7 test
		rol	a			; rotate carry into a1 lsb
		bftsth	#$4000,x0		; bas bit 6 test
		rol	a			; rotate carry into a1 lsb
		bftsth	#$1000,x0		; bas bit 5 test
		rol	a			; rotate carry into a1 lsb
		bftsth	#$2000,x0		; bas bit 4 test
		rol	a			; rotate carry into a1 lsb
		bftsth	#$0200,x0		; bas bit 3 test
		rol	a			; rotate carry into a1 lsb
		bftsth	#$0400,x0		; bas bit 2 test
		rol	a			; rotate carry into a1 lsb
		bftsth	#$0800,x0		; bas bit 1 test
		rol	a			; rotate carry into a1 lsb
		bftsth	#$0100,x0		; bas bit 0 test
		rol	a			; rotate carry into a1 lsb
		move	a1,x:(r2)		; store rearranged bas data

		move	#bas_for_erc,r0

		rts

;;***********************************************************************
;;*									*
;;*	BAS for ERC sort routine  : 	    This routine uses the 	*  
;;*	H221 data acquired during the last even state to sort the	*
;;* 	BAS code for subsequent error correction using the double	*
;;*	error-correcting code. The position of the bits are  ;		*
;;*									*
;;*	msb	<--------------------  a0  ------------------->		*
;;*									*
;;*		b  b  b  b  b  b  b  b	 f  f  f  f  f 	f  f  m		*
;;*		a  a  a  a  a  a  a  a	 a  a  a  a  a	a  a  f		*
;;*		s  s  s  s  s  s  s  s	 w  w  w  w  w  w  w		*
;;*		   					      c		*
;;*		b  b  b  b  b  b  b  b 	 b  b  b  b  b 	b  b  o		*
;;*		i  i  i  i  i  i  i  i	 i  i  i  i  i 	i  i  u		*
;;*		t  t  t  t  t  t  t  t 	 t  t  t  t  t 	t  t  n		*
;;*							      t		*
;;*		7  6  4  5  1  2  3  0	 6  5  4  3  2	1  0  #		*
;;*									*
;;*	# 	== 	count bits for frames 0,2,4,6			*
;;*		 	count enable bit frame 8			*
;;*									*
;;*	The position of the BAS bits after state execution will be :	*
;;*									*
;;*		     <--------  Bas Erc Storage  -------->		*
;;*									*
;;*					b b b b	b b b b			*
;;*		      	0 0 0 0	0 0 0 0 a a a a	a a a a			*
;;*					s s s s	s s s s			*
;;*									*
;;*					0 1 2 3	4 5 6 7			*
;;*									*
;;*	Date	: 	3/9/90						*
;;*	Version	:	1.0						*
;;*									*
;;***********************************************************************

bas_for_erc	move	x:decoded_bas_ptr,r3	; recall latest bas pointer
		move	#crc_bit_sort,r0	; next state

		clr	a	x:(r3)+,b	; clear a, 
						; get latest BAS word in b
		do	#8,bas_re_org
		
		ror	b			; BAS bit into carry and then
		rol	a			; carry into a1 lsb
		
bas_re_org	move	a1,x:bas_erc_store	; store rearranged bas data
		
		rts

;;***********************************************************************
;;*									*
;;*	CRC Bit Sort Routine  :  This routine takes the CRC data	*
;;*	generated by the last CRC pass and sorts it into a form		*
;;* 	which makes it easy to perform the comparison between this	*
;;*	data and the CRC bits transmitted in the next odd 		*
;;*	submultiframe							*
;;*									*
;;*	Date	:	12/9/90						*
;;*	Version	:	1.0						*
;;*									*
;;***********************************************************************

crc_bit_sort	move	x:rx_crc_data,a		; get latest local CRC data
		clr	b			; clear b for storage
		asr4	a			; shift crc bits into 4 lsb's
		
		do	#4,crc_bit_re_org
		
		ror	a			; shift crc bit into carry and 
		rol	b			; then into b1 lsb

crc_bit_re_org	move	b1,x:rx_crc_data	; store masked CRC data

		move	#term_alarm_test,r0	; Terminal alarm check state

		rts

;;***********************************************************************
;;*									*
;;*	Terminal Alarm test state   :   This state tests bit 1 of	*
;;*	frame 14. If set then the transmitting terminal is in a		*
;;*	state of alarm. 						*
;;*									*
;;*	Date	: 	1/10/90						*
;;*	Version	:	1.2						*
;;*									*
;;***********************************************************************

term_alarm_test	move	x:bas_erc_faw_ptr,r3	; restore pointer
		move	x:rx_count_ptr,r2	; compare count with that
		move	#1135,x0		; of the first bit in frame 14
		move	x:(r2),b		
		move	#control_word,r2	; control word pointer in r2
		cmp	x0,b	x:(r3)+,y0	; update bas/erc/faw rx pointer	
		bne	<end_alarm_state	; If frame ref. count is 
						; not equal to 1135, exit state
		bfclr	#$8000,x:(r2)		; default, clear alarm bit
		bftsth	#$0001,y0 		; test alarm bit
		bcc	<end_alarm_state	; no alarm then exit state

		bfset	#$8000,x:(r2)		; there is an alarm so set
						; the alarm bit
end_alarm_state	move	#smf_odd_state,r0	; all even state processing done						; go to odd submultiframe state
		move	r3,x:bas_erc_faw_ptr	; store updated pointer
		
		rts				

;;***********************************************************************
;;*									*
;;*	SMF odd state routine  :  This routine is used to acquire	*
;;*	the odd frame H221 protocol data. The data is stored in a	*
;;*	location pointed to by a stored address value.			*
;;*									*
;;*	Date	: 	3/9/90						*
;;*	Version	:	1.0						*
;;*									*
;;***********************************************************************

smf_odd_state	move	x:rx_count_ptr,r2	; restore pointers
		move	x:bas_erc_faw_ptr,r3

		move	x:isdn_count_rx,b	; current isdn count in b
		move	x:ir,a			; current isdn rx byte in a 
		move	x:(r3),a0		; current bas word in a0
		asr	a	x:(r2+9),x0	; new H221 bit in old H221 word,
						; end of odd H221 fm count in x0
						; store new H221 data
		cmp	x0,b	a0,x:(r3)+	; end of odd frame H221 bits ?
		blt	<end_odd_state		; no, then branch
		
		move	#control_word,r2	; get control word ptr in r2	
		move	#faw_check_state,r0	; H221 acquisition is complete,
		bfset	#$1000,x:(r2)		; new state pointed to by r0
						; set odd smf bit in control
end_odd_state	rts				; word
	
;;****************************************************************************
;;*									     *
;;*	Frame Alignment check state  :  this state checks the latest odd     *
;;*	and even frames for correct frame alignment. If three consecutive    *
;;*	alignment errors occur the search for frame alignment begins again   *
;;*	at bit_field_state_0.						     *
;;*									     *
;;* 	The position of the bits are  ;					     *
;;*									     *
;;*		msb	<--------------------  a0  ------------------->	     *
;;*									     *
;;*			b  b  b  b  b  b  b  b	 f  f  f  f  f 	f  f  m	     *
;;*			a  a  a  a  a  a  a  a	 a  a  a  a  a	a  a  f	     *
;;*			s  s  s  s  s  s  s  s	 w  w  w  w  w  w  w	     *
;;*			   					      c	     *
;;*			b  b  b  b  b  b  b  b 	 b  b  b  b  b 	b  b  o	     *
;;*			i  i  i  i  i  i  i  i	 i  i  i  i  i 	i  i  u	     *
;;*			t  t  t  t  t  t  t  t 	 t  t  t  t  t 	t  t  n	     *
;;*								      t	     *
;;*			7  6  4  5  1  2  3  0	 6  5  4  3  2	1  0  #	     *
;;*									     *
;;*	Date 	:	4/9/90						     *
;;*	Version	:	1.0						     *
;;*									     *
;;****************************************************************************

faw_check_state	move	x:bas_erc_faw_ptr,r2	; restore pointer
		move	x:faw_error_count,b	; faw error incremental counter
						; in b
		inc24	b	x:(r2-1),a	; increment faw error count as  
						; default & update ptr address
		bftsth	#$00d8,a1		; test even faw high bits
		bcc	<faw_not_ok
		bftstl	#$0026,a1		; test even faw low bits
		bcc	<faw_not_ok
		bftsth	#$0002,x:(r2)		; test bit 2 in current odd 
		bcc	<faw_not_ok		; frame, if ok then pass
		
		clr	b			; if faw ok, clear consecutive
						; error count
faw_not_ok	move	b,x:faw_error_count	; store new error count
		move	#mf_align_chck_1,r0	; default next state
		
		movei	#3,x0
		cmp	x0,b			; has error count reached 3 ?
		blt	<not_3_consec		; if not, then pass

		move	#bas_revert,r0		; if 3 consecutive errors search
						; for frame alignment begins
not_3_consec	rts				; again		


;;****************************************************************************
;;*									     *
;;*	Multiframe Alignment Check Routine  :  This routine obtains	     *
;;*	the multiframe alignment bits from each odd frame and after	     *
;;*	completion, at the isdn reference count of #895, goes to state 	     *
;;*	mf_align_check2 to complete test for proper multiframe alignment.    *
;;*	If 3 consecutive alignment errors occur, the search for	both frame   *
;;*	and multiframe alignment occurs once more in bit_field_state_0	     *
;;*									     *
;;*	Date	:	4/9/90						     *
;;*	Version	:	1.0						     *
;;*									     *
;;****************************************************************************

mf_align_chck_1	move	x:rx_count_ptr,r2
		move	x:bas_erc_faw_ptr,r3	; restore pointers
		move	#erc_sort_state,r0	; next state

		move	x:(r3),a		; get latest H221 word
		move	x:mf_align_wrd,a0	; shift in the latest mf
		asr	a	x:(r2)+,b	; alignment bit into a0
		move	a0,x:mf_align_wrd	; and update pointer
		
		move	#815,x0			; has complete multiframe 
		cmp	x0,b			; alignment word been 			
		bne	<end_mf_check1		; collected
		
		move	#mf_align_chck_2,r0	; new next state if compare 
						; true
end_mf_check1	move	r2,x:rx_count_ptr	; store updated pointer

		rts

;;***********************************************************************
;;*									*
;;*	Multiframe error check routine  :  this routine compares the 	*
;;*	received multiframe bits with the alignment signal and sets	*
;;*	the mf_align_bit in the control word appropriately.		*
;;*									*
;;*	Date	:	12/9/90						*
;;*	Version	:	1.0						*
;;*									*
;;***********************************************************************

mf_align_chck_2	move	#mf_error_count,r3	
		move	#erc_sort_state,r0	; new next state
		move	#control_word,r2	; control word pointer in r2
		
		move	x:(r3),b		; recall current multiframe
						; error count
		move	x:mf_align_wrd,a	; latest multiframe alignment
		inc24	b			; bits in a and increment error
						; count for default
		bftsth	#$d000,a1		; test for correct alignment
		bcc	<mf_align_error		; '1' bits
		bftstl	#$2c00,a1		; test for correct alignment
		bcc	<mf_align_error		; '0' bits

		clr	b			; if correct alignment then
						; clear error count
mf_align_error	bfset	#$4000,x:(r2)		; set multiframe alignment bit
						; in control word as default
		movei	#3,x0			; test incremental error count
		cmp	x0,b	b,x:(r3)+n3	; and save it
		blt	<end_mf_state2		; if 3 or more, reset alignment
		
		bfclr	#$4000,x:(r2)		; if no alignment then clear 	
		move	x0,x:(r3)		; alignment bit in control word
						; & limit error count to 3
end_mf_state2	rts

;;***********************************************************************
;;*									*
;;*	Error Code Sort routine  :  This routine is used for 		*
;;*	sorting the bit rate allocation signal error correcting		*
;;*	code. The position of the bits are :				*
;;*									*
;;*	msb	<--------------------- a0 -------------------->		*
;;*									*
;;*		e  e  e	 e  e  e  e  e	 c  c  c  c  e	b  f  m		*
;;*		r  r  r	 r  r  r  r  r	 r  r  r  r  r	i  a  f		*
;;*		c  c  c	 c  c  c  c  c	 c  c  c  c  r 	t  w  		*
;;*						     o	      a		*
;;*		b  b  b	 b  b  b  b  b	 b  b  b  b  r	A  b  l		*
;;*		i  i  i	 i  i  i  i  i	 i  i  i  i  	   i  i		*
;;*		t  t  t	 t  t  t  t  t	 t  t  t  t  b	   t  g		*
;;*						     i	      n		*
;;*		7  6  5	 3  4  0  1  2	 4  3  2  1  t	   8  #	        *
;;*									*
;;*	# == bit 1 of frames 1,3,5,7,9,11				*
;;*									*
;;*	The position of the BAS ERC bits before storage 		*
;;*	will be :							*
;;*									*
;;*		  <-------  Bas/Erc  Storage  -------->			*
;;*									*
;;*		  b b b b   b b	b b   e e e e	e e e e			*
;;*		  a a a a   a a a a   r r r r	r r r r			*
;;*		  s s s	s   s s	s s   c c c c 	c c c c			*
;;*									*
;;*		  0 1 2	3   4 5	6 7   0 1 2 3	4 5 6 7			*
;;*									*
;;*	Date	:	4/9/90						*
;;*	Version	:	1.0						*
;;*									*
;;***********************************************************************
		
erc_sort_state	move	x:bas_erc_faw_ptr,r3
		move	x:bas_erc_store,a
		
		bftsth	#$0400,x:(r3)		; erc bit 0 test
		rol	a			; rotate carry into a1 lsb
		bftsth	#$0200,x:(r3)		; erc bit 1 test
		rol	a			; rotate carry into a1 lsb
		bftsth	#$0100,x:(r3)		; erc bit 2 test
		rol	a			; rotate carry into a1 lsb
		bftsth	#$1000,x:(r3)		; erc bit 3 test
		rol	a			; rotate carry into a1 lsb
		bftsth	#$0800,x:(r3)		; erc bit 4 test
		rol	a			; rotate carry into a1 lsb
		bftsth	#$2000,x:(r3)		; erc bit 5 test
		rol	a			; rotate carry into a1 lsb
		bftsth	#$4000,x:(r3)		; erc bit 6 test
		rol	a			; rotate carry into a1 lsb
		bftsth	#$8000,x:(r3)		; erc bit 7 test
		rol	a			; rotate carry into a1 lsb
		move	a1,x:bas_erc_store	; re-store rearranged 
						; bas/erc data
		move	#crc_sort_2,r0		; next state
		
		rts
		
;;***************************************************************************
;;*									    *
;;*	CRC Sort 2 routine  :  This routine is used to sort the received    *
;;*	CRC bits in the odd frames prior to comparing with the locally 	    *
;;*	generated CRC bits.  The position of the latest isdn bits are :	    *
;;*									    *
;;*	msb	<--------------------- a0 -------------------->		    *
;;*									    *
;;*		e  e  e	 e  e  e  e  e	 c  c  c  c  e	b  f  m		    *
;;*		r  r  r	 r  r  r  r  r	 r  r  r  r  r	i  a  f		    *
;;*		c  c  c	 c  c  c  c  c	 c  c  c  c  r 	t  w  		    *
;;*						     o	      a		    *
;;*		b  b  b	 b  b  b  b  b	 b  b  b  b  r	A  b  l		    *
;;*		i  i  i	 i  i  i  i  i	 i  i  i  i  	   i  i		    *
;;*		t  t  t	 t  t  t  t  t	 t  t  t  t  b	   t  g		    *
;;*						     i	      n		    *
;;*		7  6  5	 3  4  0  1  2	 4  3  2  1  t	   8  #	            *
;;*						  *			    *
;;*	# == bit 1 of frames 1,3,5,7,9,11				    *
;;*	* == msb							    *
;;*									    *
;;*	Date 	:	14/9/90						    *
;;*	version	;	1.0						    *
;;*									    *
;;***************************************************************************

crc_sort_2	move	x:bas_erc_faw_ptr,r3
		move	#crc_en_disen_state,r0	; next state
		
		move	x:(r3),a		; latest isdn received data
		asr4	a			; shift crc bits into lsb's
		movei	#15,x0			; mask in x0
		and	x0,a			; clear unnecessary bits

		move	a1,x:crc_sorted		; save sorted crc bits

		rts

;;*****************************************************************************
;;*									      *
;;*	CRC disable/enable check state  :  This state checks the received     *
;;*	CRC bits for disabling or enabling before entering the CRC test state.*
;;*	The position of the latest isdn bits are :			      *
;;*									      *
;;*	msb	<--------------------- a0 -------------------->		      *
;;*									      *
;;*		e  e  e	 e  e  e  e  e	 c  c  c  c  e	b  f  m		      *
;;*		r  r  r	 r  r  r  r  r	 r  r  r  r  r	i  a  f		      *
;;*		c  c  c	 c  c  c  c  c	 c  c  c  c  r 	t  w  		      *
;;*						     o	      a		      *
;;*		b  b  b	 b  b  b  b  b	 b  b  b  b  r	A  b  l		      *
;;*		i  i  i	 i  i  i  i  i	 i  i  i  i  	   i  i		      *
;;*		t  t  t	 t  t  t  t  t	 t  t  t  t  b	   t  g		      *
;;*						     i	      n		      *
;;*		7  6  5	 3  4  0  1  2	 4  3  2  1  t	   8  #	              *
;;*						  *			      *
;;*	# == bit 1 of frames 1,3,5,7,9,11				      *
;;*	* == msb							      *
;;*									      *
;;*	Date	: 	14/9/90						      *
;;*	Version	:	1.0						      *
;;*									      *
;;*****************************************************************************

crc_en_disen_state move	#control_word,r2
		move	x:bas_erc_faw_ptr,r3
		bftsth	#$0400,x:(r2)
		bcs	<crc_enabled

;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

		move	#crc_test_count,r0	; crc count pointer in r0
		move	x:crc_enable_cnt,b	; get latest crc enabling count
		inc24 	b 	b0,x:(r0)+	; inc it & clear crc test count
		clr	a	b0,x:(r0)+	; clear a & crc error count

		bftsth	#$00f0,x:(r3)		; all crc bits received '1' ?
		tcs	a,b			; yes, crc still disabled
						; ==> clear b
		move	b,x:crc_enable_cnt	; store modified disable count
		move	#error_calc_1,r0	; next state
		movei	#2,y1
		cmp	y1,b			; has the count reached 2 ?
	  	blt	<end_check_state	; no, then do nothing, crc not
						; enabled.
		bfset	#$0400,x:(r2)		; yes, set crc enabled bit in
		move	b0,x:crc_enable_cnt	; control word & clear enbl cnt
		move	#crc_test_state,r0	; new next state

		bra	<end_check_state	; now finish state

;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

crc_enabled	move	#crc_test_state,r0	; default next state
		move	x:crc_disable_cnt,b	; get latest crc disable count
		inc24	b	b0,y0		; increment it, set y0 to 0

		bftsth	#$00f0,x:(r3)		; test crc bits for disable
		tcc	y0,b			; some '0's received ? yes
						; then clear disable count
		move	b,x:crc_disable_cnt	; store the modified reference
		movei	#8,y1
		cmp	y1,b			; count, has it reached 8 ?
		blt	<end_check_state	; if not then exit state

		move	#error_calc_1,r0	; if yes, then new next state,
		bfclr	#$0c00,x:(r2)		; set crc disabled bit in
		move	b0,x:crc_disable_cnt	; control word, clear rx error
						; bit & crc disable count.

;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

end_check_state	rts

;;***********************************************************************
;;*									*
;;*	CRC test state	:  This state is used to compare the received	*
;;*	CRC data with that generated locally.  It also calculates the 	*
;;*	number of errors received in the last 100 blocks. If this 	*
;;* 	number exceeds 89 then the search for frame alignment is 	*
;;*	re-initiated from bit_field_state_0.				*
;;*									*
;;*	Date	:	14/9/90						*
;;*	Version	:	1.0						*
;;*									*
;;***********************************************************************

crc_test_state	move	#crc_test_count,r2	; **** x memory partitiion ****
		move	#error_calc_1,r0	;
		move	#control_word,r3	; crc_test_count    ds	1
						; crc_error_count   ds	1
						; end_count  	    dc	100
						; test_error_count  dc	89
						; crc_sorted	    ds	1
						;
						;******************************
		move	x:(r2+4),b		; get latest received crc bits
		move	x:rx_crc_data,x0	; get latest locally generated
						; crc bits
		bfclr	#$0800,x:(r3)		; clear crc error flag in
						; control word as default
		cmp	x0,b	x:(r2+1),a	; crc_error_count in a
		beq	<crc_ok			; compare both sets of crc bits
						; if the same then, O.K.
		bfset	#$0800,x:(r3)		; if different, set crc error
		inc24	a			; flag in control word and
						; increment error count
crc_ok		move	x:(r2),b		; get latest crc test count
		inc24	b	a,x:(r2+1)	; increment it, and store
						; latest updated error count
		move	x:(r2+2),x0		; & max. reference count in x0
		cmp	x0,b	b,x:(r2)+n2	; compare current count with
		blt	<crc_check_done		; max. and store updated count

		move	a0,x:(r2)		; clear test count
		move	x:(r2+3),x0		; get error compare value of 89
		cmp	x0,a	a0,x:(r2+1)	; compare actual error count
		ble	<crc_check_done		; with stored max. & reset
						; error count
		move	#bas_revert,r0		; if the actual error count is
						; > 89 then start search for
crc_check_done	rts				; frame alignment once more.

;;****************************************************************************
;;*									     *
;;*	Error Calc State 1	: 	This state takes the latest	     *
;;*	rearranged bas data and calculates the ERROR bits from transmission  *
;;*	The structure used is as indicated below :			     *
;;*									     *
;;*			     b b b b 	b b b b	   e e e e    e	e e e	     *
;;*			     a a a a 	a a a a	   r r r r    r	r r r	     *
;;*	y y y y   y y y	y    s s s s	s s s s    c c c c    c	c c c	     *
;;*									     *
;;*	8 7 6 5   4 3 2	1    0 1 2 3	4 5 6 7	   0 1 2 3    4	5 6 7	     *
;;*									     *
;;*	<----   a1   ---->   <---------------   a0   --------------->  	     *
;;*									     *
;;*	For the correct polynomial division (i.e. generator polynomial	     *
;;*	g(x) == x8 + x7 + x6 + x4 + x2 + x + 1) the equations required are   *
;;*									     *
;;*	+  == modulo 2 addition		@ y1 == y8 + bas 0		     *
;;*	@  == next clock value		@ y2 == y8 + y1			     *
;;*	y8 == output			@ y3 == y8 + y2			     *
;;*					@ y5 == y8 + y4			     *
;;*					@ y7 == y8 + y6			     *
;;*					@ y8 == y8 + y7			     *
;;*									     *
;;*	Date	:	2/10/90 & 12/10/90				     *
;;*	Version	:	1.0 & 1.1					     *
;;*									     *
;;****************************************************************************

error_calc_1	move	#bas_erc_store,r2
		move	#error_calc_2,r0
		move	r2,x:(r2+7)		; store pointer
		move	x:(r2),a		; set up a accumulator for erc
						; bit evaluation
		move	a0,x:(r2+4)		; clear reference count
		move	a0,x:(r2+5)		; store a accumulator set-up
		move	a1,x:(r2+6)		; for next state

		rts

error_calc_2	move	x:r2_temp_2,r2		; recall pointer
						; The storage structure used
						; for this routine is as below
						; ******************************
						;
						; bas_erc_store	ds	1
						; mask		dc	$00d7
						; error_ref_val	dc	0
						;		dc	16
						; count_check	ds	1
						; temp_error	ds	2
						; r2_temp_2	ds	1
						; error_store	ds	1
						;
						;*******************************
		clr	a			; clear accumulators for loop
		clr	b	x:(r2+1),x0	; load generator polynomial mask
						; into x0
		move	x:(r2+5),a1		; restore crc division data into
		move	x:(r2+6),a0		; accumulator a

		bfclr	#$0080,a1		; test last output bit, result
		tcc	x0,b			; sets current mask in b.
		asl	a	b,y1		; shift crc before eor'ing, and
						; new mask in y1
		eor	y1,a	x:(r2+4),b	; update crc storage bits and
						; get loop count value in b
		move	x:(r2+3),y0		; max. loop count of 16 in y0
		move	a1,x:(r2+5)		; store crc division data into
						; memory
		inc24	b	a0,x:(r2+6)	; inc. loop count, compare with
 		cmp	y0,b	b,x:(r2+4)	; max. and save updated count
		blt	<end_error_calc		; if not complete, repeat state

		move	a1,x:(r2+8)		; store calculated ERC bits
		move	#bas_error_fix_1,r0	; new next state pointer

end_error_calc	rts

;;***********************************************************************
;;*									*
;;*	BAS Error Correct Routines	:	These routines take	*
;;*	the error correcting data generated from the last routine	*
;;*	and subsequently correct the latest received BAS signal.	*
;;*									*
;;*	Date	:	2/10/90						*
;;*	Version	:	1.0						*
;;*									*
;;***********************************************************************

bas_error_fix_1	move	#single_error,r0	; single error check remainders
		move	x:error_store,b		; latest error remainder result
		clr	a	b,y0		; clear a for loop, ensure y0 is
						; not empty if error present
		tst	b	x:(r0)+,x0	; check for received errors and
		beq	<no_bas_error		; load first ref. in x0 whilst
						; updating remainder pointer
		do 	#8,bas_fix_lp_1		; repeat loop for all possible
						; single error remainders
		cmp 	x0,b	x:(r0)+,x0	; check for remainder equality
						; and get new remainder in x0
		teq	y0,a	r0,r2		; if equal make sure a is not
						; cleared and store remainder
						; pointer value
bas_fix_lp_1	move	#bas_error_fix_2,r0	; default next state
		tst	a	x:(r2+6),a	; has error been located ?
						; put error correct mask in a
		beq	<end_check_1		; if a is clear error not found
						; go to next search state
no_bas_error	move	#bas_valid_tst_0,r0	; no error or error found
						; then next state is this
		move	a1,x:error_mask		; store relevant error correct
						; mask
end_check_1	rts

;;+++++++++++++++++++++++++++++++++++++++++++++++

bas_error_fix_2	move	#double_error_0,r0	; double error check remainders
		move	x:error_store,b		; latest error remainder result
		clr	a	b,y0		; clear a for loop and ensure
						; y0 is not empty.
		move	x:(r0)+,x0		; load first ref. in x0 whilst
						; updating the remainder pointer
		do 	#7,bas_fix_lp_2		; repeat loop for all possible
						; single error remainders
		cmp 	x0,b	x:(r0)+,x0	; check for remainder equality
						; and put new remainder in x0
		teq	y0,a	r0,r2		; if equal, make sure a is not
						; cleared and store remainder
						; pointer value
bas_fix_lp_2	move	#bas_error_fix_3,r0	; default next state
		tst	a	x:(r2+5),a	; has error been located ?
						; put error correct mask in a
		beq	<end_check_2		; if a is clear, error not found
						; go to next search state
		move	#bas_valid_tst_0,r0	; a has data, error fix next
						; state
		move	a1,x:error_mask		; store relevant error correct							; mask
end_check_2	rts

;;+++++++++++++++++++++++++++++++++++++++++++++++

bas_error_fix_3	move	#double_error_1,r0	; double error check remainders
		move	x:error_store,b		; latest error remainder result
		clr	a	b,y0		; clear a for loop and ensure y0
						; is not empty.
		move	x:(r0)+,x0		; load first ref. in x0 whilst 
						; updating the remainder pointer
		do 	#7,bas_fix_lp_3		; repeat loop for all possible
						; single error remainders
		cmp 	x0,b	x:(r0)+,x0	; check for remainder equality
						; and get new remainder in x0
		teq	y0,a	r0,r2		; if equal, make sure a is not 
						; cleared and store remainder
						; pointer value
bas_fix_lp_3	move	#bas_error_fix_4,r0	; default next state	
		tst	a	x:(r2+5),a	; has error been located ?
						; put error correct mask in a
		beq	<end_check_3		; if a is clear, error not found
						; go to next search state
		move	#bas_valid_tst_0,r0	; a has data, error fix next
						; state
		move	a1,x:error_mask		; store relevant error correct							; mask
end_check_3	rts
		
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

bas_error_fix_4	move	#double_error_2,r0	; double error check remainders
		move	x:error_store,b		; latest error remainder result
		clr	a	b,y0		; clear a for loop and ensure y0
						; is not empty.
		move	x:(r0)+,x0		; load first ref. in x0 whilst 
						; updating the remainder pointer
		do 	#7,bas_fix_lp_4		; repeat loop for all possible
						; single error remainders
		cmp 	x0,b	x:(r0)+,x0	; check for remainder equality
						; and get new remainder in x0
		teq	y0,a	r0,r2		; if equal, make sure a is not
						; cleared and store remainder
						; pointer value
bas_fix_lp_4	move	#bas_error_fix_5,r0	; default next state
		tst	a	x:(r2+5),a	; has error been located ?
						; get error correct mask in a 
		beq	<end_check_4		; if a is clear, error not found
						; go to next search state
		move	#bas_valid_tst_0,r0	; a has data, error fix next
						; state
		move	a1,x:error_mask		; store relevant error correct							; mask
end_check_4	rts				
		
;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

bas_error_fix_5	move	#double_error_3,r0	; double error check remainders
		move	x:error_store,b		; latest error remainder result
		clr	a	b,y0		; clear a for loop and ensure y0
						; is not empty.
		move	x:(r0)+,x0		; load first ref. in x0 whilst 
						; updating the remainder pointer
		do 	#7,bas_fix_lp_5		; repeat loop for every possible
						; single error remainder
		cmp 	x0,b	x:(r0)+,x0	; check for remainder equality
						; and get new remainder in x0
		teq	y0,a	r0,r2		; if equal, make sure a is not
						; cleared and store remainder
						; pointer value
bas_fix_lp_5	move	#bas_error_fix_6,r0	; default next state
		tst	a	x:(r2+5),a	; has error been located ?
						; put error correct mask in a 
		beq	<end_check_5		; if a is clear, error not found
						; go to next search state
		move	#bas_valid_tst_0,r0	; a has data, error fix next
						; state
		move	a1,x:error_mask		; store relevant error correct							; mask
end_check_5	rts				
		
;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

bas_error_fix_6	move	#error_0001_mask,r0	; single error check remainders
		move	x:error_store,b		; latest error remainder result
		clr	a	x:(r0)+,y0	; clear a for loop and ensure y0						; contains the error mask.
		move	x:(r0)+,x0		; load first ref. in x0 whilst 
						; updating the remainder pointer
		do 	#8,bas_fix_lp_6		; repeat loop for all possible
						; single error remainders
		cmp 	x0,b	x:(r0)+,x0	; check for remainder equality
						; and get new remainder in x0
		teq	y0,a			; if equal, correction mask in a

bas_fix_lp_6	move	#bas_error_fix_7,r0	; default next state	
		tst	a			; has error been located ?
		beq	<end_check_6		; if a is clear, error not found
						; go to next search state
		move	#bas_valid_tst_0,r0	; a has data, error fix next
						; state
		move	a1,x:error_mask		; store relevant error correct							; mask
end_check_6	rts				
		
;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

bas_error_fix_7	move	#error_0002_mask,r0	; single error check remainders
		move	x:error_store,b		; latest error remainder result
		clr	a	x:(r0)+,y0	; clear a for loop and ensure y0						; contains the error mask.
		move	x:(r0)+,x0		; load first ref. in x0 whilst
						; updating the remainder pointer
		do 	#8,bas_fix_lp_7		; repeat loop for all possible
						; single error remainder
		cmp 	x0,b	x:(r0)+,x0	; check for remainder equality
						; and get new remainder in x0
		teq	y0,a			; if equal, correction mask in a  
bas_fix_lp_7	move	#bas_error_fix_8,r0	; default next state	
		tst	a			; has error been located ?
		beq	<end_check_7		; if a is clear, error not found
						; go to next search state
		move	#bas_valid_tst_0,r0	; a has data, error fix next 
						; state
		move	a1,x:error_mask		; store relevant error correct							; mask
end_check_7	rts				
		
;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

bas_error_fix_8	move	#error_0004_mask,r0	; single error check remainders
		move	x:error_store,b		; latest error remainder result
		clr	a	x:(r0)+,y0	; clear a for loop and ensure y0						; contains the error mask.
		move	x:(r0)+,x0		; load first ref. in x0 whilst
						; updating the remainder pointer
		do 	#8,bas_fix_lp_8		; repeat loop for all possible
						; single error remainders
		cmp 	x0,b	x:(r0)+,x0	; check for remainder equality
						; and get new remainder in x0
		teq	y0,a			; if equal, correction mask in a  
bas_fix_lp_8	move	#bas_error_fix_9,r0	; default next state	
		tst	a			; has error been located ?
		beq	<end_check_8		; if a is clear, error not found
						; go to next search state
		move	#bas_valid_tst_0,r0	; a has data, error fix next
						; state
		move	a1,x:error_mask		; store relevant error correct							; mask
end_check_8	rts				
		
;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

bas_error_fix_9	move	#error_0008_mask,r0	; single error check remainders
		move	x:error_store,b		; latest error remainder result
		clr	a	x:(r0)+,y0	; clear a for loop and ensure y0						; contains the error mask.
		move	x:(r0)+,x0		; load first ref. in x0 whilst
						; updating the remainder pointer
		do 	#8,bas_fix_lp_9		; repeat loop for all possible
						; single error remainders
		cmp 	x0,b	x:(r0)+,x0	; check for remainder equality
						; and get new remainder in x0
		teq	y0,a			; if equal, correction mask in a  
bas_fix_lp_9	move	#bas_err_fix_10,r0	; default next state	
		tst	a			; has error been located ?
		beq	<end_check_9		; if a is clear, error not found
						; go to next search state
		move	#bas_valid_tst_0,r0	; a has data, error fix next
						; state
		move	a1,x:error_mask		; store relevant error correct							; mask
end_check_9	rts
		
;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

bas_err_fix_10	move	#error_0010_mask,r0	; single error check remainders
		move	x:error_store,b		; latest error remainder result
		clr	a	x:(r0)+,y0	; clear a for loop and ensure y0						; contains the error mask.
		move	x:(r0)+,x0		; load first ref. in x0 whilst
						; updating the remainder pointer
		do 	#8,bas_fix_lp_10	; repeat loop for every possible
						; single error remainder
		cmp 	x0,b	x:(r0)+,x0	; check for remainder equality
						; and get new remainder in x0
		teq	y0,a			; if equal, correction mask in a  
bas_fix_lp_10	move	#bas_err_fix_11,r0	; default next state	
		tst	a			; has error been located ?
		beq	<end_check_10		; if a is clear, error not found
						; go to next search state
		move	#bas_valid_tst_0,r0	; a has data, error fix next 
						; state
		move	a1,x:error_mask		; store relevant error correct							; mask
end_check_10	rts
		
;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

bas_err_fix_11	move	#error_0020_mask,r0	; single error check remainders
		move	x:error_store,b		; latest error remainder result
		clr	a	x:(r0)+,y0	; clear a for loop and ensure y0						; contains the error mask.
		move	x:(r0)+,x0		; load first ref. in x0 whilst
						; updating the remainder pointer
		do 	#8,bas_fix_lp_11	; repeat loop for every possible
						; single error remainder
		cmp 	x0,b	x:(r0)+,x0	; check for remainder equality
						; and get new remainder in x0
		teq	y0,a			; if equal, correction mask in a  
bas_fix_lp_11	move	#bas_err_fix_12,r0	; default next state	
		tst	a			; has error been located ?
		beq	<end_check_11		; if a is clear, error not found
						; go to next search state
		move	#bas_valid_tst_0,r0	; a has data, error fix next 
						; state
		move	a1,x:error_mask		; store relevant error correct							; mask
end_check_11	rts
		
;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

bas_err_fix_12	move	#error_0040_mask,r0	; single error check remainders
		move	x:error_store,b		; latest error remainder result
		clr	a	x:(r0)+,y0	; clear a for loop and ensure y0						; contains the error mask.
		move	x:(r0)+,x0		; load first ref. in x0 whilst
						; updating the remainder pointer
		do 	#8,bas_fix_lp_12	; repeat loop for every possible
						; single error remainder
		cmp 	x0,b	x:(r0)+,x0	; check for remainder equality
						; and get new remainder in x0
		teq	y0,a			; if equal, correction mask in a  
bas_fix_lp_12	move	#bas_err_fix_13,r0	; default next state	
		tst	a			; has error been located ?
		beq	<end_check_12		; if a is clear, error not found
						; go to next search state
		move	#bas_valid_tst_0,r0	; a has data, error fix next 
						; state
		move	a1,x:error_mask		; store relevant error correct							; mask
end_check_12	rts
		
;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

bas_err_fix_13	move	#control_word,r2	
		move	#error_0080_mask,r0	; single error check remainders
		move	x:error_store,b		; latest error remainder result
		clr	a	x:(r0)+,y0	; clear a for loop and ensure y0						; contains the error mask.
		move	x:(r0)+,x0		; load first ref. in x0 whilst
						; updating the remainder pointer
		do 	#8,bas_fix_lp_13	; repeat loop for every possible
						; single error remainder
		cmp 	x0,b	x:(r0)+,x0	; check for remainder equality
						; and get new remainder in x0
		teq	y0,a			; if equal, correction mask in a
bas_fix_lp_13	move	#bas_valid_tst_0,r0	; default next state
		bfset	#$0020,x:(r2)		; default BAS correct indicator
						; in control word
		move	a1,x:error_mask		; store relevant error correct							; mask
		tst	a			; has error been located ?
		bne	<end_check_13		; if a is clear, error not found

		move	#bas_fix_end,r0
		bfclr	#$0020,x:(r2) 		; and current BAS is invalid

end_check_13	rts

;;*****************************************************************************
;;*									      *
;;*	Multiframe and Frame alignment test states	:  	This state    *
;;*	is used to check whether the latest received and decoded BAS signal   *
;;*	should be validated. In order to do this we must check for frame and  *
;;*	multiframe alignment and that the Frame alignment signal in the same  *
;;*	submultiframe has fewer than 2 bits in error. If either of these      *
;;* 	conditions are not met then the current decoded BAS is ignored.	      *
;;*									      *
;;*	Date	:	4/10/90						      *
;;*	Version	:	1.0						      *
;;*									      *
;;*****************************************************************************

bas_valid_tst_0	move	x:bas_erc_faw_ptr,r2	; get latest H221 word pointer
		move	#bas_valid_tst_1,r0	; next state
							
		clr	b	x:(r2-1),x0	; clear b and y for state and
		tfr3	b,y0	x:(r2)+,x1	; get EVEN frame H221 word,
						; and update pointer
		bftstl	#$0002,x0		; faw bit 0, should be low
		adc	y,b			; add carry to correct bit count
		bftstl	#$0004,x0		; faw bit 1, should be low
		adc	y,b			; add carry to correct bit count
		bftsth	#$0008,x0		; faw bit 2, should be high
		adc	y,b			; add carry to correct bit count
		bftsth	#$0010,x0		; faw bit 3, should be high
		adc	y,b			; add carry to correct bit count
		bftstl	#$0020,x0		; faw bit 4, should be low
		adc	y,b			; add carry to correct bit count
		bftsth	#$0040,x0		; faw bit 5, should be high
		adc	y,b			; add carry to correct bit count
		bftsth	#$0080,x0		; faw bit 6, should be high
		adc	y,b			; add carry to correct bit count
		bftsth	#$0002,x1		; faw bit 7, should be high
		adc	y,b			; add carry to correct bit count

		move	b0,x:faw_true_bit_cnt	; store the correct bit count
		move	r2,x:bas_erc_faw_ptr	; store updated pointer
		
		rts

bas_valid_tst_1	move	#control_word,r2	; get control word
		move	#bas_fix_end,r0		; next state
		
		bfclr	#$0020,x:(r2)		; set BAS invalid indicator
						; in control word
		move	x:faw_true_bit_cnt,b	; get the correct bit count in b
		movei	#6,x0			; is correct bit count greater
		cmp	x0,b			; than or equal to 6 ?
		ble	<bas_invalid		; if less than 6 then bas is 
						; invalid.
		bftsth	#$6000,x:(r2)		; test for frame AND multiframe
		bcc	<bas_invalid		; alignment, branch if not OK
		
		bfset	#$0020,x:(r2)		; set BAS valid indicator 
		
bas_invalid	rts
		
;;***********************************************************************
;;*									*
;;*	BAS Fix End State	:	This state checks the		*
;;* 	control word for whether the BAS invalid flag is asserted	*
;;*	and subsequently either updates the latest decoded BAS		*
;;* 	signal or ignores the current received BAS as a result.		*
;;*									*
;;*	Date	:	12/10/90					*
;;*	Version	:	1.0						*
;;*									*
;;***********************************************************************

bas_fix_end	move	#smf_state_0,r0		; next state
		move	x:control_word,x1	; if the current received bas
		bftsth	#$0020,x1		; is not valid then do nothing
		bcc	<bas_not_true
		
		move	x:decoded_bas_ptr,r3	; recall current BAS pointer
		move	m3,x:decoded_bas_ptr	; save current m3 value
		move	#7,m3			; modulo 8 buffer
		move	x:error_mask,x0		; get error mask
		move	x:(r3),b		; get latest decoded BAS
		eor	x0,b			; change incorrect bits in
		move	b1,x:(r3)+		; received bas, store and update
						; pointer
		move	x:decoded_bas_ptr,m3	; restore m3 value
		move	r3,x:decoded_bas_ptr	; BAS pointer for next time and
						; store new value				
bas_not_true	rts
		
;;***************************************************************************
;;*									    *
;;*	BAS Revert State	: 	The function of this state is	    * 
;;*	to reset the latest decoded BAS word to its 3'rd previous value     *
;;*	after frame alignment has been lost.				    *
;;*								            *
;;*	Date	:	4/10/90						    *
;;*	Version	:	1.0					    	    *
;;*									    *
;;***************************************************************************

bas_revert	move	x:decoded_bas_ptr,r3	; last decoded BAS pointer
		move	m3,x:decoded_bas_ptr	; store current value of r3
		move	#7,m3			; set m3 for modulo 8 addressing
						; i.e. 8 word circular buffer
		move	#bf_state_0,r0		; next state
		lea	(r3)-,r3		; set decoded BAS(n) to BAS(n-1)
						; as last valid BAS pointer
		move	x:decoded_bas_ptr,m3	; restore last m3 register value
		move	r3,x:decoded_bas_ptr	; 3'rd last decoded BAS word

		rts

;;***************************************************************************
;;*									    *
;;*	CRC performance check for the ISDN 64 kbps channel		    *
;;*	Data structure used ;						    *
;;*									    *
;;*   |	   a1	   |	        a1	       |	    a0           |  *
;;*									    *
;;*    0  0  0  y     x xd1xd2xd3xd4xd5xd6xd7    x xd1xd2xd3xd4xd5xd6xd7    *
;;*		      *	       *        				    *
;;*   output states    penultimate ISDN data	     last data rx	    *
;;*   	   y		     ir(N-1)		         ir(N)	  	    *
;;*									    *
;;*		d 	== single state delay				    *
;;*		* 	== bits to be x'ored				    *
;;*		y4	== output and crc result msb			    *
;;*		@	== after next clock i.e. next left shift	    *
;;*									    *
;;*	Equations governing the crc operation are as below :		    *
;;*								  	    *
;;*		@ x	== 	y + xd1 			  	    *
;;*		@ xd3	==	y + xd4					    *
;;*									    *
;;*	The CRC equation for the ISDN line check is	:		    *
;;*			      						    *
;;*		y(d)/x(d) == g(d) == d4/(1+d+d4)		 	    *
;;*									    *
;;*		Date	:	27/9/90					    *
;;*				29/4/91 				    *
;;*		Version	:	1.8					    *
;;*				1.9					    *
;;*								  	    *
;;***************************************************************************

;;  Optimised storage set_up  :			isdn_count_rx	ds	1
;;						rx_crc_store	ds	1
;;								dc	0
;;								dc	8
;;						ir_shft		ds	1
;;						rx_crc_value_2	dc	12
;;								dc	$0090
;;						rx_crc_data	ds	1

crc_rx		move	#isdn_count_rx,r3	; optimised storage pointer
		move	x:rx_crc_cnt_ptr,r2	; crc count comparison pointer

		move	x:(r3)+,b		; current isdn count in b
		move	x:(r3)+,a		; last crc storage value in a
		move	x:(r3)+,y0		; zero ref. count in y0
		move	x:(r2)+n2,x1 x:(r3)+,x0	; current reference count in x1
						; default loop count in x0
		cmp	x1,b	x:(r2+50),x1	; first byte of new smf ?
						; last byte of smf, count in x1
		bne	<rx_smf_not_done
		cmp	y0,b	x:(r2)+,y1	; first byte of multiframe ?
						; update reference counter in y1
		bne	<rx_cnt_not_zero	; no, then branch

		move	#crc_count,r2		; yes, restore count pointer,

rx_cnt_not_zero	move	a1,x:rx_crc_data	; store final crc result,
		move	x:ir,a			; isdn data in a1 lower byte
						; this provides the d4 multiply 
		bra	<crc_loop_rx		; function in crc generator eqn.
						; wait for next intrupt for crc
rx_smf_not_done	move	x:(r3)+,a0		; new isdn data in here to a0
		move	x:(r2+34),y1		; crc bit rx, lower window count
		cmp	y1,b	x:(r2+42),y1	; current isdn count in window ?
		blt	<out_window_rx		; no, then branch
		cmp	y1,b			; current isdn count in window ?
		bgt	<out_window_rx		; no, then branch

		bfclr	#$0100,a0		; if in window, clear last isdn
						; rx lsb before executing crc
out_window_rx	cmp	x1,b	x:(r3)+,y0	; last count in present block ?
						; update pointer for next time.
		tne	x0,b			; appropriate loop count
		teq	y0,b			; in b1
		swap	b			; loop count in b0
		tfr3	b,y0	x:(r3)+,x0	; clear y0 for crc loop, 
						; crc mask 2 in x0
		do	b0,crc_loop_rx		; do loop b0 times

		bfclr	#$0080,a1		; test last output,
		tcc	x0,b			; set mask as a result of test
		asl	a	b,y1		; mask in y1, shift bits for eor
		eor	y1,a	y0,b		; perform modulo 2 of a1 bits 
						; and clear b
crc_loop_rx	move	a1,x:rx_crc_store	; save CRC data for next rx
		move	r2,x:rx_crc_cnt_ptr	; save reference count pointer

		rts

		nolist