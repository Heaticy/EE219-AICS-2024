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
#define ADDR_BUFFER1 0x80b00000

// 第一层池化
#define INPUT_HEIGHT_POOL1 28
#define INPUT_WIDTH_POOL1 28
#define OUTPUT_HEIGHT_POOL1 14
#define OUTPUT_WIDTH_POOL1 14
#define POOL_SIZE 2
#define POOL_STRIDE 2

// 第二层卷积
#define INPUT_HEIGHT_CONV2 14
#define INPUT_WIDTH_CONV2 14
#define INPUT_CHANNELS_CONV2 12
#define OUTPUT_CHANNELS_CONV2 32
#define OUTPUT_HEIGHT_CONV2 12
#define OUTPUT_WIDTH_CONV2 12
#define KERNEL_SIZE_CONV2 3
#define STRIDE_CONV2 1
// img2col_2
#define W_IM2COL2 KERNEL_SIZE_CONV2 *KERNEL_SIZE_CONV2 *INPUT_CHANNELS_CONV2
#define H_IM2COL2 OUTPUT_HEIGHT_CONV2 *OUTPUT_WIDTH_CONV2
#define ADDR_IM2COL2 0x80c00000
#define ADDR_WEIGHT2 0x80e00000
#define ADDR_BUFFER2 0x81000000

// 第二层池化
#define INPUT_HEIGHT_POOL2 12
#define INPUT_WIDTH_POOL2 12
#define OUTPUT_HEIGHT_POOL2 6
#define OUTPUT_WIDTH_POOL2 6

// 全连接
#define FC1_INPUT_SIZE (OUTPUT_CHANNELS_CONV2 * OUTPUT_HEIGHT_POOL2 * OUTPUT_WIDTH_POOL2)
#define FC1_OUTPUT_SIZE 256
#define FC2_OUTPUT_SIZE 64
#define FC3_OUTPUT_SIZE 10

