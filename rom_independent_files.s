
/*
SAVE subroutines:

1. For version 1.0:
JSR E6CA (interrupts off)
JSR E57B (save)
JSR E804 (interrupts on)

#5F, #60 Start address
#61, #62 End address.
#63 Autoload flag – set to zero if no autoload required.
#64 Machine code of BASIC – set to zero for BASIC.
#67 Speed. Zero means fast, one means slow.
#35 – #44 Filename, terminated by #00



2. For version 1.1:
JSR E76A (interrupts off) set6522ForCassette
JSR E585 (print ‘saving’)
JSR E607 (save header record) outputFileHeader
JSR E62E (save area of memory)
JSR E93D (interrupts on)

#2A9, #2AA Start address
#2AB, #2AC End address.
#2AD Autoload flag – zero means no autoload.
#2AE Machine code flag – set to zero if BASIC.
#24D Speed. Zero means fast, one means slow,
#27F – #28E Filename, terminated with zero.
*/

saveAtmos
.(
    ; set start address
    lda #$00
    sta $2A9
    lda #$90
    sta $2AA
    ; set end address
    lda #$00
    sta $2AB
    lda #$93
    sta $2AC
    ; set no autoload
    lda #$00
    sta $2AD
    ; set machine code
    lda #01
    sta $2AE
    ; set fast
    lda #$00
    sta $24D
    ; set filename ('AA' #0)
    lda #$41
    sta $27F
    sta $280
    lda #$00
    sta $281

    JSR $E76A; (interrupts off) set6522ForCassette
    JSR $E585; (print ‘saving’)
    JSR $E607; (save header record) outputFileHeader
    JSR $E62E; (save area of memory)
    JSR $E93D; (interrupts on)

    RTS
.)

