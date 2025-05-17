
#!/usr/bin/env python3

import sys
import subprocess
import matplotlib.pyplot as plt

def parse_size_output(binary):
    result = subprocess.run(['size', '-A', binary], capture_output=True, text=True)
    lines = result.stdout.splitlines()[1:]  # skip the header
    sections = []
    base = 0x400000

    for line in lines:
        parts = line.split()
        if len(parts) >= 2:
            name = parts[0]
            size = int(parts[1])
            sections.append((name, size))

    return sections, base

def draw_memory_map(sections, base_addr, output_svg):
    addrs = [base_addr + sum(s for _, s in sections[:i]) for i in range(len(sections))]
    fig, ax = plt.subplots(figsize=(8, 4))

    for (name, size), addr in zip(sections, addrs):
        ax.barh(1, width=size, left=addr, height=0.5, label=f"{name} @ 0x{addr:X} ({size} bytes)")

    ax.set_xlim(base_addr - 0x100, base_addr + sum(size for _, size in sections) + 0x100)
    ax.set_yticks([])
    ax.set_xlabel("Memory Address")
    ax.set_title("AArch64 ELF Section Map")
    ax.legend(loc='upper right', fontsize='small')
    plt.tight_layout()
    plt.savefig(output_svg, format='svg')
    print(f"Memory map saved to {output_svg}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: gen_map.py <binary> <output.svg>")
        sys.exit(1)
    binary = sys.argv[1]
    output_svg = sys.argv[2]
    sections, base_addr = parse_size_output(binary)
    draw_memory_map(sections, base_addr, output_svg)
