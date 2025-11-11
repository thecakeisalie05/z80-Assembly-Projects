; String copy routine, written by ChatGPT

; Name:                 strcpy
; Function:             copy a string from HL to DE
; Inputs:               Reg HL (source), Reg DE (destination)
; Outputs:              none
strcpy
        PUSH AF
strcpy_loop
        LD A, (HL)
        CP 0
        JR Z, done_copy
        LD (DE), A
        INC HL
        INC DE
        JR strcpy_loop
done_copy
        POP AF
        RET


; Name:                 getstrsize
; Function:             measure the size of the string pointed to by HL
; Inputs:               Reg HL (pointer to string)
; Outputs:              Reg A (length)
getstrsize
        PUSH BC
        LD BC, #0
strszloop
        LD A, (HL)
        INC B
        CP 0
        JR Z, done_size
        INC HL
        JR strszloop
done_size
        LD A, B
        POP BC
        RET
