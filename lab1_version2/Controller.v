`timescale 1ns/1ps
module Controller(
    input  clk,
    input  rst_n,
    input  start,
    output reg [2:0] state,
    output reg done
);
    localparam IDLE = 3'd0,
               S1   = 3'd1,
               S2   = 3'd2,
               S3   = 3'd3,
               S4   = 3'd4,
               S5   = 3'd5;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            done  <= 1'b0;
        end else begin
            done <= 1'b0;
            case (state)
                IDLE: begin
                    if (start)
                        state <= S1;
                    else
                        state <= IDLE;
                end
                S1: state <= S2;
                S2: state <= S3;
                S3: state <= S4;
                S4: state <= S5;
                S5: begin
                    state <= IDLE;
                    done  <= 1'b1;
                end
                default: begin
                    state <= IDLE;
                    done  <= 1'b0;
                end
            endcase
        end
    end
endmodule
