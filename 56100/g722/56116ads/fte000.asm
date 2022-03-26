      page 75,63,0,0

;***************************************************************
;program name = asm file that will test the ADM56116 memory and
;portb & c continuity for the functional test.
;date last modified = 05-30-90
;revision = 00
;***************************************************************

;***************************************************************
;define equate constants
;***************************************************************

pbddr     equ  $FFC2
pcddr     equ  $FFC3
pbd       equ  $FFE2
pcd       equ  $FFE3
bcr       equ  $FFDE
scrpad    equ  $40
errpad    equ  $50

          org  p:$e000


;***************************************************************
;pmemtst11 is an address memory test in which a 0 is placed in 
;address 0 of RAM and a 1 in 1 and so forth through (8k-this  
;.lod file = approximately 7k) of program memory and the full 8k
;of X data memory.  Since the default mode is mode2, the first 2k
;of internal RAM, both P & X, are internal.    
;***************************************************************

pmemtst11 jsr  initmem 
          jsr  initbcr 
          move #errpad,r1     ;load initial error pointer. 
          move #errpad+$f,y0  ;load errpad maximum +1 into y0. 
          move #>$11,a        ;load test number. 
          move #scrpad+$1,r2  ;load scrpad pointer. 
          move a1,a0          ;prepare a1 to store. 
          move a0,p:(r2)      ;store test number.       
          move #0,x0          ;clear x0. 
          move #$400,r0       ;load pmem start pointer. 
          move #$1c00,r3      ;load do loop counter. 
          do r3,wrtest11 
          move #>$1,a         ;load a 1 adder. 
          move x0,a0          ;prepare x0 to store. 
          move a0,p:(r0)+     ;store a0 to memory. 
          move #>$1,a         ;load a 1 adder. 
          add  x0,a           ;add a 1 to x0. 
          move a1,x0          ;restore x0. 
wrtest11  move #0,x0          ;clear x0. 
          move #$400,r0       ;reload pmem start pointer. 
          do r3,rdtest11 
          move p:(r0)+,a      ;get memory value. 
          cmpm x0,a           ;compare read with write. 
          jsne error          ;go post error. 
          move #>$1,a         ;load a 1 adder. 
          add x0,a            ;add a 1 to x0. 
          move a1,x0          ;restore x0. 
rdtest11  move #scrpad+$0,r2  ;load error pointer. 
          move #$1,x0         ;load error test. 
          move p:(r2),a       ;get error flag. 
          cmpm x0,a           ;did an error occur. 
          jeq  badhang1       ;loop on bad address. 
          jmp  pmemtst12      ;go on to test2.          
badhang1  jmp  badhang1       ;bad board address. 
 
;***************************************************************
;pmemtst12 is a memory test that will walk a 1 through each of 
;data bus pins as the address is simulateously incremented.
;***************************************************************

pmemtst12 move #>$12,a        ;load test number. 
          move #scrpad+$1,r2  ;load srcpad pointer. 
          move a1,a0          ;prepare a1 to store. 
          move a0,p:(r2)      ;store test number.       
          move #$400,r0       ;load pmem start pointer. 
          move #$160,r3       ;load do loop counter. 
          do   r3,wrtest12
          move #>$1,x0        ;load initial bit. 
          do   #$10,wrtest120 
          move x0,a0          ;prepare x0 to store. 
          move a0,p:(r0)+     ;store a0 to memory. 
          move x0,b           ;move x0 to b to shift left. 
          lsl b               ;shift bit left. 
          move b1,x0          ;restore x0. 
wrtest120 nop 
wrtest12  move #$400,r0       ;load pmem start pointer. 
          do   r3,rdtest12 
          move #>$1,x0        ;load initial bit. 
          do   #$10,rdtest120 
          clr  a 
          move p:(r0)+,a      ;get read word. 
          cmp  x0,a 
          jsne error 
          move x0,b           ;move x0 to b to shift left. 
          lsl b               ;shift bit left. 
          move b1,x0          ;restore x0. 
rdtest120 nop 
rdtest12  move #scrpad+$0,r2  ;load error pointer. 
          move #$1,x0         ;load error test. 
          move p:(r2),a       ;get error flag. 
          cmpm x0,a           ;did an error occur. 
          jeq  badhang2       ;loop on bad address. 
          jmp  pmemtst13      ;go on to test3.          
badhang2  jmp  badhang2       ;bad board address. 

;***************************************************************
;pmemtst13 is a memory test that will walk a 0 through each of 
;data bus pins as the address is simulateously incremented.
;***************************************************************

