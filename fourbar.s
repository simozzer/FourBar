// Called fourbar, as a reference to foo-bar
// Each bar will contain 16 semi-quavers, 
// and we will just allow for four bars of music (initially)
// For each channel we will store (per semi quaver)
// Octave (hi-nibble) & Note (lo-nibble)(lo-word)
// Vol (lo-nibble)(hi-word)

// There are much better tunes available using things
// like MYM, and other programs to created to use Atari St
// music files - but these seem to take a lot of memory 
// or a lot of CPU time decompressing existing data.
// I'm trying to keep things as simple a possible (KISS)
// to reduce the demands on CPU and memory.

// The data will be stored using this format
// OCTAVE 0-7 (3 bits, but will use 4)
// NOTE (1-12/ can be stores as 0-11) (4 bits)
// VOL (1-15 - volume level, 0 = use envelope from play) (lo 4 bits)


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; runTracker: 
;   display the UI for the tracker and repsond to key presses
; ------------------------------------------------------------------------------     
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
    cmp #09
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
    jsr clearTrackerInterupt
    jsr clearSound// Silence  
    lda #0
    sta $8FFF
    rts

    checkDelete
    cpx #KEY_DELETE
    bne checkCopy
    jsr processDeleteNote
    jmp refreshTrackerScreen

    checkCopy
    cpx #KEY_C
    bne checkPaste
    jsr processCopyLine
    jmp refreshTrackerScreen

    checkPaste
    cpx #KEY_V
    bne checkS
    jsr processPasteLine
    jmp refreshTrackerScreen

    checkS
    cpx #KEY_S
    bne checkF
    jsr slowDown
    jmp refreshTrackerScreen

    checkF
    cpx #KEY_F
    bne checkD
    jsr speedUp
    jmp refreshTrackerScreen

    checkD
    cpx #KEY_D
    bne checkOne
    jsr deleteLine
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
    bne checkZ
    lda #112
    sta _first_visible_tracker_step_line
    lda #07
    sta _tracker_bar_index 
    jmp refreshTrackerScreen

    checkZ
    cpx #KEY_Z
    bne checkX
    jsr processCopyNote
    jmp refreshTrackerScreen

    checkX
    cpx #KEY_X
    bne checkA
    jsr processPasteNote
    jmp refreshTrackerScreen    

    checkA
    cpx #KEY_A
    bne checkL
    jsr clearTrackerInterupt
    jsr clearSound// Silence    
    jsr copyMusicToSaveBuffer // copy data from music buffer to save buffer    
    LDA #01// STORE value to indicate run save
    STA $8FFF    
    rts
    // FROM BASIC
    // save data
    // resume tracker interupt
    
    checkL
    cpx #KEY_L
    bne checkB
    jsr clearTrackerInterupt
    jsr clearSound
    
    LDA #02// STORE value to tell BASIC to run load
    STA $8FFF
    RTS
    // FROM BASIC -- peform load thebn copy load buffer to music
    // restore tracker interrupt

    checkB
    cpx #KEY_B
    bne checkN
    jsr processCopyBar
    jmp loopAgain


    checkN
    cpx #KEY_N
    bne checkP
    jsr processPasteBar
    jmp refreshTrackerScreen

    checkP
    cpx #KEY_P
    bne checkT
    jsr clearTrackerInterupt
    jsr clearSound
    
    LDA #03// STORE value to tell BASIC to print data
    STA $8FFF
    RTS

    checkT
    cpx #KEY_T
    bne checkM
    jsr toggleShortNote
    jmp refreshTrackerScreen


    checkM
    cpx #KEY_M
    bne loopAgain
    jsr toggleSongBarMode

    :loopAgain
    jmp readAgain
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; speedUp: 
;   reduce the interval between steps to speed up playback
; ------------------------------------------------------------------------------   
speedUp
.(
    lda _tracker_step_length
    clc
    cmp #05
    bne increaseSpeed
    rts

    increaseSpeed
    dec _tracker_step_length
    lda _tracker_step_length
    lsr
    sta _tracker_step_half_length;
    rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; slowDown: 
;   increase the interval between steps to slow down playback
; ------------------------------------------------------------------------------  
slowDown
.(
    lda _tracker_step_length
    cmp #20
    bpl done
    inc _tracker_step_length
    lda _tracker_step_length
    lsr
    sta _tracker_step_half_length;

    :done
    rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; processCopyLine: 
;   copy the selected line of notes into a buffer
; ------------------------------------------------------------------------------ 
processCopyLine
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
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; processPasteBuffer: 
;   paste the copy line buffer into the currently selected line
; ------------------------------------------------------------------------------ 
processPasteLine
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
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; deleteLine: 
;   delete all notes in the currently selected line
; ------------------------------------------------------------------------------ 
deleteLine
.(
    clc
    lda _tracker_selected_row_index
    adc _first_visible_tracker_step_line
    tay
    lda trackerMusicDataLo,Y
    sta deleteLoop+1
    lda trackerMusicDataHi,y
    sta deleteLoop+2
    clc
    ldy #00
    lda #00
    :deleteLoop
    sta $ffff,Y
    iny
    cpy #06
    bne deleteLoop
    rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; toggleShortNote: 
;   toggle the length of the currently selected note
; ------------------------------------------------------------------------------ 
toggleShortNote
.(
    clc
    lda _tracker_selected_row_index
    adc _first_visible_tracker_step_line
    tay
    lda trackerMusicDataLo,Y
    sta _copy_note_lo
    lda trackerMusicDataHi,y
    sta _copy_note_hi

    lda _tracker_selected_col_index
    cmp #TRACKER_COL_INDEX_NOTE_CH1
    bne nextCheck0

    jmp toggleLengthNote1
    nextCheck0
        cmp #TRACKER_COL_INDEX_OCT_CH1
        bne nextCheck2
        jmp toggleLengthNote1
    nextCheck2
        cmp #TRACKER_COL_INDEX_VOL_CH1
        bne nextCheck3
        jmp toggleLengthNote1
    nextCheck3
        cmp #TRACKER_COL_INDEX_NOTE_CH2
        bne nextCheck4
        jmp toggleLengthNote2
    nextCheck4    
        cmp #TRACKER_COL_INDEX_OCT_CH2
        bne nextCheck6
        jmp toggleLengthNote2
    nextCheck6
        cmp #TRACKER_COL_INDEX_VOL_CH2
        bne nextCheck7
        jmp toggleLengthNote2
    nextCheck7
        cmp  #TRACKER_COL_INDEX_NOTE_CH3
        bne nextCheck8
        jmp toggleLengthNote3
    nextCheck8
        cmp #TRACKER_COL_INDEX_OCT_CH3
        bne nextCheck9
        jmp toggleLengthNote3
    nextCheck9  
        cmp #TRACKER_COL_INDEX_VOL_CH3
        bne done
        jmp toggleLengthNote3
    done
    rts

    :toggleLengthNote1
    .(
        ldy #01
        jmp toggleNoteLength
    .)

    :toggleLengthNote2
    .(
        ldy #03
        jmp toggleNoteLength
    .)

    :toggleLengthNote3
    .(
        ldy #05
        jmp toggleNoteLength
    .)

    :toggleNoteLength
    .(
        lda (_copy_note),Y
        eor #$80
        sta (_copy_note),Y
    .)
.)

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; processCopyNote: 
;   copy the currently selected note
; ------------------------------------------------------------------------------ 
processCopyNote
.(
    clc
    lda _tracker_selected_row_index
    adc _first_visible_tracker_step_line
    tay
    lda trackerMusicDataLo,Y
    sta _copy_note_lo
    lda trackerMusicDataHi,y
    sta _copy_note_hi

    lda _tracker_selected_col_index
    cmp #TRACKER_COL_INDEX_NOTE_CH1
    bne nextCheck0

    ldy #0
    lda (_copy_note),Y
    sta trackerNoteCopyByte1
    iny 
    lda (_copy_note),Y
    sta trackerNoteCopyByte2

    rts
    nextCheck0
        cmp #TRACKER_COL_INDEX_OCT_CH1
        bne nextCheck2
        ldy #0
        lda (_copy_note),Y
        sta trackerNoteCopyByte1
        iny 
        lda (_copy_note),Y
        sta trackerNoteCopyByte2
            
        rts



    nextCheck2
        cmp #TRACKER_COL_INDEX_VOL_CH1
        bne nextCheck3
        ldy #0
        lda (_copy_note),Y
        sta trackerNoteCopyByte1
        iny 
        lda (_copy_note),Y
        sta trackerNoteCopyByte2

        rts



    nextCheck3
        cmp #TRACKER_COL_INDEX_NOTE_CH2
        bne nextCheck4

        ldy #2
        lda (_copy_note),Y
        sta trackerNoteCopyByte1
        iny 
        lda (_copy_note),Y
        sta trackerNoteCopyByte2


        rts

    nextCheck4    
        cmp #TRACKER_COL_INDEX_OCT_CH2
        bne nextCheck6

        ldy #2
        lda (_copy_note),Y
        sta trackerNoteCopyByte1
        iny 
        lda (_copy_note),Y
        sta trackerNoteCopyByte2

        rts



    nextCheck6
        cmp #TRACKER_COL_INDEX_VOL_CH2
        bne nextCheck7

        ldy #2
        lda (_copy_note),Y
        sta trackerNoteCopyByte1
        iny 
        lda (_copy_note),Y
        sta trackerNoteCopyByte2


        rts

    nextCheck7
        cmp  #TRACKER_COL_INDEX_NOTE_CH3
        bne nextCheck8

        ldy #4
        lda (_copy_note),Y
        sta trackerNoteCopyByte1
        iny 
        lda (_copy_note),Y
        sta trackerNoteCopyByte2

        rts

    nextCheck8
        cmp #TRACKER_COL_INDEX_OCT_CH3
        bne nextCheck9

        ldy #4
        lda (_copy_note),Y
        sta trackerNoteCopyByte1
        iny 
        lda (_copy_note),Y
        sta trackerNoteCopyByte2


        rts

    nextCheck9  
        cmp #TRACKER_COL_INDEX_VOL_CH3
        bne done

        ldy #4
        lda (_copy_note),Y
        sta trackerNoteCopyByte1
        iny 
        lda (_copy_note),Y
        sta trackerNoteCopyByte2

        rts

    done
    rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; processPasteNote: 
;   paste the copy buffer over the currently selected note
; ------------------------------------------------------------------------------ 
processPasteNote
.(
    clc
    lda _tracker_selected_row_index
    adc _first_visible_tracker_step_line
    tay
    lda trackerMusicDataLo,Y
    sta _copy_note_lo
    lda trackerMusicDataHi,y
    sta _copy_note_hi

    lda _tracker_selected_col_index
    cmp #TRACKER_COL_INDEX_NOTE_CH1
    bne nextCheck0

    ldy #0
    lda trackerNoteCopyByte1
    sta (_copy_note),Y
    iny 
    lda trackerNoteCopyByte2
    sta (_copy_note),Y

    rts
    nextCheck0
        cmp #TRACKER_COL_INDEX_OCT_CH1
        bne nextCheck2
        ldy #0
        lda trackerNoteCopyByte1
        sta (_copy_note),Y
        iny 
        lda trackerNoteCopyByte2
        sta (_copy_note),Y
            
        rts



    nextCheck2
        cmp #TRACKER_COL_INDEX_VOL_CH1
        bne nextCheck3
        ldy #0
        lda trackerNoteCopyByte1
        sta (_copy_note),Y
        iny 
        lda trackerNoteCopyByte2
        sta (_copy_note),Y

        rts



    nextCheck3
        cmp #TRACKER_COL_INDEX_NOTE_CH2
        bne nextCheck4

        ldy #2
        lda trackerNoteCopyByte1
        sta (_copy_note),Y
        iny 
        lda trackerNoteCopyByte2
        sta (_copy_note),Y


        rts

    nextCheck4    
        cmp #TRACKER_COL_INDEX_OCT_CH2
        bne nextCheck6

        ldy #2
        lda trackerNoteCopyByte1
        sta (_copy_note),Y
        iny 
        lda trackerNoteCopyByte2
        sta (_copy_note),Y

        rts



    nextCheck6
        cmp #TRACKER_COL_INDEX_VOL_CH2
        bne nextCheck7

        ldy #2
        lda trackerNoteCopyByte1
        sta (_copy_note),Y
        iny 
        lda trackerNoteCopyByte2
        sta (_copy_note),Y


        rts

    nextCheck7
        cmp  #TRACKER_COL_INDEX_NOTE_CH3
        bne nextCheck8

        ldy #4
        lda trackerNoteCopyByte1
        sta (_copy_note),Y
        iny 
        lda trackerNoteCopyByte2
        sta (_copy_note),Y

        rts

    nextCheck8
        cmp #TRACKER_COL_INDEX_OCT_CH3
        bne nextCheck9

        ldy #4
        lda trackerNoteCopyByte1
        sta (_copy_note),Y
        iny 
        lda trackerNoteCopyByte2
        sta (_copy_note),Y


        rts

    nextCheck9  
        cmp #TRACKER_COL_INDEX_VOL_CH3
        bne done

        ldy #4
        lda trackerNoteCopyByte1
        sta (_copy_note),Y
        iny 
        lda trackerNoteCopyByte2
        sta (_copy_note),Y

        rts

    done
    rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




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
        tax
        and #$F0
        sta _hi_nibble
        txa
        and #$0f   
        clc
        cmp #15
        bcc incrementVolChannel1
        jmp done

        incrementVolChannel1 // Add to vol value channel 1
        clc
        adc #$01
        adc _hi_nibble
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
        tax
        and #$F0
        sta _hi_nibble
        txa
        and #$0f   
        clc
        cmp #15
        bcc incrementVolChannel2
        jmp done

        incrementVolChannel2 // Add to vol value channel 2
        clc
        adc #$01
        adc _hi_nibble
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
        bne nextCheck10
        ldy #5
        lda (_copy_mem_src),y
        tax
        and #$F0
        sta _hi_nibble
        txa
        and #$0f   
        clc
        cmp #15
        bcc incrementVolChannel3
        jmp done

        incrementVolChannel3 // Add to vol value channel 3
        clc
        adc #$01
        adc _hi_nibble
        sta (_copy_mem_src),y
        rts

    nextCheck10
        cmp #TRACKER_COL_INDEX_NOISE_CH3
        bne done
        ldy #5
        lda (_copy_mem_src),Y
        and #$8f;  bitmask 0b10001111
        sta _music_data_temp; store the result of the above bitmask (needed later to xor the result)
        lda (_copy_mem_src),Y
        and #$70 ; mask the 3 bits we're interested in
        lsr
        lsr
        lsr
        lsr 
        and #07
        sta _lo_nibble
        clc
        cmp #7
        bcc incrementNoiseValue
        jmp done

        incrementNoiseValue
        clc
        adc #01
        asl
        asl
        asl
        asl
        adc _music_data_temp
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
        tax
        and #$F0
        sta _hi_nibble
        txa
        and #$0f
        sta _lo_nibble

        clc
        cmp #1
        bne decrementVolChannel1
        jmp done

        decrementVolChannel1 // Subtract from volume channel 1
        clc
        sbc #01
        adc _hi_nibble
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

        ldy #03
        lda (_copy_mem_src),y
        tax
        and #$F0
        sta _hi_nibble
        txa
        and #$0f
        sta _lo_nibble

        clc
        cmp #1
        bne decrementVolChannel2
        jmp done

        decrementVolChannel2 // Subtract from volume channel 2
        clc
        sbc #01
        adc _hi_nibble
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
        bne nextCheck10

        ldy #5
        lda (_copy_mem_src),y
        tax
        and #$F0
        sta _hi_nibble
        txa
        and #$0f
        sta _lo_nibble

        clc
        cmp #1
        bne decrementVolChannel3
        jmp done

        decrementVolChannel3 // Subtract from volume channel 3
        clc
        sbc #01
        adc _hi_nibble
        sta (_copy_mem_src),y
        rts

    nextCheck10
        cmp #TRACKER_COL_INDEX_NOISE_CH3
        bne done
        ldy #5
        lda (_copy_mem_src),Y
        and #$8f;  bitmask 0b10001111
        sta _music_data_temp; store the result of the above bitmask (needed later to xor the result)
        lda (_copy_mem_src),Y
        and #$70 ; mask the 3 bits we're interested in
        lsr
        lsr
        lsr
        lsr 
        and #07
        sta _lo_nibble
        clc
        cmp #1
        bne decrementNoiseValue
        jmp done


        decrementNoiseValue
        sec
        sbc #01
        asl
        asl
        asl
        asl
        clc
        adc _music_data_temp
        sta (_copy_mem_src),y
        rts 

    done
    rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; processDeleteNote: 
;   handle the delete key being pressed to delete the currently selected note
; ------------------------------------------------------------------------------  
processDeleteNote
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
        bne nextCheck10

        ldy #4
        lda #0
        sta (_copy_mem_src),y
        rts     
    nextCheck10
        cmp #TRACKER_COL_INDEX_NOISE_CH3
        bne done
        ldy #5
        lda (_copy_mem_src),Y
        and #$8F
        sta (_copy_mem_src),y

    done
        rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; processCopyBar: 
;   copy all the notes for the current line into a buffer
; ------------------------------------------------------------------------------  
processCopyBar
.(
    ldy _first_visible_tracker_step_line

    lda trackerMusicDataLo,Y
    sta copyLoop+1
    lda trackerMusicDataHi,y
    sta copyLoop+2
    
    clc
    ldy #00
   :copyLoop
    lda $ffff,Y
    sta barCopyBuffer,Y
    iny
    cpy #96
    bne copyLoop 
    rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; processPasteBar: 
;   paste over all the notes in the current bar from a copy buffer
; ------------------------------------------------------------------------------ 
processPasteBar
.(
    LDY _first_visible_tracker_step_line
    lda trackerMusicDataLo,Y
    sta pasteLoop+4
    lda trackerMusicDataHi,y
    sta pasteLoop+5
    clc
    ldy #00
    :pasteLoop
    lda barCopyBuffer,Y
    sta $ffff,Y
    iny
    cpy #96
    bne pasteLoop
    rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; copyMusicToSaveBuffer: 
;   copy all the data from all notes, in all bars, to a seperate location
;   so that we can save the data.
; ------------------------------------------------------------------------------ 
copyMusicToSaveBuffer
.(
    lda #<trackerMusicData
    sta _copy_mem_src_lo
    lda #>trackerMusicData
    sta _copy_mem_src_hi
    lda #$00
    sta _copy_mem_dest_lo
    lda #$90
    sta _copy_mem_dest_hi
    lda #$00
    sta _copy_mem_count_lo
    lda #$03
    sta _copy_mem_count_hi
    jsr CopyMemory
    rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; copyMusicFromLoadBuffer: 
;   copy the data, as loaded into memory, from the load buffer into the actual
;   area used by the tracker.
; ------------------------------------------------------------------------------ 
copyMusicFromLoadBuffer
.(
    lda #$00
    sta _copy_mem_src_lo
    lda #$90
    sta _copy_mem_src_hi
    lda #<trackerMusicData
    sta _copy_mem_dest_lo
    lda #>trackerMusicData
    sta _copy_mem_dest_hi
    lda #$00
    sta _copy_mem_count_lo
    lda #$03
    sta _copy_mem_count_hi
    jsr CopyMemory
    rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; toggleSongBarMode: 
;   toggle between song and bar mode
; ------------------------------------------------------------------------------
toggleSongBarMode 
.(
    lda _tracker_play_mode
    cmp #TRACKER_PLAY_MODE_SONG
    beq toggleToBarMode
    lda #TRACKER_PLAY_MODE_SONG
    sta _tracker_play_mode
    rts
    toggleToBarMode
    lda #TRACKER_PLAY_MODE_BAR
    sta _tracker_play_mode
    rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 