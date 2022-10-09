AS = ca65
CC = cc65
LD = ld65

.PHONY: clean

build: main.nes

%.o: src/%.s
	$(AS) -g --create-dep "$@.dep" --debug-info $< -o $@

main.nes: layout entry.o
	$(LD) --dbgfile main.dbg -C $^ -o $@

clean:
	rm -f main.nes *.dep *.o *.dbg

include $(wildcard *.dep)
