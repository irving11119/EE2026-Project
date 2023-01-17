`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.10.2022 00:09:38
// Design Name: 
// Module Name: OLED_MIX
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


module OLED_MIX(
        input [12:0] my_pixel_index, input [3:0] vol, input clk, output reg [15:0] oled_data
    );
    // Palette
    wire [15:0] black = 16'd0;
    wire [15:0] white = ~black;
    wire [15:0] red = 16'b1111100000000000;
    wire [15:0] greenll = 16'b0011111111100111;
    wire [15:0] greenl = 16'b0001111111100011;
    wire [15:0] green = 16'b0000011111100000;
    wire [15:0] orange = 16'b1111111111100000;

    // Coords
    wire [6:0] x; //from 0 to 95
    wire [5:0] y; //
    assign x = my_pixel_index%96;
    assign y = my_pixel_index/96;
    
    always @ (posedge clk) begin
       if ((x >= 43) && (x <= 53) && (y >= 55) && (y < 60) && vol >= 1) begin
           oled_data <= red;
       end else if ((((x == 2 || x == 93) && (y >= 2 && y <= 60)) || ((y == 2 || y == 60) && (x >= 2 && x <= 93 ))) && vol >= 1) begin
           oled_data <= {5'b11111, 6'd0, 5'd0}; //red
       end else if ((x >= 43) && (x <= 53) && (y >= 47) && (y < 52) && vol >= 2) begin
           oled_data <= orange;
       end else if ((((x >=4 && x<=6 || x>=89 && x<=91) && (y >=4 && y <=58)) || ((y >= 4 && y <=6 || y <= 58 && y >= 56)) && (x >= 4 && x <= 91)) && vol >= 2) begin
           oled_data <= 16'hFFA500; //orange  
       end else if ((x >= 43) && (x <= 53) && (y >= 39) && (y < 44) && vol >= 3) begin
           oled_data <= green;
       end else if ((((x == 8 || x == 87) && (y >= 8 && y <= 54)) || ((y == 8 || y == 54) && (x >= 8 && x <= 87 ))) && vol >= 3) begin
           oled_data <= {5'd0, 6'b111111, 5'd0}; //green
       end else if ((x >= 43) && (x <= 53) && (y >= 31) && (y < 36) && vol >= 4) begin
           oled_data <= greenl;
       end else if ((((x == 10 || x == 85) && (y >= 10 && y <= 52)) || ((y == 10 || y == 52) && (x >= 10 && x <= 85 ))) && vol >= 4) begin
           oled_data <= {5'd0, 6'b111111, 5'd0}; //green
       end else if ((x >= 43) && (x <= 53) && (y >= 23) && (y < 28) && vol >= 5) begin
           oled_data <= greenll;
       end else if ((((x == 12 || x == 83) && (y >= 12 && y <= 50)) || ((y == 12 || y == 50) && (x >= 12 && x <= 83 ))) && vol >= 5) begin
           oled_data <= {5'd0, 6'b111111, 5'd0}; //green
       end else begin
           oled_data <= black;
       end
     end
endmodule
