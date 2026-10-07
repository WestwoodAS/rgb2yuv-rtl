`timescale 1ns/1ns
`define bits 9

module testbench();
  parameter half_clk = 20;
  parameter clk_period = 2 * half_clk;
  integer imageIN,imageOUTY,imageOUTU,imageOUTV, i, cc, j;
  integer bmp_width, bmp_hight, data_start_index, bmp_size;
  reg [7:0]  bmp_data [0:200000];
  reg rst,clk,start;
  wire [8:0] outY,outU,outV;
  wire done;

  initial begin
    clk = 1'b0;
    rst = 1'b1;
    start = 1'b0;
    #(clk_period) rst = 1'b0;
    #(clk_period) rst = 1'b1;
  end

  always #(half_clk) clk = ~clk;

  RGB2YUV rgbtuv(
    .start(start),
    .clk(clk),
    .rst_n(rst),
    .inportR({1'b0,bmp_data[(i-data_start_index)*3+data_start_index+2]}),
    .inportG({1'b0,bmp_data[(i-data_start_index)*3+data_start_index+1]}),
    .inportB({1'b0,bmp_data[(i-data_start_index)*3+data_start_index]}),
    .done(done),
    .outportY(outY),
    .outportU(outU),
    .outportV(outV)
  );

  task process_one_pixel;
  begin
    @(negedge clk);
    start = 1'b1;
    repeat(3) @(negedge clk);
    start = 1'b0;
    wait(done == 1'b1);
    $fwrite(imageOUTY,"%c%c%c",outY[7:0],outY[7:0],outY[7:0]);
    $fwrite(imageOUTU,"%c%c%c",outU[7:0],outU[7:0],outU[7:0]);
    $fwrite(imageOUTV,"%c%c%c",outV[7:0],outV[7:0],outV[7:0]);
    @(negedge clk);
  end
  endtask

  initial begin
    imageIN = $fopen("mountain256.bmp","rb");
    imageOUTY = $fopen("mountain256Y.bmp","wb");
    imageOUTU = $fopen("mountain256U.bmp","wb");
    imageOUTV = $fopen("mountain256V.bmp","wb");
    cc = $fread(bmp_data,imageIN);

    bmp_width = {bmp_data[21],bmp_data[20],bmp_data[19],bmp_data[18]};
    bmp_hight = {bmp_data[25],bmp_data[24],bmp_data[23],bmp_data[22]};
    data_start_index = {bmp_data[13],bmp_data[12],bmp_data[11],bmp_data[10]};
    bmp_size  = {bmp_data[5],bmp_data[4],bmp_data[3],bmp_data[2]};

    for(j = 0; j < 54; j = j + 1) begin
      $fwrite(imageOUTY,"%c",bmp_data[j]);
      $fwrite(imageOUTU,"%c",bmp_data[j]);
      $fwrite(imageOUTV,"%c",bmp_data[j]);
    end

    @(negedge rst);
    @(posedge rst);

    for(i = data_start_index; i < bmp_width*bmp_hight+data_start_index; i = i + 1) begin
      process_one_pixel();
    end

    #(clk_period*2)
    $fclose(imageOUTY);
    $fclose(imageOUTU);
    $fclose(imageOUTV);
    $fclose(imageIN);
    $finish;
  end
endmodule
