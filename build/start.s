    .section .text
    .globl _start
    .extern __stack_top
_start:
    lui sp, %hi(__stack_top)
    addi sp, sp, %lo(__stack_top)
    call main
    ebreak

    .section .results
    .globl reserved_results
reserved_results:
    .space 44
    