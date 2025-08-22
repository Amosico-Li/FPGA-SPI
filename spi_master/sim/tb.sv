`timescale 1ns/1ps
module tb;
    /* Driver Signals and Parameters */ 
    parameter N = 8;
    parameter CLK_DIV = 20;
    logic clk;
    logic rst_n;
    logic start;
    logic cpol;
    logic cpha;
    logic lsbf;
    logic miso; 
    logic [N-1:0] wdata; 

    /* Test Spi Master Output Signals */
    logic nss;          
    logic sclk;                  
    logic mosi;     
    logic done;        
    logic [N-1:0] rdata;     


    always #10 clk = ~clk;          // 50MHz clock generation

    /*-------------------Initialize Part-------------------*/
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
        wdata = 16'h0000; 
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
        miso = 0; 
        #5;
        make_pulse(70, 1000, miso);
    end

    /*-------------------Task Part-------------------*/
    task automatic tick(int n);
        repeat (n) @(posedge clk);
    endtask 

    /* Custom Waveform -> Sim MISO */
    task automatic make_pulse(int m, n, ref s);
        repeat (n) begin
            s = 'd0;
            tick(m / 5);
            s = 'd1;
            tick(m / 4);
            s = 'd0;
            tick(m / 3);
            s = 'd1;
            tick(m / 2);
        end
    endtask

    /* Master -> MOSI Output */
    task automatic m_send(logic[N-1:0] d);
        @(posedge clk);
        wdata = d;
        start = 1;
        @(posedge clk);
        start = 0;
        @(posedge done);
    endtask

    /* Set cpol cpha lsbf */
    task automatic set_para(logic cpol_i, logic cpha_i, logic lsbf_i);
        cpol = cpol_i;
        cpha = cpha_i;
        lsbf = lsbf_i;
        #1us;
    endtask

    spi_master_debug #(
        .BIT_WIDTH(N),
        .CLK_DIV(CLK_DIV)
    ) spi_master_inst (
        .clk(clk),              //i
        .rst_n(rst_n),          //i
        .start(start),          //i
        .sclk(sclk),            //o
        .nss(nss),              //o
        .miso(miso),            //i
        .mosi(mosi),            //o
        .done(done),            //o
        .rdata(rdata),          //o
        .wdata(wdata),          //i
        .cpol(cpol),            //i
        .cpha(cpha),            //i
        .lsbf(lsbf)             //i
    );




endmodule