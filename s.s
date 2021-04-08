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
posx    equ $02         ; position in X (in byte, not pixel)
posy    equ $14         ; position in Y (= line #)
*
        org   $8000

        lda #posx
        sta left
        clc 
        adc nbcol
        cmp #$28         ; 40 columns max.
        bge n1
        sta right
        jmp n2
n1      lda #$27
        sta right
*
n2      lda #posy
        sta top
        clc 
        adc nblig
        cmp #$C0        ; 192 lines max.
        bge n3
        sta bottom
        jmp n4
n3      lda #$BF 
        sta bottom
n4      nop
*
        lda #>cut
        sta ptr2+1
        lda #<cut
        sta ptr2
newline ldx top
        lda hi,x 
        sta ptr+1
        lda lo,x 
        sta ptr
        ldy left
load    lda cut
        sta (ptr),y 
        inc load+1
        bne ok
        inc load+2
ok      iny
        cpy right
        bne load
        inc top
        lda top
        cmp bottom
        bne newline
        rts




left    hex 00
right   hex 00
top     hex 00
bottom  hex 00
*   
nblig    hex   1c
nbcol    hex   1e
cut      hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000007001
         hex   3000180300180000
         hex   1800000078330000
         hex   604c190306306000
         hex   0000000018033000
         hex   0003001800001800
         hex   004c61300000604c
         hex   0103067070000030
         hex   060018037879191f
         hex   667c78007c78004c
         hex   61704307604c1963
         hex   0770797878310600
         hex   1803303818336618
         hex   4c01184c01006030
         hex   660c604c19330630
         hex   6f40190300007803
         hex   3018183366187c01
         hex   184c01006030660f
         hex   604c193306306678
         hex   1903000018033018
         hex   183366180c00184c
         hex   010060306600407f
         hex   18330630604c1903
         hex   000018036019181f
         hex   7c70780070780000
         hex   6030460700331863
         hex   0730607819030000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000060010000
         hex   00003c400f600300
         hex   3800000000000000
         hex   0000000000000000
         hex   0000300000000000
         hex   6640193006000c00
         hex   0000000000000000
         hex   0000000000000000
         hex   787971713f006640
         hex   193000003e3c7c00
         hex   0600000000000000
         hex   0000000000003038
         hex   1833660066400f30
         hex   00000c661c000600
         hex   0000000000000000
         hex   0000000030181833
         hex   66007e4019300000
         hex   0c660c0000000000
         hex   0000000000000000
         hex   0000301818336600
         hex   664c193366000c66
         hex   0c00060000000000
         hex   0000000000000000
         hex   301870316600664c
         hex   0f6363000c3c0c00
         hex   0600000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000030000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000003000007063
         hex   0c0300001800003e
         hex   6000000000180000
         hex   0000000000006000
         hex   1833000030060003
         hex   0000180000633000
         hex   0000001800004c01
         hex   0000000060001833
         hex   60033046470f0f00
         hex   1f33000378186363
         hex   0c1f1e3e4c017878
         hex   7161630c00300006
         hex   70630c4319401933
         hex   00734c1903664c19
         hex   306600004c390033
         hex   6606003060073066
         hex   0f431f4019330063
         hex   7c1963674c193e66
         hex   00000c1870336007
         hex   0030300630660043
         hex   0140193300630c70
         hex   31664c1933660000
         hex   4c191833660c0070
         hex   63077043070e0f00
         hex   1f3e003e78606047
         hex   0f1f3e6600007818
         hex   7063630c00000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000

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

