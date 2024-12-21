main:
        lui     x29,2148532224
        lui     x5,2152726528
        lui     x31,2154823680
        lui     x8,2151677952
        addi    x10 x29 32
        addi    x7 x0 0
        addi    x30 x0 64
.L2:
        addi    x28 x8 0
        addi    x6 x31 0
        addi    x17 x5 0
        addi    x16 x0 0
.L4:
        lw      x12,0(x17)
        addi    x13 x28 0
        addi    x15 x29 0
.L3:
        lw      x14,0(x15)
        lw      x11,0(x13)
        addi    x15,x15,4
        addi    x13,x13,4
        mul     x14,x14,x11
        add     x12,x12,x14
        bne     x15,x10,.L3
        sw      x12,0(x6)
        addi    x16,x16,8
        addi    x17,x17,4
        addi    x6,x6,4
        addi    x28,x28,32
        bne     x16,x30,.L4
        addi    x7,x7,8
        addi    x29,x29,32
        addi    x10,x15,32
        addi    x5,x5,32
        addi    x31,x31,32
        bne     x7,x16,.L2
