		org	x:$00

		list		; enable H221 variable listing

;;***********************************************************************

control_word	ds	1	; isdn control word
				; ***********************************
				; b0  = H221 tx enable 	   	0 = disabled
				; b1  = tx CRC enable	   	0 = disabled
				; b2  = tx mf count enable 	0 = disabled
				; b3  =
				; b4  =
				; b5  = current rx BAS OK  	0 = not valid
				; b6  =	terminal alarm tx  	0 = no alarm
				; b7  = interrupt occurrence 	0 = no
				; b8  = isdn rx     	   	0 = no rx
				; b9  =	rx enable  	   	0 = enabled
				; b10 =	rx CRC enable 	   	0 = disabled
				; b11 = rx CRC error   	   	0 = no error
				; b12 =	rx odd/even smf	   	0 = even
				; b13 = frame alignment	   	0 = no
				; b14 = multiframe alignment   	0 = no
				; b15 = terminal alarm rx  	0 = no alarm
					
;;++++++++++++++++++++++++++++++++++++++++++++++++
;;
;; 		Receive storage
;;
;;++++++++++++++++++++++++++++++++++++++++++++++++

bas_faw_0		ds	1
erc_faw_0		ds	1
mf_align_wrd		ds	1
mf_count_rx		ds	1
ir			ds	1
faw_error_count		ds	1
mf_error_count		ds	1

;;++++++++++++++++++++++++++++++++++++++++++++++++
;;
;;	Optimised CRC Check Storage
;;
;;++++++++++++++++++++++++++++++++++++++++++++++++

crc_enable_cnt		ds	1
crc_disable_cnt		ds	1
isdn_count_rx		ds	1
rx_crc_store		ds	1
			dc	0
			dc	8
ir_shft			ds	1	; data resides in upper byte of word
rx_crc_value_2		dc	12
			dc	$0090
rx_crc_data		ds	1
rx_crc_cnt_ptr		ds	1
								
;;++++++++++++++++++++++++++++++++++++++++++++++++
;;
;;	Optimised rx even state storage
;;
;;++++++++++++++++++++++++++++++++++++++++++++++++

decoded_bas_ptr		ds	1
bas_erc_faw_ptr		ds	1
rx_count_ptr		ds	1
		org	x:$0018		; 8 word modulo buffer
decoded_bas		ds	8
bas_erc_faw		ds	17
		
;;++++++++++++++++++++++++++++++++++++++++++++++++
;;
;;	Optimised CRC test state storage
;;
;;++++++++++++++++++++++++++++++++++++++++++++++++

crc_test_count		ds	1
crc_error_count 	ds	1
end_count		dc	100
test_error_count	dc	89
crc_sorted		ds	1

;;++++++++++++++++++++++++++++++++++++++++++++++++
;;
;;	Optimised BAS Error detect storage
;;
;;++++++++++++++++++++++++++++++++++++++++++++++++

bas_erc_store		ds	1
mask			dc	$00d7
error_ref_val		dc	0
			dc	16
count_check_2		ds	1
temp_error		ds	2
r2_temp_2		ds	1
error_store		ds	1
error_mask		ds	1
faw_true_bit_cnt	ds	1

;;++++++++++++++++++++++++++++++++++++++++++++++++
;;
;;	BAS Error correct references
;;
;;++++++++++++++++++++++++++++++++++++++++++++++++
									
single_error	dc	$009e		; for error	0001
		dc	$004f		; position	0002		
		dc	$00cc		;		0004
		dc	$0066		;		0008
		dc	$0033		;		0010
		dc	$00f2		;		0020
		dc	$0079		;		0040
		dc	$00d7		;		0080

bas_err_mask_0	dc	$0001		; these values are the x'or 
		dc	$0002		; errors to be used upon the 
		dc	$0004		; latest received DECODED BAS
		dc	$0008		; for a single error in the 
		dc	$0010		; indicated position
		dc	$0020		; N.B. the b0 bit of the received
		dc	$0040		; BAS is taken to be the MSB for 
		dc	$0080		; BAS CRC operation ==> an implied
					; 'b0' errorin the error result 
					; is actually in b7 
					
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

