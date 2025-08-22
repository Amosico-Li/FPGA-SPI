/* 
 * @Module Name  : spi_slave
 * @Autor        : Amosico
 * @CreateTime   : 2025-08-12 17:49:18
 * @LastEditTime : 2025-08-22 09:59:33
 * @Version      : 0
 */


module spi_slave_debug #(
    parameter BIT_WIDTH = 8
)(
    /* driver signals */
    input logic clk,
    input logic rst_n,
    /* spi interface */
    input logic sclk,
    input logic nss,
    output logic miso,
    input logic mosi,
    output logic done,
    /* data interface */
    output logic [BIT_WIDTH - 1:0] rdata,
    input logic [BIT_WIDTH - 1:0] wdata,
    /* debug interface */
    input logic cpol,
    input logic cpha,
    input logic lsbf
);

    parameter IDLE = 3'd1;
    parameter TRANS = 3'd4;

    reg [2:0] state;
    reg [2:0] next;
    reg start_en;
    reg [1:0] nss_dly;
    reg [1:0] sclk_dly;  
    reg [1:0] mosi_dly;
    reg sclk_pe;
    reg sclk_ne;
    wire edge_1;
    wire edge_2;
    wire rd_edge;
    reg stop;
    reg load;
    reg [5:0] bcnt;
    reg [BIT_WIDTH - 1:0] rdata_tmp;
    reg [BIT_WIDTH - 1:0] wdata_tmp;


    /* Signal(Input) Delay */
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            nss_dly <= 'd0;
        else
            nss_dly <= {nss_dly[0], nss};
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            sclk_dly <= 'd0;
        else
            sclk_dly <= {sclk_dly[0], sclk};
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            mosi_dly <= 'd0;
        else
            mosi_dly <= {mosi_dly[0], mosi};
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sclk_pe <= 1'b0;
            sclk_ne <= 1'b0;
        end 
        else begin
            sclk_pe <= (sclk_dly[1:0] == 2'b01);
            sclk_ne <= (sclk_dly[1:0] == 2'b10);
        end
    end



    assign edge_1 = cpol ? sclk_ne : sclk_pe;    
    assign edge_2 = cpol ? sclk_pe : sclk_ne;
    assign rd_edge = (cpha) ? edge_2 : edge_1;
    assign wr_edge = (cpha) ? edge_1 : edge_2;
    assign start_en = (nss_dly[1:0] == 2'b10);

    /* Part: Read */
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            bcnt <= 'd0;
        else if((bcnt == BIT_WIDTH) && edge_2 || nss_dly[1])
            bcnt <= 'd0;
        else if(edge_1 && (state == TRANS))
            bcnt <= bcnt + 'd1;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            rdata_tmp <= 'd0;
        else if(start_en)
            rdata_tmp <= 'd0;
        else if (rd_edge && (state == TRANS)) begin
            if(lsbf == 0)
                rdata_tmp <= {rdata_tmp[BIT_WIDTH-2:0], mosi_dly[1]};
            else
                rdata_tmp <= {mosi_dly[1], rdata_tmp[BIT_WIDTH-1:1]};
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            stop <= 1'd0;
        else if((bcnt == BIT_WIDTH) && edge_2)
            stop <= 1'd1;
        else 
            stop <= 1'd0;
    end 

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            done <= 1'b0;
        else if(stop)
            done <= 1'b1;
        else
            done <= 1'b0;
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            rdata <= 'd0;
        else if(stop)
            rdata <= rdata_tmp;
    end


    /* Part: Write */
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            load <= 'd0;
        else 
            load <= done;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            wdata_tmp <= 'dz;
        else if(start_en || load)
            wdata_tmp <= wdata;
        else if(rd_edge && (state == TRANS)) begin
            if(lsbf)
                wdata_tmp <= wdata_tmp >> 1;
            else
                wdata_tmp <= wdata_tmp << 1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            miso <= 'dz;
        else if(start_en || load)
            if(lsbf)
                miso <= wdata[0];
            else 
                miso <= wdata[BIT_WIDTH-1];
        else if(wr_edge && (state == TRANS))
            if(lsbf)
                miso <= wdata_tmp[0];
            else 
                miso <= wdata_tmp[BIT_WIDTH-1];
    end



    /* Part: FSM */
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
                        next <= TRANS;
                    else    
                        next <= IDLE;
                end
                TRANS: begin
                    if (nss_dly[1])
                        next <= IDLE;
                    else
                        next <= TRANS;
                end

            endcase
        end
    end


endmodule