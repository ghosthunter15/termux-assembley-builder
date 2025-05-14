ENTRY(_start)

SECTIONS
{
  . = 0x400000;  /* Base address of the program */

  .text : {
    *(.text)
  }

  .rodata : {
    *(.rodata*)
  }

  .data : {
    *(.data)
  }

  .bss : {
    *(.bss COMMON)
  }
}
