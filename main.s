rts

StartProg
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Main program
; ------------------------------------------------------------------------------
    :start
    
    // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    // I'm not sure if this is needed but I've included it to try and work around problems i've
    // had with loading and saving data
    sei
    jsr copyZeroPage
    jsr copyRuntimeVariables
    cli
    // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    ;// NOKEYCLICK+SCREEN no cursor
	lda #8+2	
	sta $26a


    ;// Initialize data for the tracker
    lda #TRACKER_PLAY_MODE_BAR
    sta _tracker_play_mode
    lda #16
    sta _tracker_last_step
    lda #0
    sta _tracker_bar_index
    sta _tracker_bar_step_index
    jsr clearSound

    ;// Setup song sequence
    lda #0
    sta barSequenceData
    sta _tracker_song_bar_lookup_index;
    lda #01
    sta barSequenceData+1
    lda #02
    sta barSequenceData+2
    lda #03
    sta barSequenceData+3
    lda #04
    sta barSequenceData+4
    lda #05
    sta barSequenceData+5
    lda #06
    sta barSequenceData+6
    lda #07
    sta barSequenceData+7
    lda #$ff
    sta barSequenceData+8

    ; setup interrupt for playing back music
    jsr setupTrackerInterrupt

    ; launch the editor
    jsr runTracker;
    
    

    // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    // I'm not sure if this is needed but I've included it to try and work around problems i've
    // had with loading and saving data
    sei
    jsr restoreRuntimeVariables;
    jsr restoreZeroPage;
    cli
    // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


    rts
    ;// END TEST SOUND




