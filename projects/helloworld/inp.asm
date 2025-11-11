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
        LD HL, #0
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





