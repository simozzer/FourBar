StartProg
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Main program
; ------------------------------------------------------------------------------
    
    jsr copyZeroPage
    jsr copyRuntimeVariables
    ;// NOKEYCLICK+SCREEN no cursor
	lda #8+2	
	sta $26a


    ;// TEST SOUND
    lda #TRACKER_PLAY_MODE_BAR
    sta _tracker_play_mode
    lda #16
    sta _tracker_last_step
    lda #0
    sta _tracker_bar_index
    sta _tracker_bar_step_index

    jsr clearSound
    jsr setupTrackerInterrupt
    jsr runTracker;
    jsr restoreRuntimeVariables
    jsr restoreZeroPage 
    rts
    ;// END TEST SOUND




