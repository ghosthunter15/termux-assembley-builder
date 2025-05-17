#!/data/data/com.termux/files/usr/bin/bash

# File: build_and_map.sh
# Usage: ./build_and_map.sh yourfile.s

set -e

# Input file check
if [ -z "$1" ]; then
    echo "Usage: $0 yourfile.s"
    exit 1
fi

SRC="$1"
OBJ="${SRC%.s}.o"
BIN="${SRC%.s}"
LD_SCRIPT="link.ld"

# Step 1: Assemble
as -o "$OBJ" "$SRC"

# Step 2: Link with custom linker script if not already present
if [ ! -f "$LD_SCRIPT" ]; then
cat > "$LD_SCRIPT" <<EOF
ENTRY(_start)
SECTIONS {
  . = 0x400000;
  .text : { *(.text) }
  .rodata : { *(.rodata*) }
  .data : { *(.data) }
  .bss : { *(.bss COMMON) }
}
EOF
else
  echo "Using existing $LD_SCRIPT"
fi

ld -T "$LD_SCRIPT" -o "$BIN" "$OBJ"

# Step 3: Print layout summary
echo "=== Section Sizes ==="
size -A "$BIN"

# Step 4: Optional visual output
# Step 4: Optional reminder
if command -v python > /dev/null && [ -f Makefile ]; then
  echo "To generate a memory map, run: make map"
fi

