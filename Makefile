# put your *.o targets here, make should handle the rest!

SRCS = main.c stm32f4xx_it.c system_stm32f4xx.c

# all the files will be generated with this name (main.elf, main.bin, main.hex, etc)

PROJ_NAME=main

CC=arm-none-eabi-gcc
OBJCOPY=arm-none-eabi-objcopy

CFLAGS  = -g3 -O0 -Wall -Tstm32_flash.ld 
CFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m4 -mthumb-interwork
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16

vpath %.c src
vpath %.a lib

ROOT=$(shell pwd)

CFLAGS += -Iinc -Ilib -Ilib/inc 
CFLAGS += -Ilib/inc/core -Ilib/inc/peripherals 

SRCS += lib/startup_stm32f4xx.s # add startup file to build

OBJS = $(SRCS:.c=.o)

OCD	= sudo openocd \
		-f /usr/share/openocd/scripts/board/stm32f4discovery.cfg

BIN=$(PROJ_NAME).elf

###################################################

.PHONY: lib proj

all: lib proj

lib:
	$(MAKE) -C lib

proj: $(BIN)

$(BIN): $(SRCS)
	$(CC) $(CFLAGS) $^ -o $@ -Llib -lstm32f4

clean:
	$(MAKE) -C lib clean
	rm -f $(BIN)

flash: $(BIN)
	$(OCD) -c init \
		-c "reset halt" \
	    -c "flash write_image erase $(BIN)" \
		-c "reset run" \
	    -c shutdown

reset:
	$(OCD) -c init -c "reset run" -c shutdown