void vle32_v_1(int64_t *rs1)
{
    asm volatile(".insn r 0x07, 0x6, 0x01, x1, %0, x0" : : "r"(rs1));
    asm volatile("nop");
}
void vle32_v_2(int64_t *rs1)
{
    asm volatile(".insn r 0x07, 0x6, 0x01, x2, %0, x0" : : "r"(rs1));
    asm volatile("nop");
}
void vse32_v(int64_t *rs1)
{
    asm volatile(".insn r 0x27, 0x6, 0x01, x3, %0, x0" : : "r"(rs1));
    asm volatile("nop");
}
void vmul_vv()
{
    asm volatile(".insn r 0x57, 0x0, 0x4b, x3, x1, x2" : :);
}
int main()
{
    // 第一层卷积和池化
    int8_t *input_data_conv1 = (int8_t *)ADDR_INPUT;
    int8_t *weight_conv1 = (int8_t *)(ADDR_WCONV1);
    int8_t *output_data_conv1 = (int8_t *)ADDR_OUTCONV1;
    int64_t *weight_input = (int64_t *)ADDR_WEIGHT1;
    int64_t *im2col_input = (int64_t *)ADDR_IM2COL1;
    int8_t *output_data_pool1 = (int8_t *)ADDR_OUTPOOL1;
    int8_t *scale_conv1 = (int8_t *)ADDR_SCONV1;
    int64_t *buffer = (int64_t *)ADDR_BUFFER1;

    // 第二层卷积和池化
    int8_t *weight_conv2 = (int8_t *)ADDR_WCONV2;
    int8_t *output_data_conv2 = (int8_t *)ADDR_OUTCONV2;
    int8_t *output_data_pool2 = (int8_t *)ADDR_OUTPOOL2;
    int64_t *im2col_input2 = (int64_t *)ADDR_IM2COL2;
    int64_t *weight_input2 = (int64_t *)ADDR_WEIGHT2;
    int64_t *buffer2 = (int64_t *)ADDR_BUFFER2;
    int8_t *scale_conv2 = (int8_t *)ADDR_SCONV2;

    // 全连接层
    int8_t *weight_fc1 = (int8_t *)ADDR_WFC1;
    int8_t *weight_fc2 = (int8_t *)ADDR_WFC2;
    int8_t *weight_fc3 = (int8_t *)ADDR_WFC3;
    int16_t *bias_fc3 = (int16_t *)ADDR_BFC3; // 偏置为 int16_t

    int8_t *scale_fc1 = (int8_t *)ADDR_SFC1;
    int8_t *scale_fc2 = (int8_t *)ADDR_SFC2;
    int8_t *scale_fc3 = (int8_t *)ADDR_SFC3;

    int8_t *output_fc1 = (int8_t *)ADDR_OUTFC1;
    int8_t *output_fc2 = (int8_t *)ADDR_OUTFC2;
    int8_t *output_fc3 = (int8_t *)ADDR_OUTFC3;
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
                        int input_h = h + kh;
                        int input_w = w + kw;
                        im2col_input[idx++] = (int64_t)input_data_conv1[(c * INPUT_HEIGHT_CONV1 + input_h) * INPUT_WIDTH_CONV1 + input_w];
                    }
                }
            }
        }
    }
    // 把weight_conv1 变成int64_t数组
    for (int i = 0; i < WEIGHT_INT8_CONV1; i++)
    {
        weight_input[i] = (int64_t)weight_conv1[i];
    }

    // im2col_input * weight_input
    const int scale_conv1_value = (int)(scale_conv1[0]);
    for (int k = 0; k < OUTPUT_CHANNELS_CONV1; k++)
    {
        for (int i = 0; i < H_IM2COL1; i++)
        {
            int64_t conv_result_conv1 = 0;
            int j = 0;
            for (j = 0; j < 72; j += V_LEN)
            {
                vle32_v_1(&im2col_input[i * W_IM2COL1 + j]);
                vle32_v_2(&weight_input[k * W_IM2COL1 + j]);
                vmul_vv();
                vse32_v(buffer);
                conv_result_conv1 += buffer[0];
                conv_result_conv1 += buffer[1];
                conv_result_conv1 += buffer[2];
                conv_result_conv1 += buffer[3];
                conv_result_conv1 += buffer[4];
                conv_result_conv1 += buffer[5];
                conv_result_conv1 += buffer[6];
                conv_result_conv1 += buffer[7];
            }
            vle32_v_1(&im2col_input[i * W_IM2COL1 + j]);
            vle32_v_2(&weight_input[k * W_IM2COL1 + j]);
            vmul_vv();
            vse32_v(buffer);
            conv_result_conv1 += buffer[0];
            conv_result_conv1 += buffer[1];
            conv_result_conv1 += buffer[2];

            output_data_conv1[k * H_IM2COL1 + i] = (int8_t)((conv_result_conv1 > 0 ? conv_result_conv1 : 0) >> scale_conv1_value);
        }
    }

    // 第一层池化
    for (int oc_pool1 = 0; oc_pool1 < OUTPUT_CHANNELS_CONV1; oc_pool1++)
    {
        for (int oh_pool1 = 0; oh_pool1 < OUTPUT_HEIGHT_POOL1; oh_pool1++)
        {
            for (int ow_pool1 = 0; ow_pool1 < OUTPUT_WIDTH_POOL1; ow_pool1++)
            {
                int base_input_index_pool1 = (oc_pool1 * INPUT_HEIGHT_POOL1 + oh_pool1 * POOL_STRIDE) * INPUT_WIDTH_POOL1 + ow_pool1 * POOL_STRIDE;
                int8_t max_value = output_data_conv1[base_input_index_pool1];
                for (int ph = 0; ph < POOL_SIZE; ph++)
                {
                    for (int pw = 0; pw < POOL_SIZE; pw++)
                    {
                        int input_index_pool1 = base_input_index_pool1 + ph * INPUT_WIDTH_POOL1 + pw;
                        if (output_data_conv1[input_index_pool1] > max_value)
                        {
                            max_value = output_data_conv1[input_index_pool1];
                        }
                    }
                }
                int output_index_pool1 = (oc_pool1 * OUTPUT_HEIGHT_POOL1 + oh_pool1) * OUTPUT_WIDTH_POOL1 + ow_pool1;
                output_data_pool1[output_index_pool1] = max_value;
            }
        }
    }

    // 第二层卷积
    // img2col_2
    int idx2 = 0;
    for (int h = 0; h < OUTPUT_HEIGHT_CONV2; h++)
    {
        for (int w = 0; w < OUTPUT_WIDTH_CONV2; w++)
        {
            for (int c = 0; c < INPUT_CHANNELS_CONV2; c++)
            {
                // 对于每个输出位置，展开对应的卷积核窗口
                for (int kh = 0; kh < KERNEL_SIZE_CONV2; kh++)
                {
                    for (int kw = 0; kw < KERNEL_SIZE_CONV2; kw++)
                    {
                        int input_h = h + kh;
                        int input_w = w + kw;
                        im2col_input2[idx2++] = (int64_t)output_data_pool1[(c * INPUT_HEIGHT_CONV2 + input_h) * INPUT_WIDTH_CONV2 + input_w];
                    }
                }
            }
        }
    }

    // 把weight_conv2 变成int64_t数组
    for (int i = 0; i < WEIGHT_INT8_CONV2; i++)
    {
        weight_input2[i] = (int64_t)weight_conv2[i];
    }

    // im2col_input * weight_input
    const int scale_conv2_value = (int)(scale_conv2[0]);
    for (int k = 0; k < OUTPUT_CHANNELS_CONV2; k++)
    {
        for (int i = 0; i < H_IM2COL2; i++)
        {
            int64_t conv_result_conv2 = 0;
            int j = 0;
            for (j = 0; j < 104; j += V_LEN)
            {
                vle32_v_1(&im2col_input2[i * W_IM2COL2 + j]);
                vle32_v_2(&weight_input2[k * W_IM2COL2 + j]);
                vmul_vv();
                vse32_v(buffer2);
                conv_result_conv2 += buffer2[0];
                conv_result_conv2 += buffer2[1];
                conv_result_conv2 += buffer2[2];
                conv_result_conv2 += buffer2[3];
                conv_result_conv2 += buffer2[4];
                conv_result_conv2 += buffer2[5];
                conv_result_conv2 += buffer2[6];
                conv_result_conv2 += buffer2[7];
            }
            vle32_v_1(&im2col_input2[i * W_IM2COL2 + j]);
            vle32_v_2(&weight_input2[k * W_IM2COL2 + j]);
            vmul_vv();
            vse32_v(buffer2);
            conv_result_conv2 += buffer2[0];
            conv_result_conv2 += buffer2[1];
            conv_result_conv2 += buffer2[2];
            conv_result_conv2 += buffer2[3];
            output_data_conv2[k * H_IM2COL2 + i] = (int8_t)((conv_result_conv2 > 0 ? conv_result_conv2 : 0) >> scale_conv2_value);
        }
    }

    // // 第二层卷积
    // const int scale_conv2_value = (int)(scale_conv2[0]);
    // for (int oc_conv2 = 0; oc_conv2 < OUTPUT_CHANNELS_CONV2; oc_conv2++)
    // {
    //     for (int oh_conv2 = 0; oh_conv2 < OUTPUT_HEIGHT_CONV2; oh_conv2++)
    //     {
    //         for (int ow_conv2 = 0; ow_conv2 < OUTPUT_WIDTH_CONV2; ow_conv2++)
    //         {
    //             int32_t conv_result_conv2 = 0;
    //             int base_output_index_conv2 = (oc_conv2 * OUTPUT_HEIGHT_CONV2 + oh_conv2) * OUTPUT_WIDTH_CONV2 + ow_conv2;
    //             for (int ic_conv2 = 0; ic_conv2 < INPUT_CHANNELS_CONV2; ic_conv2++)
    //             {
    //                 int base_input_index_conv2 = ic_conv2 * INPUT_HEIGHT_CONV2 * INPUT_WIDTH_CONV2;
    //                 int base_weight_index_conv2 = (oc_conv2 * INPUT_CHANNELS_CONV2 + ic_conv2) * KERNEL_SIZE_CONV2 * KERNEL_SIZE_CONV2;
    //                 for (int kh_conv2 = 0; kh_conv2 < KERNEL_SIZE_CONV2; kh_conv2++)
    //                 {
    //                     for (int kw_conv2 = 0; kw_conv2 < KERNEL_SIZE_CONV2; kw_conv2++)
    //                     {
    //                         int input_h_conv2 = oh_conv2 * STRIDE_CONV2 + kh_conv2;
    //                         int input_w_conv2 = ow_conv2 * STRIDE_CONV2 + kw_conv2;
    //                         int input_index_conv2 = base_input_index_conv2 + input_h_conv2 * INPUT_WIDTH_CONV2 + input_w_conv2;
    //                         int weight_index_conv2 = base_weight_index_conv2 + kh_conv2 * KERNEL_SIZE_CONV2 + kw_conv2;
    //                         conv_result_conv2 += (int)(output_data_pool1[input_index_conv2]) * (int)(weight_conv2[weight_index_conv2]);
    //                     }
    //                 }
    //             }
    //             output_data_conv2[base_output_index_conv2] = (int8_t)((conv_result_conv2 > 0 ? conv_result_conv2 : 0) >> scale_conv2_value);
    //         }
    //     }
    // }
    // 第二层池化
    for (int oc_pool2 = 0; oc_pool2 < OUTPUT_CHANNELS_CONV2; oc_pool2++)
    {
        for (int oh_pool2 = 0; oh_pool2 < OUTPUT_HEIGHT_POOL2; oh_pool2++)
        {
            for (int ow_pool2 = 0; ow_pool2 < OUTPUT_WIDTH_POOL2; ow_pool2++)
            {
                int base_input_index_pool2 = (oc_pool2 * INPUT_HEIGHT_POOL2 + oh_pool2 * POOL_STRIDE) * INPUT_WIDTH_POOL2 + ow_pool2 * POOL_STRIDE;
                int8_t max_value = output_data_conv2[base_input_index_pool2];
                for (int ph = 0; ph < POOL_SIZE; ph++)
                {
                    for (int pw = 0; pw < POOL_SIZE; pw++)
                    {
                        int input_index_pool2 = base_input_index_pool2 + ph * INPUT_WIDTH_POOL2 + pw;
                        if (output_data_conv2[input_index_pool2] > max_value)
                        {
                            max_value = output_data_conv2[input_index_pool2];
                        }
                    }
                }
                int output_index_pool2 = (oc_pool2 * OUTPUT_HEIGHT_POOL2 + oh_pool2) * OUTPUT_WIDTH_POOL2 + ow_pool2;
                output_data_pool2[output_index_pool2] = max_value;
            }
        }
    }

    // 第一层全连接
    const int scale_fc1_value = (int)(scale_fc1[0]);
    for (int i_fc1 = 0; i_fc1 < FC1_OUTPUT_SIZE; i_fc1++)
    {
        int32_t fc1_result = 0;
        for (int j_fc1 = 0; j_fc1 < FC1_INPUT_SIZE; j_fc1++)
        {
            fc1_result += (int)(output_data_pool2[j_fc1]) * (int)(weight_fc1[i_fc1 * FC1_INPUT_SIZE + j_fc1]);
        }
        fc1_result = fc1_result > 0 ? fc1_result : 0;
        output_fc1[i_fc1] = (int8_t)(fc1_result >> scale_fc1_value);
    }

    // 第二层全连接
    const int scale_fc2_value = (int)(scale_fc2[0]);
    for (int i_fc2 = 0; i_fc2 < FC2_OUTPUT_SIZE; i_fc2++)
    {
        int32_t fc2_result = 0;
        for (int j_fc2 = 0; j_fc2 < FC1_OUTPUT_SIZE; j_fc2++)
        {
            fc2_result += (int)(output_fc1[j_fc2]) * (int)(weight_fc2[i_fc2 * FC1_OUTPUT_SIZE + j_fc2]);
        }
        fc2_result = fc2_result > 0 ? fc2_result : 0;
        output_fc2[i_fc2] = (int8_t)(fc2_result >> scale_fc2_value);
    }

    // 第三层全连接（带偏置）
    const int scale_fc3_value = (int)(scale_fc3[0]);
    for (int i_fc3 = 0; i_fc3 < FC3_OUTPUT_SIZE; i_fc3++)
    {
        int32_t fc3_result = 0;
        for (int j_fc3 = 0; j_fc3 < FC2_OUTPUT_SIZE; j_fc3++)
        {
            fc3_result += (int)(output_fc2[j_fc3]) * (int)(weight_fc3[i_fc3 * FC2_OUTPUT_SIZE + j_fc3]);
        }
        fc3_result += (int)(bias_fc3[i_fc3]);
        output_fc3[i_fc3] = (int8_t)(fc3_result >> scale_fc3_value);
    }

    // 输出最终结果
    printf("Final output (FC3):\n");
    for (int i = 0; i < FC3_OUTPUT_SIZE; i++)
    {
        printf("%d ", output_fc3[i]);
    }
    printf("\n");
    return 0;
}
