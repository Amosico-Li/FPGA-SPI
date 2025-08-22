`timescale 1ns/1ps
module tb;
    /* System Signals */
    logic clk;
    logic rst_n;

    /* Test Spi Master Signals */
    logic s_i;
    wire p_o_0;
    wire p_o_1;
    
    /* 50MHz clock generation */
    always #10 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        s_i = 0;
        #5 rst_n = 1;
        // Create a pulse of 5 cycles with a width of 10 cycles
        make_pulse(15, 5, s_i); 
    end

    task automatic tick(int n);
        repeat(n) @(posedge clk);
    endtask 

    task automatic make_pulse(int m,n, ref s);
        repeat(n) begin
            s = 1;  tick(m);
            s = 0;  tick(m / 2);
        end
    endtask 


    edge_detector # (
        .MODE(0)
    ) uut_0 (
        .clk(clk),
        .rst_n(rst_n),
        .signal(s_i),
        .pulse(p_o_0)
    );

    edge_detector # (
        .MODE(1)           
    ) uut_1(
        .clk(clk),
        .rst_n(rst_n),
        .signal(s_i),
        .pulse(p_o_1)
    );


endmodule