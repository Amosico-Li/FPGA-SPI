/* 
 * @Module Name  : spi_master_debug
 * @Autor        : Amosico
 * @CreateTime   : 2025-08-19 16:37
 * @LastEditTime : 2025-08-20 11:12:08
 * @Version      : DEBUG V1.0
 */

module spi_master_debug # (
    parameter BIT_WIDTH = 16, 
    parameter CLK_DIV = 10
)(
    /* driver signals */
    input logic clk,
    input logic rst_n,
    input logic start,
    /* spi interface */
    output logic sclk,
    output logic nss,
    input logic miso,
    output logic mosi,
    output logic done,
    /* data interface */
    output reg [BIT_WIDTH-1:0] rdata,
    input logic [BIT_WIDTH-1:0] wdata,
    /* debug interface */
    input logic cpol,
    input logic cpha,
    input logic lsbf
);
    localparam DEBUG_VIERSION = 1;
    localparam IDLE = 'd1;  
    localparam ALIGN = 'd2;                        
    localparam TRANS = 'd4;
    reg [2:0] state, next;                          // state machine

    wire start_en;
    reg stop;
    wire edge_1;               
    wire edge_2;                 
    wire wr_edge;                                   // write edge for data transfer
    wire rd_edge;                                   // read edge for data transfer
    reg [15:0]ccnt;                                 // clock counter for sclk generation 
    reg [4:0] bcnt;                                 // bit counter for data transfer
    reg [BIT_WIDTH - 1:0] rdata_tmp ;               // temporary register for received data
    reg [BIT_WIDTH - 1:0] wdata_tmp;                // temporary register for write data   

    /*--------- Start Detect ---------*/
    edge_detector #(
        .MODE(0)            
    ) e_d_1 (
        .clk(clk),
        .rst_n(rst_n),
        .signal(start),
        .pulse(start_en)
    );

    /*----------- SCLK NSS -----------*/
    assign edge_1 = (ccnt == 'd0);
    assign edge_2 = (ccnt == CLK_DIV / 2);

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            ccnt <= 'd0;
        else if(ccnt < CLK_DIV - 'd1)
            ccnt <= ccnt + 'd1;
        else
            ccnt <= 'd0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            sclk <= cpol;
        else if ((state == TRANS) & (bcnt != BIT_WIDTH)) begin
            if(edge_1 | edge_2)
                sclk <= ~sclk;
        end
        else begin
            sclk <= cpol; 
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            nss <= 1'b1; 
        else if((bcnt == BIT_WIDTH) && edge_2)        
            nss <= 1'b1;
        else if((state == ALIGN) && edge_1)
            nss <= 1'b0; 
    end

    /*--------- SPI transfer data ---------*/
    assign wr_edge = cpha ? edge_2 : edge_1; 
    assign rd_edge = cpha ? edge_1 : edge_2;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            bcnt <= 'd0;
        else if(start_en)
            bcnt <= 'd0;
        else if(edge_1 & (state == TRANS))
            bcnt <= bcnt + 'd1;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            stop <= 1'b0;
        else if((bcnt == BIT_WIDTH - 1) && edge_1)
            stop <= 1'b1;
        else 
            stop <= 1'b0;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            done <= 1'b0;
        else if(stop)
            done <= 1'b1;
        else 
            done <= 1'b0;
    end

    /* Part: Read */
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            rdata_tmp <= 'd0;
        else if(start_en)
            rdata_tmp <= 'd0;
        else if(rd_edge && (state == TRANS) && (bcnt != BIT_WIDTH)) begin
            if(lsbf)
                rdata_tmp <= {miso, rdata_tmp[BIT_WIDTH-1:1]};  
            else
                rdata_tmp <= {rdata_tmp[BIT_WIDTH-2:0], miso};  
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            rdata <= 'd0;
        else if(stop)
            rdata <= rdata_tmp;
    end

    /* Part: Write */
    // PS: Whatever read operation at the left or right edge.
    //     Data should be prepared at the read edge.
    //     And MOSI should be updated at the write edge.
    //    (Other slaves read data according to the specified read edge)
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            wdata_tmp <= 'd0;
        else if(start_en)
            wdata_tmp <= wdata;
        else if((state == TRANS) && rd_edge) begin
            if(lsbf)
                wdata_tmp <= (wdata_tmp >> 1);
            else    
                wdata_tmp <= (wdata_tmp << 1);
        end
    end

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            mosi <= 'd0;
        else if(start_en) begin
            if(lsbf)
                mosi <= wdata[0];
            else
                mosi <= wdata[BIT_WIDTH-1];
        end
        else if((state == TRANS) && wr_edge) begin
            if(lsbf)
                mosi <= wdata_tmp[0];
            else    
                mosi <= wdata_tmp[BIT_WIDTH-1];
        end
    end


    /*--------------- SPI SM ---------------*/
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            state <= IDLE;
        else
            state <= next;
    end

    always @(*) begin
        if(!rst_n) begin
            next = IDLE;
        end
        else begin
            case (state)
                IDLE: begin
                    if (start_en) 
                        next <= ALIGN;
                    else    
                        next <= IDLE;
                end
                ALIGN: begin
                    if(edge_1)
                        next <= TRANS;
                    else
                        next <= ALIGN;
                end 
                TRANS: begin
                    if ((bcnt == BIT_WIDTH) && edge_2)
                        next <= IDLE;
                    else
                        next <= TRANS;
                end

            endcase
        end
    end



endmodule