double_error_0	dc	$00d1		; for errors	0003
		dc	$0052		; in positions	0005
		dc	$00f8		;		0009
		dc	$00ad		;		0011
		dc	$006c		;		0021
		dc	$00e7		;		0041
		dc	$0049		;		0081

bas_err_mask_1	dc	$0003		; these values are the x'or
		dc	$0005		; errors to be used upon the 
		dc	$0009		; latest received DECODED BAS
		dc	$0011		; for double errors in the
		dc	$0021		; indicated positions
		dc	$0041
		dc	$0081

;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

double_error_1	dc	$0083		; for errors	0006
		dc	$0029		; in positions	000a
		dc	$007c		;		0012
		dc	$00bd		; 		0022
		dc	$0036		;		0042
		dc	$0098		;		0082
		dc	$00ae		;		00c0

bas_err_mask_2	dc	$0006		; these values are the x'or
		dc	$000a		; errors to be used upon the 
		dc	$0012		; DECODED BAS for double errors 
		dc	$0022		; in the indicated positions
		dc	$0042
		dc	$0082
		dc	$00c0
		
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

double_error_2	dc	$00aa		; for errors	000c
		dc	$00ff		; in positions	0014
		dc	$003e		;		0024
		dc	$00b5		;		0044
		dc	$001b		;		0084
		dc	$008b		;		0060
		dc	$0025		;		00a0

bas_err_mask_3	dc	$000c		; these values are the x'or
		dc	$0014		; errors to be used upon the 
		dc	$0024		; DECODED BAS for double errors 
		dc	$0044		; in the indicated positions
		dc	$0084
		dc	$0060
		dc	$00a0
		
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		
double_error_3	dc	$0055		; for errors	0018
		dc	$0094		; in positions	0028
		dc	$001f		;		0048
		dc	$00b1		;		0088
		dc	$00c1		;		0030
		dc	$004a		;		0050
		dc	$00e4		;		0090
		
bas_err_mask_4	dc	$0018		; these values are the x'or
		dc	$0028		; errors to be used upon the 
		dc	$0048		; DECODED BAS for double errors
		dc	$0088		; in the indicated positions
		dc	$0030
		dc	$0050
		dc	$0090
				
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
		
error_0001_mask	dc	$0001		; error position mask

bas_err_0001	dc	$001e		; single BAS
		dc	$00de		; error in position
		dc	$00be		; 0001
		dc	$008e
		dc	$0096
		dc	$009a
		dc	$009c
		dc	$009f
		
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		
error_0002_mask	dc	$0002		; error position mask

bas_err_0002	dc	$00cf		; single BAS
		dc	$000f		; error in position
		dc	$006f		; 0002
		dc	$005f
		dc	$0047
		dc	$004b
		dc	$004d
		dc	$004e
		
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
		
error_0004_mask	dc	$0004		; error position mask

bas_err_0004	dc	$004c		; single BAS 
		dc	$008c		; error in position
		dc	$00ec		; 0004
		dc	$00dc
		dc	$00c4
		dc	$00c8
		dc	$00ce
		dc	$00cd
		
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
		
error_0008_mask	dc	$0008		; error position mask

bas_err_0008	dc	$00e6		; single BAS
		dc	$0026		; error in position
		dc	$0046		; 0008
		dc	$0076
		dc	$006e
		dc	$0062
		dc	$0064
		dc	$0067
		
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
		
error_0010_mask	dc	$0010		; error position mask

bas_err_0010	dc	$00b3		; single BAS 
		dc	$0073		; error in position
		dc	$0013		; 0010
		dc	$0023
		dc	$003b
		dc	$0037
		dc	$0031
		dc	$0032
		
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		

error_0020_mask	dc	$0020		; error position mask

bas_err_0020	dc	$0072		; single BAS
		dc	$00b2		; error in position
		dc	$00d2		; 0020
		dc	$00e2
		dc	$00fa
		dc	$00f6
		dc	$00f0
		dc	$00f3
		
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		
error_0040_mask	dc	$0040		; error position mask