pmemtst13 move #>$13,a        ;load test number. 
          move #scrpad+$1,r2  ;load srcpad pointer. 
          move a1,a0          ;prepare a1 to store. 
          move a0,p:(r2)      ;store test number.       
          move #$400,r0       ;load pmem start pointer. 
          move #$160,r3       ;load do loop counter. 
          do   r3,wrtest13 
          move #>$fffe,x0     ;load initial bit. 
          do   #$10,wrtest130 
          move x0,a0          ;prepare x0 to store. 
          move a0,p:(r0)+     ;store a0 to memory. 
          clr  b
          move #$80,b2        ;prepare to set carry flag.
          asl  b              ;set carry flag.
          move x0,b           ;move x0 to b to shift left. 
          rol b               ;shift bit left. 
          move b1,x0          ;restore x0. 
wrtest130 nop 
wrtest13  move #$400,r0       ;load pmem start pointer. 
          do   r3,rdtest13 
          move #>$fffe,x0          ;load initial bit. 
          do   #$10,rdtest130 
          clr  a 
          move p:(r0)+,a      ;get read word. 
          cmp  x0,a 
          jsne error 
          clr  b
          move #$80,b2        ;prepare to set carry flag.
          asl  b              ;set carry flag.
          move x0,b           ;move x0 to b to shift left. 
          rol b               ;shift bit left. 
          move b1,x0          ;restore x0. 
rdtest130 nop 
rdtest13  move #scrpad+$0,r2  ;load error pointer. 
          move #$1,x0         ;load error test. 
          move p:(r2),a       ;get error flag. 
          cmpm x0,a           ;did an error occur. 
          jeq  badhang3       ;loop on bad address. 
          jmp  xmemtst21      ;go on to x data memory.       
badhang3  jmp  badhang3       ;bad board address. 
 
;***************************************************************
;xmemtst21 is an address memory test in which a 0 is placed in 
;address 0 of RAM and a 1 in 1 and so forth through (8k-this  
;.lod file = approximately 7k) of program memory and the full 8k
;of X data memory.  Since the default mode is mode2, the first 2k
;of internal RAM, both P & X, are internal.    
;***************************************************************

xmemtst21 jsr  initmem 
          jsr  initbcr 
          move #errpad,r1     ;load initial error pointer. 
          move #errpad+$f,y0  ;load errpad maximum +1 into y0. 
          move #>$21,a        ;load test number. 
          move #scrpad+$1,r2  ;load scrpad pointer. 
          move a1,a0          ;prepare a1 to store. 
          move a0,p:(r2)      ;store test number.       
          move #0,x0          ;clear x0. 
          move #$0,r0         ;load xmem start pointer. 
          move #$2000,r3      ;load do loop counter. 
          do r3,wrtest21 
          move #>$1,a         ;load a 1 adder. 
          move x0,a0          ;prepare x0 to store. 
          move a0,x:(r0)+     ;store a0 to memory. 
          move #>$1,a         ;load a 1 adder. 
          add  x0,a           ;add a 1 to x0. 
          move a1,x0          ;restore x0. 
wrtest21  move #0,x0          ;clear x0. 
          move #$0,r0         ;reload xmem start pointer. 
          do r3,rdtest21 
          move x:(r0)+,a      ;get memory value. 
          cmpm x0,a           ;compare read with write. 
          jsne error          ;go post error. 
          move #>$1,a         ;load a 1 adder. 
          add x0,a            ;add a 1 to x0. 
          move a1,x0          ;restore x0. 
rdtest21  move #scrpad+$0,r2  ;load error pointer. 
          move #$1,x0         ;load error test. 
          move p:(r2),a       ;get error flag. 
          cmpm x0,a           ;did an error occur. 
          jeq  badhang4       ;loop on bad address. 
          jmp  xmemtst22      ;go on to test2.          
badhang4  jmp  badhang4       ;bad board address. 
 
;***************************************************************
;xmemtst2 is a memory test that will walk a 1 through each of 
;data bus pins as the address is simulateously incremented.
;***************************************************************

xmemtst22 move #>$22,a        ;load test number. 
          move #scrpad+$1,r2  ;load srcpad pointer. 
          move a1,a0          ;prepare a1 to store. 
          move a0,p:(r2)      ;store test number.       
          move #$0,r0         ;load xmem start pointer. 
          move #$200,r3       ;load do loop counter. 
          do   r3,wrtest22
          move #>$1,x0        ;load initial bit. 
          do   #$10,wrtest220 
          move x0,a0          ;prepare x0 to store. 
          move a0,x:(r0)+     ;store a0 to memory. 
          move x0,b           ;move x0 to b to shift left. 
          lsl b               ;shift bit left. 
          move b1,x0          ;restore x0. 
wrtest220 nop 
wrtest22  move #$0,r0         ;load xmem start pointer. 
          do   r3,rdtest22 
          move #>$1,x0        ;load initial bit. 
          do   #$10,rdtest220 
          clr  a 
          move x:(r0)+,a      ;get read word. 
          cmp  x0,a 
          jsne error 
          move x0,b           ;move x0 to b to shift left. 
          lsl b               ;shift bit left. 
          move b1,x0          ;restore x0. 
