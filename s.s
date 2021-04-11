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
* VAR
ptr     equ $06
ptr2    equ $08
* 
* CONST
framemax equ $09 
posx    equ $05         ; position in X (in byte, not pixel)
posy    equ $3F         ; position in Y (= line #)
posx2   equ $0E  
posy2   equ $64
posx3   equ $01
posy3   equ $97

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
*
*
*
* BEGIN
* setup vars for shape 1
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
* paint shape 1 while playing "music"
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
* inner loop (line)
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
        lda top         ; play every 4 lines
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
endtune lda play+1      ; get value 
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
        sta play2+2
*
        lda saveptr+4  
        sta play3+1
        lda saveptr+5  
        sta play3+2
* 
* Display hit a key 
        setvar #posx2;#posy2;nbcol2;nblig2;left;right;top;bottom
        bitmap hitk;top;left;right;bottom
*
* Display 3 wolves
        setvar #posx3;#posy3;nbcol3;nblig3;left;right;top;bottom
        bitmap loup3;top;left;right;bottom

        rts             ; end of program
*
* setup a note from note list ans play it
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
        jsr sound       ; play the speaker
playend rts

* space for saving pointers
* inside code (self modified)
saveptr ds 6,0
*
* tune = note list : pitch / duration hi / duration lo
* 00 = flag for end of list
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
* bitmap : hit a key...
nblig2   hex   0a
nbcol2   hex   0c
hitk     hex   0000000000000000
         hex   000000000c180600
         hex   0040010000000000
         hex   0c00060000400100
         hex   000000007c181f00
         hex   0f40191e66000000
         hex   4c19060018400d33
         hex   660000004c190600
         hex   1f400f3f66000000
         hex   4c19064019401903
         hex   7c604c014c191c00
         hex   1f40191e60604c01
         hex   0000000000000000
         hex   3c00000000000000
         hex   0000000000000000

* bitmap : tribute to Wild Man
nblig    hex   1b
nbcol    hex   1e
cut      hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000070
         hex   0130001803001800
         hex   0018000000783300
         hex   00604c1903063060
         hex   0000000000180330
         hex   0000030018000018
         hex   0000006030000060
         hex   4c01030670700000
         hex   0000001803787919
         hex   1f667c78007c7800
         hex   0060704307604c19
         hex   6307707978780100
         hex   0018033038183366
         hex   184c01184c010060
         hex   30660c604c193306
         hex   306f401903000078
         hex   033018183366187c
         hex   01184c0100603066
         hex   0f604c1933063066
         hex   7819030000180330
         hex   18183366180c0018
         hex   4c01006030660040
         hex   7f18330630604c19
         hex   0300001803601918
         hex   1f7c707800707800
         hex   0060304607003318
         hex   6307306078190300
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   000000001c000000
         hex   00400778013c0000
         hex   0700000000000000
         hex   0000000000000000
         hex   0000060000000060
         hex   0c18036600400100
         hex   0000000000000000
         hex   0000000000000000
         hex   1f1f1e7e07600c18
         hex   0306006047470f00
         hex   0000000000000000
         hex   0000000000000607
         hex   33660c600c780106
         hex   0040614c03000000
         hex   0000000000000000
         hex   0000000006033366
         hex   0c600f1803060040
         hex   614c010000000000
         hex   0000000000000000
         hex   0000060333660c60
         hex   4c1933660c40614c
         hex   0100000000000000
         hex   0000000000000000
         hex   06031e660c604c79
         hex   313c0c4041470100
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0040010000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000001800007831
         hex   460100000c00001f
         hex   30000000000c0000
         hex   0000000000003000
         hex   4c19000018034001
         hex   00000c0040311800
         hex   0000000c00006600
         hex   0000000030004c19
         hex   7001186363470740
         hex   4f1940013c4c7131
         hex   460f0f1f66003c7c
         hex   7870310600180003
         hex   783146610c604c19
         hex   4039664c0133660c
         hex   18330000661c4019
         hex   3303001870031873
         hex   47610f604c194031
         hex   7e4c7133660c1f33
         hex   0000060c78197003
         hex   0018180318334061
         hex   00604c1940310678
         hex   1833664c19330000
         hex   660c4c1933060078
         hex   7103786103470740
         hex   0f1f001f3c307063
         hex   470f1f3300003c0c
         hex   7871310600000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000
*
* bitmap : 3 wolves
nblig3   hex   29
nbcol3   hex   25
loup3    hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000084900000
         hex   0000820000000000
         hex   000000000000a000
         hex   0000000000000000
         hex   0000000000000000
         hex   701f7f1f00008918
         hex   0000000000000000
         hex   0000840207000000
         hex   0000000000000000
         hex   0000000000e47f7f
         hex   7fefcc9d78000000
         hex   000000c0ecfe8ce6
         hex   840f000000000000
         hex   0000000000006000
         hex   00007cf3ef7fffcc
         hex   3fe9030000000092
         hex   707fefbcb61f3e00
         hex   0000000000000000
         hex   00001060030000fc
         hex   e87f7fef777fed0f
         hex   00000000ffed7f7f
         hex   f3ef7f7d01000000
         hex   00000000000000e7
         hex   a60f00009ef17f7f
         hex   9fb3fbf79f000000
         hex   d0cf7f7f6fcdfd7f
         hex   7f01000000000000
         hex   000000c8b9b73f00
         hex   00ad787f7fefcc7f
         hex   7fbb00000030837f
         hex   7f7fdbd97d6f0100
         hex   0000000000000000
         hex   ecdf7ffe00009b70
         hex   3fffbefbfd7fad00
         hex   0000f8017ff7dfbd
         hex   beffdf8500000000
         hex   00000000e0b6fb7f
         hex   ef010087687f7f7f
         hex   cffb7f3b0000003c
         hex   00fe7f7eb7f7f63f
         hex   8300000000000000
         hex   00dcdbe57fff00c0
         hex   03707fdbdf793fff
         hex   a7000000fc00fd3f
         hex   7fdfb9ffff840000
         hex   0000300000603fed
         hex   f67eef016081606f
         hex   edbbcfdd7fff0000
         hex   000c81fe7f7e3f1e
         hex   7f7f07000000007c
         hex   a5fe7f7fb3fbfd9f
         hex   836000a0ffcc9ff3
         hex   f97f3f8100009e00
         hex   3c7f39cfd97d7f1f
         hex   000000007ff77f7f
         hex   7fdfdd7f3f81c800
         hex   c03fa3f6cdb77f6f
         hex   83000099007ccff9
         hex   b7f64effcc000000
         hex   00ef7e7f7f7fede6
         hex   7d7f05b000a0fe20
         hex   7e3c7e4f4f050000
         hex   8e0074bddccf99fb
         hex   b6ab000000c09ff9
         hex   ef7f7eb7fb6e7f83
         hex   9200a09f81d97337
         hex   cfcd820000a70070
         hex   8f98ffe6b69b4100
         hex   0000a09b787f777f
         hex   dbddfded8e8c0000
         hex   9b00e6b3fe073984
         hex   00009b00f096e4db
         hex   e7cce58400000060
         hex   a7787f3f6fbfe6db
         hex   b9300100c0890099
         hex   b3f7069000000003
         hex   00308b90fb9d8b00
         hex   820000006086787f
         hex   dbfddff9fc910300
         hex   00e8a100e4b3e601
         hex   0000000003007085
         hex   90b3ee8c00000000
         hex   00f081726fcfd97f
         hex   e68ec0820000bca6
         hex   00c4b39681000000
         hex   608100f08400317e
         hex   830000000000b882
         hex   787f8de7f3998300
         hex   000000928d0098bb
         hex   a600000000c08100
         hex   fc00c088b7070000
         hex   000000d881687f93
         hex   98efe68400000000
         hex   848e00c0bc940000
         hex   0000a08200ec8400
         hex   a2fe840000000000
         hex   1800c8df07e4ecd7
         hex   0000000000828d00
         hex   90df890000000090
         hex   0000b4030090fd01
         hex   0000000000cc0060
         hex   7e8d90f2ab010000
         hex   0000060600e07e81
         hex   0000000000000070
         hex   0400c8ed00000000
         hex   00000600a07f8300
         hex   60ff000000000084
         hex   0300f0fc82000000
         hex   0000000040930010
         hex   3900000000004089
         hex   00c0ed850060cf00
         hex   0000000082820030
         hex   bb00000000000000
         hex   0000870018990000
         hex   00000090810000fe
         hex   8200609d00000000
         hex   00a40000f0bc0000
         hex   000000000000008e
         hex   00c8a40000000000
         hex   988100a0b98100a0
         hex   ae00000000c0c081
         hex   00f8920000000000
         hex   000000009c008cd0
         hex   0000000000890000
         hex   00ef0000c0950000
         hex   0000008182002c8b
         hex   0000000000000000
         hex   00b2009200010000
         hex   00c081000000ed00
         hex   0000990100000000
         hex   8281009c8c000000
         hex   000000000000d800
         hex   0640040000000000
         hex   0000c09d81000086
         hex   9300000000848200
         hex   9990000000000000
         hex   000000c890820092
         hex   0000000000000000
         hex   9b8100c8818a0000
         hex   00000081008e8200
         hex   0000000000000000
         hex   a0e0000088000000
         hex   00000000a0e00000
         hex   a200a00000000000
         hex   0000890000000000
         hex   0000000000c08100
         hex   0092000000000000
         hex   00008284004000a0
         hex   00000000008900c5
         hex   8400000000000000
         hex   0000008600000000
         hex   0000000000000081
         hex   82000000c0000000
         hex   00008400e2820000
         hex   0000000000000000
         hex   8800000000000000
         hex   0000000082900000
         hex   00a0000000000000
         hex   a082000000000000
         hex   0000000000a40000
         hex   0000000000000000
         hex   0081880000000000
         hex   0000000000a00000
         hex   0000000000000000
         hex   0000900000000000
         hex   0000000000008200
         hex   0000000000000000
         hex   0000c08100000000
         hex   0000000000000000
         hex   8100000000000000
         hex   0000000000000000
         hex   00000000000000a0
         hex   0000000000000000
         hex   0000000040010000
         hex   0000000000000000
         hex   8400000000000000
         hex   0000000000850000
         hex   0000000000000000
         hex   0000000000000000
         hex   0000000000980000
         hex   0000000000

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
