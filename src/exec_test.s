    .section .text
    .org 0
    .globl _start
_start:
    /* init registers as necessary */
    li x1, 0x0
    li x2, 0x0
    li x3, 0x0
    li x4, 0x0
    li x5, 0x0
    li x6, 0x0
    li x7, 0x0

    /* test load operations */ 
    lb x1, 0x0(x0)
    lb x2, 0x1(x0)
    lh x3, 0x2(x0)
    lh x4, 0x3(x0)
    lw x5, 0x4(x0)
    lbu x6, 0x5(x0)
    lhu x7, 0x6(x0)

    sb x2, 0x8(x0)
    sh x4, 0x9(x0)
    sw x6, 0xA(x0)

    addi x10, x0, 0x10
    /* test store operations */ /* 
    sb x1, 0x8(x0)
    sh x2, 0x9(x0)
    sw x3, 0xA(x0) */ 
