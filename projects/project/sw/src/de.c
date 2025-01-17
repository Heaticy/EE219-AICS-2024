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

void vle32_v(register int *vd, int64_t *rs1)
{
    asm volatile(".insn r 0x07, 0x6, 0x01, %0, %1, x0" : : "r"(vd), "r"(rs1));
    asm volatile("nop");
}
void vse32_v(register int *vs3, int64_t *rs1)
{
    asm volatile(".insn r 0x27, 0x6, 0x01, %0, %1, x0" : : "r"(vs3), "r"(rs1));
    asm volatile("nop");
}
void vmul_vv(register int *vd, register int *vs1, register int *vs2)
{
    asm volatile(".insn r 0x57, 0x0, 0x4b, %0, %1, %2" : : "r"(vd), "r"(vs1), "r"(vs2));
}
int main()
{ // 第一层卷积和池化
    int8_t *input_data_conv1 = (int8_t *)ADDR_INPUT;
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
    int8_t *weight_conv1 = (int8_t *)(ADDR_WCONV1);
    for (int i = 0; i < WEIGHT_INT8_CONV1; i++)
    {
        weight_input[i] = (int64_t)weight_conv1[i];
    }

    // im2col_input * weight_input
    register int *reg_vx1 asm("x1");
    register int *reg_vx2 asm("x2");
    register int *reg_vx3 asm("x3");
    int8_t *output_data_conv1 = (int8_t *)ADDR_OUTCONV1;
    int8_t *scale_conv1 = (int8_t *)ADDR_SCONV1;
    const int scale_conv1_value = (int)(scale_conv1[0]);
    int64_t *buffer = (int64_t *)ADDR_BUFFER1;
    for (int k = 0; k < OUTPUT_CHANNELS_CONV1; k++)
    {
        for (int i = 0; i < H_IM2COL1; i++)
        {
            int64_t conv_result_conv1 = 0;
            int j = 0;
            for (j = 0; j < 72; j += V_LEN)
            {
                vle32_v(reg_vx1, &im2col_input[i * W_IM2COL1 + j]);
                // vse32_v(reg_vx1, buffer);
                // printf("buffer: %ld %ld %ld %ld %ld %ld %ld %ld\n", buffer[0], buffer[1], buffer[2], buffer[3], buffer[4], buffer[5], buffer[6], buffer[7]);
                // printf("im2col_input: %ld %ld %ld %ld %ld %ld %ld %ld\n", im2col_input[i * W_IM2COL1 + j], im2col_input[i * W_IM2COL1 + j + 1], im2col_input[i * W_IM2COL1 + j + 2], im2col_input[i * W_IM2COL1 + j + 3], im2col_input[i * W_IM2COL1 + j + 4], im2col_input[i * W_IM2COL1 + j + 5], im2col_input[i * W_IM2COL1 + j + 6], im2col_input[i * W_IM2COL1 + j + 7]);
                vle32_v(reg_vx2, &weight_input[k * W_IM2COL1 + j]);
                // vse32_v(reg_vx2, buffer);
                // printf("buffer: %ld %ld %ld %ld %ld %ld %ld %ld\n", buffer[0], buffer[1], buffer[2], buffer[3], buffer[4], buffer[5], buffer[6], buffer[7]);
                // printf("weight_input: %ld %ld %ld %ld %ld %ld %ld %ld\n", weight_input[k * W_IM2COL1 + j], weight_input[k * W_IM2COL1 + j + 1], weight_input[k * W_IM2COL1 + j + 2], weight_input[k * W_IM2COL1 + j + 3], weight_input[k * W_IM2COL1 + j + 4], weight_input[k * W_IM2COL1 + j + 5], weight_input[k * W_IM2COL1 + j + 6], weight_input[k * W_IM2COL1 + j + 7]);
                vmul_vv(reg_vx3, reg_vx1, reg_vx2);
                vse32_v(reg_vx3, buffer);
                // printf("buffer: %ld %ld %ld %ld %ld %ld %ld %ld\n", buffer[0], buffer[1], buffer[2], buffer[3], buffer[4], buffer[5], buffer[6], buffer[7]);
                // printf("mul: %ld %ld %ld %ld %ld %ld %ld %ld\n", im2col_input[i * W_IM2COL1 + j] * weight_input[k * W_IM2COL1 + j], im2col_input[i * W_IM2COL1 + j + 1] * weight_input[k * W_IM2COL1 + j + 1], im2col_input[i * W_IM2COL1 + j + 2] * weight_input[k * W_IM2COL1 + j + 2], im2col_input[i * W_IM2COL1 + j + 3] * weight_input[k * W_IM2COL1 + j + 3], im2col_input[i * W_IM2COL1 + j + 4] * weight_input[k * W_IM2COL1 + j + 4], im2col_input[i * W_IM2COL1 + j + 5] * weight_input[k * W_IM2COL1 + j + 5], im2col_input[i * W_IM2COL1 + j + 6] * weight_input[k * W_IM2COL1 + j + 6], im2col_input[i * W_IM2COL1 + j + 7] * weight_input[k * W_IM2COL1 + j + 7]);
                conv_result_conv1 += buffer[0];
                conv_result_conv1 += buffer[1];
                conv_result_conv1 += buffer[2];
                conv_result_conv1 += buffer[3];
                conv_result_conv1 += buffer[4];
                conv_result_conv1 += buffer[5];
                conv_result_conv1 += buffer[6];
                conv_result_conv1 += buffer[7];
            }
            for (j = 72; j < W_IM2COL1; j++)
            {
                conv_result_conv1 += im2col_input[i * W_IM2COL1 + j] * weight_input[k * W_IM2COL1 + j];
            }
            output_data_conv1[k * H_IM2COL1 + i] = (int8_t)((conv_result_conv1 > 0 ? conv_result_conv1 : 0) >> scale_conv1_value);
        }
    }
    return 0;
}
