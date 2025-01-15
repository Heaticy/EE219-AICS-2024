// #include "trap.h"

// #define STR2(s) #s
// #define STR(s) STR2(s)

// #define INST_OPV_BIN(funct6, vm, vs2, vs1, funct3, vd, opcode) 0b##funct6##vm##vs2##vs1##funct3##vd##opcode
// #define WORD(inst) ".word " #inst ""
// #define ASM_CUSTOM(inst) WORD(inst)
// #define PUTCH ASM_CUSTOM(0x0005007f)

// void vadd_vv(register int *vd, register int *vs1, register int *vs2)
// {
//     asm volatile(".insn r 0x57, 0x0, 0x01, %0, %1, %2" : : "r"(vd), "r"(vs1), "r"(vs2));
// }

// void vadd_vx(register int *vd, register int *rs1, register int *vs2)
// {
//     asm volatile(".insn r 0x57, 0x4, 0x01, %0, %1, %2" : : "r"(vd), "r"(rs1), "r"(vs2));
// }

// void vadd_vi(register int *vd, register int *imm, register int *vs2)
// {
//     asm volatile(".insn r 0x57, 0x3, 0x01, %0, %1, %2" : : "r"(vd), "r"(imm), "r"(vs2));
// }
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

// int main()
// {

//     register int *reg_vx0 asm("x0");
//     register int *reg_vx1 asm("x1");
//     register int *reg_vx2 asm("x2");

//     // vadd_vv(reg_vx1, reg_vx1, reg_vx2);
//     // vadd_vx(reg_vx2, reg_vx1, reg_vx2);
//     // vadd_vi(reg_vx2, reg_vx0, reg_vx2);
//     vle32_v(reg_vx1, 0x80800000);
//     vse32_v(reg_vx1, 0x80f00000);

//     return 0;
// }
