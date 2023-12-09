    .zero

    *= $50

_zp_start_

_copy_mem_src
_copy_mem_src_lo .dsb 1
_copy_mem_src_hi .dsb 1
_copy_mem_dest
_copy_mem_dest_lo .dsb 1
_copy_mem_dest_hi .dsb 1
_copy_mem_count
_copy_mem_count_lo .dsb 1
_copy_mem_count_hi .dsb 1

_line_no .dsb 1

_gKey .dsb 1

_music_octave .dsb 1
_music_note .dsb 1
_music_vol .dsb 1
_music_data_temp .dsb 1
_music_info_byte_addr
_music_info_byte_lo .dsb 1
_music_info_byte_hi .dsb 1
_tracker_screen_line .dsb 1
_tracker_step_line .dsb 1
_first_visible_tracker_step_line .dsb 1
_tracker_play_mode .dsb 1
_tracker_last_step .dsb 1

_tracker_bar_index .dsb 1
_tracker_bar_step_index .dsb 1

_tracker_selected_col_index .dsb 1
_tracker_selected_row_index .dsb 1

_hi_nibble .dsb 1
_lo_nibble .dsb 1

_last_key .dsb 1

_tracker_step_index .dsb 1
_tracker_step_cycles_remaining .dsb 1
_tracker_step_length .dsb 1

_playback_music_info_byte_addr
_playback_music_info_byte_lo .dsb 1
_playback_music_info_byte_hi .dsb 1


_copy_note
_copy_note_lo .dsb 1
_copy_note_hi .dsb 1



_zp_end_


.text