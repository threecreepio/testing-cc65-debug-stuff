.import MovePlayer

StartupHandler:
    sei
:   bit PPUSTATUS         ; delay
    bpl :-
    ldy #0
    lda #0
:   sta $000,y            ; clear memory
    sta $200,y
    sta $300,y
    sta $400,y
    sta $500,y
    sta $600,y
    sta $700,y
    iny
    bne :-
:   bit PPUSTATUS          ; delay
    bpl :-
    lda #%01000000         ; disable apu irq
    sta SNDMODE

    lda #$30
    sta PlayerX
    sta PlayerY

    ldx #$FF               ; clear stack
    txs

    jsr ClearPPU           ; clear ppu
    WriteDataToPPU $3F00, MenuPalette, MenuPaletteEnd - MenuPalette ; write palette
    WriteDataToPPU $2040, HelloThere, HelloThereEnd - HelloThere ; write friendly greeting
    jsr MoveSpritesOffscreen

    lda #%00011110  ; ppu setup
    sta PPUMASK
    lda #%10001000
    sta PPUCTRL
:   jmp :-

NMIHandler:
    lda #2
    sta OAM_DMA
    jsr ReadJoypad
    beq :+
    jsfar ALTBank, MovePlayer
:   lda PlayerY
    sta Sprite_Y_Position
    lda PlayerX
    sta Sprite_X_Position
    lda #2
    sta Sprite_Tilenumber
    sta Sprite_Attributes
    lda #0
    sta PPUSCROLL
    sta PPUSCROLL
    cli
    rti

MoveSpritesOffscreen:
    ldy #$00
    lda #$f8
:   sta Sprite_Y_Position,y
    iny
    iny
    iny
    iny
    bne :-
    rts

ClearPPU:
    lda #$20         ; empty out the first ppu nametable
    sta PPUADDR
    lda #$00
    sta PPUADDR
    lda #$0
    ldx #$0
    ldy #$0
:   sta PPUDATA
    iny
    bne :-
    inx
    cpx #$4
    bne :-
    rts

ReadJoypad:
    lda #$01
    sta JOYPAD_PORT
    sta Joypad
    lsr a
    sta JOYPAD_PORT
@KeepReading:
    lda JOYPAD_PORT
    lsr a
    rol Joypad
    bcc @KeepReading
    rts

MenuPalette:
.byte $0F, $3B, $10, $00
.byte $0F, $30, $10, $00
.byte $0F, $27, $10, $00
.byte $0F, $30, $10, $00
.byte $0F, $3B, $10, $00
.byte $0F, $30, $10, $00
.byte $0F, $27, $10, $00
.byte $0F, $30, $10, $00
MenuPaletteEnd:

HelloThere:
.byte "WALK AROUND..."
HelloThereEnd:

BankingCode StartupBank
