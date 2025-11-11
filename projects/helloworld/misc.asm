
; Name:                 signal
; Function:             make it really obvious that something happened
; Inputs:               none
; Outputs:              well it fucks all of the registers so...
signal
    LD A, #FF
    LD B, #FF
    LD C, #FF
    LD D, #FF
    LD E, #FF
    RET


; Name:                 signal_safe
; Function:             make it somewhat obvious that something happened
; Inputs:               none
; Outputs:              none, but writes to Port B
signal_safe
    LD B, #FF
    CALL writepb
    RET