// =======================================
// You need to finish this module
// =======================================

`include "v_defines.v"

module v_id #(
    parameter VLMAX     = 8,
    parameter VALUOP_DW = 5,
    parameter VMEM_DW   = 512,
    parameter VMEM_AW   = 64,
    parameter VREG_DW   = 512,
    parameter VREG_AW   = 5,
    parameter INST_DW   = 32,
    parameter REG_DW    = 64,
    parameter REG_AW    = 5
) (
    input                   clk,
    input                   rst,

    input   [INST_DW-1:0]   inst_i,

    output  reg                rs1_en_o,
    output  reg[REG_AW-1:0]    rs1_addr_o,
    input   [REG_DW-1:0]    rs1_dout_i,

    output  reg                vs1_en_o,
    output  reg[VREG_AW-1:0]   vs1_addr_o,
    input   [VREG_DW-1:0]   vs1_dout_i,

    output  reg                vs2_en_o,
    output  reg[VREG_AW-1:0]   vs2_addr_o,
    input   [VREG_DW-1:0]   vs2_dout_i,

    output  reg[VALUOP_DW-1:0] valu_opcode_o,
    output  reg[VREG_DW-1:0]   operand_v1_o,
    output  reg[VREG_DW-1:0]   operand_v2_o,

    output  reg                vmem_ren_o,
    output  reg                vmem_wen_o,
    output  reg[VMEM_AW-1:0]   vmem_addr_o,
    output  reg[VMEM_DW-1:0]   vmem_din_o,

    output  reg                vid_wb_en_o,
    output  reg                vid_wb_sel_o,
    output  reg[VREG_AW-1:0]   vid_wb_addr_o
);

localparam VALU_OP_NOP  = 5'd0 ;
localparam VALU_OP_VADD = 5'd1 ;
localparam VALU_OP_VMUL = 5'd2 ;

wire [6:0] opcode = inst_i[6:0];
wire [4:0] vd = inst_i[11:7];
wire [5:0] funct6 = inst_i[31:26];
wire [2:0] funct3 = inst_i[14:12];
assign rs1_en_o = 1'b1;
assign rs1_addr_o = inst_i[19:15];
assign vs1_en_o = 1'b1;
assign vs1_addr_o = inst_i[19:15];
assign vs2_en_o = 1'b1;
assign vmem_addr_o = rs1_dout_i;
assign vmem_din_o = vs2_dout_i;
assign operand_v2_o = vs2_dout_i;
assign vid_wb_addr_o = vd;

always @(*) begin
    case(opcode)
        7'b0000111: begin
            vs2_addr_o = inst_i[24:20];
            valu_opcode_o = VALU_OP_NOP;
            operand_v1_o = vs1_dout_i;
            vid_wb_en_o = 1'b1;
            vid_wb_sel_o = 1'b1;
            vmem_ren_o = 1'b1;
            vmem_wen_o = 1'b0;
        end
        7'b0100111: begin
            vs2_addr_o = inst_i[11:7];
            valu_opcode_o = VALU_OP_NOP;
            operand_v1_o = vs1_dout_i;
            vid_wb_en_o = 1'b0;
            vid_wb_sel_o = 1'b0;
            vmem_ren_o = 1'b0;
            vmem_wen_o = 1'b1;
        end
        7'b1010111: begin
            vs2_addr_o = inst_i[24:20];
            vmem_ren_o = 1'b0;
            vmem_wen_o = 1'b0;
            vid_wb_en_o = 1'b1;
            vid_wb_sel_o = 1'b0;
            case(funct6)
                6'b000000: begin
                    valu_opcode_o = VALU_OP_VADD;
                    case (funct3)
                        3'b000: begin
                            operand_v1_o = vs1_dout_i;
                        end
                        3'b011: begin
                            operand_v1_o = {8{{60{inst_i[19]}},inst_i[18:15]}};
                        end
                        3'b100: begin
                            operand_v1_o = {8{rs1_dout_i}};
                        end
                        default: begin
                            operand_v1_o = vs1_dout_i;
                        end
                    endcase
                end
                6'b100101: begin
                    valu_opcode_o = VALU_OP_VMUL;
                    case (funct3)
                        3'b000: begin
                            operand_v1_o = vs1_dout_i;
                        end
                        3'b011: begin
                            operand_v1_o = {8{{60{inst_i[19]}},inst_i[18:15]}};
                        end
                        3'b100: begin
                            operand_v1_o = {8{rs1_dout_i}};
                        end
                        default: begin
                            operand_v1_o = vs1_dout_i;
                        end
                    endcase
                end
                default: begin
                    valu_opcode_o = VALU_OP_NOP;
                end
            endcase
        end
        default: begin
            valu_opcode_o = VALU_OP_NOP;
            vs2_addr_o = inst_i[24:20];
            operand_v1_o = vs1_dout_i;
            vid_wb_en_o = 1'b0;
            vid_wb_sel_o = 1'b0;
            vmem_ren_o = 1'b0;
            vmem_wen_o = 1'b0;
        end
    endcase
end

endmodule

