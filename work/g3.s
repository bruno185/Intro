* ROM routines
        lst off
*
home    equ  $FC58
text    equ  $FB2F
col80off equ $C00C
cout    equ  $FDED
vtab    equ  $FC22
getln   equ  $FD6A
bascalc equ  $FBC1
cr      equ  $FD8E      ; print carriage return 
clreop  equ  $FC42      ; clear from cursor to end of page
clreol  equ  $FC9C      ; clear from cursor to end of line
xtohex  equ  $F944
rdkey   equ  $FD0C      ; wait for keypress
auxmov  equ  $C311      
xfer    equ  $C314

* ROM switches
*
graphics equ $C050
mixoff   equ $C052
hires    equ $C057
page1    equ $C054
page2    equ $C055
clr80col equ $C000 
vbl      equ $C019     
*
*
ptr      equ   $06

        org   $6000
* HGR
        lda #21         ; go 40 col. 
        jsr cout
        jsr dohilo2     ; populate hgr2 line address
        jsr clear1       ; fill hgr page1 with color1
        jsr clear2      ; fill hgr page2 with color2
        jsr dovbl 
        lda page1
        lda mixoff      ; no text
        lda graphics    ; graphic mode
        lda hires       ; hgr   
*

main    inc counter     ; go for 255 cycles
        lda counter
        beq out
        lda tempo
        eor #$01
        sta tempo
        bne p2 
        jsr dovbl       ; display page 1        
        lda page1   
        inc color2        
        jsr clear2      ; while loading page 2
        jmp main
*
p2      jsr dovbl       ; display page 2
        lda page2
        inc color1
        jsr clear1       ; while loading page 2
        jmp main
*
out     jsr text
        jsr home
        rts   
*
* VBL : wait for vertical retrace
*
dovbl   nop
        pha
loopvbl lda vbl
        bmi loopvbl
        pla 
        rts

*
* clear screen page 1 with color1
*
clear1  ldx #$00
c2      lda lo,x
        sta ptr
        lda hi,x
        sta ptr+1
        ldy #$27
        lda color1
c1      sta (ptr),y
        dey
        bpl c1
        inx
        cpx #$C0       ; 192 ligne
        bne c2
        rts
*
* clear screen page 2 with color2
*
clear2  ldx #$00
c22     lda lo2,x
        sta ptr
        lda hi2,x
        sta ptr+1
        ldy #$27
        lda color2
c21     sta (ptr),y
        dey
        bpl c21
        inx
        cpx #$C0       ; 192 ligne
        bne c22
        rts

dohilo2 nop
        ldx #$00        
loophl2 lda lo,x
        sta lo2,x
        lda hi,x 
        clc 
        adc #$20
        sta hi2,x 
        inx
        cpx #$C0        ; 192 lines
        bne loophl2
        
        rts


color1  hex FF
color2  hex AA
tempo   hex 00
counter hex 00
*
hi      hex 2024282C3034383C
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
lo      hex 0000000000000000
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
hi2     ds    192,0
lo2     ds    192,0

fastclr nop   
        ldx #$00
fc22    lda #color2
fc21    sta $4000,x
        inx   
        bne fc21
        inc fc21+2
        lda fc21+2
        cmp #$60
        bne fc22
        lda #40
        sta fc21+2
        rts
