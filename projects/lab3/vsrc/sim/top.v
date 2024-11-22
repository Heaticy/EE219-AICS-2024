`timescale 1ns / 1ps
`define IMG_C 3
`define IMG_W 1
`define IMG_H 1
`define FILTER_NUM 2
`define FILTER_SIZE 3
`define DEBUG 0
`define STATE_IDLE 0
`define STATE_IM2COL 1
`define STATE_SYSTOLIC 2

module pe_top(
    input clk
);

parameter IMG_C         = `IMG_C;
parameter IMG_H         = `IMG_H;
parameter IMG_W         = `IMG_W;
parameter FILTER_NUM    = `FILTER_NUM;
parameter FILTER_SIZE   = `FILTER_SIZE;
parameter M             = `IMG_H * `IMG_W;
parameter N             = `FILTER_SIZE * `FILTER_SIZE * `IMG_C;
parameter K             = `FILTER_NUM;
parameter DATA_WIDTH    = 32;
parameter ADDR_WIDTH    = 32;

parameter MEM_SIZE      = 32'h00005000;
parameter IMG_BASE      = 32'h00000000;
parameter WEIGHT_BASE   = 32'h00001000;
parameter IM2COL_BASE   = 32'h00002000;
parameter OUTPUT_BASE   = 32'h00003000;

reg [DATA_WIDTH*M-1:0] X;
reg [DATA_WIDTH*K-1:0] W;
reg [DATA_WIDTH*M*K-1:0] Y;

reg [DATA_WIDTH*M-1:0] X_buffer [0:N-1];
reg [DATA_WIDTH*K-1:0] W_buffer [0:N-1];

genvar i, j, k;

wire [ADDR_WIDTH-1:0] addr_rd, addr_wr;
reg [DATA_WIDTH-1:0] mem [MEM_SIZE-1:0];
reg [DATA_WIDTH-1:0] data_rd;
wire [DATA_WIDTH-1:0] data_wr;
wire mem_wr_en;

reg rst_im2col, rst_systolic;
wire im2col_done, systolic_done;
reg [1:0] state;
reg rst_n;
reg [1:0] rst_cnt;

im2col #(
    .IMG_C(IMG_C),
    .IMG_W(IMG_W),
    .IMG_H(IMG_H),
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .FILTER_SIZE(FILTER_SIZE),
    .IMG_BASE(IMG_BASE),
    .IM2COL_BASE(IM2COL_BASE)
)im2col(
    .clk(clk),
    .rst_n(rst_im2col),
    .data_rd(data_rd),
    .data_wr(data_wr),
    .addr_rd(addr_rd),
    .addr_wr(addr_wr),
    .done(im2col_done),
    .mem_wr_en(mem_wr_en)
);

systolic_array #(
    .M(M),
    .N(N),
    .K(K),
    .DATA_WIDTH(DATA_WIDTH)
)systolic_array(
    .clk(clk),
    .rst_n(rst_systolic),
    .X(X),
    .W(W),
    .Y(Y),
    .done(systolic_done)
);

// Memory
always @(posedge clk) begin
    data_rd <= mem[addr_rd];
    if (mem_wr_en) begin
        mem[addr_wr] <= data_wr;
    end
end

always@(posedge clk) begin
    case(state)
        `STATE_IDLE: begin
            rst_im2col      <= 1;
            rst_systolic    <= 1;
            $writememh("../mem/mem_out.txt", mem);
            if (!rst_n) begin
                state       <= `STATE_IDLE;
            end
            else begin
                state       <= `STATE_IM2COL;
            end
        end
        `STATE_IM2COL: begin
            rst_im2col      <= 1;
            rst_systolic    <= 0;
            if (im2col_done) begin
                state       <= `STATE_SYSTOLIC;
            end
            else begin
                state       <= `STATE_IM2COL;
            end
        end
        `STATE_SYSTOLIC: begin
            rst_im2col      <= 0;
            rst_systolic    <= 1;
            if (systolic_done) begin
                state       <= `STATE_IDLE;
            end
            else begin
                state       <= `STATE_SYSTOLIC;
            end
        end
    endcase
end

always@(posedge clk) begin
    if (rst_cnt == 0) begin
        rst_n               <= 0;
        rst_cnt             <= 0;
    end
    else begin
        if (rst_cnt == 1) begin
            rst_n           <= 1;
        end 
        if (rst_cnt == 2) begin
            rst_n           <= 0;
        end 
        rst_cnt             <= rst_cnt - 1;
    end
end


initial begin
    $readmemh("../mem/mem_init.txt", mem);
    state        = `STATE_IDLE;
    rst_cnt      = 2'b11;
end

for (i = 0; i < N; i = i + 1) begin
    for (j = 0; j < K; j = j + 1) begin
        always@(posedge im2col_done) begin
            W_buffer[i][(j+1)*DATA_WIDTH-1:j*DATA_WIDTH] <= mem[WEIGHT_BASE + i*K +j];
        end
    end
end

for (i = 0; i < N; i = i + 1) begin
    for (j = 0; j < M; j = j + 1) begin
        always@(posedge im2col_done) begin
            X_buffer[i][(j+1)*DATA_WIDTH-1:j*DATA_WIDTH] <= mem[IM2COL_BASE + i*M +j];
        end
    end
end

reg [31:0] X_count;
always@(posedge clk or negedge rst_systolic) begin
    if (!rst_systolic) begin
        X       <= 0;
        W       <= 0;
        X_count <= 0;
    end
    else begin
        X_count <= X_count + 1;
        if (X_count < N) begin
            X   <= X_buffer[X_count];  
            W   <= W_buffer[X_count];        
        end
        else begin
            X   <= 0;
        end
    end
end

for (i = 0; i < M; i = i + 1) begin
    for (j = 0; j < K; j = j + 1) begin
        always@(posedge systolic_done) begin
            mem[OUTPUT_BASE + i*K+j] = Y[i*K*DATA_WIDTH+(j+1)*DATA_WIDTH-1:i*K*DATA_WIDTH+j*DATA_WIDTH];
        end
    end
end

endmodule