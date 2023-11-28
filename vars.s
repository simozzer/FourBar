    .zero

    *= $50

_zp_start_

_plot_ch_x .dsb 1
_plot_ch_y .dsb 1
_plot_ascii .dsb 1
_line_start
_line_start_lo .dsb 1
_line_start_hi .dsb 1

_copy_mem_src
_copy_mem_src_lo .dsb 1
_copy_mem_src_hi .dsb 1
_copy_mem_dest
_copy_mem_dest_lo .dsb 1
_copy_mem_dest_hi .dsb 1
_copy_mem_count
_copy_mem_count_lo .dsb 1
_copy_mem_count_hi .dsb 1


_player_animation_index .dsb 1

_line_no .dsb 1

_gKey .dsb 1

_music_octave .dsb 1
_music_note .dsb 1
_music_len .dsb 1
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

_tracker_next_start .dsb 1
_tracker_next_stop .dsb 1
_tracker_bar_index .dsb 1

_tracker_selected_col_index .dsb 1
_tracker_selected_row_index .dsb 1

_hi_nibble .dsb 1
_lo_nibble .dsb 1

_last_key .dsb 1

_tracker_step_index .dsb 1
_tracker_step_cycles_remaining .dsb 1
_tracker_step_length .dsb 1

_tracker_playback_addr
_tracker_playback_addr_lo .dsb 1
_tracker_playback_addr_hi .dsb 1

_tracker_temp_byte .dsb 1

_playback_music_info_byte_addr
_playback_music_info_byte_lo .dsb 1
_playback_music_info_byte_hi .dsb 1



_zp_end_

// Part of code copied from Kong, which was supplied with the OSDK
rand_low		.dsb 1		;// Random number generator, low part
rand_high		.dsb 1		;// Random number generator, high part
b_tmp1          .dsb 1

.text