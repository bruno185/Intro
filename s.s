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
wait    equ $FCA8

* ROM switches
*
graphics equ $C050
mixoff   equ $C052
hires    equ $C057
page1    equ $C054
page2    equ $C055
clr80col equ $C000 
vbl      equ $C019    
spkr     equ $C030 
*
ptr     equ $06
ptr2    equ $08
* 
* CONST
framemax equ $09 
posx    equ $05         ; position in X (in byte, not pixel)
posy    equ $3F         ; position in Y (= line #)
posx2   equ $0F 
posy2   equ $64
delay   equ $01  
*
        org   $8000

* * * * * * * * *
*     MACROS    *
* * * * * * * * *
*
        DO 0
m_inc   MAC         ; inc 16  bits integer
        inc ]1        ; usually a pointer
        bne m_incf
        inc ]1+1
m_incf  EOM

* Add a 1 byte value to a 2 bytes value
* result stored in 2 bytes value memory address
addval  MAC     
        lda ]1 
        clc
        adc ]2
        sta ]1
        lda ]1+1
        adc #$00
        sta ]1+1
        EOM

donote  MAC
        lda ]1
        sta pitch
        lda ]2
        sta lengthhi
        lda ]2+1
        sta lengthlo
        jsr sound
        EOM

* init. variables 
* params : posx, posy, nbcol, nblig, left, right, top bottom
setvar  MAC
        lda ]1          ; posx      
        sta ]5          ; left
        clc 
        adc ]3          ; nbcol
        cmp #$28        ; 40 columns max.
        bge n1
        sta ]6          ; right
        jmp n2
n1      lda #$27
        sta ]6          ; right
n2      lda ]2          ; posy
        sta ]7          ; top
        clc 
        adc ]4          ; nblig
        cmp #$C0        ; 192 lines max.
        bge n3
        sta ]8          ; bottom
        jmp n4
n3      lda #$BF 
        sta ]8          ; bottom
n4      nop
        EOM
        FIN

* display a bitmap
* params : data pointer, top, left, right, bottom
bitmap  MAC
        lda #>]1   ; (re)init shape pointer
        sta load2+2
        lda #<]1
        sta load2+1
newln2  ldx ]2         ; outter loop starts here, top
        lda hi,x        ; from top to botton
        sta ptr+1
        lda lo,x 
        sta ptr
        ldy ]3          ; left
load2   lda ]1       ; inner loop starts here
        sta (ptr),y     ; from left to right
        inc load2+1      ; update shape pointer
        bne ok2
        inc load2+2
ok2     iny             ; next byte un row
        cpy ]4       ; end of line ? (right)
        bne load2
        inc ]2          ; top+1
        lda ]2
        cmp ]5      ; last line ? (bottom)
        beq endshap2
        jmp newln2
endshap2 EOM

* BEGIN
* setup vars for limits in HGR screen
        setvar #posx;#posy;nbcol;nblig;left;right;top;bottom
* save tune pointers
        lda play+1 
        sta saveptr
        lda play+2
        sta saveptr+1
*
        lda play2+1
        sta saveptr+2
        lda play2+2
        sta saveptr+3
*
        lda play3+1
        sta saveptr+4
        lda play3+2
        sta saveptr+5
*
* paint shape 1
*
        lda #>cut       ; (re)init shape pointer
        sta load+2
        lda #<cut
        sta load+1
newline ldx top         ; outter loop starts here
        lda hi,x        ; from top to botton
        sta ptr+1
        lda lo,x 
        sta ptr
        ldy left
load    lda cut         ; inner loop starts here
        sta (ptr),y     ; from left to right
        inc load+1      ; update shape pointer
        bne ok
        inc load+2
ok      iny             ; next byte un row
        cpy right       ; end of line ?
        bne load
*
        lda top         ; play evrery 4 lines
        and #03
        bne noplay
        jsr play
*
noplay  inc top
        lda top
        cmp bottom      ; last line ?
        beq endtune
        jmp newline
*
endtune 
        lda play+1      ; get value 
        sta ptr2        ; pointed by play+1
        lda play+2      ; to check tune has finished
        sta ptr2+1
        ldy #$00
        lda (ptr2),y    
        beq endprog     ; 0 = flag for end of tune
        jsr play        ; else play
        jmp endtune
