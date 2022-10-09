Joypad                = $10
PlayerX               = $11
PlayerY               = $12

Sprite_Y_Position     = $0200
Sprite_Tilenumber     = $0201
Sprite_Attributes     = $0202
Sprite_X_Position     = $0203

PPUCTRL               = $2000
PPUMASK               = $2001
PPUSTATUS             = $2002
PPUSCROLL             = $2005
PPUADDR               = $2006
PPUDATA               = $2007
OAM_DMA               = $4014
JOYPAD_PORT           = $4016
SNDMODE               = $4017

MMC5_PRGMode          = $5100
MMC5_CHRMode          = $5101
MMC5_RAMProtect1      = $5102
MMC5_RAMProtect2      = $5103
MMC5_ExRamMode        = $5104
MMC5_Nametables       = $5105
MMC5_FillTile         = $5106
MMC5_CHRBank          = $5120
MMC5_PRGBank          = $5113
MMC5_VSplitMode       = $5200
MMC5_VSplitScroll     = $5201
MMC5_VSplitBank       = $5202
MMC5_SLCompare        = $5203
MMC5_SLIRQ            = $5204

; this is a macro to write data to the ppu
.macro WriteDataToPPU PPU, Start, Len
    ; update the ppu location
    lda #>PPU
    sta PPUADDR
    lda #<PPU
    sta PPUADDR
    ; and write 'Len' bytes to ppu, starting at the memory location in 'Start'
    ldx #0
:   lda Start,x
    sta PPUDATA
    inx
    cpx #Len
    bne :-
.endmacro
