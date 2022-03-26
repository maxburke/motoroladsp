;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Companded CODEC to/from Linear Data Conversion Test Program
; 
; Last Update 20 Apr 87   Version 1.0
;
    page        132
loglint ident   1,0
;
; CODEC to DSP56001 interface program used to test LOGLIN and LINLOG
; macros on the DSP56001 Application Development System (ADS) hardware.
; The SSI interface is used for analog I/O with a mu-law formatted Motorola
; MC14402 CODEC.  Bit sync and frame sync clocks are generated by the SSI
; internal clock generator.
;
; Latest Revision - April 20, 1987
; Tested and verified - April 20, 1987
;
        opt     mex
        nolist
        include 'dsplib:ioequ'
        include 'dsplib:loglin'
        include 'dsplib:linlog'
        list
;
; Cold start (reset)
;
        org     p:0
        jmp     <start
;
; Initialize peripherals
;
        org     p:$100
start   movep   #0,x:M_BCR              ;set for zero wait state memory
        or      #$4,omr                 ;enable mu/a-law lookup table
        movep   #0,x:M_PCC              ;reset SSI and Port C pins
        movep   #$000127,x:M_CRA        ;init SSI for 128.125 KHz continuous
                                        ; clock (PSR=0,PM=40-1), 8.008 KHz
        movep   #$003230,x:M_CRB        ; word length frame sync (WL=8 bits,
                                        ; DC=2-1) using a 20.5 MHz DSP clock.
        movep   #$1e0,x:M_PCC           ;init PC5-PC8 as SSI pins
;
; Receive SSI data
;
datain  jclr    #M_RDF,x:M_SR,datain    ;loop until receive data available
        movep   x:M_RX,a1               ;read SSI receive data register
;
; Convert mu-law data to linear fraction
;
        mulin
;
; Insert digital signal processing here
;
        nop
;
; Convert linear fraction to mu-law data
;
        linmu
;
; Transmit SSI data
;
dataout jclr    #M_TDE,x:M_SR,dataout   ;loop until transmit ready
        movep   a1,x:M_TX               ;write SSI transmit data register
        jmp     <datain                 ;do it again
        end     start
