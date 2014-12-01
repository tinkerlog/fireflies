# Name: Makefile
# Author: <insert your name here>
# Copyright: <insert your copyright message here>
# License: <insert your license reference here>

# This is a prototype Makefile. Modify it according to your needs.
# You should at least check the settings for
# DEVICE ....... The AVR device you compile for
# CLOCK ........ Target AVR clock rate in Hertz
# OBJECTS ...... The object files created from your source files. This list is
#                usually the same as the list of source files with suffix ".o".
# PROGRAMMER ... Options to avrdude which define the hardware you use for
#                uploading to the AVR and the interface where this hardware
#                is connected.
# FUSES ........ Parameters for avrdude to flash the fuses appropriately.

DEVICE     = attiny13
CLOCK      = 9600000
# PROGRAMMER = -c avr910 -P /dev/tty.SLAB_USBtoUART -C /Users/alex/etc/avrdude.conf
PROGRAMMER = -c usbtiny -v 
OBJECTS    = firefly.o
# Fuses: internal oscilator, no prescale
FUSES      =  -U hfuse:w:0xFF:m -U lfuse:w:0x7A:m

# Tune the lines below only if you know what you are doing:

AVRDUDE = avrdude $(PROGRAMMER) -p $(DEVICE)
OBJDUMP = avr-objdump
COMPILE = avr-gcc -Wall -Os -DF_CPU=$(CLOCK) -mmcu=$(DEVICE)

# symbolic targets:
all:	firefly.hex firefly.lss

.c.o:
	$(COMPILE) -c $< -o $@

.S.o:
	$(COMPILE) -x assembler-with-cpp -c $< -o $@
# "-x assembler-with-cpp" should not be necessary since this is the default
# file type for the .S (with capital S) extension. However, upper case
# characters are not always preserved on Windows. To ensure WinAVR
# compatibility define the file type manually.

.c.s:
	$(COMPILE) -S $< -o $@

flash:	all
	$(AVRDUDE) -U flash:w:firefly.hex:i

fuse:
	$(AVRDUDE) $(FUSES)

# Xcode uses the Makefile targets "", "clean" and "install"
install: flash fuse

# if you use a bootloader, change the command below appropriately:
load: all
	bootloadHID main.hex

clean:
	rm -f firefly.hex firefly.elf $(OBJECTS)

# file targets:
firefly.elf: $(OBJECTS)
	$(COMPILE) -o firefly.elf $(OBJECTS)

firefly.hex: firefly.elf
	rm -f firefly.hex
	avr-objcopy -j .text -j .data -O ihex firefly.elf firefly.hex
# If you have an EEPROM section, you must also create a hex file for the
# EEPROM and add it to the "flash" target.

# Targets for code debugging and analysis:
disasm:	firefly.elf
	avr-objdump -d firefly.elf

%.lss: %.elf
	@echo
	$(OBJDUMP) -h -S $< > $@

cpp:
	$(COMPILE) -E firefly.c
