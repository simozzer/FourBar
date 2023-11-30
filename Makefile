#NO_LIB=1

SRC=vars.s define.s main.s utils.s rom_independent_sound.s fourbar.s tracker_display.s tracker_interrupt.s tracker_data.s messages.s lookup.s
BIN=scroll
OBJ=$(SRC:.s=.o)

include ../../rules.mk

all: $(SRC) $(BIN)




