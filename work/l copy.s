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
ptr     equ $06
ptr2    equ $08
* 
* CONST
framemax equ $09 
posx    equ $13
posy    equ $60
*
        org   $8000
        lda #17         ; 40 col. 
        jsr cout
*
        lda page1
        lda mixoff      ; no text
        lda graphics    ; graphic mode
        lda hires       ; hgr 

mainlp  nop
        jsr setvars
        bcs out
        jsr doframe
        inc framenb
        jmp mainlp
out     rts

setvars lda framenb
        asl
        asl
        sta curpos
        tax
        lda anim,x
        cmp #$FF
        bne notfinished
        sec 
        rts 
notfinished sta xstart
        inx 
        lda anim,x
        sta xend
        inx
        lda anim,x
        sta ystart
        inx
        lda anim,x
        sta yend
        clc
        rts
*
*
doframe ldx ystart      
loop21  lda hi,x        ; set destination line pointer (ptr), $2000
        sta ptr+1
        clc
        adc #$40
        sta ptr2+1      ; set source line pointer (ptr2), $6000
        lda lo,x 
        sta ptr
        sta ptr2
        ldy xstart
        sty tempy1
        ldy xend
        sty tempy2
loop11  ldy tempy2
        lda (ptr2),y
        ldy tempy1
        sta (ptr),y
        inc tempy1
        inc tempy2
        lda tempy1
        cmp xend
        bne loop11
        inx 
        cpx yend
        bne loop21
        rts

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
tempy1  hex 00
tempy2  hex 00

curpos  hex 00
framenb hex 00

xstart  hex 00
xend    hex 00
ystart  hex 00
yend    hex 00

dxstart hex 00
dxend   hex 00
dystart hex 00
dyend   hex 00

anim    hex 000D00400D1A0040    ; 2 frames
        hex 1A280040            ; +1 frame : 3 frames on same row
        hex 000D40800D1A4080    ; 2 frames
        hex 1A284080            ; +1 frame : 3 frames on same row
        hex 000D80C00D1A80C0    ; 2 frames
        hex 1A2880C0            ; +1 frame : 3 frames on same row
        hex FF                  ; marker for end.
*
hi2     ds    192,0
lo2     ds    192,0