bas_err_0040	dc	$00f9		; single BAS
		dc	$0039		; error in position
		dc	$0059		; 0040
		dc	$0069
		dc	$0071
		dc	$007d
		dc	$007b
		dc	$0078
		
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++		
		
error_0080_mask	dc	$0080		; error position mask

bas_err_0080	dc	$0057		; single BAS
		dc	$0097		; error in position
		dc	$00f7		; 0080
		dc	$00c7
		dc	$00df
		dc	$00d3
		dc	$00d5
		dc	$00d6

;;++++++++++++++++++++++++++++++++++++++++++++++++
;;
;;	Transmit and Receive reference counts
;;
;;++++++++++++++++++++++++++++++++++++++++++++++++

tx_count	dc	0		; 
crc_count	dc	160
		dc	320
		dc	480
		dc	640
		dc	800
		dc	960
		dc	1120
		dc	0
rx_count_0	dc	80		; Pointer for the initial frame 
		dc	240		; and multiframe synchronisation
		dc	400
		dc	560
		dc	720
		dc	880
		dc	1040
		dc	1200
		dc	1280
rx_count	dc	15		; Pointer to the end of each
		dc	175		; H221 word for even submultiframe
		dc	335		; receptions
		dc	495
		dc	655
		dc	815
		dc	975
		dc	1135
first_rx	dc	1280		; This pointer ensures the correct
		dc	95		; synchronisation of the receive
		dc	255		; H221 state machine
		dc	415
		dc	575
		dc	735
		dc	895
		dc	1055
		dc	1215
crc_bit_start	dc	84		; Pointer to the start of the
		dc	244		; crc bit count window for H221
		dc	404		; tx and rx
		dc	564
		dc	724
		dc	884
		dc	1044
		dc	1204
crc_bit_end	dc	87		; Pointer to the end of the
		dc	247		; crc bit count window for H221
		dc	407		; tx and rx
		dc	567
		dc	727
		dc	887
		dc	1047
		dc	1207
crc_end_smf	dc	159		; Pointer to the last byte of
		dc	319		; each submultiframe.
		dc	479
		dc	639
		dc	799
		dc	959
		dc	1119
		dc	1279
		
;;++++++++++++++++++++++++++++++++++++++++++++++++
;;
;;		Transmit storage
;;
;;++++++++++++++++++++++++++++++++++++++++++++++++

is_shft		ds	1		; data resides in the lower byte	
bas_data	ds	1
bas_state_ptr	ds	1
faw_state_ptr	ds	1
erc_state_ptr	ds	1
disable_crc_ptr	ds	1
enable_crc_ptr	ds	1
mfaw_data	dc	$0034
mfaw_store	ds	1

;;++++++++++++++++++++++++++++++++++++++++++++++++
;;
;;	Transmit State 0 optimised store
;;
;;++++++++++++++++++++++++++++++++++++++++++++++++

tx_ref_count_ptr	ds	1
tx_0_val		dc	15
			dc	1120
			dc	0
mf_count_store		ds	1
mf_count		ds	1

;;++++++++++++++++++++++++++++++++++++++++++++++++
;;
;;		Optimised tx CRC Storage
;;
;;++++++++++++++++++++++++++++++++++++++++++++++++

isdn_count_tx	ds	1
tx_crc_store	ds	1
		dc	0
		dc	8
is		ds	1		; data resides in upper byte
tx_crc_value_2	dc	12
		dc	$0090
tx_crc_data	ds	1
tx_crc_cnt_ptr	ds	1

;;+++++++++++++++++++++++++++++++++++++++++++++++++
;;
;;		Optimised BAS CRC Storage
;;
;;+++++++++++++++++++++++++++++++++++++++++++++++++

bas_store	ds	1
bas_mask	dc	$00d7
erc_ref_val	dc	0
		dc	16
count_check	ds	1
temp_erc	ds	2
r2_temp		ds	1
erc_store	ds	1

;;**********************************************************************

		nolist