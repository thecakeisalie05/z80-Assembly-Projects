; Name:                 writepa
; Function:             writes a value to port A
; Inputs:               Reg B
; Outputs:              none
writepa
        LD HL, port_A
        LD (HL), B
        RET

; Name:                 writepb
; Function:             writes a value to port B
; Inputs:               Reg B
; Outputs:              none
writepb
        LD HL, port_B
        LD (HL), B
        RET


; Name:                 readpa
; Function:             reads the value from port A
; Inputs:               none
; Outputs:              Reg A
readpa
        LD HL, port_A
        LD A, (HL)
        RET


; Name:                 readpb
; Function:             reads the value from port B
; Inputs:               none
; Outputs:              Reg A
readpb
        LD HL, port_B
        LD A, (HL)
        RET