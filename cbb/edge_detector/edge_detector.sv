module edge_detector #(
    parameter MODE = 0              // 0: rising edge, 1: falling edge
)(
    input clk,
    input rst_n,
    input logic signal,
    output logic pulse
);
    reg signal_dly;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            signal_dly <= 1'b0;
        else
            signal_dly <= signal;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
           pulse <= 1'b0;
        else begin
            if(MODE == 0) begin
                pulse <= signal & ~signal_dly;
            end 
            else begin 
                pulse <= ~signal & signal_dly;
            end
        end
    end
    
endmodule