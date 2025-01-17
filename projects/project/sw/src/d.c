#include "model.h"
#include "trap.h"

// 第一层卷积
#define INPUT_HEIGHT_CONV1 32
#define INPUT_WIDTH_CONV1 32
#define INPUT_CHANNELS_CONV1 3
#define OUTPUT_CHANNELS_CONV1 12
#define OUTPUT_HEIGHT_CONV1 28
#define OUTPUT_WIDTH_CONV1 28
#define KERNEL_SIZE_CONV1 5

// img2col_1
#define W_IM2COL1 KERNEL_SIZE_CONV1 *KERNEL_SIZE_CONV1 *INPUT_CHANNELS_CONV1
#define H_IM2COL1 OUTPUT_HEIGHT_CONV1 *OUTPUT_WIDTH_CONV1
#define V_LEN 8
#define ADDR_IM2COL1 0x80900000
#define ADDR_WEIGHT1 0x80a00000
#define ADDR_MUL1 0x80b00000
#define ADDR_BUFFER1 0x80c00000
// register int *reg_vx1 asm("x1");
// register int *reg_vx2 asm("x2");
// register int *reg_vx3 asm("x3");
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
int main()
{ // 第一层卷积和池化
    int8_t *input_data_conv1 = (int8_t *)ADDR_INPUT;
    // int8_t *weight_conv1 = (int8_t *)ADDR_WCONV1;
    // int8_t *output_data_conv1 = (int8_t *)ADDR_OUTCONV1;
    // int8_t *output_data_pool1 = (int8_t *)ADDR_OUTPOOL1;

    // int8_t *scale_conv1 = (int8_t *)ADDR_SCONV1;
    // im2col_input
    int64_t *im2col_input = (int64_t *)ADDR_IM2COL1;

    int idx = 0;
    // img2col_1

    for (int h = 0; h < OUTPUT_HEIGHT_CONV1; h++)
    {
        for (int w = 0; w < OUTPUT_WIDTH_CONV1; w++)
        {
            for (int c = 0; c < INPUT_CHANNELS_CONV1; c++)
            {
                // 对于每个输出位置，展开对应的卷积核窗口
                for (int kh = 0; kh < KERNEL_SIZE_CONV1; kh++)
                {
                    for (int kw = 0; kw < KERNEL_SIZE_CONV1; kw++)
                    {
                        // 计算卷积窗口在输入特征图中的位置
                        int input_h = h + kh; // 没有 stride，h 直接对应输入图像的位置
                        int input_w = w + kw; // 没有 stride，w 直接对应输入图像的位置

                        im2col_input[idx++] = (int64_t)input_data_conv1[(c * INPUT_HEIGHT_CONV1 + input_h) * INPUT_WIDTH_CONV1 + input_w];
                    }
                }
            }
        }
    }
    // 把weight_conv1 变成int64_t数组
    int64_t *weight_input = (int64_t *)ADDR_WEIGHT1;
    int8_t *weight_conv1 = (int8_t *)ADDR_WCONV1;
    for (int i = 0; i < WEIGHT_INT8_CONV1; i++)
    {
        weight_input[i] = (int64_t)weight_conv1[i];
    }

    // im2col_input * weight_input
    int64_t *mul_out = (int64_t *)ADDR_MUL1;
    for (int k = 0; k < OUTPUT_CHANNELS_CONV1; k++)
    {
        for (int i = 0; i < H_IM2COL1; i++)
        {
            int64_t temp = 0;
            for (int j = 0; j < W_IM2COL1; j++)
            {
                temp += im2col_input[i * W_IM2COL1 + j] * weight_input[k * W_IM2COL1 + j];
            }
            // printf("temp: %d,i:%d,k:%d\n", temp, i, k);
            mul_out[k * H_IM2COL1 + i] = temp;
        }
    }
    // int8_t *output_data_conv1 = (int8_t *)ADDR_OUTCONV1;
    // writeback to int8 and >>8
    // for (int i = 0; i < OUTPUT_INT8_CONV1; i++)
    // {
    //     output_data_conv1[i] = (int8_t)(mul_out[i] >> 8);
    // }
    return 0;
}
