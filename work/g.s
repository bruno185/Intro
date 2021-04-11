* ROM routines
home      equ $FC58
text      equ $FB2F
col80off  equ $C00C
cout      equ $FDED
vtab      equ $FC22
getln     equ $FD6A
bascalc   equ $FBC1
cr        equ $FD8E     ; print carriage return 
clreop    equ $FC42     ; clear from cursor to end of page
clreol    equ $FC9C     ; clear from cursor to end of line
xtohex    equ $F944
rdkey     equ $FD0C     ; wait for keypress
auxmov    equ $C311 
xfer      equ $C314

* ROM switches
*
graphics equ $C050
mixoff   equ $C052
hires    equ $C057
page1    equ $C054
page2    equ $C055
clr80col equ $C000 
*
ptr      equ $06
color    equ $ff
color2   equ %01101100

        org $6000
* HGR
        lda mixoff
        sta clr80col
        lda page2
        lda graphics
        lda hires
        
*
bigloop nop
        jsr clear2              ; blanc
        jsr rdkey
        jsr clear               ; rayures
        lda page1
        jsr rdkey
eorloop lda tempo
        eor #$01
        sta tempo
        bne p2 
        ldx page1
        jsr rdkey
        jmp eorloop
p2      lda page2
        jsr rdkey
        jmp eorloop

        rts 

*
* clear screen
*
clear   ldx #$00
c2      lda lo,x
        sta ptr
        lda hi,x
        sta ptr+1
        ldy #$27
        lda #color2
c1      sta (ptr),y
        dey
        bpl c1
        inx
        cpx #$C0        ; 192 ligne
        bne c2
        rts

clear2  nop 
        ldx #$00
cl22    lda #color
cl21    sta $4000,x
        inx 
        bne cl21
        inc cl21+2
        lda cl21+2
        cmp #$60
        bne cl22
        lda #40
        sta cl21+2
        rts


tempo   hex 00
*
hi          hex 2024282C3034383C
            hex 2024282C3034383C
            hex 2125292D3135393D
            hex 2125292D3135393D
            hex 22262A2E32363A3E
            hex 22262A2E32363A3E
            hex 23272B2F33373B3F
            hex 23272B2F33373B3F
            hex 2024282C3034383C
            hex 2024282C3034383C
            hex 2125292D3135393D
            hex 2125292D3135393D
            hex 22262A2E32363A3E
            hex 22262A2E32363A3E
            hex 23272B2F33373B3F
            hex 23272B2F33373B3F
            hex 2024282C3034383C
            hex 2024282C3034383C
            hex 2125292D3135393D
            hex 2125292D3135393D
            hex 22262A2E32363A3E
            hex 22262A2E32363A3E
            hex 23272B2F33373B3F
            hex 23272B2F33373B3F
lo          hex 0000000000000000
            hex 8080808080808080
            hex 0000000000000000
            hex 8080808080808080
            hex 0000000000000000
            hex 8080808080808080
            hex 0000000000000000
            hex 8080808080808080
            hex 2828282828282828
            hex A8A8A8A8A8A8A8A8
            hex 2828282828282828
            hex A8A8A8A8A8A8A8A8
            hex 2828282828282828
            hex A8A8A8A8A8A8A8A8
            hex 2828282828282828
            hex A8A8A8A8A8A8A8A8
            hex 5050505050505050
            hex D0D0D0D0D0D0D0D0
            hex 5050505050505050
            hex D0D0D0D0D0D0D0D0
            hex 5050505050505050
            hex D0D0D0D0D0D0D0D0
            hex 5050505050505050
            hex D0D0D0D0D0D0D0D0
*
hi2     ds 300,0
lo2     ds 300,0

