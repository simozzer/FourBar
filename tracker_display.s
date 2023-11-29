

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; printTrackerLineData: 
;   Display the tracker on the screen for a specific line
; ------------------------------------------------------------------------------
printTrackerLineData
.( 
    ldy _tracker_screen_line; plotting of bar data starts at line 4
    lda ScreenLineLookupLo,Y
    sta _copy_mem_dest_lo
    lda ScreenLineLookupHi,y
    sta _copy_mem_dest_hi


    ldy _tracker_step_line ; plotting of data for bar 1 starts at zero
    lda trackerMusicDataLo,Y
    sta _music_info_byte_lo
    lda trackerMusicDataHi,y
    sta _music_info_byte_hi

    // PRINT PART 1 INFO
    ldy #0 ; Load 1st byte of line
    lda (_music_info_byte_addr),y
    cmp #00
    bne printNote1Data

    // printEmptyNote1
    ldy #TRACKER_COL_NOTE_CH_1
    lda #ASCII_SPACE
    clearNoteLoop1
    sta (_copy_mem_dest),Y
    iny
    cpy #19
    bne clearNoteLoop1
    jmp processNote2Data


    printNote1Data
    tax ; make a copy of the value (the lower 4 bits will be used for note)
    ; get Part 1 Octave
    and #$F0
    lsr
    lsr
    lsr 
    lsr
    and #$0F
    sta _music_octave
    ;convert octave to digit and print on screen
    adc #48
    ldy #TRACKER_COL_OCT_CH_1
    sta (_copy_mem_dest),y

    ; get Part 1 Note
    txa
    and #$0F
    sta _music_note
    adc _music_note ;double the value to lookup string
    tax
    ; lookup string for note and display on screen
    lda notesToDisplay,x
    ldy #TRACKER_COL_NOTE_CH_1
    sta (_copy_mem_dest),Y
    inx
    lda notesToDisplay,x
    iny
    sta (_copy_mem_dest),Y
    
    
    ;get Second Music Info Byte
    ldy #01
    lda (_music_info_byte_addr),y ; 
    sta _music_data_temp ; make a copy of the value (the lower 4 bits will be used for volume)

    ;get Part 1 Vol
    and #$0f
    adc _music_data_temp
    tax
    lda numbersToDisplay,x
    ldy #TRACKER_COL_VOL_CH_1
    sta (_copy_mem_dest),Y
    inx
    lda numbersToDisplay,x
    iny
    sta (_copy_mem_dest),Y


    :processNote2Data
    // PRINT PART 2 INFO
    ldy #02 
    lda (_music_info_byte_addr),y
    cmp #00
    bne printNote2Data
    
    ldy #TRACKER_COL_NOTE_CH_2
    lda #ASCII_SPACE
    clearNoteLoop2
    sta (_copy_mem_dest),Y
    iny
    cpy #38
    bne clearNoteLoop2
    jmp processNote3Data

    printNote2Data
    tax ; make a copy of the value (the lower 4 bits will be used for note)
    txa

    ; get Part 2 Octave
    and #$F0
    lsr
    lsr
    lsr 
    lsr
    and #$0F
    sta _music_octave
    ;convert octave to digit and print on screen
    adc #48
    ldy #TRACKER_COL_OCT_CH_2
    sta (_copy_mem_dest),y

    ; get Part 2 Note
    txa
    and #$0F
    sta _music_note
    adc _music_note ;double the value to lookup string
    tax
    ; lookup string for note and display on screen
    lda notesToDisplay,x
    ldy #TRACKER_COL_NOTE_CH_2
    sta (_copy_mem_dest),Y
    inx
    lda notesToDisplay,x
    iny
    sta (_copy_mem_dest),Y

    ldy #03
    ;get Second Music Info Byte
    lda (_music_info_byte_addr),y ; 
    sta _music_data_temp ; make a copy of the value (the lower 4 bits will be used for volume)

    ;get Part 2 Vol
    and #$0f  
    adc _music_data_temp
    tax
    lda numbersToDisplay,x
    ldy #TRACKER_COL_VOL_CH_2
    sta (_copy_mem_dest),Y
    inx
    lda numbersToDisplay,x
    iny
    sta (_copy_mem_dest),Y


    :processNote3Data
    // PRINT PART 3 INFO
    ldy #04 
    lda (_music_info_byte_addr),y
    cmp #00
    bne printNote3Data
    
    ldy #TRACKER_COL_NOTE_CH_3
    lda #ASCII_SPACE
    clearNoteLoop3
    sta (_copy_mem_dest),Y
    iny
    cpy #38
    bne clearNoteLoop3
    rts

    printNote3Data
    tax ; make a copy of the value (the lower 4 bits will be used for note)
    txa

    ; get Part 3 Octave
    and #$F0
    lsr
    lsr
    lsr 
    lsr
    and #$0F
    sta _music_octave
    ;convert octave to digit and print on screen
    adc #48
    ldy #TRACKER_COL_OCT_CH_3
    sta (_copy_mem_dest),y

    ; get Part 2 Note
    txa
    and #$0F
    sta _music_note
    adc _music_note ;double the value to lookup string
    tax
    ; lookup string for note and display on screen
    lda notesToDisplay,x
    ldy #TRACKER_COL_NOTE_CH_3
    sta (_copy_mem_dest),Y
    inx
    lda notesToDisplay,x
    iny
    sta (_copy_mem_dest),Y

    ldy #05
    ;get Second Music Info Byte
    lda (_music_info_byte_addr),y ; 
    sta _music_data_temp ; make a copy of the value (the lower 4 bits will be used for volume)

    ;get Part 3 Vol
    and #$0f  
    adc _music_data_temp
    tax
    lda numbersToDisplay,x
    ldy #TRACKER_COL_VOL_CH_3
    sta (_copy_mem_dest),Y
    inx
    lda numbersToDisplay,x
    iny
    sta (_copy_mem_dest),Y



    rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  




; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; printTrackerInstructions: 
;   Print some instructions in the status line at the top of the screen
; ------------------------------------------------------------------------------
printTrackerInstructions
    lda #<TrackerInstructions
    sta loadMessageLoop+1
    lda #>TrackerInstructions
    sta loadMessageLoop+2
    jsr printStatusMessage
    rts
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; printTrackerScreen: 
;   Display the tracker on the screen for the current selected bar
; ------------------------------------------------------------------------------
printTrackerScreen
.(    
    ldy #0
    sty _line_no
    loopy
    lda ScreenLineLookupLo,Y
    sta _copy_mem_dest_lo
    lda ScreenLineLookupHi,y
    sta _copy_mem_dest_hi
    lda trackerScreenDataLo,y
    sta _copy_mem_src_lo
    lda trackerScreenDataHi,Y
    sta _copy_mem_src_hi

    lda _tracker_bar_index
    adc #48
    sta $BBAF

    ldy #0
    loopx
    lda (_copy_mem_src),y
    sta (_copy_mem_dest),y
    iny
    cpy #40
    bne loopx
    ldy _line_no

    iny
    sty _line_no
    cpy #27
    bne loopy

    lda #03
    sta _tracker_screen_line
    lda _first_visible_tracker_step_line
    sta _tracker_step_line
    
    :printMusicLoop
    jsr printTrackerLineData

    ldy _tracker_screen_line
    iny
    cpy #19
    beq screenPlotted
    inc _tracker_screen_line
    inc _tracker_step_line
    jmp printMusicLoop

    screenPlotted 
    // Highlight selected cell
    lda _tracker_selected_row_index
    adc #2
    tay 
    lda ScreenLineLookupLo,Y
    sta _copy_mem_dest_lo
    lda ScreenLineLookupHi,y
    sta _copy_mem_dest_hi
    ldy _tracker_selected_col_index
    lda trackerAttributeColumns,y
    tay
    lda #PAPER_WHITE
    sta (_copy_mem_dest),Y
    lda #PAPER_BLACK
    iny 
    iny 
    iny
    sta (_copy_mem_dest),Y
    
    rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  



