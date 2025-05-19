.section .text
    .org 0
    .globl _start
_start:
    sw x0, 0x0(x0)
    sw x0, 0x4(x0)
    sw x0, 0x8(x0)
    sw x0, 0xC(x0)
    sw x0, 0x10(x0)
    sw x0, 0x14(x0)
    sw x0, 0x18(x0)
    sw x0, 0x1C(x0)
    sw x0, 0x20(x0)
    sw x0, 0x24(x0)
    sw x0, 0x28(x0)
    sw x0, 0x2C(x0)
    sw x0, 0x30(x0)
    sw x0, 0x34(x0)
    sw x0, 0x38(x0)
    li x31, 2000000
    sw x31, 0x3C(x0)
    
    mul x11, x1, x2
    mulh x12, x9, x10
    mulhsu x13, x5, x6
    mulhu x14, x6, x7
    div x15, x11, x2
    divu x16, x11, x5
    rem x17, x11, x3
    remu x18, x11, x3
    ecall
