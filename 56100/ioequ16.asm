;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Motorola Standard I/O Equates for DSP56116.
; 
; Update 25 Aug 87   Version 1.1   fixed M_OF
; Last Update 24 Jul 91  Version 1.2  fixed for DSP56116 peripheral map.
;
;************************************************************************
;
;       EQUATES for DSP56116 I/O registers and ports
;
;************************************************************************
ioequ16   ident   1,0
;------------------------------------------------------------------------
;
;       EQUATES for I/O Port Programming
;
;------------------------------------------------------------------------
;       Register Addresses
M_BCR EQU  $FFDE   ; Bus Control Register
M_PBC   EQU     $FFC0           ; Port B Control Register
M_PBDDR EQU     $FFC2           ; Port B Data Direction Register
M_PBD   EQU     $FFE2           ; Port B Data Register
M_PCC   EQU     $FFC1           ; Port C Control Register
M_PCDDR EQU     $FFC3           ; Port C Data Direction Register
M_PCD   EQU     $FFE3           ; Port C Data Register
;------------------------------------------------------------------------
;
;       EQUATES for Host Interface
;
;------------------------------------------------------------------------
;       Register Addresses
M_HCR   EQU     $FFC4           ; Host Control Register
M_HSR   EQU     $FFE4           ; Host Status Register
M_HRX   EQU     $FFE5           ; Host Receive Data Register
M_HTX   EQU     $FFE5           ; Host Transmit Data Register
;       Host Control Register Bit Flags
M_HRIE  EQU     0               ; Host Receive Interrupt Enable
M_HTIE  EQU     1               ; Host Transmit Interrupt Enable
M_HCIE  EQU     2               ; Host Command Interrupt Enable
M_HF2   EQU     3               ; Host Flag 2
M_HF3   EQU     4               ; Host Flag 3
;       Host Status Register Bit Flags
M_HRDF  EQU     0               ; Host Receive Data Full
M_HTDE  EQU     1               ; Host Transmit Data Empty
M_HCP   EQU     2               ; Host Command Pending
M_HF    EQU     $18             ; Host Flag Mask
M_HF0   EQU     3               ; Host Flag 0
M_HF1   EQU     4               ; Host Flag 1
M_DMA   EQU     7               ; DMA Status
;------------------------------------------------------------------------
;
;       EQUATES for Synchronous Serial Interface (SSI0)
;
;------------------------------------------------------------------------
;       Register Addresses
M_0RX    EQU     $FFF1          ; Serial SSI0 Receive Data Register
M_0TX    EQU     $FFF1          ; Serial SSI0 Transmit Data Register
M_0CRA   EQU     $FFD0          ; SSI0 Control Register A
M_0CRB   EQU     $FFD1          ; SSI0 Control Register B
M_0SR    EQU     $FFF0          ; SSI0 Status Register
M_0TSR   EQU     $FFF0          ; SSI0 Time Slot Register
M_0RSMA0 EQU     $FFF2          ; Read/Write SSI0 Rcv Slot Mask Reg A
M_0RSMB0 EQU     $FFF3          ; Read/Write SSI0 Rcv Slot Mask Reg B
M_0TSMA0 EQU     $FFF4          ; Read/Write SSI0 Xmt Slot Mask Reg A
M_0TSMB0 EQU     $FFF5          ; Read/Write SSI0 Xmt Slot Mask Reg B
;       SSI Control Register A Bit Flags
M_0PM    EQU     $FF            ; Prescale Modulus Select Mask
M_0DC    EQU     $1F00          ; Frame Rate Divider Control Mask
M_0WL    EQU     $6000          ; Word Length Control Mask
M_0WL0   EQU     13             ; Word Length Control 0
M_0WL1   EQU     14             ; Word Length Control 1
M_0PSR   EQU     15             ; Prescaler Range
;       SSI Control Register B Bit Flags
M_OF    EQU     $3              ; Serial Output Flag Mask
M_OF0   EQU     0               ; Serial Output Flag 0
M_OF1   EQU     1               ; Serial Output Flag 1
M_0FLG EQU  2    ; CRB Flag Bit
M_0AMU  EQU     3               ; A/Mu Law Selection
M_0FSD  EQU     4               ; Frame Sync Direction Bit
M_0SCKD EQU     5               ; Clock Source Direction
M_0SCKP EQU     6               ; Clock Polarity Bit
M_0SHFD EQU  7    ; MSB Position Bit
M_0FSL EQU  8    ; Frame Sync Length
M_0FSI EQU  9    ; Frame Sync Invert
M_0SYN  EQU     10              ; Sync/Async Control
M_0MOD  EQU     11              ; Mode Select
M_0STE  EQU     12              ; SSI0 Transmit Enable
M_0SRE  EQU     13              ; SSI0 Receive Enable
M_0STIE EQU     14              ; SSI0 Transmit Interrupt Enable
M_0SRIE EQU     15              ; SSI0 Receive Interrupt Enable
;       SSI Status Register Bit Flags
M_0IF   EQU     $2              ; Serial Input Flag Mask
M_0IF0  EQU     0               ; Serial Input Flag 0
M_0IF1  EQU     1               ; Serial Input Flag 1
M_0TFS  EQU     2               ; Transmit Frame Sync
M_0RFS  EQU     3               ; Receive Frame Sync
M_0TUE  EQU     4               ; Transmitter Underrun Error
M_0ROE  EQU     5               ; Receiver Overrun Error
M_0TDE  EQU     6               ; Transmit Data Register Empty
M_0RDF  EQU     7               ; Receive Data Register Full
;------------------------------------------------------------------------
;
;       EQUATES for Synchronous Serial Interface (SSI1)
;
;------------------------------------------------------------------------
;       Register Addresses
M_1RX    EQU     $FFF9          ; Serial SSI1 Receive Data Register
M_1TX    EQU     $FFF9          ; Serial SSI1 Transmit Data Register
M_1CRA   EQU     $FFD8          ; SSI1 Control Register A
M_1CRB   EQU     $FFD9          ; SSI1 Control Register B
M_1SR    EQU     $FFF8          ; SSI1 Status Register
M_1TSR   EQU     $FFF8          ; SSI1 Time Slot Register
M_1RSMA0 EQU     $FFFA          ; Read/Write SSI1 Rcv Slot Mask Reg A
M_1RSMB0 EQU     $FFFB          ; Read/Write SSI1 Rcv Slot Mask Reg B
M_1TSMA0 EQU     $FFFC          ; Read/Write SSI1 Xmt Slot Mask Reg A
M_1TSMB0 EQU     $FFFD          ; Read/Write SSI1 Xmt Slot Mask Reg B
;       SSI Control Register A Bit Flags
M_1PM    EQU     $FF            ; Prescale Modulus Select Mask
M_1DC    EQU     $1F00          ; Frame Rate Divider Control Mask
M_1WL    EQU     $6000          ; Word Length Control Mask
M_1WL0   EQU     13             ; Word Length Control 0
M_1WL1   EQU     14             ; Word Length Control 1
M_1PSR   EQU     15             ; Prescaler Range
;       SSI Control Register B Bit Flags
M_1F    EQU     $3              ; Serial Output Flag Mask
M_1F0   EQU     0               ; Serial Output Flag 0
M_1F1   EQU     1               ; Serial Output Flag 1
M_1FLG EQU  2    ; CRB Flag Bit
M_1AMU  EQU     3               ; A/Mu Law Selection
M_1FSD  EQU     4               ; Frame Sync Direction Bit
M_1SCKD EQU     5               ; Clock Source Direction
M_1SCKP EQU     6               ; Clock Polarity Bit
M_1SHFD EQU  7    ; MSB Position Bit
M_1FSL EQU  8    ; Frame Sync Length
M_1FSI EQU  9    ; Frame Sync Invert
M_1SYN  EQU     10              ; Sync/Async Control
M_1MOD  EQU     11              ; Mode Select
M_1STE  EQU     12              ; SSI1 Transmit Enable
M_1SRE  EQU     13              ; SSI1 Receive Enable
M_1STIE EQU     14              ; SSI1 Transmit Interrupt Enable
M_1SRIE EQU     15              ; SSI1 Receive Interrupt Enable
;       SSI Status Register Bit Flags
M_IF    EQU     $2              ; Serial Input Flag Mask
M_IF0   EQU     0               ; Serial Input Flag 0
M_IF1   EQU     1               ; Serial Input Flag 1
M_TFS   EQU     2               ; Transmit Frame Sync
M_RFS   EQU     3               ; Receive Frame Sync
M_TUE   EQU     4               ; Transmitter Underrun Error
M_ROE   EQU     5               ; Receiver Overrun Error
M_TDE   EQU     6               ; Transmit Data Register Empty
M_RDF   EQU     7               ; Receive Data Register Full
;------------------------------------------------------------------------
;
;       EQUATES for Exception Processing
;
;------------------------------------------------------------------------
;       Register Addresses
M_IPR   EQU     $FFDF           ; Interrupt Priority Register
;       Interrupt Priority Register Bit Flags
M_IAL   EQU     $7              ; IRQA Mode Mask
M_IAL0  EQU     0               ; IRQA Mode Interrupt Priority Level (low)
M_IAL1  EQU     1               ; IRQA Mode Interrupt Priority Level (high)
M_IAL2  EQU     2               ; IRQA Mode Trigger Mode
M_IBL   EQU     $38             ; IRQB Mode Mask
M_IBL0  EQU     3               ; IRQB Mode Interrupt Priority Level (low)
M_IBL1  EQU     4               ; IRQB Mode Interrupt Priority Level (high)
M_IBL2  EQU     5               ; IRQB Mode Trigger Mode
M_HPL   EQU     $300            ; Host Interrupt Priority Level Mask
M_HPL0  EQU     8               ; Host Interrupt Priority Level Mask (low)
M_HPL1  EQU     9               ; Host Interrupt Priority Level Mask (high)
M_0SSL  EQU     $C00            ; SSI0 Interrupt Priority Level Mask
M_0SSL0 EQU     10              ; SSI0 Interrupt Priority Level Mask (low)
M_0SSL1 EQU     11              ; SSI0 Interrupt Priority Level Mask (high)
M_1SSL  EQU     $3000           ; SSI1 Interrupt Priority Level Mask
M_1SSL0 EQU     12              ; SSI1 Interrupt Priority Level Mask (low)
M_1SSL1 EQU     13              ; SSI1 Interrupt Priority Level Mask (high)
M_IL EQU  $C000   ; Timer Interrupt Priority Level Mask
M_ILl EQU  14    ; Timer Interrupt Priority Level Mask (low)
M_IL EQU  15    ; Timer Interrupt Priority Level Mask (high)
 
;--------------------------------------------------------------------------
;
;  EQUATES for Timer and Event Counter
;
;--------------------------------------------------------------------------
;       Register Addresses
M_TPR EQU  $FFEF   ; Timer Preload Register
M_TCPR EQU  $FFEE   ; Timer Compare Register
M_TCTR EQU  $FFED   ; Timer Count Register
M_TCR EQU  $FFEC   ; Timer Control Register
;      Timer Control Register Bit Flags
M_TDC EQU  $FF    ; Timer Decrement Ratio Mask
M_TES EQU  8    ; Timer Event Select Bit Mask
M_OIE EQU  9    ; Timer Overflow Interrupt Enable Bit Mask
M_CIE EQU  10    ; Timer Compare Interrupt Enable Mask
M_TO EQU  $3800   ; Timer Output Enable Bit Mask
M_TINV EQU  14    ; Timer Inverter Bit Mask
M_TE EQU  15    ; Timer Enable Bit Mask
 
 
