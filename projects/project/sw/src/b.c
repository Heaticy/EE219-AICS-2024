#include "trap.h"

#define STR2(s) #s
#define STR(s) STR2(s)

#define INST_OPV_BIN(funct6, vm, vs2, vs1, funct3, vd, opcode) 0b##funct6##vm##vs2##vs1##funct3##vd##opcode
#define WORD(inst) ".word " #inst ""
#define ASM_CUSTOM(inst) WORD(inst)
#define PUTCH ASM_CUSTOM(0x0005007f)

// void vadd_vx(register int *vd, register int *rs1, register int *vs2)
// {
//     asm volatile(".insn r 0x57, 0x4, 0x01, %0, %1, %2" : : "r"(vd), "r"(rs1), "r"(vs2));
// }

void vadd_vi(register int *vd, register int *imm, register int *vs2)
{
    asm volatile(".insn r 0x57, 0x3, 0x01, %0, %1, %2" : : "r"(vd), "r"(imm), "r"(vs2));
}
// void vle32_v(register int *vd, uintptr_t addr)
// {
//     asm volatile(".insn r 0x07, 0x6, 0x01, %0, %1, x0"
//                  : "=r"(vd)
//                  : "r"(addr));
// }

// void vse32_v(register int *vd, uintptr_t addr)
// {
//     asm volatile(".insn r 0x27, 0x6, 0x01, %0, %1, x0"
//                  : "=r"(vd)
//                  : "r"(addr));
// }
void vle32_v(register int *vd, intptr_t rs1)
{
    asm volatile(".insn r 0x07, 0x6, 0x01, %0, %1, x0" : : "r"(vd), "r"(rs1));
}
void vse32_v(register int *vs3, intptr_t rs1)
{
    asm volatile(".insn r 0x27, 0x6, 0x01, %0, %1, x0" : : "r"(vs3), "r"(rs1));
}
void vmul_vx(register int *vd, int64_t xrs1, register int *vs2)
{
    asm volatile(
        ".insn r 0x57, 0x4, 0x4b, %0, %1, %2"
        : : "r"(vd), "r"(xrs1), "r"(vs2));
}
void vadd_vv(register int *vd, register int *vs1, register int *vs2)
{
    asm volatile(".insn r 0x57, 0x0, 0x01, %0, %1, %2" : : "r"(vd), "r"(vs1), "r"(vs2));
}
void vadd_vx(register int *vd, int64_t xrs1, register int *vs2)
{
    asm volatile(
        ".insn r 0x57, 0x4, 0x01, %0, %1, %2"
        : : "r"(vd), "r"(xrs1), "r"(vs2));
}

void vmul_vv(register int *vd, register int *vs1, register int *vs2)
{
    asm volatile(".insn r 0x57, 0x0, 0x4b, %0, %1, %2" : : "r"(vd), "r"(vs1), "r"(vs2));
}
// void vmul_vx(register int *vd, register int *rs1, register int *vs2)
// {
//     asm volatile(".insn r 0x57, 0x4, 0x4b, %0, %1, %2" : : "r"(vd), "r"(rs1), "r"(vs2));
// }
void vmul_vi(register int *vd, register int *imm, register int *vs2)
{
    asm volatile(".insn r 0x57, 0x3, 0x4b, %0, %1, %2" : : "r"(vd), "r"(imm), "r"(vs2));
}

int main()
{

    // register int *reg_vx0 asm("x0");
    register int *reg_vx1 asm("x1");
    register int *reg_vx2 asm("x2");
    // register int *reg_rx1 asm("x1");
    // asm volatile("addi %0, x0, 1" : "=r"(reg_rx1));
    // vadd_vv(reg_vx1, reg_vx1, reg_vx2);
    vle32_v(reg_vx1, 0x80800000);
    // vadd_vx(reg_vx2, reg_rx1, reg_vx1);
    vmul_vx(reg_vx2, 2, reg_vx1);
    vse32_v(reg_vx2, 0x80f00000);

    // vadd_vx(reg_vx2, reg_rx21, reg_vx1);
    // asm volatile(".insn r 0x57, 0x0, 0x01, %0, %1, %2" : : "r"(0x2), "r"(0x1), "r"(0x1));

    return 0;
}
