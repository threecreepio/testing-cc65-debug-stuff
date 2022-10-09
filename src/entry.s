.include "defines.inc"
.include "debug.inc"

.segment "INES"
.byte "NES",26
.byte 8; prg
.byte 1; chr
.byte $50

EmptyBank0  = 0
EmptyBank1  = 4
ALTBank     = 8
StartupBank = 12

.macro jsfar bank, addr
    lda #<addr
    sta $100
    lda #>addr
    sta $101
    lda #bank
    jsr _BankJSR
.endmacro

.macro BankingCode bank
.res $FF70 - *, $FF
_BankJSR:
    sta $102
    lda #bank
    pha
    lda $102
    jsr SetPRGBank
    lda $101
    jsr @CallJSR
    pla
    jsr SetPRGBank
    rts
@CallJSR:
    jmp ($100)

VStart:
    sei
    ldx #$FF
    txs
    lda #%01000000         ; disable apu irq
    sta $4017
    lda #%10
    sta MMC5_RAMProtect1
    lda #%01
    sta MMC5_RAMProtect2
    lda #0
    sta MMC5_CHRMode       ; use 1kb chr banking
    lda #1
    sta MMC5_PRGMode       ; use 16kb prg banking
    lsr a
    sta MMC5_PRGBank
    lda #StartupBank
    jsr SetPRGBank
    lda #$44
    sta MMC5_Nametables    ; set vertical mirroring
    jmp $8000

SetPRGBank:
    clc
    ora #$80
    sta MMC5_PRGBank+2
    adc #2
    sta MMC5_PRGBank+4
    rts

VIRQ:
    sei
    php
    pha
    lda MMC5_SLIRQ ; ACK
	pla
	plp
    rti

.res $FFFA - *, $EA
.word NMIHandler
.word VStart
.word VIRQ
.endmacro

.scope PRG
setsegment "PRG"
.org $8000
.include "prg_main.s"
.endscope

.scope EMPTY0
setsegment "EMPTY0"
.org $8000
.include "prg_empty0.s"
.endscope

.scope EMPTY1
setsegment "EMPTY1"
.org $8000
.include "prg_empty1.s"
.endscope

.scope ALT
setsegment "ALT"
.org $8000
.include "prg_alt.s"
.endscope

.segment "CHR"
.incbin "../chr/charset.chr"
.incbin "../chr/charset.chr"
