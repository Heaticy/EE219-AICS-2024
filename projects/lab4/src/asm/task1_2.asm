; =======================================
; task1_2
; =======================================
main:
    addi    x9,x0,0
    jal     x0,.L2
.L7:
    addi    x18,x0,0
    jal     x0,.L3
.L6:
    addi    x19,x0,0
    slli    x15,x9,3
    add     x15,x18,x15
    slli    x15,x15,2
    lui     x13,2152726528 ;c 
    add     x13,x13,x15
    lw      x12,0(x13)
    jal     x0,.L4
.L5:
    slli    x15,x9,3
    add     x15,x19,x15
    slli    x15,x15,2
    lui     x14 2148532224  ;a
    add     x15,x14,x15
    lw      x14,0(x15)
    slli    x15,x18,3
    add     x15,x19,x15
    slli    x15,x15,2
    lui     x13 2151677952  ;bt
    add     x15,x13,x15
    lw      x15,0(x15)
    mul     x14,x14,x15
    add     x12,x12,x14
    addi    x19,x19,1
.L4:
    addi    x15,x0,8
    blt     x19,x15,.L5
    slli    x15,x9,3
    add     x15,x18,x15
    slli    x15,x15,2
    lui     x13,2154823680 ;d
    add     x13,x13,x15
    sw      x12,0(x13)
    addi    x18,x18,1 
.L3:
    addi    x15 x0 8
    blt     x18,x15,.L6
    addi    x9,x9,1
.L2:
    addi    x15 x0 8
    blt     x9,x15,.L7
halt
