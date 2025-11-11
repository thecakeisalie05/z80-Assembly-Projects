; Name:                 pushinpbuf
; Function:             push the value in reg B to the input buffer
; Inputs:               Reg B
; Outputs:              none
pushinpbuf
        PUSH HL
        PUSH DE
        LD D, #0                        ; (thank you copilot) get rid of undefined shit in D
        LD HL, buf_hptr                 ; Locate the head pointer
        LD E, (HL)                      ; Store the head pointer in E
        LD HL, keybuf                   ; Now actually go to the buffer
        ADD HL, DE                      ; Move to the head location
        LD (HL), B                      ; Store our value
        CALL inchead                    ; Increment the head pointer
        POP DE
        POP HL
        RET


; Name:                 pullinpbuf
; Function:             pull the next value from the input buffer
; Inputs:               none
; Outputs:              Reg A
pullinpbuf
        PUSH HL
        PUSH DE
        LD D, #0                        ; (thank you copilot) get rid of undefined shit in D
        LD HL, buf_tptr                 ; Locate the tail pointer
        LD E, (HL)                      ; Store the tail pointer in E
        LD HL, keybuf                   ; Now actually go to the buffer
        ADD HL, DE                      ; Move to the tail location
        LD A, (HL)                      ; Store our value
        CALL inctail                    ; Increment the head pointer
        POP DE
        POP HL
        RET

; Name:                 getbuflen
; Function:             gets the length of the input buffer
; Inputs:               none
; Outputs:              Reg A
getbuflen
        LD HL, buf_tptr
        LD C, (HL)
        LD HL, buf_hptr
        LD A, (HL)
        SUB C
        RET

; Name:                 getbufstatus
; Function:             gets the status of the input buffer
; Inputs:               none
; Outputs:              Reg A
getbufstatus
        CALL getbuflen
        CP 0
        JR Z, emptybuf
        JR nostatus
emptybuf
        LD A, #FF
        JR endstatus
nostatus
        LD A, #00
        JR endstatus
endstatus      
        RET

; Name:                 incringptr
; Function:             increment register B in a closed loop of 64
; Inputs:               Reg B
; Outputs:              Reg B
incringptr
        INC B
        CP 63
        JR Z, overptr
        JR doneincptr
overptr
        LD B, #0
doneincptr
        RET

; Name:                 inchead
; Function:             increment the head pointer
; Inputs:               none
; Outputs:              none
inchead
        PUSH BC
        LD HL, buf_hptr
        LD B, (HL)
        CALL incringptr
        LD (HL), B
        POP BC
        RET

; Name:                 inctail
; Function:             increment the tail pointer
; Inputs:               none
; Outputs:              none
inctail
        PUSH BC
        LD HL, buf_tptr
        LD B, (HL)
        CALL incringptr
        LD (HL), B
        POP BC
        RET




; Name:                 parsenext
; Function:             parse the next character from the input buffer
; Inputs:               none
; Outputs:              Reg A
parsenext
        CALL getbufstatus
        CP #FF
        JR Z, endparse
        CALL pullinpbuf
        CP ENTER
        JR Z, enterhandle
        JR endparse
enterhandle
        CALL signal
endparse
        RET


