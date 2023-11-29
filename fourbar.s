// Called fourbar, as a reference to foo-bar
// Each bar will contain 16 semi-quavers, 
// and we will just allow for four bars of music (initially)
// For each channel we will store (per semi quaver)
// Octave (hi-nibble) & Note (lo-nibble)(lo-word)
// Length (hi-nibble) & Vol (lo-nibble)(hi-word)
// so we should be able to contain a 'tune' in 128 bytes per channel.
// We will just allow for 2 channels of music,
// this will leave 1 tone channel for the game to use for simple sfx 
// the noise channel should also be available, if I can work out
// how to use this for drums then I will.


// There are much better tunes available using things
// like MYM, and other programs to created to use Atari St
// music files - but these seem to take a lot of memory 
// or a lot of CPU time decompressing existing data.
// I'm trying to keep things as simple a possible (KISS)
// to reduce the demands on CPU and memory.
// (And also to eliminate the learning curve by not 
// actually learning all the IO required to program the 
// sound chip).

// The data will be stored using this format
// OCTAVE 0-7 (3 bits, but will use 4. The hi bit will be used for 'no note')
// NOTE (1-12/ can be stores as 0-11) (4 bits)
// VOL (1-15 - volume level, 0 = use envelope from play) (lo 4 bits)


// temporary code to test tracker screen
runTracker
.(

    jsr printTrackerInstructions
    lda #0
    sta _first_visible_tracker_step_line
    sta _tracker_selected_col_index
    sta _tracker_selected_row_index
    :refreshTrackerScreen
    jsr printTrackerScreen

    :readAgain
    jsr _getKey
    ldx KEY_PRESS_LOOKUP
    cpx _last_key
    beq readAgain
    stx _last_key
    

    cpx #KEY_DOWN_ARROW
    bne checkUp
    lda _tracker_selected_row_index
    cmp #15
    bpl checkUp
    inc _tracker_selected_row_index
    jmp refreshTrackerScreen    

    checkUp
    cpx #KEY_UP_ARROW
    bne checkRight
    lda _tracker_selected_row_index
    cmp #01
    bmi checkRight
    dec _tracker_selected_row_index
    jmp refreshTrackerScreen


    checkRight
    cpx #KEY_RIGHT_ARROW
    bne checkLeft
    lda _tracker_selected_col_index
    cmp #08
    bpl checkLeft
    inc _tracker_selected_col_index
    jmp refreshTrackerScreen

    checkLeft
    cpx #KEY_LEFT_ARROW
    bne checkPlus
    lda _tracker_selected_col_index
    cmp #01
    bmi checkPlus
    dec _tracker_selected_col_index
    jmp refreshTrackerScreen

    checkPlus
    cpx #KEY_PLUS
    bne checkMinus
    jsr processPlus
    jmp refreshTrackerScreen

    checkMinus
    cpx #KEY_MINUS
    bne checkQuit
    jsr processMinus
    jmp refreshTrackerScreen

    checkQuit
    cpx #KEY_Q
    bne checkDelete
    rts

    checkDelete
    cpx #KEY_DELETE
    bne checkCopy
    jsr processDelete
    jmp refreshTrackerScreen

    checkCopy
    cpx #KEY_C
    bne checkPaste
    jsr processCopy
    jmp refreshTrackerScreen

    checkPaste
    cpx #KEY_V
    bne checkS
    jsr processPaste
    jmp refreshTrackerScreen

    checkS
    cpx #KEY_S
    bne checkF
    jsr slowDown
    jmp refreshTrackerScreen

    checkF
    cpx #KEY_F
    bne checkOne
    jsr speedUp
    jmp refreshTrackerScreen

    checkOne
    cpx #KEY_1
    bne checkTwo
    lda #0
    sta _first_visible_tracker_step_line
    sta _tracker_bar_index
    jmp refreshTrackerScreen


    checkTwo
    cpx #KEY_2
    bne checkThree
    lda #16
    sta _first_visible_tracker_step_line
    lda #01
    sta _tracker_bar_index
    jmp refreshTrackerScreen

    checkThree
    cpx #KEY_3
    bne checkFour
    lda #32
    sta _first_visible_tracker_step_line
    lda #02
    sta _tracker_bar_index
    jmp refreshTrackerScreen


    checkFour
    cpx #KEY_4
    bne checkFive
    lda #48
    sta _first_visible_tracker_step_line
    lda #03
    sta _tracker_bar_index
    jmp refreshTrackerScreen     

    checkFive
    cpx #KEY_5
    bne checkSix
    lda #64
    sta _first_visible_tracker_step_line
    lda #04
    sta _tracker_bar_index  
    jmp refreshTrackerScreen 

    checkSix  
    cpx #KEY_6
    bne checkSeven
    lda #80
    sta _first_visible_tracker_step_line
    lda #05
    sta _tracker_bar_index  
    jmp refreshTrackerScreen   

    checkSeven
    cpx #KEY_7
    bne checkEight
    lda #96
    sta _first_visible_tracker_step_line
    lda #06
    sta _tracker_bar_index  
    jmp refreshTrackerScreen 

    checkEight
    cpx #KEY_8
    bne loopAgain
    lda #112
    sta _first_visible_tracker_step_line
    lda #07
    sta _tracker_bar_index 
    jmp refreshTrackerScreen
    
/*
    checkB
    cpy #KEY_B
    bne loopAgain
    lda _tracker_play_mode
    cmp #TRACKER_PLAY_MODE_BAR
    beq songMode

    lda #TRACKER_PLAY_MODE_BAR
    sta _tracker_play_mode
    // TODO -- in tracker interrupt change on the next 16
    // TODO -- change to current displayed bar
    jmp loopAgain

    songMode
    lda #TRACKER_PLAY_MODE_SONG
    sta _tracker_play_mode
    lda #00
    sta _tracker
    */
    
    loopAgain
    jmp readAgain
.)