* restore tune pointers
* in self modified code 
endprog lda saveptr  
        sta play+1
        lda saveptr+1  
        sta play+2
*
        lda saveptr+2  
        sta play2+1
        lda saveptr+3  
        sta play3+2
*
        lda saveptr+4  
        sta play3+1
        lda saveptr+5  
        sta play3+2

        setvar #posx2;#posy2;nbcol2;nblig2;left;right;top;bottom
        bitmap hitk;top;left;right;bottom
        rts             ; end of program
*
*
*
play    lda tune        ; self modified address
        beq playend
        sta pitch       ; set pitch
play2   lda tune+1      ; self modified address
        sta lengthhi    ; set duration (lo byte)
play3   lda tune+2      ; self modified address
        sta lengthlo    ; set duration (hi byte)
* self modification
        addval play+1;#$03      ; adjust pointer to tune 
        addval play2+1;#$03     ; for next note
        addval play3+1;#$03
*
        jsr sound       ; play a note
playend rts

saveptr ds 6,0
*
tune    hex 5203A4      ; note20
        hex 52020B      ; note20
        hex 4E03DB      ; note21
        hex 4E020B      ; note21
        hex 490416      ; note22
        hex 49020B      ; note22
        hex 4E03DB      ; note21
        hex 4E020B      ; note21              
        hex 5203A4      ; note20
*        hex 52020B      ; note20
        hex 00
        
* play a note  
* with diration lo/hi and pitch variables      
sound   ldy lengthlo
bip     lda $c030       ;4 cycles
        ldx pitch       ;3 cycles
inloop  nop             ;2 cycles
        nop             ;2 cycles
        nop             ;2 cycles
        nop             ;2 cycles
        dex             ;2 cycles
        bne inloop      ;3 cycles
        dey             ;2 cycles
        bne bip         ;3 cycles
        dec lengthhi    ;5 cycles
        bne bip         ;3 cycles
        rts
*
* MUSIC
* notes
note01	hex     FB
note02	hex	ED
note03	hex	DF
note04	hex	D3
note05	hex	C7
note06	hex	BB
note07	hex	B1
note08	hex	A7
note09	hex	9D
note10	hex	94
note11	hex	8C
note12	hex	84
note13	hex	7C
note14	hex	75
note15	hex	6F
note16	hex	68
note17	hex	62
note18	hex	5D
note19	hex	57
note20	hex	52
note21	hex	4E
note22	hex	49
note23	hex	45
note24	hex	41
note25	hex	3D
note26	hex	3A
note27	hex	36
note28	hex	33
note29	hex	30
note30	hex	2D
note31	hex	2B
note32	hex	28
note33	hex	26
*
* durations
d1	hex	0137
d2	hex	0149
d3	hex	015D
d4	hex	0171
d5	hex	0188
d6	hex	019F
d7	hex	01B8
d8	hex	01D2
d9	hex	01ED
d10	hex	020B
d11	hex	022A
d12	hex	024B
d13	hex	026E
d14	hex	0293
d15	hex	02BA
d16	hex	02E3
d17	hex	0310
d18	hex	033E
d19	hex	0370
d20	hex	03A4
d21	hex	03DB
d22	hex	0416
d23	hex	0454
d24	hex	0496
d25	hex	04DC
d26	hex	0526
d27	hex	0574
d28	hex	05C7
d29	hex	0620
d30	hex	067D
d31	hex	06E0
d32	hex	0748
d33	hex	07B7

pitch           hex 00
lengthlo        hex 00
lengthhi        hex 00
tempo           hex 00
*
*
* GRAPHICS
*
left    hex 00
right   hex 00
top     hex 00
bottom  hex 00
*   
nblig2   hex   0b                       ; hit a key...
nbcol2   hex   09
hitk     hex   0000000000000000
         hex   0000000000000000
         hex   0000060c03000060
         hex   0000000600030000
         hex   600000003e4c0f40
         hex   07600c0f33660c03
         hex   000c60461933660c
         hex   03400f60471f3366
         hex   0c03600c604c013e
         hex   660c0e400f600c0f
         hex   3000000000000000
         hex   001e000000000000
         hex   000000
*
nblig   hex   1c                        ; tribute...
nbcol   hex   1e
cut     hex   0000000000000000
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
