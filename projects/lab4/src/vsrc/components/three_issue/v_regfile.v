// =======================================
// You need to finish this module
// =======================================

module v_regfile #(
    parameter VREG_DW    = 256,
    parameter VREG_AW    = 5
)(
    input                       clk,
    input                       rst,

    input                       is1_vwb_en_i,
    input       [VREG_AW-1:0]   is1_vwb_addr_i,
    input       [VREG_DW-1:0]   is1_vwb_data_i,

    input                       is1_vs1_en_i,
    input       [VREG_AW-1:0]   is1_vs1_addr_i,
    output reg  [VREG_DW-1:0]   is1_vs1_data_o,

    input                       is1_vs2_en_i,
    input       [VREG_AW-1:0]   is1_vs2_addr_i,
    output reg  [VREG_DW-1:0]   is1_vs2_data_o,

    input                       is2_vwb_en_i,
    input       [VREG_AW-1:0]   is2_vwb_addr_i,
    input       [VREG_DW-1:0]   is2_vwb_data_i,

    input                       is2_vs1_en_i,
    input       [VREG_AW-1:0]   is2_vs1_addr_i,
    output reg  [VREG_DW-1:0]   is2_vs1_data_o,

    input                       is2_vs2_en_i,
    input       [VREG_AW-1:0]   is2_vs2_addr_i,
    output reg  [VREG_DW-1:0]   is2_vs2_data_o
);

endmodule
