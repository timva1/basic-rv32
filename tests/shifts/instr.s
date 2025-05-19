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

    /* perform tests */
    /* test 1 */
    add x31, x1, x2
    sll x31, x31, x4
    sw x31, 0x0(x0)

    /* test 2 */
    add x31, x10, x16
    srl x31, x31, x4
    sw x31, 0x4(x0)
    
    /* test 3 */
    sra x31, x6, x1
    sw x31, 0xC(x0)

    /* test 4 */
    sra x31, x13, x1
    sw x31, 0x10(x0)

    /* test 5 */
    add x31, x3, x6
    slli x31, x31, 0x17
    sw x31, 0x8(x0)

    /* test 6 */
    slli x31, x3, 0x19
    add x31, x31, x11
    add x31, x31, x6
    srli x31, x31, 0x5
    sw x31, 0x14(x0)

    /* test 7 */
    srli x31, x10, 0x3
    slli x30, x18, 0xF
    sub x31, x31, x30
    slli x31, x31, 0x3
    srai x31, x31, 0x3
    sw x31, 0x18(x0)

    /* no more tests */

    ecall
