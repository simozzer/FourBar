StartProg
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Main program
; ------------------------------------------------------------------------------
    
    ;// NOKEYCLICK+SCREEN no cursor
	lda #8+2	
	sta $26a


    ;// TEST SOUND
    lda #TRACKER_PLAY_MODE_BAR
    sta _tracker_play_mode
    lda #16
    sta _tracker_last_step
    lda #0
    sta _tracker_next_start 
    lda #16
    sta _tracker_next_stop
    lda #0
    sta _tracker_bar_index
    sta _tracker_bar_step_index

    jsr clearSound
    jsr setupTrackerInterrupt
    jsr runTracker; 
    rts
    ;// END TEST SOUND




