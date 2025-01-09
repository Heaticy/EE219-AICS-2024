// =======================================
// You need to finish this module
// =======================================

module v_alu_2 #(
    parameter SEW       = 32,
    parameter VLMAX     = 8,
    parameter VALUOP_DW = 5,
    parameter VREG_DW   = 256,
    parameter VREG_AW   = 5
)(
    input                   clk,
    input                   rst,
    input [VALUOP_DW-1:0]   valu_opcode_i,
    input [VREG_DW-1:0]     operand_v1_i,
    input [VREG_DW-1:0]     operand_v2_i,
    output reg[VREG_DW-1:0]     valu_result_o
);

localparam VALU_OP_NOP  = 5'd0 ;
localparam VALU_OP_VADD = 5'd1 ;
localparam VALU_OP_VMUL = 5'd2 ;

always@(*)begin
    case (valu_opcode_i)
        VALU_OP_NOP: begin
            valu_result_o = 256'h0;
        end
        VALU_OP_VADD: begin
            valu_result_o = {{operand_v1_i[8*SEW-1-:SEW] + operand_v2_i[8*SEW-1-:SEW]},{operand_v1_i[7*SEW-1-:SEW] + operand_v2_i[7*SEW-1-:SEW]},
                              {operand_v1_i[6*SEW-1-:SEW] + operand_v2_i[6*SEW-1-:SEW]},{operand_v1_i[5*SEW-1-:SEW] + operand_v2_i[5*SEW-1-:SEW]},
                                {operand_v1_i[4*SEW-1-:SEW] + operand_v2_i[4*SEW-1-:SEW]},{operand_v1_i[3*SEW-1-:SEW] + operand_v2_i[3*SEW-1-:SEW]},
                                    {operand_v1_i[2*SEW-1-:SEW] + operand_v2_i[2*SEW-1-:SEW]},{operand_v1_i[1*SEW-1-:SEW] + operand_v2_i[1*SEW-1-:SEW]}};
        end
        VALU_OP_VMUL: begin
            valu_result_o = {{operand_v1_i[8*SEW-1-:SEW] * operand_v2_i[8*SEW-1-:SEW]},{operand_v1_i[7*SEW-1-:SEW] * operand_v2_i[7*SEW-1-:SEW]},
                              {operand_v1_i[6*SEW-1-:SEW] * operand_v2_i[6*SEW-1-:SEW]},{operand_v1_i[5*SEW-1-:SEW] * operand_v2_i[5*SEW-1-:SEW]},
                                {operand_v1_i[4*SEW-1-:SEW] * operand_v2_i[4*SEW-1-:SEW]},{operand_v1_i[3*SEW-1-:SEW] * operand_v2_i[3*SEW-1-:SEW]},
                                    {operand_v1_i[2*SEW-1-:SEW] * operand_v2_i[2*SEW-1-:SEW]},{operand_v1_i[1*SEW-1-:SEW] * operand_v2_i[1*SEW-1-:SEW]}};
        end
        default: begin
            valu_result_o = 256'h0;
        end
    endcase
end


endmodule