`timescale 1ns/1ps
module Controller(
    input  clk,
    input  rst_n,
    output reg [1:0] phase
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            phase <= 2'd0;
        else if (phase == 2'd2)
            phase <= 2'd0;
        else
            phase <= phase + 2'd1;
    end
endmodule
