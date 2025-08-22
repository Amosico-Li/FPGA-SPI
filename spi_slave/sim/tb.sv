`timescale 1ns/1ps
//`define _SPI_SLAVE
module tb;
    /* Driver Signals and Parameters */
    parameter N = 8;
    parameter CLK_DIV = 20;
    reg clk;
    reg rst_n;
    reg start;
    reg cpol;
    reg cpha;
    reg lsbf;
    reg[N-1:0] m_wdata;
    reg[N-1:0] s_wdata;

    /* SPI Interface */
    wire nss;
    wire sclk;
    wire mosi;
    wire miso;
    wire m_done;
    wire s_done;

    /* Data */
    wire[N-1:0] m_rdata;
    wire[N-1:0] s_rdata;

    always #5 clk = ~clk;          //100MHz clock generation


    /* ------------------------Initialize Part------------------------ */
    initial begin
        clk = 0;
        rst_n = 0;
        #5 rst_n = 1;
    end

     initial begin
        cpol = 0;
        cpha = 0;
        lsbf = 0;
        start = 0;
        m_wdata = 'd0; 
        @(posedge rst_n);
        #8us set_para(0, 0, 0); m_send(8'h12); m_send(8'h34);
        #2us set_para(0, 0, 1); m_send(8'h56); m_send(8'h78);
        #8us set_para(0, 1, 0); m_send(8'h12); m_send(8'h34);
        #2us set_para(0, 1, 1); m_send(8'h56); m_send(8'h78);
        #8us set_para(1, 0, 0); m_send(8'h12); m_send(8'h34);
        #2us set_para(1, 0, 1); m_send(8'h56); m_send(8'h78);
        #8us set_para(1, 1, 0); m_send(8'h12); m_send(8'h34);
        #2us set_para(1, 1, 1); m_send(8'h56); m_send(8'h78);
    end

    initial begin
        s_wdata = 'd0;
        s_send(8'hFE); s_send(8'hDC); @(negedge s_done);
        s_send(8'h12); s_send(8'h34); @(negedge s_done);
        s_send(8'hBA); s_send(8'h98); @(negedge s_done);
        s_send(8'h56); s_send(8'h78); @(negedge s_done);
        s_send(8'h76); s_send(8'h54); @(negedge s_done);
        s_send(8'h9A); s_send(8'hBC); @(negedge s_done);
        s_send(8'hA8); s_send(8'hA9); @(negedge s_done);
        s_send(8'hAA); s_send(8'hBB); @(negedge s_done);
    end

    /* ----------------------------Task Part---------------------------- */
    /* Set cpol cpha lsbf */
    task automatic set_para(logic cpol_i, logic cpha_i, logic lsbf_i);
        cpol = cpol_i;
        cpha = cpha_i;
        lsbf = lsbf_i;
        #1us;
    endtask

    /* Master -> MOSI Output */
    task automatic m_send(logic[N-1:0] d);
        @(posedge clk);
        m_wdata = d;
        start = 1;
        @(posedge clk);
        start = 0;
        @(posedge m_done);
    endtask

    /* Slave -> MISO Output */
    task automatic s_send(logic[N-1:0] d);
        @(negedge nss|s_done);
        s_wdata = d;
    endtask

    spi_master_debug #(
        .BIT_WIDTH(N),
        .CLK_DIV(CLK_DIV)
    ) spi_master_inst (
        .clk(clk),                  //i
        .rst_n(rst_n),              //i
        .start(start),              //i
        .sclk(sclk),                //o
        .nss(nss),                  //o
        .miso(miso),                //i
        .mosi(mosi),                //o
        .done(m_done),              //o
        .rdata(m_rdata),            //o
        .wdata(m_wdata),            //i
        .cpol(cpol),                //i
        .cpha(cpha),                //i
        .lsbf(lsbf)                 //i
    );

    spi_slave_debug #(
        .BIT_WIDTH(N)
    )spi_slave_inst(
        .clk(clk),                  //i
        .rst_n(rst_n),              //i
        .sclk(sclk),                //i
        .nss(nss),                  //i
        .miso(miso),                //o
        .mosi(mosi),                //i
        .done(s_done),              //i
        .rdata(s_rdata),            //o    
        .wdata(s_wdata),            //i    
        .cpol(cpol),                //i
        .cpha(cpha),                //i
        .lsbf(lsbf)                 //i
    );

endmodule