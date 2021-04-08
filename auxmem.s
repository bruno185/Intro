* Demonstrate usage of AUXMOV and XFER
* prog. :
* - copies a piece of code in aux memory
* - transfer execution to that code in aux mem.
* - code in aux mem. transfer execution to main memory.
*
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


*
* ROM switches
ALTCHARSET0FF   equ $C00E 
ALTCHARSET0N    equ $C00F
kbd     equ $C000
kbdstrb equ $C010
*
* page 0
ptr       equ $06
cv        equ $25
ch        equ $24 
wndlft    equ $20
wndwdth   equ $21
wndtop    equ $22
wndbtm    equ $23 
prompt    equ $33
*
* prog. equ
*
* MACROS

        DO 0
print   MAC         ; display a 0 terminated string
        ldx #$00      ; in argument
boucle  lda ]1,X
        beq finm
        ora #$80
        jsr cout
        inx
        bra boucle
finm    EOM 
        FIN

        org $6000
*    
        lda #<aux       ; this code will stay in main memory
        sta $3C         ; begining of memory to tranfer
        lda #>aux
        sta $3D
*
        lda #<auxend      ; end of memory to tranfer
        sta $3E
        lda #>auxend
        sta $3F
*
        lda #<aux       ; detination adresse (same as in main)   
        sta $42
        lda #>aux
        sta $43
        sec
        jsr auxmov      ; tranfer code in aux. mem.
*
        ldx #$00        ; erase code in main 
        lda #$00        ; to make sure code is executed in aux.
erase   sta aux,x
        dex
        bne erase
*
        lda #<aux       ; address of code in aux.
        sta $3ED
        lda #>aux
        sta $3EE
        sec
        clv
        jmp xfer        ; transfer execution to aux mem.


final   nop
        print inmain
        rts
inmain  asc "back in main memory !"
        hex 00
*
* this part is to be transfered and excuted in aux. mem
aux     print inaux     ; print a text
        lda #<final     ; execution address to go back to main mem.
        sta $3ED
        lda #>final
        sta $3EE
        clc
        clv
        jmp xfer        ; transfer to main mem. 
inaux   asc "now in aux. memory !"
        hex 8D00
auxend  nop             ; end of code in aux. mem.
*



