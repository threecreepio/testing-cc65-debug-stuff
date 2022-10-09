.export MovePlayer
MovePlayer:
    lda Joypad
    and #%11
    tay
    clc
    lda Movement,y
    adc PlayerX
    sta PlayerX
    lda Joypad
    lsr a
    lsr a
    and #%11
    tax
    clc
    lda Movement,x
    adc PlayerY
    sta PlayerY
    DEBUG_TRACE "Movement"
    rts

Movement: .byte $00,$01,$FF,$00

NMIHandler: rti
BankingCode ALTBank