rdtest220 nop 
rdtest22  move #scrpad+$0,r2  ;load error pointer. 
          move #$1,x0         ;load error test. 
          move p:(r2),a       ;get error flag. 
          cmpm x0,a           ;did an error occur. 
          jeq  badhang5       ;loop on bad address. 
          jmp  xmemtst23      ;go on to test3.          
badhang5  jmp  badhang5       ;bad board address. 

;***************************************************************
;xmemtst23 is a memory test that will walk a 0 through each of 
;data bus pins as the address is simulateously incremented.
;***************************************************************

xmemtst23 move #>$23,a        ;load test number. 
          move #scrpad+$1,r2  ;load srcpad pointer. 
          move a1,a0          ;prepare a1 to store. 
          move a0,p:(r2)      ;store test number.       
          move #$0,r0         ;load xmem start pointer. 
          move #$200,r3       ;load do loop counter. 
          do   r3,wrtest23
          move #>$fffe,x0     ;load initial bit. 
          do   #$10,wrtest230 
          move x0,a0          ;prepare x0 to store. 
          move a0,x:(r0)+     ;store a0 to memory. 
          clr  b
          move #$80,b2        ;prepare to set carry flag.
          asl  b              ;set carry flag.
          move x0,b           ;move x0 to b to shift left. 
          rol b               ;shift bit left. 
          move b1,x0          ;restore x0. 
wrtest230 nop 
wrtest23  move #$0,r0         ;load xmem start pointer. 
          do   r3,rdtest23 
          move #>$fffe,x0          ;load initial bit. 
          do   #$10,rdtest230 
          clr  a 
          move x:(r0)+,a      ;get read word. 
          cmp  x0,a 
          jsne error 
          clr  b
          move #$80,b2        ;prepare to set carry flag.
          asl  b              ;set carry flag.
          move x0,b           ;move x0 to b to shift left. 
          rol b               ;shift bit left. 
          move b1,x0          ;restore x0. 
rdtest230 nop 
rdtest23  move #scrpad+$0,r2  ;load error pointer. 
          move #$1,x0         ;load error test. 
          move p:(r2),a       ;get error flag. 
          cmpm x0,a           ;did an error occur. 
          jeq  badhang6       ;loop on bad address. 
          jmp  porttst31      ;go on to test the ports.      
badhang6  jmp  badhang6       ;bad board address. 
 
;****************************************************************
;this is the entry point for portb & portc test.
;****************************************************************
          
porttst31 jsr  initmem 
          jsr  initbcr 
          move #errpad,r1     ;load initial error pointer. 
          move #errpad+$f,y0  ;load errpad maximum +1 into y0. 
          move #>$31,a        ;load test number. 
          move #scrpad+$1,r2  ;load scrpad pointer. 
          move a1,a0          ;prepare a1 to store. 
          move a0,p:(r2)      ;store test number.       
          move #$55aa,r0      ;load dummy port address for error.
          move #$ffff,x0      ;set all of x0.
          move x0,x:pbd       ;store all ones in pbd.
          move x0,x:pcd       ;store all ones in pcd.
          move #$0fff,x0      ;load direction for pbd.
          move x0,x:pbddr     ;store direction in pbddr.
          move #>$1,x0        ;load initial one in lsb.
          do   #$c,endloop31
          move x0,x:pbd       ;store x0 in pbd.
          move x:pcd,a        ;get read data from pcd.
          cmpm x0,a           ;compare read with write.
          jsne error          ;go post the error.
          move x0,b           ;get x0 to shift left.
          lsl b               ;shift 1 bit to left.
          move b1,x0          ;restore x0.
endloop31 move #>$32,a        ;load test number. 
          move #scrpad+$1,r2  ;load scrpad pointer. 
          move a1,a0          ;prepare a1 to store. 
          move a0,p:(r2)      ;store test number.       
          move #$55aa,r0      ;load dummy port address for error.
          move #$1,x0         ;load initial read value.
          move #$7000,y1      ;load mask for bits 12,13,14.
          do   #$3,endloop32  
          move x0,x:pbd       ;store x0 in pbd.
          move x:pbd,a        ;get read data from pbd.
          and  y1,a           ;mask off desired bits via y1.
          rep  #$c
          lsr  a              ;move bit 12 places to right
          cmpm x0,a           ;compare read with write.
          jsne error          ;go post error.
          move x0,b           ;get x0 to shift left.
          lsl  b              ;shift bit left.
          move b1,x0          ;restore x0.
endloop32 move #scrpad+$0,r2  ;load error pointer.
          move #$1,x0         ;load error test.
          move p:(r2),a       ;get error flag.
          cmpm x0,a           ;did an error occur.
          jeq  badhang7       ;loop on bad address.
          jmp  porttst33      ;good board address.          
