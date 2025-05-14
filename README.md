# AArch64 Assembly Builder for Termux

This project provides a minimal toolchain for assembling, linking, and visualizing AArch64 ELF binaries inside **Termux** on Android.

### Features

- Assemble AArch64 `.s` source files
- Link using a custom or user-defined `link.ld`
- Print section sizes
- Auto-generate memory layout diagram (`elf_map.svg`)

---

## Usage

### Step 1: Install dependencies
```bash
pkg install clang binutils python
