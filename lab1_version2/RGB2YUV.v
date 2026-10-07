`timescale 1ns/1ps
module RGB2YUV(
    input  start,
    input  clk,
    input  rst_n,
    input  [8:0] inportR,
    input  [8:0] inportG,
    input  [8:0] inportB,
    output done,
    output [8:0] outportY,
    output [8:0] outportU,
    output [8:0] outportV
);
    wire [2:0] state;

    Controller u_controller(
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .state(state),
        .done(done)
    );

    Datapath u_datapath(
        .state(state),
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .inportR(inportR),
        .inportG(inportG),
        .inportB(inportB),
        .outportY(outportY),
        .outportU(outportU),
        .outportV(outportV)
    );
endmodule
