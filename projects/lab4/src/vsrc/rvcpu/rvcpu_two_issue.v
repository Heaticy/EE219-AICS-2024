// =======================================
// You need to finish this module
// =======================================

module rvcpu_two_issue #(
    parameter PC_START  = 32'h8000_0000, 
    parameter ISSUE_NUM = 2,
    parameter INST_DW   = 32,
    parameter INST_AW   = 32,
    parameter MEM_DW    = 32,
    parameter MEM_AW    = 32,
    parameter RAM_DW    = 32,
    parameter RAM_AW    = 32,
    parameter REG_DW    = 32,
    parameter REG_AW    = 5,
    parameter ALUOP_DW  = 5,

    parameter SEW       = 32, 
    parameter VLMAX     = 8,
    parameter VALUOP_DW = 5,
    parameter VREG_DW   = 256,
    parameter VREG_AW   = 5,
    parameter VMEM_DW   = 256,
    parameter VMEM_AW   = 32,
    parameter VRAM_DW   = 256,
    parameter VRAM_AW   = 32
)(
    input                           clk,
    input                           rst,

    output                          inst_en_o,
    output  [INST_AW-1:0]           inst_addr_o,
    input   [INST_DW*ISSUE_NUM-1:0] inst_i,

    output                          ram_ren_o,
    output                          ram_wen_o,
    output  [RAM_AW-1:0]            ram_addr_o,
    output  [RAM_DW-1:0]            ram_mask_o,
    output  [RAM_DW-1:0]            ram_din_o,
    input   [RAM_DW-1:0]            ram_dout_i,

    output                          vram_ren_o,
    output                          vram_wen_o,
    output  [VRAM_AW-1:0]           vram_addr_o,
    output  [VRAM_DW-1:0]           vram_mask_o,
    output  [VRAM_DW-1:0]           vram_din_o,
    input   [VRAM_DW-1:0]           vram_dout_i
);

wire    [INST_DW*ISSUE_NUM-1:0]  inst            ;
wire    [INST_DW-1:0]            s_inst          ;
wire    [INST_DW-1:0]            v_inst        ;
assign  s_inst = inst[INST_DW-1:0];
assign  v_inst = inst[2*INST_DW-1:INST_DW];

wire    [ALUOP_DW-1:0]            s_alu_opcode      ;
wire    [REG_DW-1:0]              s_operand_1       ;
wire    [REG_DW-1:0]              s_operand_2       ;
wire                            s_branch_en       ;
wire    [INST_AW-1:0]            s_branch_offset   ;
wire                            s_jump_en         ;
wire    [INST_AW-1:0]            s_jump_offset     ;
wire                            s_mem_ren         ;
wire                            s_mem_wen         ;
wire                            s_id_wb_en        ;
wire                            s_id_wb_sel       ;
wire    [REG_AW-1:0]              s_id_wb_addr      ;

wire                             control_en      ;
wire    [INST_AW-1:0]            control_pc      ;
wire    [INST_AW-1:0]            current_pc      ;

wire    [REG_DW-1:0]              s_alu_result      ;

wire    [MEM_AW-1:0]              s_mem_addr        ;
wire    [MEM_DW-1:0]              s_mem_dout        ;
wire    [MEM_DW-1:0]              s_mem_din         ;

wire                            s_wb_en           ;
wire    [REG_AW-1:0]              s_wb_addr         ;
wire    [REG_DW-1:0]              s_wb_data         ;
wire                            s_rs1_en          ;
wire    [REG_AW-1:0]              s_rs1_addr        ;
wire    [REG_DW-1:0]              s_rs1_data        ;
wire                            s_rs2_en          ;
wire    [REG_AW-1:0]              s_rs2_addr        ;
wire    [REG_DW-1:0]              s_rs2_data        ;

