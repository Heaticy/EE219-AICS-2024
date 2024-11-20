`timescale 1ns / 1ps

module im2col #(
    parameter IMG_C         = 1,
    parameter IMG_W         = 8,
    parameter IMG_H         = 8,
    parameter DATA_WIDTH    = 8,
    parameter ADDR_WIDTH    = 32,
    parameter FILTER_SIZE   = 3,
    parameter IMG_BASE      = 16'h0000,
    parameter IM2COL_BASE   = 16'h2000
) (
    input clk,
    input rst_n,
    input [DATA_WIDTH-1:0] data_rd,
    output reg[DATA_WIDTH-1:0] data_wr,
    output reg[ADDR_WIDTH-1:0] addr_wr,
    output reg[ADDR_WIDTH-1:0] addr_rd,
    output reg done,
    output reg mem_wr_en
);

parameter FILTER_WINDOW_SIZE = FILTER_SIZE * FILTER_SIZE *IMG_C;
parameter IMG_SIZE = IMG_W * IMG_H;
reg [(IMG_C) * (IMG_W + 2)*(IMG_H + 2) - 1 : 0] IMG_PADDING_BUFFER;
parameter IMG_C_WIDTH = 32;
parameter IMG_W_WIDTH = 32;
parameter IMG_H_WIDTH = 32;
parameter FILTER_SIZE_WIDTH = 32;
parameter PADDING_SIZE = (FILTER_SIZE - 1) / 2;
parameter PADDING_W = IMG_W + 2*PADDING_SIZE;
parameter PADDING_H = IMG_H + 2*PADDING_SIZE;
reg [IMG_C_WIDTH-1:0] channel;
reg [IMG_W_WIDTH-1:0] col;
reg [IMG_H_WIDTH-1:0] row;
reg [FILTER_SIZE_WIDTH-1:0] filter_row;
reg [FILTER_SIZE_WIDTH-1:0] filter_col;


parameter IDLE = 0;
parameter READING = 1;
parameter WRITING = 2;
parameter DONE = 3;

reg [1:0] current_state;
reg [1:0] next_state;
reg[31:0]x;
always@(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

always@(*)begin
    case(current_state)
        IDLE: begin
            next_state = READING;
        end
        READING: begin
            if (channel == IMG_C - 1 && row == PADDING_H - 1 && col == PADDING_W - 1) begin
                next_state = WRITING;
            end
            else begin
                next_state = READING;
            end
        end
        WRITING: begin
            if(channel == IMG_C - 1 && row == IMG_H - 1 && col == IMG_W - 1&& filter_row == FILTER_SIZE - 1 && filter_col == FILTER_SIZE - 1)begin
                next_state = DONE;
            end
            else begin
                next_state = WRITING;
            end
        end
        DONE: begin
            next_state = DONE;
        end
    endcase
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        done <= 0;
        channel <= 0;
        col <= 0;
        row <= 0;
        filter_col <= 0;
        filter_row <= 0;
        addr_rd <= IMG_BASE;
        addr_wr <= IM2COL_BASE;
        mem_wr_en <= 0;
        IMG_PADDING_BUFFER <= 0;
    end
    case(current_state)
        IDLE: begin
            done <= 0;
            channel <= 0;
            col <= 0;
            row <= 0;
            filter_col <= 0;
            filter_row <= 0;
            addr_rd <= IMG_BASE;
            addr_wr <= IM2COL_BASE;
            data_wr <= 0;
            mem_wr_en <= 0;
            IMG_PADDING_BUFFER <= 0;
        end
        READING: begin
            done <= 0;
            addr_rd <= addr_rd + DATA_WIDTH;
            x<= ((channel * PADDING_W * PADDING_H) + (row * PADDING_W) + col + 1) * DATA_WIDTH - 1 ;
            IMG_PADDING_BUFFER[( (channel * PADDING_W * PADDING_H) + (row * PADDING_W) + col + 1) * DATA_WIDTH - 1 -: DATA_WIDTH] <= data_rd[DATA_WIDTH-1:0];
            if(col == PADDING_W -1)begin
                col <= 0;
                if(row == PADDING_H -1)begin
                    row <= 0;
                    if(channel == IMG_C - 1)begin
                        channel <= 0;
                        mem_wr_en <= 1;
                    end
                    else begin
                        channel <= channel + 1;
                    end
                end
                else begin
                    row <= row + 1;
                end
            end
            else begin
                col <= col + 1;
            end
        end
        WRITING: begin
            done <= 0;
            mem_wr_en <= 1;
            addr_wr <= addr_wr + DATA_WIDTH;
            if(filter_col == FILTER_SIZE - 1)begin
                filter_col <= 0;
                if(filter_row == FILTER_SIZE - 1)begin
                    filter_row <= 0;
                    if(channel == IMG_C - 1)begin
                        channel <= 0;
                        if(col == IMG_W - 1)begin
                            col <= 0;
                            if(row == IMG_H - 1)begin
                                row <= 0;
                            end
                            else begin
                                row <= row + 1;
                            end
                        end
                        else begin
                            col <= col + 1;
                        end
                    end
                    else begin
                        channel <= channel + 1;
                    end
                end
                else begin
                    filter_row <= filter_row + 1;
                end
            end
            else begin
                filter_col <= filter_col + 1;
            end
            data_wr[DATA_WIDTH-1:0] <= IMG_PADDING_BUFFER[(channel * (PADDING_H) * (PADDING_W) + (row + filter_row) * (PADDING_W) + col + filter_col + 1) * DATA_WIDTH - 1 -: DATA_WIDTH];
        end
        DONE: begin
            done <= 1;
            mem_wr_en <= 0;
        end

    endcase
end

assign done = 1; // you should overwrite this

endmodule