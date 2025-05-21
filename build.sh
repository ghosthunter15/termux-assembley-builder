#!/data/data/com.termux/files/usr/bin/bash
# build.sh - cross-arch assembler for AArch64 and x86_64 & arm7

set -e

SRC="${1:-hello.s}"
ARCH="${2:-aarch64}"  # Default to aarch64

OBJ="${SRC%.s}.o"
OUT="${SRC%.s}"
LD_SCRIPT="link.${ARCH}.ld"

# Toolchains
case "$ARCH" in
  aarch64)
    AS=as
    LD=ld
    ;;
  x86_64)
    AS=x86_64-linux-android-as
    LD=x86_64-linux-android-ld
    ;;
  armv7)
    AS=arm-linux-androideabi-as
    LD=arm-linux-androideabi-ld
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# Generate basic linker script if missing
if [ ! -f "$LD_SCRIPT" ]; then
cat > "$LD_SCRIPT" <<EOF
ENTRY(_start)
SECTIONS {
  . = 0x400000;
  .text : { *(.text) }
  .rodata : { *(.rodata*) }
  .data : { *(.data) }
  .bss  : { *(.bss COMMON) }
}
EOF
fi

# Assemble and Link
$AS -g -o "$OBJ" "$SRC"
$LD -T "$LD_SCRIPT" -o "$OUT" "$OBJ"
echo "Built $OUT for $ARCH"
size -A "$OUT"


# Step 3: Print layout summary
echo "=== Section Sizes ==="
size -A "$BIN"

# Step 4: Optional visual output
# Step 4: Optional reminder
if command -v python > /dev/null && [ -f Makefile ]; then
  echo "To generate a memory map, run: make map"
fi