wire    [VALUOP_DW-1:0]            v_alu_opcode      ;
wire    [VREG_DW-1:0]              v_operand_1       ;
wire    [VREG_DW-1:0]              v_operand_2       ;
wire                            v_mem_ren         ;
wire                            v_mem_wen         ;
wire                            v_id_wb_en        ;
wire                            v_id_wb_sel       ;
wire    [VREG_AW-1:0]              v_id_wb_addr      ;

wire    [VREG_DW-1:0]            v_alu_result      ;

wire    [VMEM_AW-1:0]              v_mem_addr        ;
wire    [VMEM_DW-1:0]              v_mem_dout        ;
wire    [VMEM_DW-1:0]              v_mem_din         ;

wire                            v_wb_en           ;
wire    [VREG_AW-1:0]              v_wb_addr         ;
wire    [VREG_DW-1:0]              v_wb_data         ;
wire                            v_rs1_en          ;
wire    [REG_AW-1:0]              v_rs1_addr        ;
wire    [REG_DW-1:0]              v_rs1_data        ;
wire                            v_vs1_en          ;
wire    [VREG_AW-1:0]              v_vs1_addr        ;
wire    [VREG_DW-1:0]              v_vs1_data        ;
wire                            v_vs2_en          ;
wire    [VREG_AW-1:0]              v_vs2_addr        ;
wire    [VREG_DW-1:0]              v_vs2_data        ;


mi_inst_fetch #(
    .PC_START(PC_START),
    .ISSUE_NUM(ISSUE_NUM),
    .INST_DW(INST_DW),
    .INST_AW(INST_AW)
)M_IF(
    .clk(clk),
    .rst(rst),

    .control_en_i(control_en),
    .control_pc_i(control_pc),
    .current_pc_o(current_pc),

    .inst_en_o(inst_en_o),
    .inst_addr_o(inst_addr_o),
    .inst_i(inst_i),
    .inst_o(inst)
);

si_inst_decode #(
    .INST_DW(INST_DW),
    .INST_AW(INST_AW),
    .MEM_AW(MEM_AW),
    .REG_DW(REG_DW),
    .REG_AW(REG_AW),
    .ALUOP_DW(ALUOP_DW)
)S_ID(
    .clk(clk),
    .rst(rst),

    .inst_i(s_inst),

    .rs1_en_o(s_rs1_en),
    .rs1_addr_o(s_rs1_addr),
    .rs1_dout_i(s_rs1_data),
    .rs2_en_o(s_rs2_en),
    .rs2_addr_o(s_rs2_addr),
    .rs2_dout_i(s_rs2_data),

    .alu_opcode_o(s_alu_opcode),
    .operand_1_o(s_operand_1),
    .operand_2_o(s_operand_2),
    .branch_en_o(s_branch_en),
    .branch_offset_o(s_branch_offset),
    .jump_en_o(s_jump_en),
    .jump_offset_o(s_jump_offset),
    .mem_ren_o(s_mem_ren),
    .mem_wen_o(s_mem_wen),
    .mem_din_o(s_mem_din),
    .id_wb_en_o(s_id_wb_en),
    .id_wb_sel_o(s_id_wb_sel),
    .id_wb_addr_o(s_id_wb_addr)
);

v_id #(
    .VLMAX(VLMAX),
    .VALUOP_DW(VALUOP_DW),
    .VMEM_DW(VMEM_DW),
    .VMEM_AW(VMEM_AW),
    .VREG_DW(VREG_DW),
    .VREG_AW(VREG_AW),
    .INST_DW(INST_DW),
    .REG_DW(REG_DW),
    .REG_AW(REG_AW)
)V_ID(
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


si_alu #(
    .PC_START(PC_START),
    .INST_DW(INST_DW),
    .INST_AW(INST_AW),
    .REG_DW(REG_DW),
    .ALUOP_DW(ALUOP_DW)
)S_ALU(
    .clk(clk),
    .rst(rst),

    .alu_opcode_i(s_alu_opcode),
    .operand_1_i(s_operand_1),
    .operand_2_i(s_operand_2),
    .alu_result_o(s_alu_result),
    .current_pc_i(current_pc),
    .branch_en_i(s_branch_en),
    .branch_offset_i(s_branch_offset),
    .jump_en_i(s_jump_en),
    .jump_offset_i(s_jump_offset),
    .control_en_o(control_en),
    .control_pc_o(control_pc)
);

