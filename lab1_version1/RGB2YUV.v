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
    wire [21:0] control;

    Controller u_controller(
        .start(start),
        .rst_n(rst_n),
        .clk(clk),
        .done(done),
        .control(control)
    );

    Datapath u_datapath(
        .inportR(inportR),
        .inportG(inportG),
        .inportB(inportB),
        .control(control),
        .clk(clk),
        .rst_n(rst_n),
        .done(done),
        .outportY(outportY),
        .outportU(outportU),
        .outportV(outportV)
    );
endmodule
