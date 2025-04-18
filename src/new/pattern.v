`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2025 06:28:11 PM
// Design Name: 
// Module Name: pattern
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pattern (
    input CLK,
    input RST,
    output reg [7:0] VGA_R,
    VGA_G,
    VGA_B,
    output VGA_HS,
    VGA_VS,
    output reg VGA_DE,
    output PCK
);
  `include "vga_param.sv"

  localparam HSIZE = 10'd64;
  localparam VSIZE = 10'd120;

  wire [9:0] HCNT, VCNT;

  syncgen syncgen (
      .CLK(CLK),
      .RST(RST),
      .PCK(PCK),
      .VGA_HS(VGA_HS),
      .VGA_VS(VGA_VS),
      .HCNT(HCNT),
      .VCNT(VCNT)
  );

  wire [9:0] HBLANK = HFRONT + HWIDTH + HBACK;
  wire [9:0] VBLANK = VFRONT + VWIDTH + VBACK;

  wire disp_enable = (VBLANK <= VCNT) && (HBLANK - 10'd1 <= HCNT) && (HCNT < HPERIOD - 10'd1);

  wire [9:0] rgb_0 = (HCNT - HBLANK + 10'd1);  //横の境界 001 or 010 or 100 or...
  // カウンタを作成してHSIZEの境界でリセット
  // それまでは4bitごとに1加算する
  reg [3:0] hGradCNT;
  always @(posedge PCK) begin
    if (RST) hGradCNT <= 4'h0;
    else if ((rgb_0[5:0] % HSIZE) == 0) hGradCNT <= 4'h0;
    else if (rgb_0[1:0] == 2'b10) hGradCNT <= hGradCNT + 1;
  end
  wire [1:0] rgb_1 = ((VCNT - VBLANK) / VSIZE);  // 縦の境界
  // 割った値をそのままcaseにかければ良い
  // 代入段階でどこに代入するか振り分ければ良い

  always @(posedge PCK) begin
    if (RST) {VGA_R, VGA_G, VGA_B} <= 24'h0;
    else if (disp_enable) begin
      case (rgb_1)
        2'b00:
        {VGA_R, VGA_G, VGA_B} <= {{hGradCNT, hGradCNT}, {hGradCNT, hGradCNT}, {hGradCNT, hGradCNT}};
        2'b01: {VGA_R, VGA_G, VGA_B} <= {{hGradCNT, hGradCNT}, 8'b0, 8'b0};
        2'b10: {VGA_R, VGA_G, VGA_B} <= {8'b0, {hGradCNT, hGradCNT}, 8'b0};
        2'b11: {VGA_R, VGA_G, VGA_B} <= {8'b0, 8'b0, {hGradCNT, hGradCNT}};
        default: {VGA_R, VGA_G, VGA_B} <= {8'b0, 8'b0, 8'b0};
      endcase

    end else {VGA_R, VGA_G, VGA_B} <= 24'h0;
  end

  always @(posedge PCK) begin
    if (RST) VGA_DE <= 1'b0;
    else VGA_DE <= disp_enable;
  end

endmodule
