# === Configuration ===
SRC     := hello.s
OBJ     := $(SRC:.s=.o)
OUT     := $(basename $(SRC))
LD_SCRIPT := link.ld

# Optional visual output file
SVG     := elf_map.svg

# === Targets ===

all: $(OUT)

$(OUT): $(OBJ) $(LD_SCRIPT)
	ld -T $(LD_SCRIPT) -o $@ $<
	@echo "Built $@"
	@size -A $@

$(OBJ): $(SRC)
	as -o $@ $<

map: $(OUT)
	@python3 tools/gen_map.py $(OUT) $(SVG)

clean:
	rm -f $(OBJ) $(OUT) $(SVG)

.PHONY: all map clean
