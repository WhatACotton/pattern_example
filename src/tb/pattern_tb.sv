module pattern_tb;
  localparam STEP = 8;
  localparam CLKNUM = (800 * 525 + 12000) * 500;
  localparam WIDTH = 800;
  localparam HEIGHT = 525;
  localparam BMP_HEADER_SIZE = 54;
  integer fd;
  reg CLK;
  reg RST;
  wire [7:0] VGA_R, VGA_G, VGA_B;
  wire VGA_HS, VGA_VS, VGA_DE;
  wire PCK;
  pattern pattern (
      .CLK(CLK),
      .RST(RST),
      .VGA_R(VGA_R),
      .VGA_G(VGA_G),
      .VGA_B(VGA_B),
      .VGA_HS(VGA_HS),
      .VGA_VS(VGA_VS),
      .VGA_DE(VGA_DE),
      .PCK(PCK)
  );

  // Clock generation
  always begin
    CLK = 0;
    #(STEP / 2);
    CLK = 1;
    #(STEP / 2);
  end

  initial begin
    $dumpfile("tb.vcd");  // For waveform generation
    $dumpvars(0, pattern_tb);

    // Open file for BMP output
    fd  = $fopen("image.tmp", "wb");

    // Write BMP header

    RST = 0;
    #(STEP * 600) RST = 1;
    #(STEP * 20) RST = 0;
    #(STEP * CLKNUM);
    $fclose(fd);
    $stop;
  end

  always @(posedge PCK) begin
    if (VGA_DE) begin
      // Write pixel data in BGR format
      $fwrite(fd, "%c%c%c", VGA_B, VGA_G, VGA_R);
    end
  end


endmodule
