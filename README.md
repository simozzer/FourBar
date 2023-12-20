# FourBar
A basic tracker program for the Oric computer, with the final aim being to provide background music in programs.

(A work in progress)

The idea, intially, is to provide a live editor/sequencer for a user to create 8 bars of music using 3 channels.

Work completed:
===============

Each bar of music will loop until the next bar is triggered. 

The user can trigger the next bar by pressing the numeric keys (1-8).

The next bar will be started when the current bar reaches the last note.

The data for the bars can be saved to, and re-loaded from a .TAP File.

Instructions for using the program are displayed in the editor screen.

TO DO:
======
Add a simple bar sequencer to allow building of a tune by providing a list of bar numbers to be triggered in sequence.

Add ability to save these sequences together with the bar data.

Simplify the playback loop in tracker_interrupt.s and modularise is so that it can be re-used in other people's programs.

Refactor the code. 

Improve comments.

Look for optimizations.

Reduce number of zero page variables.


Download:
=========
The latest working version of the program is available in the [build section)(/BUILD) as FOURBAR.TAP.


I've decided to try use a mix of basic an assembler for this, as it will simplify the code (particularly the load & save routines).





