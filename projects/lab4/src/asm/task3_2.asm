; =======================================
; task3_2
; =======================================

main:
        lui     x6,2153775104   ;         nop           ;         nop           ;
        lui     x17,2155872256  ;         nop           ;         nop           ;
        lui     x16,2151677952  ;         nop           ;         nop           ;
        lui     x29,2149580800  ;         nop           ;         nop           ;
        addi    x10,x29,256      ;         nop          ;         nop           ;
        addi    x28 x0 0        ;         nop           ;         nop           ;
        addi    x30 x0 64       ;         nop           ;         nop           ;
.L3:
        addi    x15 x29 0       ;         nop           ;   vle32.v   vx2,x6,1  ;
        addi    x13 x16 0       ;         nop           ;         nop           ;
.L2:
        lw      x11,0(x13)      ;         nop           ; vle32.v   vx1,x15,1   ;
        addi    x15,x15,32      ;         nop           ;         nop           ;
        addi    x13,x13,4       ;         nop           ;         nop           ;
                nop             ; vmul.vx   vx3,vx1,x11,1 ;         nop           ;
                nop             ; vadd.vv   vx2,vx2,vx3,1 ;         nop           ;
        bne     x10,x15,.L2     ;         nop           ;         nop           ;
                nop             ;         nop           ; vse32.v   vx2,x17,1   ;
        addi    x28,x28,8       ;         nop           ;         nop           ;
        addi    x6,x6,32        ;         nop           ;         nop           ;
        addi    x17,x17,32      ;         nop           ;         nop           ;
        addi    x16,x16,32      ;         nop           ;         nop           ;
        bne     x28,x30,.L3     ;         nop           ;         nop           ;