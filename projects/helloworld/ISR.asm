; Name:                 myfirstISR
; Function:             write F0 to port A on interrupt 04
; Inputs:               none
; Outputs:              none
; Remarks:              This is ISR 04h
myfirstISR
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL

        LD A, 00f0h
        CALL writepa

        POP HL
        POP DE
        POP BC
        POP AF
        ; for nested interrupts?
        EI
        RETI

; Name:                 keyboardISR
; Function:             take keyboard input and push it to the input buffer
; Inputs:               none
; Outputs:              none
; Remarks:              This is ISR 06h
keyboardISR
        PUSH AF
        PUSH BC
        PUSH DE
        PUSH HL

       
        ; sets B to port B input
        CALL readpb

        LD B, A

        ; Pushes B to the input buffer
        CALL pushinpbuf

        POP HL
        POP DE
        POP BC
        POP AF
        ; for nested interrupts?
        EI
        RETI


