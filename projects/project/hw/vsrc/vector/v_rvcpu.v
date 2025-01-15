`include "v_defines.v"

module v_rvcpu(
    input                       clk,
    input                       rst,
    input   [`VINST_BUS]        inst ,

    input   [`SREG_BUS]         vec_rs1_data,
	output            	        vec_rs1_r_ena,
	output  [`SREG_ADDR_BUS]   	vec_rs1_r_addr,

    output                      vram_r_ena,
    output  [`VRAM_ADDR_BUS]    vram_r_addr,
    input   [`VRAM_DATA_BUS]    vram_r_data,

    output                      vram_w_ena,
    output  [`VRAM_ADDR_BUS]    vram_w_addr,
    output  [`VRAM_DATA_BUS]    vram_w_data,
    output  [`VRAM_DATA_BUS]    vram_w_mask
);

wire    [`VINST_BUS]            v_inst = inst        ;
wire    [4:0]            v_alu_opcode      ;
wire    [`VREG_BUS]              v_operand_1       ;
wire    [`VREG_BUS]              v_operand_2       ;
wire                            v_mem_ren         ;
wire                            v_mem_wen         ;
wire                            v_id_wb_en        ;
wire                            v_id_wb_sel       ;
wire    [`VREG_ADDR_BUS]              v_id_wb_addr      ;

wire    [`VREG_BUS]            v_alu_result      ;

wire    [`VMEM_ADDR_BUS]              v_mem_addr        ;
wire    [`VMEM_DATA_BUS]              v_mem_dout        ;
wire    [`VMEM_DATA_BUS]              v_mem_din         ;

wire                            v_wb_en           ;
wire    [`VREG_ADDR_BUS]              v_wb_addr         ;
wire    [`VREG_BUS]              v_wb_data         ;
wire                            v_rs1_en          ;
wire    [`VREG_ADDR_BUS]              v_rs1_addr        ;
wire    [`SREG_BUS]              v_rs1_data        ;
wire                            v_vs1_en          ;
wire    [`VREG_ADDR_BUS]              v_vs1_addr        ;
wire    [`VREG_BUS]              v_vs1_data        ;
wire                            v_vs2_en          ;
wire    [`VREG_ADDR_BUS]              v_vs2_addr        ;
wire    [`VREG_BUS]              v_vs2_data        ;

assign v_rs1_data = vec_rs1_data;
assign vec_rs1_r_ena = v_rs1_en;
assign vec_rs1_r_addr = v_rs1_addr;

v_id V_ID(
    .clk(clk),
    .rst(rst),

    .inst_i(v_inst),
    .rs1_en_o(v_rs1_en),
    .rs1_addr_o(v_rs1_addr),
    .rs1_dout_i(v_rs1_data),
    .vs1_en_o(v_vs1_en),
    .vs1_addr_o(v_vs1_addr),
    .vs1_dout_i(v_vs1_data),
    .vs2_en_o(v_vs2_en),
    .vs2_addr_o(v_vs2_addr),
    .vs2_dout_i(v_vs2_data),
    .valu_opcode_o(v_alu_opcode),
    .operand_v1_o(v_operand_1),
    .operand_v2_o(v_operand_2),
    .vmem_ren_o(v_mem_ren),
    .vmem_wen_o(v_mem_wen),
    .vmem_addr_o(v_mem_addr),
    .vmem_din_o(v_mem_din),
    .vid_wb_en_o(v_id_wb_en),
    .vid_wb_sel_o(v_id_wb_sel),
    .vid_wb_addr_o(v_id_wb_addr)
);

v_alu V_ALU(
    .clk(clk),
    .rst(rst),
    .valu_opcode_i(v_alu_opcode),
    .operand_v1_i(v_operand_1),
    .operand_v2_i(v_operand_2),
    .valu_result_o(v_alu_result)
);

v_mem_access V_MEM(
    .clk(clk),
    .rst(rst),
    .vmem_ren_i(v_mem_ren),
    .vmem_wen_i(v_mem_wen),
    .vmem_addr_i(v_mem_addr),
    .vmem_din_i(v_mem_din),
    .vmem_dout_o(v_mem_dout),
    .vram_r_ena(vram_r_ena),
    .vram_r_addr(vram_r_addr),
    .vram_r_data(vram_r_data),
    .vram_w_ena(vram_w_ena),
    .vram_w_addr(vram_w_addr),
    .vram_w_data(vram_w_data),
    .vram_w_mask(vram_w_mask)
);


v_wb V_WB(
    .clk(clk),
    .rst(rst),
    .vid_wb_en_i(v_id_wb_en),
    .vid_wb_sel_i(v_id_wb_sel),
    .vid_wb_addr_i(v_id_wb_addr),
    .valu_result_i(v_alu_result),
    .vmem_result_i(v_mem_dout),
    .vwb_en_o(v_wb_en),
    .vwb_addr_o(v_wb_addr),
    .vwb_data_o(v_wb_data)
);

v_regfile V_REG(
    .clk(clk),
    .rst(rst),
    .vwb_en_i(v_wb_en),
    .vwb_addr_i(v_wb_addr),
    .vwb_data_i(v_wb_data),
    .vs1_en_i(v_vs1_en),
    .vs1_addr_i(v_vs1_addr),
    .vs1_data_o(v_vs1_data),
    .vs2_en_i(v_vs2_en),
    .vs2_addr_i(v_vs2_addr),
    .vs2_data_o(v_vs2_data)
);

endmodule