v_alu #(
    .SEW(SEW),
    .VLMAX(VLMAX),
    .VALUOP_DW(VALUOP_DW),
    .VREG_DW(VREG_DW),
    .VREG_AW(VREG_AW)
)V_ALU(
    .clk(clk),
    .rst(rst),
    .valu_opcode_i(v_alu_opcode),
    .operand_v1_i(v_operand_1),
    .operand_v2_i(v_operand_2),
    .valu_result_o(v_alu_result)
);
    

assign s_mem_addr = s_alu_result;

si_mem_access #( 
    .MEM_DW(MEM_DW),
    .MEM_AW(MEM_AW),
    .RAM_DW(RAM_DW),
    .RAM_AW(RAM_AW)
)S_MEM(
    .clk(clk),
    .rst(rst),
    .mem_ren_i(s_mem_ren),
    .mem_wen_i(s_mem_wen),
    .mem_addr_i(s_mem_addr),
    .mem_din_i(s_mem_din),
    .mem_dout_o(s_mem_dout),
    .ram_ren_o(ram_ren_o),
    .ram_wen_o(ram_wen_o),
    .ram_addr_o(ram_addr_o),
    .ram_mask_o(ram_mask_o),
    .ram_din_o(ram_din_o),
    .ram_dout_i(ram_dout_i)
);

v_mem_access #(
    .VMEM_DW(VMEM_DW),
    .VMEM_AW(VMEM_AW),
    .VRAM_DW(VRAM_DW),
    .VRAM_AW(VRAM_AW)
)V_MEM(
    .clk(clk),
    .rst(rst),
    .vmem_ren_i(v_mem_ren),
    .vmem_wen_i(v_mem_wen),
    .vmem_addr_i(v_mem_addr),
    .vmem_din_i(v_mem_din),
    .vmem_dout_o(v_mem_dout),
    .vram_ren_o(vram_ren_o),
    .vram_wen_o(vram_wen_o),
    .vram_addr_o(vram_addr_o),
    .vram_mask_o(vram_mask_o),
    .vram_din_o(vram_din_o),
    .vram_dout_i(vram_dout_i)
);

si_write_back #(
    .REG_DW(REG_DW),
    .REG_AW(REG_AW)
)S_WB(
    .clk(clk),
    .rst(rst), 
    .id_wb_en_i(s_id_wb_en),
    .id_wb_addr_i(s_id_wb_addr),
    .id_wb_sel_i(s_id_wb_sel),
    .alu_result_i(s_alu_result),
    .mem_result_i(s_mem_dout),
    .wb_en_o(s_wb_en),
    .wb_addr_o(s_wb_addr),
    .wb_data_o(s_wb_data)
);

v_wb #(
    .VREG_DW(VREG_DW),
    .VREG_AW(VREG_AW)
)V_WB(
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

mi2_regfile #(
    .REG_DW(REG_DW),
    .REG_AW(REG_AW)
)M_REG(
    .clk(clk),
    .rst(rst),
    .is1_wb_en_i(s_wb_en),
    .is1_wb_addr_i(s_wb_addr),
    .is1_wb_data_i(s_wb_data),
    .is1_rs1_en_i(s_rs1_en),
    .is1_rs1_addr_i(s_rs1_addr),
    .is1_rs1_data_o(s_rs1_data),
    .is1_rs2_en_i(s_rs2_en),
    .is1_rs2_addr_i(s_rs2_addr),
    .is1_rs2_data_o(s_rs2_data),
    .is2_rs1_en_i(v_rs1_en),
    .is2_rs1_addr_i(v_rs1_addr),
    .is2_rs1_data_o(v_rs1_data)
);

v_regfile #(
    .VREG_DW(VREG_DW),
    .VREG_AW(VREG_AW)
)V_REG(
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
