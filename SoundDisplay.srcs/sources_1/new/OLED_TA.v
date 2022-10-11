`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2022 09:37:33 PM
// Design Name: 
// Module Name: OLED_TA
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


module OLED_TA(
    input [12:0] my_pixel_index, input btnU, input clk, output reg [15:0] oled_data
    );
        wire [12:0] x;
        wire [12:0] y;
        assign x = my_pixel_index % 96;
        assign y = my_pixel_index / 96;
        reg [2:0] counter = 3'd0;
        reg [1:0] btnState = 2'd0;

        debouncer debouncer_inst(
        .pb(btnU),
        .clk(clk),
        .sig(sig)
        );

        always @ (posedge clk) begin
    //    if (((x == 2 || x == 93) && (y >= 2 && y <= 60)) || ((y == 2 || y == 60) && (x > 2 && x < 93 )))
        if (((x == 2 || x == 93) && (y >= 2 && y <= 60)) || ((y == 2 || y == 60) && (x >= 2 && x <= 93 )))
        begin
            oled_data <= {5'b11111, 6'd0, 5'd0}; //red
        end
        
        else if (((x >=4 && x<=6 || x>=89 && x<=91) && (y >=4 && y <=58)) || ((y >= 4 && y <=6 || y <= 58 && y >= 56)) && (x >= 4 && x <= 91))
        begin
            oled_data <= 16'hFFA500; //orange
        end

        else if ((((x == 8 || x == 87) && (y >= 8 && y <= 54)) || ((y == 8 || y == 54) && (x >= 8 && x <= 87 ))) && counter > 3'd0)
        begin
            oled_data <= {5'd0, 6'b111111, 5'd0}; //green
        end

        else if ((((x == 10 || x == 85) && (y >= 10 && y <= 52)) || ((y == 10 || y == 52) && (x >= 10 && x <= 85 ))) && counter > 3'd1)
        begin
            oled_data <= {5'd0, 6'b111111, 5'd0}; //green
        end

        else if ((((x == 12 || x == 83) && (y >= 12 && y <= 50)) || ((y == 12 || y == 50) && (x >= 12 && x <= 83 ))) && counter > 3'd2)
        begin
            oled_data <= {5'd0, 6'b111111, 5'd0}; //green
        end

        else if ((((x == 14 || x == 81) && (y >= 14 && y <= 48)) || ((y == 14 || y == 48) && (x >= 14 && x <= 81 ))) && counter > 3'd3)
        begin
            oled_data <= {5'd0, 6'b111111, 5'd0}; //green
        end

        else 
        begin
            oled_data <= 16'd0; //black
        end

        if (sig)
        begin
            if (btnState) begin
                btnState <= 0; //Reset button state to 0
                counter <= (counter == 3'd4) ? 3'd0 : counter + 1;
            end
        end 
        else 
        begin
        btnState <= 1;            
        end
    end

endmodule