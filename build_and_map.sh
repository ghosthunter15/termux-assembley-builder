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
if command -v python > /dev/null; then
  python3 - <<EOF
import subprocess
import matplotlib.pyplot as plt

out = subprocess.check_output(['size', '-A', '$BIN'], text=True).splitlines()[1:]
labels, sizes = zip(*[(l.split()[0], int(l.split()[1])) for l in out if len(l.split()) >= 2])
base = 0x400000
addrs = [base + sum(sizes[:i]) for i in range(len(sizes))]

fig, ax = plt.subplots()
for i, (l, a, s) in enumerate(zip(labels, addrs, sizes)):
    ax.barh(1, width=s, left=a, height=0.5, label=f"{l} @ 0x{a:X}")

ax.set_xlim(base - 0x100, base + sum(sizes) + 0x100)
ax.set_yticks([])
ax.set_xlabel("Memory Address")
ax.set_title("AArch64 ELF Section Map")
ax.legend(loc='upper right')
plt.tight_layout()
plt.savefig("elf_map.svg")
print("Map saved as elf_map.svg")
EOF
fi
