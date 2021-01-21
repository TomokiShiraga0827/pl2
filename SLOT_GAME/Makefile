AS = arm-none-eabi-as
LD = arm-none-eabi-ld 
LDFLAGS = -m armelf
OBJCP = arm-none-eabi-objcopy
OBJCPFLAGS = -O binary

.PHONY: clean

all: slot

%.o: %.s
	$(AS) $< -o $@

slot.elf: left_number.o right_number.o kiseki_kai.o result_faled.o acomu_kai.o result_zorome.o fanfare_kai.o result_zorome77.o menu.o
	$(LD) $(LDFLAGS) $+ -o $@

slot.img: slot.elf
	$(OBJCP) $< $(OBJCPFLAGS) $@

main.img: slot.img
	cp $< $@

# .oファイルやa.outファイルやバックアップファイルを削除

clean:
	rm -f *.o *~ *.elf *.img