speedUp
.(
    lda _tracker_step_length
    clc
    cmp #01
    bne increaseSpeed
    rts

    increaseSpeed
    dec _tracker_step_length
    rts
.)

slowDown
.(
    lda _tracker_step_length
    cmp #20
    bpl done
    inc _tracker_step_length

    done
    rts
.)

processCopy
.(
    clc
    lda _tracker_selected_row_index
    adc _first_visible_tracker_step_line
    tay
    lda trackerMusicDataLo,Y
    sta copyLoop+1
    lda trackerMusicDataHi,y
    sta copyLoop+2
    
    clc
    ldy #00
   :copyLoop
    lda $ffff,Y
    sta trackerCopyBuffer,Y
    iny
    cpy #06
    bne copyLoop 
    rts
.)

processPaste
.(
    clc
    lda _tracker_selected_row_index
    adc _first_visible_tracker_step_line
    tay
    lda trackerMusicDataLo,Y
    sta pasteLoop+4
    lda trackerMusicDataHi,y
    sta pasteLoop+5
    clc
    ldy #00
    :pasteLoop
    lda trackerCopyBuffer,Y
    sta $ffff,Y
    iny
    cpy #06
    bne pasteLoop
    rts
.)



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; processPlus: 
;   handle the plus key being pressed to increment a column value
;   for the current step in the tracker display
; ------------------------------------------------------------------------------            
processPlus
.(
    clc
    lda _tracker_selected_row_index
    adc _first_visible_tracker_step_line
    tay
    lda trackerMusicDataLo,Y
    sta _copy_mem_src_lo
    lda trackerMusicDataHi,y
    sta _copy_mem_src_hi

    lda _tracker_selected_col_index
    cmp #TRACKER_COL_INDEX_NOTE_CH1
    bne nextCheck0

    ldy #0
    lda (_copy_mem_src),y
    tax
    and #$F0
    sta _hi_nibble
    txa
    and #$0f
    sta _lo_nibble
    cmp #12
    bmi incrementNoteChannel1
    jmp done

    incrementNoteChannel1 // Add to note value channel 1
    tax
    inx
    txa
    sta _lo_nibble
    adc _hi_nibble
    ldy #0
    sta (_copy_mem_src),y
    rts

nextCheck0
    cmp #TRACKER_COL_INDEX_OCT_CH1
    bne nextCheck2

    ldy #0
    lda (_copy_mem_src),y
    tax
    and #$0f
    sta _lo_nibble
    txa
    and #$f0
    lsr
    lsr 
    lsr
    lsr
    sta _hi_nibble
    clc
    cmp #07
    bcc incrementOctChannel1
    jmp done

    incrementOctChannel1 // Add to oct value channel 1
    clc
    adc #$01
    asl
    asl
    asl
    asl

    adc _lo_nibble
    ldy #0
    sta (_copy_mem_src),y
    rts



nextCheck2
    cmp #TRACKER_COL_INDEX_VOL_CH1
    bne nextCheck3

    
    ldy #1
    lda (_copy_mem_src),y
    and #$0f
    clc
    cmp #15
    bcc incrementVolChannel1
    jmp done

    incrementVolChannel1 // Add to oct value channel 1
    adc #$01
    sta (_copy_mem_src),y
    rts



nextCheck3
    cmp #TRACKER_COL_INDEX_NOTE_CH2
    bne nextCheck4

    ldy #2
    lda (_copy_mem_src),y
    tax
    and #$F0
    sta _hi_nibble
    txa
    and #$0f
    sta _lo_nibble
    cmp #12
    bmi incrementNoteChannel2
    jmp done

    incrementNoteChannel2 // Add to note value channel 2
    tax
    inx
    txa
    sta _lo_nibble
    adc _hi_nibble
    ldy #2
    sta (_copy_mem_src),y
    rts

nextCheck4    
    cmp #TRACKER_COL_INDEX_OCT_CH2
    bne nextCheck6

    ldy #2
    lda (_copy_mem_src),y
    tax
    and #$0f
    sta _lo_nibble
    txa
    and #$f0
    lsr
    lsr 
    lsr
    lsr
    sta _hi_nibble
    clc
    cmp #07
    bcc incrementOctChannel2
    jmp done

    incrementOctChannel2 // Add to oct value channel 2
    clc
    adc #$01
    asl
    asl
    asl
    asl

    adc _lo_nibble
    ldy #2
    sta (_copy_mem_src),y
    rts



nextCheck6
    cmp #TRACKER_COL_INDEX_VOL_CH2
    bne nextCheck7

    ldy #3
    lda (_copy_mem_src),y
    and #$0f
    clc
    cmp #15
    bcc incrementVolChannel2
    jmp done

    incrementVolChannel2 // Add to oct value channel 2
    clc
    adc #$01
    sta (_copy_mem_src),y
    rts

nextCheck7
    cmp  #TRACKER_COL_INDEX_NOTE_CH3
    bne nextCheck8

    ldy #4
    lda (_copy_mem_src),y
    tax
    and #$F0
    sta _hi_nibble
    txa
    and #$0f
    sta _lo_nibble
    cmp #12
    bmi incrementNoteChannel3
    jmp done

    incrementNoteChannel3 // Add to note value channel 2
    tax
    inx
    txa
    sta _lo_nibble
    adc _hi_nibble
    ldy #4
    sta (_copy_mem_src),y
    rts

nextCheck8
    cmp #TRACKER_COL_INDEX_OCT_CH3
    bne nextCheck9

    ldy #4
    lda (_copy_mem_src),y
    tax
    and #$0f
    sta _lo_nibble
    txa
    and #$f0
    lsr
    lsr 
    lsr
    lsr
    sta _hi_nibble
    clc
    cmp #07
    bcc incrementOctChannel3
    jmp done

    incrementOctChannel3 // Add to oct value channel 1
    clc
    adc #$01
    asl
    asl
    asl
    asl

    adc _lo_nibble
    ldy #4
    sta (_copy_mem_src),y
    rts

nextCheck9  
    cmp #TRACKER_COL_INDEX_VOL_CH3
    bne done
    ldy #5
    lda (_copy_mem_src),y
    and #$0f
    clc
    cmp #15
    bcc incrementVolChannel3
    jmp done

    incrementVolChannel3 // Add to oct value channel 1
    adc #$01
    sta (_copy_mem_src),y
    rts

done
    rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; processMinus: 
;   handle the plus key being pressed to decrement a column value
;   for the current step in the tracker display
; ------------------------------------------------------------------------------  
processMinus
.(
    clc
    lda _tracker_selected_row_index
    adc _first_visible_tracker_step_line
    tay
    lda trackerMusicDataLo,Y
    sta _copy_mem_src_lo
    lda trackerMusicDataHi,y
    sta _copy_mem_src_hi

    lda _tracker_selected_col_index
    cmp #TRACKER_COL_INDEX_NOTE_CH1
    bne nextCheck0

    ldy #0
    lda (_copy_mem_src),y
    tax
    and #$F0
    sta _hi_nibble
    txa
    and #$0f
    sta _lo_nibble
    clc
    cmp #02
    bcs decrementNoteChanel1
    jmp done

    decrementNoteChanel1 // subtract from note value channel 1
    tax
    dex
    txa
    clc
    sta _lo_nibble
    adc _hi_nibble
    ldy #0
    sta (_copy_mem_src),y
    rts

nextCheck0
    cmp #TRACKER_COL_INDEX_OCT_CH1
    bne nextCheck2
    ldy #0
    lda (_copy_mem_src),y
    tax
    and #$0f
    sta _lo_nibble
    txa
    and #$f0
    lsr
    lsr 
    lsr
    lsr
    sta _hi_nibble
    clc
    cmp #0
    bne decrementOctChannel1
    jmp done

    decrementOctChannel1 // Add to oct value channel 1
    tax
    dex
    txa
    asl
    asl
    asl
    asl
    adc _lo_nibble
    ldy #0
    sta (_copy_mem_src),y
    rts

nextCheck2
    cmp #TRACKER_COL_INDEX_VOL_CH1
    bne nextCheck3

    
    ldy #1
    lda (_copy_mem_src),y
    and #$0f
    clc
    cmp #0
    bne decrementVolChannel1
    jmp done

    decrementVolChannel1 // Add to oct value channel 1
    sbc #01
    sta (_copy_mem_src),y
    rts

nextCheck3
    cmp #TRACKER_COL_INDEX_NOTE_CH2
    bne nextCheck4

    ldy #2
    lda (_copy_mem_src),y
    tax
    and #$F0
    sta _hi_nibble
    txa
    and #$0f
    sta _lo_nibble
    clc
    cmp #02
    bcs decrementNoteChanel2
    jmp done

    decrementNoteChanel2 // subtract from note value channel 2
    tax
    dex
    txa
    clc
    sta _lo_nibble
    adc _hi_nibble
    ldy #2
    sta (_copy_mem_src),y
    rts


nextCheck4    
    cmp #TRACKER_COL_INDEX_OCT_CH2
    bne nextCheck6

    ldy #2
    lda (_copy_mem_src),y
    tax
    and #$0f
    sta _lo_nibble
    txa
    and #$f0
    lsr
    lsr 
    lsr
    lsr
    sta _hi_nibble
    clc
    cmp #0
    bne decrementOctChannel2
    jmp done

    decrementOctChannel2 // subtract from oct value channel 2
    tax
    dex
    txa
    asl
    asl
    asl
    asl

    adc _lo_nibble
    ldy #2
    sta (_copy_mem_src),y
    rts
nextCheck6
    cmp #TRACKER_COL_INDEX_VOL_CH2
    bne nextCheck7

    ldy #3
    lda (_copy_mem_src),y
    and #$0f
    clc
    cmp #0
    bne decrementVolChannel2
    jmp done

    decrementVolChannel2 // Add to oct value channel 1
    sbc #01
    sta (_copy_mem_src),y
    rts

nextCheck7
    cmp  #TRACKER_COL_INDEX_NOTE_CH3
    bne nextCheck8

    ldy #4
    lda (_copy_mem_src),y
    tax
    and #$F0
    sta _hi_nibble
    txa
    and #$0f
    sta _lo_nibble
    clc
    cmp #02
    bcs decrementNoteChanel3
    jmp done

    decrementNoteChanel3 // subtract from note value channel 1
    tax
    dex
    txa
    clc
    sta _lo_nibble
    adc _hi_nibble
    ldy #4
    sta (_copy_mem_src),y
    rts

nextCheck8
    cmp #TRACKER_COL_INDEX_OCT_CH3
    bne nextCheck9
    ldy #4
    lda (_copy_mem_src),y
    tax
    and #$0f
    sta _lo_nibble
    txa
    and #$f0
    lsr
    lsr 
    lsr
    lsr
    sta _hi_nibble
    clc
    cmp #0
    bne decrementOctChannel3
    jmp done

    decrementOctChannel3 // Add to oct value channel 1
    tax
    dex
    txa
    asl
    asl
    asl
    asl
    adc _lo_nibble
    ldy #4
    sta (_copy_mem_src),y
    rts
    
nextCheck9
    cmp #TRACKER_COL_INDEX_VOL_CH3
    bne done

    ldy #5
    lda (_copy_mem_src),y
    and #$0f
    clc
    cmp #0
    bne decrementVolChannel3
    jmp done

    decrementVolChannel3 // Add to oct value channel 1
    sbc #01
    sta (_copy_mem_src),y
    rts

done
    rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 



processDelete
.(
        clc
    lda _tracker_selected_row_index
    adc _first_visible_tracker_step_line
    tay
    lda trackerMusicDataLo,Y
    sta _copy_mem_src_lo
    lda trackerMusicDataHi,y
    sta _copy_mem_src_hi

    lda _tracker_selected_col_index
    cmp #TRACKER_COL_INDEX_NOTE_CH1
    bne nextCheck0

    ldy #0
    lda #0
    sta (_copy_mem_src),y
    rts

nextCheck0
    cmp #TRACKER_COL_INDEX_OCT_CH1
    bne nextCheck2

    ldy #0
    lda #0
    sta (_copy_mem_src),y
    rts

nextCheck2
    cmp #TRACKER_COL_INDEX_VOL_CH1
    bne nextCheck3

    
    ldy #1
    lda #0
    sta (_copy_mem_src),y
    rts



nextCheck3
    cmp #TRACKER_COL_INDEX_NOTE_CH2
    bne nextCheck4

    ldy #2
    lda #0
    sta (_copy_mem_src),y
    rts


nextCheck4    
    cmp #TRACKER_COL_INDEX_OCT_CH2
    bne nextCheck6

    ldy #2
    lda #0
    sta (_copy_mem_src),y
    rts

nextCheck6
    cmp #TRACKER_COL_INDEX_VOL_CH2
    bne nextCheck7

    ldy #2
    lda #0
    sta (_copy_mem_src),y
    rts
nextCheck7
    cmp #TRACKER_COL_INDEX_NOTE_CH3
    bne nextCheck8

    ldy #4
    lda #0
    sta (_copy_mem_src),y
    rts    
nextCheck8
    cmp #TRACKER_COL_INDEX_OCT_CH3
    bne nextCheck9

    ldy #4
    lda #0
    sta (_copy_mem_src),y
    rts     
nextCheck9
    cmp #TRACKER_COL_INDEX_VOL_CH3
    bne done

    ldy #4
    lda #0
    sta (_copy_mem_src),y
    rts     

done
    rts
.)
