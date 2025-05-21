MEMORY
{
  RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 4K
}

ENTRY(_start)

SECTIONS
{
  /* Reserved section at start of RAM */
  .results 0x00000000 : ALIGN(4)
  {
    __results_start = .;
    KEEP(*(.results))
    . = ALIGN(4);
    __results_end = .;
  } > RAM

  /* Code section after reserved */
  .text : ALIGN(4)
  {
    *(.text._start)
    *(.text*)
  } > RAM

  .data : ALIGN(4)
  {
    *(.data*)
  } > RAM

  .bss : ALIGN(4)
  {
    *(.bss*)
    *(COMMON)
  } > RAM

  __stack_top = ORIGIN(RAM) + LENGTH(RAM);
}
