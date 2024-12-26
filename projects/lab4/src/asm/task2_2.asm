; =======================================
; task2_2
; =======================================

main:
        lui     x29,2148532224  ;               nop;
        lui     x5,2152726528   ;               nop;
        lui     x31,2154823680  ;               nop;
        lui     x8,2151677952   ;               nop;
        addi    x10 x29 32      ;               nop;
        addi    x7 x0 0         ;               nop;
        addi    x30 x0 64       ;               nop;
.L2:
        addi    x28 x8 0        ;               nop;
        addi    x6 x31 0        ;               nop;
        addi    x17 x5 0        ;               nop;
        addi    x16 x0 0        ;               nop;
.L4:
        lw      x12,0(x17)      ;               nop;
        addi    x13 x28 0       ;               nop;
        addi    x15 x29 0       ;               nop;
.L3:
        lw      x14,0(x15)      ;               nop;
        lw      x11,0(x13)      ;               nop;
        addi    x15,x15,4       ;               nop;
        addi    x13,x13,4       ;               nop;
        mul     x14,x14,x11     ;               nop;
        add     x12,x12,x14     ;               nop;
        bne     x15,x10,.L3     ;               nop;
        sw      x12,0(x6)       ;               nop;
        addi    x16,x16,8       ;               nop;
        addi    x17,x17,4       ;               nop;
        addi    x6,x6,4         ;               nop;
        addi    x28,x28,32      ;               nop;
        bne     x16,x30,.L4     ;               nop;
        addi    x7,x7,8         ;               nop;
        addi    x29,x29,32      ;               nop;
        addi    x10,x15,32      ;               nop;
        addi    x5,x5,32        ;               nop;
        addi    x31,x31,32      ;               nop;
        bne     x7,x16,.L2      ;               nop;
