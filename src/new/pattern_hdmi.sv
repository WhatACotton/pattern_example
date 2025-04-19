`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2025 06:25:23 PM
// Design Name: 
// Module Name: pattern_hdmi
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


`ifndef SYNTHESIS
`include "pattern.sv"
`include "../imports/src/rgb2dvi.vhd"
`endif

module pattern_hdmi (
    input CLK,
    input RST,
    output HDMI_CLK_N,
    HDMI_CLK_P,
    output [2:0] HDMI_N,
    HDMI_P
);
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

  rgb2dvi #(
      .kClkPrimitive("MMCM"),
      .kClkRange(5)  //25MHz <= fPCK < 30MHz
  ) rgb2dvi (
      .PixelClk(PCK),
      .TMDS_Clk_n(HDMI_CLK_N),
      .TMDS_Clk_p(HDMI_CLK_P),
      .TMDS_Data_n(HDMI_N),
      .TMDS_Data_p(HDMI_P),
      .aRst(RST),
      .vid_pData({VGA_R, VGA_G, VGA_B}),
      .vid_pHSync(VGA_HS),
      .vid_pVDE(VGA_DE),
      .vid_pVSync(VGA_VS)
  );
endmodule
