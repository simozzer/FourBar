// implementation of 'MUSIC' and 'SOUND' without need to call ROM
// basically just a trimmed down copy of the Atmos ROM routines,
// with the validation removed (for speed).


independentSound
    LDA $02E1 ;SOUND
    CMP #$01 ;Branch if tone channel A is     
    BNE channelANotUsed ;not being used. 
    LDA #$00 ;Write the tone period for 
    LDX $02E3 ;channel A to the sound chip
    JSR $F590 ;Write low byte of period. 
    LDA #$01 
    LDX $02E4 
    JSR $F590 ;Write high byte of period. 
    loadAmplitudeChannelA; $FB57 
    LDA $02E5 ;Load amplitude and keep it in 
    AND #$0F ;the range 0-15. If amplitude 
    BNE useChannelAEnvelope ;is zero then use envelope 
    LDX #$10 ;control. 
    BNE skipChannelAEnvelope;$FB63
    useChannelAEnvelope 
    TAX 
    skipChannelAEnvelope
    LDA #$08     
    JSR $F590 
    RTS     
    channelANotUsed
    CMP #$02 ;Branch if tone channel B is 
    BNE channelBNotUsed ;not being used. 
    LDA #$02 
    LDX $02E3 ;Write low byte of tone period 
    JSR $F590 ;to the sound chip. 
    LDA #$03 
    LDX $02E4 ;Write high byte of tone period 
    JSR $F590 ;to the sound chip. 
    loadAmplitudeChannelB; FB7D
    LDA $02E5 ;Load and set amplitude in 
    AND #$0F ;range 0-15. 
    BNE useChannelBEnvelope; $FB88 
    LDX #$10 ;If amplitude is zero then use 
    BNE skipChannelBEnvelope; $FB89 
    useChannelBEnvelope;FB88 AA 
    TAX 
    skipChannelBEnvelope;FB89 A9 09 
    LDA #$09 
    JSR $F590 
    RTS 
    channelBNotUsed;FB8F C9 03 
    CMP #$03 ;Branch if tone channel C is 
    BNE channelCNotUsed; $FBB5 ;not being used. 
    LDA #$04 
    LDX $02E3 ;Write low byte of tone period 
    JSR $F590 ;to the sound chip. 
    LDA #$05 
    LDX $02E4 ;Write high byte of tone period 
    JSR $F590 ;to the sound chip. 
    loadAmplitudeChannelC; FBA3
    LDA $02E5 ;Load and set the amplitude in 
    AND #$0F ;the range 0-15.
    BNE useChannelCEnvelope; $FBAE 
    LDX #$10 ;If amplitude is zero then use 
    BNE skipChannelCEnvelope; $FBAF ;envelope control. 
    useChannelCEnvelope;FBAE AA 
    TAX 
    skipChannelCEnvelope ;FBAF A9 0A 
    LDA #$0A 
    JSR $F590 
    RTS 
    channelCNotUsed;FBB5 A9 06 
    LDA #$06 ;This routine sets up the noise 
    LDX $02E3 ;period to be used. 
    JSR $F590 ;Sound channels 4, 5 & 6 
    LDA $02E1 ;produce noise on tone channels 
    CMP #$04 ;A, B & C respectively. 
    BEQ loadAmplitudeChannelA; $FB57 
    CMP #$05 
    BEQ loadAmplitudeChannelB; $FB7D 
    CMP #$06 
    BEQ loadAmplitudeChannelC; $FBA3 ;An error is produced if the 
    INC $02E0 ;sound channels are not in 
    RTS ;correct range. 



// MUSIC SIMPLIFIED
independentMusic
.(
    LDY $02E3 ;Use the octave and note 
    LDX $02E5 ;values to look up the tone 
    LDA TonePeriodLookup1,X ;periods in the table below. 
    STA $02E4 
    LDA TonePeriodLookup2,X 
    STA $02E3 
    LDA $02E7 
    STA $02E5 
    :decY
    DEY 
    BMI jumpToSound 
    LSR $02E4 
    ROR $02E3 
    JMP decY
jumpToSound
    JMP independentSound ;Goto Sound command. 
    INC $02E0 
    RTS 
.)

TonePeriodLookup1
//FC5E
    .byt $00,$07,$07,$06,$06,$05,$05,$05 ;Data for the Music command. 
//FC66 
    .byt $04,$04
TonePeriodLookup2
//FC68
    .byt $04,$04,$03,$00,$77,$0B ; Converts the notes into tone 
//FC6E 
    .byt $A6,$47,$EC,$97,$47,$FB,$B3,$70 ; periods. 