    .section .text
    .org 0
    .globl _start
_start:
    /* initialize register values initialized sram */
    lw x1, 0x44(x0)
    lw x2, 0x48(x0)
    lw x3, 0x4C(x0)
    lw x4, 0x50(x0)
    lw x5, 0x54(x0)
    lw x6, 0x58(x0)
    lw x7, 0x5C(x0)
    lw x8, 0x60(x0)
    lw x9, 0x64(x0)
    lw x10, 0x68(x0)
    lw x11, 0x6C(x0)
    lw x12, 0x70(x0)
    lw x13, 0x74(x0)
    lw x14, 0x78(x0)
    lw x15, 0x7C(x0)
    lw x16, 0x80(x0)
    lw x17, 0x84(x0)
    lw x18, 0x88(x0)
    lw x19, 0x8C(x0)
    lw x20, 0x90(x0)
    lw x21, 0x94(x0)
    lw x22, 0x98(x0)
    lw x23, 0x9C(x0)
    lw x24, 0xA0(x0)
    lw x25, 0xA4(x0)
    lw x26, 0xA8(x0)
    lw x27, 0xAC(x0)
    lw x28, 0xB0(x0)
    lw x29, 0xB4(x0)
    lw x30, 0xB8(x0)
    lw x31, 0xBC(x0)

    sw x1, 0(x0)
    sw x2, 4(x0)
    mv x3, x2
    li x4, 8
    li x5, 60

start_fib:
    add x3, x1, x2
    sw x3, 0(x4)
    addi x4, x4, 4
    mv x1, x2
    mv x2, x3
    ble x4, x5, start_fib
    
    ebreak
