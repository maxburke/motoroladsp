          page   132,65,3,3
;         opt       CC
;********************************************************
;*    Motorola Austin DSP Operation  10 April 1991      *
;*                                                      *
;*  COPYRIGHT (C) BY MOTOROLA INC, ALL RIGHTS RESERVED  *
;*                                                      *
;*      ALTHOUGH THE INFORMATION CONTAINED HEREIN,      *
;*      AS WELL AS ANY INFORMATION PROVIDED RELATIVE    *
;*      THERETO, HAS BEEN CAREFULLY REVIEWED AND IS     *
;*      BELIEVED ACCURATE, MOTOROLA ASSUMES NO          *
;*      LIABILITY ARISING OUT OF ITS APPLICATION OR     *
;*      USE, NEITHER DOES IT CONVEY ANY LICENSE UNDER   *
;*      ITS PATENT RIGHTS NOR THE RIGHTS OF OTHERS.     *
;*                                                      *
;********************************************************

;****************************************************************************
;   slave2.asm  - demo code for DSP96002 multi-device simulation
;
;   9 April 91: Roman Robles - polish for 4 dev. sim.
;
;   relavant topology for this simulation:
;
;                       B       A          B       A
;             ----------+       +----------+       +-----------
;              Upstream |       |  Master  |       |   Slave   
;              DSP96002 |=====> | DSP96002 |=====> |  DSP96002 
;             __________|(PIO)  |__________| (DMA) |___________
;
;****************************************************************************
; Equates Section
;****************************************************************************

RESET   equ     $00000000               ; reset isr
DMA0    equ     $00000010               ; DMA channel 0 isr
HOSTCMD equ     $0000001C               ; port A default host command
XMEMRD  equ     $00000024               ; port A host X memory read
MAIN    equ     $00000200               ; main routine

IPR     equ     $FFFFFFFF               ; interrupt priority reg
BCRA    equ     $FFFFFFFE               ; port A bus control reg
BCRB    equ     $FFFFFFFD               ; port b bus control reg
PSR     equ     $FFFFFFFC               ; port select reg

HRES    equ     5                       ; host interface reset bit
HTDE    equ     1                       ; host transmit data reg. empty

;****************************************************************************
; addresses of channel 0 DMA registers
;****************************************************************************

DMA0SAR equ     $FFFFFFDE               ; DMA ch 0 source address reg
DMA0CR  equ     $FFFFFFDC               ; DMA ch 0 counter reg
DMA0DAR equ     $FFFFFFDA               ; DMA ch 0 destination address reg
DMA0DOR equ     $FFFFFFD9               ; DMA ch 0 destination offset reg
DMA0CSR equ     $FFFFFFD8               ; DMA ch 0 control/status reg

;****************************************************************************
; addresses of port A and B  host interface registers
;****************************************************************************

HRXA    equ     $FFFFFFEF               ; port a host receive reg
HTXCA   equ     $FFFFFFEE               ; port a host tx reg and HMRC clear
HSRA    equ     $FFFFFFED               ; port a host status reg
HCRA    equ     $FFFFFFEC               ; port a host control reg

HTXB    equ     $FFFFFFE7               ; port b host trans/receive reg
HSRB    equ     $FFFFFFE5               ; port b host status reg
HCRB    equ     $FFFFFFE4               ; port b host control reg

;****************************************************************************
; fast interrupt service routines
;****************************************************************************

        org     p:RESET                 ; reset isr
        jmp     MAIN

        org     p:DMA0                  ; DMA channel 0 isr
        bset    #HRES,x:HCRA            ; disable DMA transfer 
        jmp	*                           ; for test purposes, stop here when
                                        ; done
        org     p:HOSTCMD               ; host command vector isr
        jsr     host_cmd

        org     p:XMEMRD                ; X memory read isr
        jsr     read_X


;*****************************************************************************
;  initialization
;*****************************************************************************

        org     p:MAIN
        movep   #$00330000,x:IPR        ; port A host port and DMA channel 0
                                        ;   have ipl=2.
        movep   #$0,x:BCRA              ; no wait states for P,X,Y,I/O
        movep   #$0,x:BCRB              ; don't care about page fault
        movep   #$FFFFFF,x:PSR          ; all external fetches will be from
                                        ; port B since port A BG~ is asserted
        movep   #$0404,x:HCRA           ; enable X memory read and host 
                                        ;   command vector interrupts
        ori     #$8,omr                 ; enable the internal data ROMs
        andi    #$CF,mr                 ; unmask all interrupts

;*****************************************************************************
;  main routine would go here, for the simlulation, just loop
;*****************************************************************************

        bclr    #HRES,x:HCRB            ; reset HI_B and enable it...  
        move    #$5,D0.l                ; prime the data 
_l1     jclr    #HTDE,x:HSRB,_l2        ; loop until HI_B Tx reg. is empty
        movep   D0.l,x:HTXB             ; send the next data word
        inc     D0.l                    ; and bump the data for next time
_l2     jmp     _l1

;*****************************************************************************
;  long interrupt service routine for handling a direct access X memory read
;    from port A host interface
;*****************************************************************************

read_X
        movep   x:HRXA,r0                ; move the desired address into r0
        nop                              ; wait for the r0 to become valid
        movep   x:(r0),x:HTXCA           ; write HTX and clear HMRC bit
        rti

;*****************************************************************************
;  long interrupt service routine for handling the default host command
;    vector for port A which is responsible for setting up the channel 0
;    DMA controller
;*****************************************************************************

host_cmd
        movep    #HRXA,x:DMA0SAR         ; get dma data from HRX
        movep    #0,x:DMA0DAR            ; begin loading the sine wave at
                                         ;   X:0
        movep    #1,x:DMA0DOR
        movep    #512,x:DMA0CR           ; transfer all 512 words 
        movep    #$C4000819,x:DMA0CSR    ; enable DMA and DMA interrupts
                                         ; single block,word xfer trig by DMA
                                         ; core and channel 0 have priority
                                         ; port a host rcv (hrdf) DMA req
                                         ; internal I/O (X mem) source
                                         ; internal X data mem dest
        rti