badhang7  jmp  badhang7       ;bad board address.

porttst33 move #>$33,a        ;load test number. 
          move #>$fff,y1      ;load new mask.
          move #scrpad+$1,r2  ;load scrpad pointer. 
          move a1,a0          ;prepare a1 to store. 
          move a0,p:(r2)      ;store test number.       
          move #$55aa,r0      ;load dummy port address for error.
          move #$ffff,x0      ;set all of x0.
          move x0,x:pbd       ;store all ones in pbd.
          move x0,x:pcd       ;store all ones in pcd.
          move #$0fff,x0      ;load direction for pbd.
          move x0,x:pbddr     ;store direction in pbddr.
          move #>$ffe,x0      ;load initial one in lsb.
          do   #$c,endloop33
          move x0,x:pbd       ;store x0 in pbd.
          move x:pcd,a        ;get read data from pcd.
          cmpm x0,a           ;compare read with write.
          jsne error          ;go post the error.
          clr  b
          move #$80,b2        ;prepare to set carry flag.
          asl  b              ;set carry flag.
          move x0,b           ;move x0 to b to shift left. 
          rol  b              ;shift bit left. 
          and  y1,b           ;mask b.
          move b1,x0          ;restore x0. 
endloop33 move #>$34,a        ;load test number. 
          move #scrpad+$1,r2  ;load scrpad pointer. 
          move a1,a0          ;prepare a1 to store. 
          move a0,p:(r2)      ;store test number.       
          move #$55aa,r0      ;load dummy port address for error.
          move #>$6,x0        ;load initial read value.
          do   #$3,endloop34  
          move #$7000,y1      ;load mask for bits 12,13,14.
          move x0,x:pbd       ;store x0 in pbd.
          move x:pbd,a        ;get read data from pbd.
          and  y1,a           ;mask unwanted bits.
          rep  #$c
          lsr  a              ;move bit 12 places to right
          cmpm x0,a           ;compare read with write.
          jsne error          ;go post error.
          clr  b
          move #$80,b2        ;prepare to set carry flag.
          asl  b              ;set carry flag.
          move x0,b           ;move x0 to b to shift left. 
          rol  b              ;shift bit left. 
          move #>$7,y1        ;load new mask.
          and  y1,b           ;mask off unwanted bits.
          move b1,x0          ;restore x0.
endloop34 move #$ffff,x0      ;load default data for ports.
          move x0,x:pbd       ;store default data in pbd.
          move x0,x:pcd       ;store default data in pcd.
          move #0,x0          ;load default direction.
          move x0,x:pbd       ;store default dir. in pbd.
          move x0,x:pcd       ;store default dir. in pcd.
          move #scrpad+$0,r2  ;load error pointer.
          move #$1,x0         ;load error test.
          move p:(r2),a       ;get error flag.
          cmpm x0,a           ;did an error occur.
          jeq  badhang8       ;loop on bad address.
goodhang  jmp  goodhang       ;good board address.          
badhang8  jmp  badhang8       ;bad board address.

error     move #scrpad+$2,r2  ;load scratchpad pointer.
          move a1,a0          ;prepare a1 to store.
          move a0,p:(r2)      ;save a1.
          move #scrpad+$0,r2  ;load scratchpad pointer.
          move #>$1,a0        ;load error flag.
          move a0,p:(r2)      ;set error flag.
          move r1,a           ;prepare r1 to compare.
          cmpm y0,a           ;compare r1 with errpad maximum.
          jeq over0           ;jump over if no available space.
          move #scrpad+$2,r2  ;load scratchpad pointer.
          move (r0)-          ;decrement r0 to real error.
          move r0,a0          ;prepare r0 to store.
          lea (r0)+,r0        ;return r0 to original value.
          move a0,p:(r1)+     ;store error address.
          move x0,p:(r1)+     ;store written value.
          move p:(r2),a       ;restore a1.
          move a1,a0          ;prepare a1 to store.
          move a0,p:(r1)+     ;store read value.
over0     rts

;***************************************************************
;this is the entry point for setting the bcr.
;***************************************************************

initbcr   move #$2,x0         ;load wait state value.
          move x0,x:bcr       ;move to 0 wait states for x data 
                              ;memory and 2 wait states for
                              ;external program memory  using 45
                              ;or 55 ns eproms at 40 Mhz
                              ;operation from internal pram.
          rts

;***************************************************************
;this is the entry point to initialize the scratch pad and error
;pad memory area for the functional tests.
;***************************************************************

initmem   move #$0,x0         ;clear x0
          move #scrpad,r2     ;load scrpad pointer.
          do #$20,endinit
          move x0,p:(r2)+     ;clear memory.
endinit   rts
