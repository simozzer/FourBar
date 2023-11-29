; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Print a message on the status line at the top of the screen
; ------------------------------------------------------------------------------
printStatusMessage
    jsr clearStatusLine
    ldy 0
    :loadMessageLoop    
    lda $ffff,Y
    beq messagePrinted
    sta $bb82,y
    iny
    jmp loadMessageLoop
    messagePrinted
    rts
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Clear text from the status line at the top of the screen
; ------------------------------------------------------------------------------
clearStatusLine
    ldy #0                      
    lda #32
.(
Loop
    cpy #38 ;
    beq ExitClear                        
    sta $BB82,Y                     
    iny                             
    jmp Loop
    ExitClear 
    rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<






; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Perform a short delay (currently used to slow to down the game a bit)
; ------------------------------------------------------------------------------
smallDelay
.(
    txa
    pha
    ldx #$10

    outer_loop
    
    ; a small delay
    ldy #255
    loop
    dey
    nop
    cpy #00
    Bne loop
    dex
    cpx #00 
    bpl outer_loop

    pla
    tax
    rts    
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Perform a big delay (currently used to wait a while before restarting the game
; ------------------------------------------------------------------------------
bigDelay
.(
    txa
    pha
    ldx #$ff

    outer_loop
    
    ; a small delay
    ldy #255
    loop
    dey
    nop
    cpy #00
    Bne loop
    dex
    cpx #00 
    bne outer_loop

    pla
    tax
    rts    
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;// Copy memory (could be further opitimised using comments from dhbug)
; ------------------------------------------------------------------------------
CopyMemory 
    ldx _copy_mem_src_lo          
    stx LoadSourceByte+1                      
    ldx _copy_mem_src_hi                        
    stx LoadSourceByte+2                      
    ldx _copy_mem_dest_lo                      
    stx SaveDestByte+1                     
    ldx _copy_mem_dest_hi           
    stx SaveDestByte+2                     
CopyLoop 
    lda _copy_mem_count_lo; LO BYTE OF COUNT 
    bne DecLo                        
    dec _copy_mem_count_hi                         
    :DecLo 
    dec _copy_mem_count_lo                   
    ; CHECK IF ALL BYTES COPIED     
    lda _copy_mem_count_lo                         
    bne LoadSourceByte                        
    lda _copy_mem_count_hi                        
    bne LoadSourceByte                        
    rts ; ZERO BYTES REMAIN          
    
    ; Copy source byte to destination              
:LoadSourceByte 
    lda $FFFF                  
:SaveDestByte 
    sta $FFFF                 
    
    ; Increment Source pointer
    inc LoadSourceByte+1                      
    bne IncDestAddress                       
    inc LoadSourceByte+2                      
    
    ; Increment Destination pointer      
:IncDestAddress 
    inc SaveDestByte+1               
    bne IncrementDone                       
    inc SaveDestByte+2                     

:IncrementDone 
    jmp CopyLoop 
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;// Wipe params. Zero all params used for a Basic Call
; ------------------------------------------------------------------------------
WipeParams
.(
ldy #08
lda #0
wipePriorParam
sta $02E0, y
dey
bne wipePriorParam
rts
.)


; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


    
