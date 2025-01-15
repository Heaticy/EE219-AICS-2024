`include "v_defines.v"
module v_mem_access (
    input                   clk,
    input                   rst,
    
    input                   vmem_ren_i,
    input                   vmem_wen_i,
    input   [`VMEM_ADDR_BUS]    vmem_addr_i,
    input   [`VMEM_DATA_BUS]    vmem_din_i,
    output  [`VMEM_DATA_BUS]    vmem_dout_o,

    output                      vram_r_ena,
    output  [`VRAM_ADDR_BUS]    vram_r_addr,
    input   [`VRAM_DATA_BUS]    vram_r_data,

    output                      vram_w_ena,
    output  [`VRAM_ADDR_BUS]    vram_w_addr,
    output  [`VRAM_DATA_BUS]    vram_w_data,
    output  [`VRAM_DATA_BUS]    vram_w_mask
);

assign vram_r_ena   = vmem_ren_i ;
assign vram_w_ena   = vmem_wen_i ;
assign vram_r_addr  = vmem_addr_i ;
assign vram_w_addr  = vmem_addr_i ;
assign vmem_dout_o  = vram_r_data ;
assign vram_w_data  = vmem_din_i ;
assign vram_w_mask  = {512{1'b1}};

endmodule
