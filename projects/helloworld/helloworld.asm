;----------------------------------------------------
; Project: helloworld.zdsp
; Main File: helloworld.asm
; Date: 11/9/2025
; Author: Connor Cieslinski
;
; Created with zDevStudio - Z80 Development Studio.
;
;----------------------------------------------------




reset           EQU 0000h               ; 3 byte reset vector
vectable        EQU 0100h               ; 256 entry interrupt vector table
constants       EQU 0200h               ; 512 byte constant space
program         EQU 0400h               ; program space from 0400h - 1000h
reserved        EQU 1000h               ; 512 bytes of reserved memory
open            EQU 1200h               ; everything else is free game


; these are in the reserved space

port_A          EQU 1000h               ; PIO port A
port_B          EQU 1001h               ; PIO port B
buf_hptr        EQU 1002h               ; Keyboard Input Buffer Pointer Head
buf_tptr        EQU 1003h               ; Keyboard Input Ring Buffer tail
keybuf          EQU 1004h               ; The actual Keyboard Input Buffer: 64 bytes
termbuf         EQU 1044h               ; The terminal input line buffer: 64 bytes, accepts input from keyboard buffer until an enter is received. Afterwards, the input is procesed

endres          EQU 1084h



; This is where we actually build the vector table
ORG vectable + 4
DW myfirstISR

ORG vectable + 6
DW keyboardISR



; 061h-066h:    a-f
; 030h-039h:    0-9
; 03Ah:         (colon)
; 008h:         (backspace)
; 00Ah:         (line feed)
; 00Dh;         (carriage return)


ORG reset
        JP init

ORG program

include "PIO.asm"
include "ISR.asm"
include "mem.asm"
include "inp.asm"

init
        ; set interrupt mode to 2 (vector table)
        IM 2

        ; Enable interrupts
        EI

        ; Specify the location of the vector table
        LD A, HIGH(vectable)
        LD I, A

       

        LD A, #00
        LD B, #00
        
                                ; A simple loop that tests the input buffer (by overflowing it slightly)
mainloop
        CALL pushinpbuf
        INC A
        INC B
        CP 70
        JR Z, endmainloop
        JR mainloop
endmainloop
        
        
idle
        JR idle










ORG constants


message
        DB "HELLO WORLD", 0
message1
        DB "Goodbye World", 0
validhex
        DB "0123456789ABCDEF"
asciihex
        DB 0x30, 0x31, 0x32, 0x33, 0x34, 0x35 ,0x36, 0x37, 0x38, 0x39, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46
        END
