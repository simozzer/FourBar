notesToDisplay
.byt "   CC# DD# E FF# GG# AA# B"

numbersToDisplay
.byt " 0 1 2 3 4 5 6 7 8 9101112131415"


trackerScreenData
.byt PAPER_WHITE, INK_BLACK,  " BAR:1                                "
.byt PAPER_WHITE, INK_BLACK,  " CHANNEL 1   CHANNEL 2   CHANNEL 3    "
.byt PAPER_WHITE, INK_BLACK,  " NOT OCT VOL NOT OCT VOL NOT OCT VOL N"
.byt PAPER_BLACK, INK_GREEN,  "                                      "
.byt PAPER_BLACK, INK_BLUE,   "                                      "
.byt PAPER_BLACK, INK_BLUE,   "                                      "
.byt PAPER_BLACK, INK_BLUE,   "                                      "
.byt PAPER_BLACK, INK_GREEN,  "                                      "
.byt PAPER_BLACK, INK_BLUE,   "                                      "
.byt PAPER_BLACK, INK_BLUE,   "                                      "
.byt PAPER_BLACK, INK_BLUE,   "                                      "
.byt PAPER_BLACK, INK_GREEN,  "                                      "
.byt PAPER_BLACK, INK_BLUE,   "                                      "
.byt PAPER_BLACK, INK_BLUE,   "                                      "
.byt PAPER_BLACK, INK_BLUE,   "                                      "
.byt PAPER_BLACK, INK_GREEN,  "                                      "
.byt PAPER_BLACK, INK_BLUE,   "                                      "
.byt PAPER_BLACK, INK_BLUE,   "                                      "
.byt PAPER_BLACK, INK_BLUE,   "                                      "
.byt PAPER_WHITE, INK_BLUE,   "+/- Change value. (S)lower, (Faster)  "
.byt PAPER_WHITE, INK_BLUE,   "Select Bar: 1,2,3,4,5,6,7,8.          "
.byt PAPER_WHITE, INK_BLUE,   "Line: (C)opy, V Paste, (D)elete.      "
.byt PAPER_WHITE, INK_BLUE,   "Note: Z Copy, X Paste, (Del)ete.      "
.byt PAPER_WHITE, INK_BLUE,   "Bar: B Copy, N Paste.                 "
.byt PAPER_WHITE, INK_BLUE,   "File: (L)oad s(A)ve (Q)uit.           "
.byt PAPER_WHITE, INK_BLUE,   "Other: (T)oggle length.               "
.byt PAPER_WHITE, INK_BLUE,   "                                      "

trackerScreenDataLo
    .byt <trackerScreenData + 0,<trackerScreenData + 40,<trackerScreenData + 80,<trackerScreenData + 120,<trackerScreenData + 160
    .byt <trackerScreenData + 200,<trackerScreenData + 240,<trackerScreenData + 280,<trackerScreenData + 320,<trackerScreenData + 360
    .byt <trackerScreenData + 400,<trackerScreenData + 440,<trackerScreenData + 480,<trackerScreenData + 520,<trackerScreenData + 560
    .byt <trackerScreenData + 600,<trackerScreenData + 640,<trackerScreenData + 680,<trackerScreenData + 720,<trackerScreenData + 760
    .byt <trackerScreenData + 800,<trackerScreenData + 840,<trackerScreenData + 880,<trackerScreenData + 920,<trackerScreenData + 960
    .byt <trackerScreenData + 1000,<trackerScreenData + 1040,<trackerScreenData + 1080


trackerScreenDataHi
    .byt >trackerScreenData + 0,>trackerScreenData + 40,>trackerScreenData + 80,>trackerScreenData + 120,>trackerScreenData + 160
    .byt >trackerScreenData + 200,>trackerScreenData + 240,>trackerScreenData + 280,>trackerScreenData + 320,>trackerScreenData + 360
    .byt >trackerScreenData + 400,>trackerScreenData + 440,>trackerScreenData + 480,>trackerScreenData + 520,>trackerScreenData + 560
    .byt >trackerScreenData + 600,>trackerScreenData + 640,>trackerScreenData + 680,>trackerScreenData + 720,>trackerScreenData + 760
    .byt >trackerScreenData + 800,>trackerScreenData + 840,>trackerScreenData + 880,>trackerScreenData + 920,>trackerScreenData + 960
    .byt >trackerScreenData + 1000,>trackerScreenData + 1040,>trackerScreenData + 1080

trackerCopyBuffer
.byt $00,$00,$00,$00,$00,$00

barCopyBuffer
.dsb 96,00

trackerNoteCopyByte1 .byt $00
trackerNoteCopyByte2 .byt $00

copyNoteDataLo .byt 00
copyNoteDataHi .byt 00

trackerAttributeColumns
.byt 3,7,10,15,19,22,27,31,34,37

zeroPageCopyBuffer
.dsb $ff, 00

variablesCopyBuffer
.dsb $ff, 00

