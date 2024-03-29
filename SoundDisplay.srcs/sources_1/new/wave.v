`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2022 10:46:20 AM
// Design Name: 
// Module Name: wave
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


module wave(
    input [15:0] sw,
    input [11:0] mic_in,
    input [12:0] pixel_index,
    input [9:0] mouse_x, 
    input [9:0] mouse_y,
    input left_click, 
    input right_click,
    input clk,
    input btnC,
    input btnL,
    input btnR,
    output reg [15:0] oled_data
    );

    wire [12:0] x;
    wire [12:0] y;
    wire clk_96hz;
    wire clk_1000hz;
    wire sig1;
    wire sig2;
    wire debounced_click;
    reg [96 * 6:0] mic_arr;
    reg [11:0] count = 0;
    reg [12:0] val;
    reg [2:0] counter = 3'd0;
    reg [1:0] btnState1 = 2'd0;
    reg [1:0] btnState2 = 2'd0; 
    reg [9:0] cursor_x;
    reg [9:0] cursor_y;
    reg button_state = 0;

    reg colour_state = 0;
    reg menu_state = 0;

    reg [32:0] freq_state = 2;
    
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;

    clk_divider clk_96(.CLK(clk),.m(130208),.CLK_OUT(clk_96hz));

    debouncer debounced(
        .pb(left_click), .clk(clk), .sig(debounced_click)
    );

    
    integer i, j;
    initial begin
        for (i = 0; i <= 96; i = i + 1) begin
            mic_arr[5:0] = 31;
            mic_arr = mic_arr << 6;
        end
        

    end
    

    always @(posedge clk_96hz) 
    begin
        count <= (count >= 2**freq_state) ? 1: count + 1;
        if (freq_state == 3) begin
            mic_arr <= mic_arr;
        end
        else if (count == 1) begin
            mic_arr <= mic_arr << 6;
            val = 62 - (mic_in / 65); 
            mic_arr[5:0] <= val;
            mic_arr[95 * 6 : 94 * 6] <= 31;
        end 

    end


    always @(posedge clk)
    begin
        cursor_x = mouse_x / 10;
        cursor_y = mouse_y / 10;

        if (debounced_click) begin
            if (button_state == 0) 
                button_state <= 1; 
        end
        else
            button_state <= 0;

        if (debounced_click && button_state == 0 && menu_state) begin
            if (cursor_x >= 3 && cursor_x <= 45 && cursor_y >= 10 && cursor_y <= 15) begin
                colour_state = 1;
            end

            else if (cursor_x >= 66 && cursor_x <= 93 && cursor_y >= 10 && cursor_y <= 15) begin
                colour_state = 0;
            end

            else if (cursor_x >= 41 && cursor_x <= 53 && cursor_y >= 50 && cursor_y <= 54) begin
                menu_state = 0;
            end

            else if (cursor_x >= 28 && cursor_x <= 30 && cursor_y >= 35 && cursor_y <= 39) begin
                freq_state <= (freq_state == 3) ? 3 : freq_state + 1;  
            end

            else if (cursor_x >= 66 && cursor_x <= 68 && cursor_y >= 35 && cursor_y <= 39) begin
                freq_state <= (freq_state == 0) ? 0 : freq_state - 1;
            end

            else
                colour_state = colour_state;
        end

        else if (debounced_click && button_state == 0 && !menu_state) begin
            menu_state <= 1;
        end


        if (menu_state) begin

            if (x >= cursor_x && x < cursor_x + 3 && y >= cursor_y && y < cursor_y + 3) begin
                oled_data <= 16'd0;
             end
            
            //back button
            else if ((x == 7 && y == 5) || (x == 6 && y == 6) || (x == 5 && y == 7) || (x == 6 && y == 8) || (x == 7 && y == 9)) begin
                oled_data <= 16'd0;
            end

            else if (((x == 7 && y == 13) || (x == 8 && y == 13) || (x == 9 && y == 13) || (x == 6 && y == 14) || (x == 6 && y == 15) || (x == 8 && y == 15) || (x == 9 && y == 15) || (x == 10 && y == 15) || (x == 6 && y == 16) || (x == 10 && y == 16) || (x == 7 && y == 17) || (x == 8 && y == 17) || (x == 9 && y == 17) || (x == 12 && y == 13) || (x == 13 && y == 13) || (x == 14 && y == 13) || (x == 12 && y == 14) || (x == 15 && y == 14) || (x == 12 && y == 15) || (x == 13 && y == 15) || (x == 14 && y == 15) || (x == 12 && y == 16) || (x == 14 && y == 16) || (x == 12 && y == 17) || (x == 15 && y == 17) || (x == 17 && y == 13) || (x == 18 && y == 13) || (x == 19 && y == 13) || (x == 20 && y == 13) || (x == 17 && y == 14) || (x == 17 && y == 15) || (x == 18 && y == 15) || (x == 19 && y == 15) || (x == 20 && y == 15) || (x == 17 && y == 16) || (x == 17 && y == 17) || (x == 18 && y == 17) || (x == 19 && y == 17) || (x == 20 && y == 17) || (x == 22 && y == 13) || (x == 24 && y == 13) || (x == 22 && y == 14) || (x == 24 && y == 14) || (x == 23 && y == 15) || (x == 23 && y == 16) || (x == 23 && y == 17) || (x == 26 && y == 13) || (x == 27 && y == 13) || (x == 28 && y == 13) || (x == 29 && y == 13) || (x == 26 && y == 14) || (x == 26 && y == 15) || (x == 27 && y == 15) || (x == 28 && y == 15) || (x == 29 && y == 15) || (x == 29 && y == 16) || (x == 26 && y == 17) || (x == 27 && y == 17) || (x == 28 && y == 17) || (x == 29 && y == 17) || (x == 32 && y == 13) || (x == 33 && y == 13) || (x == 31 && y == 14) || (x == 34 && y == 14) || (x == 31 && y == 15) || (x == 31 && y == 16) || (x == 34 && y == 16) || (x == 32 && y == 17) || (x == 33 && y == 17) || (x == 37 && y == 13) || (x == 38 && y == 13) || (x == 36 && y == 14) || (x == 39 && y == 14) || (x == 36 && y == 15) || (x == 37 && y == 15) || (x == 38 && y == 15) || (x == 39 && y == 15) || (x == 36 && y == 16) || (x == 39 && y == 16) || (x == 36 && y == 17) || (x == 39 && y == 17) || (x == 41 && y == 13) || (x == 41 && y == 14) || (x == 41 && y == 15) || (x == 41 && y == 16) || (x == 41 && y == 17) || (x == 42 && y == 17) || (x == 43 && y == 17) || (x == 44 && y == 17) || (x == 46 && y == 13) || (x == 47 && y == 13) || (x == 48 && y == 13) || (x == 49 && y == 13) || (x == 46 && y == 14) || (x == 46 && y == 15) || (x == 47 && y == 15) || (x == 48 && y == 15) || (x == 49 && y == 15) || (x == 46 && y == 16) || (x == 46 && y == 17) || (x == 47 && y == 17) || (x == 48 && y == 17) || (x == 49 && y == 17)))
            begin
                 oled_data <= 16'd0;
            end

            //colour
            else if (((x == 67 && y == 13) || (x == 68 && y == 13) || (x == 66 && y == 14) || (x == 69 && y == 14) || (x == 66 && y == 15) || (x == 66 && y == 16) || (x == 69 && y == 16) || (x == 67 && y == 17) || (x == 68 && y == 17) || (x == 72 && y == 13) || (x == 73 && y == 13) || (x == 71 && y == 14) || (x == 74 && y == 14) || (x == 71 && y == 15) || (x == 74 && y == 15) || (x == 71 && y == 16) || (x == 74 && y == 16) || (x == 72 && y == 17) || (x == 73 && y == 17) || (x == 76 && y == 13) || (x == 76 && y == 14) || (x == 76 && y == 15) || (x == 76 && y == 16) || (x == 76 && y == 17) || (x == 77 && y == 17) || (x == 78 && y == 17) || (x == 79 && y == 17) || (x == 82 && y == 13) || (x == 83 && y == 13) || (x == 81 && y == 14) || (x == 84 && y == 14) || (x == 81 && y == 15) || (x == 84 && y == 15) || (x == 81 && y == 16) || (x == 84 && y == 16) || (x == 82 && y == 17) || (x == 83 && y == 17) || (x == 86 && y == 13) || (x == 89 && y == 13) || (x == 86 && y == 14) || (x == 89 && y == 14) || (x == 86 && y == 15) || (x == 89 && y == 15) || (x == 86 && y == 16) || (x == 89 && y == 16) || (x == 87 && y == 17) || (x == 88 && y == 17) || (x == 91 && y == 13) || (x == 92 && y == 13) || (x == 93 && y == 13) || (x == 91 && y == 14) || (x == 94 && y == 14) || (x == 91 && y == 15) || (x == 92 && y == 15) || (x == 93 && y == 15) || (x == 91 && y == 16) || (x == 93 && y == 16) || (x == 91 && y == 17) || (x == 94 && y == 17))) 
            begin
                oled_data <= 16'd0;
            end
            

            //freq
            else if (((x == 24 && y == 25) || (x == 25 && y == 25) || (x == 26 && y == 25) || (x == 27 && y == 25) || (x == 24 && y == 26) || (x == 24 && y == 27) || (x == 25 && y == 27) || (x == 26 && y == 27) || (x == 27 && y == 27) || (x == 24 && y == 28) || (x == 24 && y == 29) || (x == 29 && y == 25) || (x == 30 && y == 25) || (x == 31 && y == 25) || (x == 29 && y == 26) || (x == 32 && y == 26) || (x == 29 && y == 27) || (x == 30 && y == 27) || (x == 31 && y == 27) || (x == 29 && y == 28) || (x == 31 && y == 28) || (x == 29 && y == 29) || (x == 32 && y == 29) || (x == 34 && y == 25) || (x == 35 && y == 25) || (x == 36 && y == 25) || (x == 37 && y == 25) || (x == 34 && y == 26) || (x == 34 && y == 27) || (x == 35 && y == 27) || (x == 36 && y == 27) || (x == 37 && y == 27) || (x == 34 && y == 28) || (x == 34 && y == 29) || (x == 35 && y == 29) || (x == 36 && y == 29) || (x == 37 && y == 29) || (x == 40 && y == 25) || (x == 41 && y == 25) || (x == 39 && y == 26) || (x == 42 && y == 26) || (x == 39 && y == 27) || (x == 42 && y == 27) || (x == 39 && y == 28) || (x == 41 && y == 28) || (x == 42 && y == 28) || (x == 40 && y == 29) || (x == 41 && y == 29) || (x == 43 && y == 29) || (x == 45 && y == 25) || (x == 48 && y == 25) || (x == 45 && y == 26) || (x == 48 && y == 26) || (x == 45 && y == 27) || (x == 48 && y == 27) || (x == 45 && y == 28) || (x == 48 && y == 28) || (x == 46 && y == 29) || (x == 47 && y == 29) || (x == 50 && y == 25) || (x == 51 && y == 25) || (x == 52 && y == 25) || (x == 53 && y == 25) || (x == 50 && y == 26) || (x == 50 && y == 27) || (x == 51 && y == 27) || (x == 52 && y == 27) || (x == 53 && y == 27) || (x == 50 && y == 28) || (x == 50 && y == 29) || (x == 51 && y == 29) || (x == 52 && y == 29) || (x == 53 && y == 29) || (x == 55 && y == 25) || (x == 58 && y == 25) || (x == 55 && y == 26) || (x == 56 && y == 26) || (x == 58 && y == 26) || (x == 55 && y == 27) || (x == 57 && y == 27) || (x == 58 && y == 27) || (x == 55 && y == 28) || (x == 58 && y == 28) || (x == 55 && y == 29) || (x == 58 && y == 29) || (x == 61 && y == 25) || (x == 62 && y == 25) || (x == 60 && y == 26) || (x == 63 && y == 26) || (x == 60 && y == 27) || (x == 60 && y == 28) || (x == 63 && y == 28) || (x == 61 && y == 29) || (x == 62 && y == 29) || (x == 65 && y == 25) || (x == 67 && y == 25) || (x == 65 && y == 26) || (x == 67 && y == 26) || (x == 66 && y == 27) || (x == 66 && y == 28) || (x == 66 && y == 29) || (x == 69 && y == 25) || (x == 69 && y == 26) || (x == 69 && y == 28) || (x == 69 && y == 29) || (x == 70 && y == 25) || (x == 70 && y == 26) || (x == 70 && y == 28) || (x == 70 && y == 29))) begin
                oled_data <= 16'd0;
            end

            //exit
            else if (((x == 41 && y == 50) || (x == 42 && y == 50) || (x == 43 && y == 50) || (x == 44 && y == 50) || (x == 41 && y == 51) || (x == 41 && y == 52) || (x == 42 && y == 52) || (x == 43 && y == 52) || (x == 44 && y == 52) || (x == 41 && y == 53) || (x == 41 && y == 54) || (x == 42 && y == 54) || (x == 43 && y == 54) || (x == 44 && y == 54) || (x == 46 && y == 50) || (x == 48 && y == 50) || (x == 46 && y == 51) || (x == 48 && y == 51) || (x == 47 && y == 52) || (x == 46 && y == 53) || (x == 48 && y == 53) || (x == 46 && y == 54) || (x == 48 && y == 54) || (x == 50 && y == 50) || (x == 50 && y == 51) || (x == 50 && y == 52) || (x == 50 && y == 53) || (x == 50 && y == 54) || (x == 52 && y == 50) || (x == 53 && y == 50) || (x == 54 && y == 50) || (x == 53 && y == 51) || (x == 53 && y == 52) || (x == 53 && y == 53) || (x == 53 && y == 54))) begin
                oled_data <= 16'b1111111111111111;
            end

            else if ((x >= 38 && x <= 55 && y >= 48 && y <= 57)) begin
                oled_data <= 16'b1111100000000000;
            end

            //96
            else if (freq_state == 2 && ((x == 40 && y == 35) || (x == 41 && y == 35) || (x == 42 && y == 35) || (x == 40 && y == 36) || (x == 42 && y == 36) || (x == 40 && y == 37) || (x == 41 && y == 37) || (x == 42 && y == 37) || (x == 42 && y == 38) || (x == 40 && y == 39) || (x == 41 && y == 39) || (x == 42 && y == 39) || (x == 44 && y == 35) || (x == 45 && y == 35) || (x == 46 && y == 35) || (x == 44 && y == 36) || (x == 44 && y == 37) || (x == 45 && y == 37) || (x == 46 && y == 37) || (x == 44 && y == 38) || (x == 46 && y == 38) || (x == 44 && y == 39) || (x == 45 && y == 39) || (x == 46 && y == 39) || (x == 48 && y == 35) || (x == 51 && y == 35) || (x == 48 && y == 36) || (x == 51 && y == 36) || (x == 48 && y == 37) || (x == 49 && y == 37) || (x == 50 && y == 37) || (x == 51 && y == 37) || (x == 48 && y == 38) || (x == 51 && y == 38) || (x == 48 && y == 39) || (x == 51 && y == 39) || (x == 53 && y == 35) || (x == 54 && y == 35) || (x == 55 && y == 35) || (x == 55 && y == 36) || (x == 54 && y == 37) || (x == 53 && y == 38) || (x == 53 && y == 39) || (x == 54 && y == 39) || (x == 55 && y == 39))) begin
                oled_data <= 16'd0;
            end

            //192
            else if (freq_state == 1 && ((x == 39 && y == 35) || (x == 38 && y == 36) || (x == 39 && y == 36) || (x == 39 && y == 37) || (x == 39 && y == 38) || (x == 38 && y == 39) || (x == 39 && y == 39) || (x == 40 && y == 39) || (x == 42 && y == 35) || (x == 43 && y == 35) || (x == 44 && y == 35) || (x == 42 && y == 36) || (x == 44 && y == 36) || (x == 42 && y == 37) || (x == 43 && y == 37) || (x == 44 && y == 37) || (x == 44 && y == 38) || (x == 42 && y == 39) || (x == 43 && y == 39) || (x == 44 && y == 39) || (x == 46 && y == 35) || (x == 47 && y == 35) || (x == 48 && y == 35) || (x == 48 && y == 36) || (x == 46 && y == 37) || (x == 47 && y == 37) || (x == 48 && y == 37) || (x == 46 && y == 38) || (x == 46 && y == 39) || (x == 47 && y == 39) || (x == 48 && y == 39) || (x == 50 && y == 35) || (x == 53 && y == 35) || (x == 50 && y == 36) || (x == 53 && y == 36) || (x == 50 && y == 37) || (x == 51 && y == 37) || (x == 52 && y == 37) || (x == 53 && y == 37) || (x == 50 && y == 38) || (x == 53 && y == 38) || (x == 50 && y == 39) || (x == 53 && y == 39) || (x == 55 && y == 35) || (x == 56 && y == 35) || (x == 57 && y == 35) || (x == 57 && y == 36) || (x == 56 && y == 37) || (x == 55 && y == 38) || (x == 55 && y == 39) || (x == 56 && y == 39) || (x == 57 && y == 39))) begin
                oled_data <= 16'd0;
            end

            //384
            else if (freq_state == 0 && ((x == 38 && y == 35) || (x == 39 && y == 35) || (x == 40 && y == 35) || (x == 40 && y == 36) || (x == 38 && y == 37) || (x == 39 && y == 37) || (x == 40 && y == 37) || (x == 40 && y == 38) || (x == 38 && y == 39) || (x == 39 && y == 39) || (x == 40 && y == 39) || (x == 42 && y == 35) || (x == 43 && y == 35) || (x == 44 && y == 35) || (x == 42 && y == 36) || (x == 44 && y == 36) || (x == 42 && y == 37) || (x == 43 && y == 37) || (x == 44 && y == 37) || (x == 42 && y == 38) || (x == 44 && y == 38) || (x == 42 && y == 39) || (x == 43 && y == 39) || (x == 44 && y == 39) || (x == 46 && y == 35) || (x == 48 && y == 35) || (x == 46 && y == 36) || (x == 48 && y == 36) || (x == 46 && y == 37) || (x == 47 && y == 37) || (x == 48 && y == 37) || (x == 48 && y == 38) || (x == 48 && y == 39) || (x == 50 && y == 35) || (x == 53 && y == 35) || (x == 50 && y == 36) || (x == 53 && y == 36) || (x == 50 && y == 37) || (x == 51 && y == 37) || (x == 52 && y == 37) || (x == 53 && y == 37) || (x == 50 && y == 38) || (x == 53 && y == 38) || (x == 50 && y == 39) || (x == 53 && y == 39) || (x == 55 && y == 35) || (x == 56 && y == 35) || (x == 57 && y == 35) || (x == 57 && y == 36) || (x == 56 && y == 37) || (x == 55 && y == 38) || (x == 55 && y == 39) || (x == 56 && y == 39) || (x == 57 && y == 39))) begin
                oled_data <= 16'd0;
            end

            //freeze
            else if (freq_state == 3 && ((x == 34 && y == 35) || (x == 35 && y == 35) || (x == 36 && y == 35) || (x == 37 && y == 35) || (x == 34 && y == 36) || (x == 34 && y == 37) || (x == 35 && y == 37) || (x == 36 && y == 37) || (x == 37 && y == 37) || (x == 34 && y == 38) || (x == 34 && y == 39) || (x == 39 && y == 35) || (x == 40 && y == 35) || (x == 41 && y == 35) || (x == 39 && y == 36) || (x == 42 && y == 36) || (x == 39 && y == 37) || (x == 40 && y == 37) || (x == 41 && y == 37) || (x == 39 && y == 38) || (x == 41 && y == 38) || (x == 39 && y == 39) || (x == 42 && y == 39) || (x == 44 && y == 35) || (x == 45 && y == 35) || (x == 46 && y == 35) || (x == 47 && y == 35) || (x == 44 && y == 36) || (x == 44 && y == 37) || (x == 45 && y == 37) || (x == 46 && y == 37) || (x == 47 && y == 37) || (x == 44 && y == 38) || (x == 44 && y == 39) || (x == 45 && y == 39) || (x == 46 && y == 39) || (x == 47 && y == 39) || (x == 49 && y == 35) || (x == 50 && y == 35) || (x == 51 && y == 35) || (x == 52 && y == 35) || (x == 49 && y == 36) || (x == 49 && y == 37) || (x == 50 && y == 37) || (x == 51 && y == 37) || (x == 52 && y == 37) || (x == 49 && y == 38) || (x == 49 && y == 39) || (x == 50 && y == 39) || (x == 51 && y == 39) || (x == 52 && y == 39) || (x == 54 && y == 35) || (x == 55 && y == 35) || (x == 56 && y == 35) || (x == 56 && y == 36) || (x == 55 && y == 37) || (x == 54 && y == 38) || (x == 54 && y == 39) || (x == 55 && y == 39) || (x == 56 && y == 39) || (x == 58 && y == 35) || (x == 59 && y == 35) || (x == 60 && y == 35) || (x == 61 && y == 35) || (x == 58 && y == 36) || (x == 58 && y == 37) || (x == 59 && y == 37) || (x == 60 && y == 37) || (x == 61 && y == 37) || (x == 58 && y == 38) || (x == 58 && y == 39) || (x == 59 && y == 39) || (x == 60 && y == 39) || (x == 61 && y == 39))) begin
                oled_data <= 16'd0;
            end


            else if ((x >= 6 && x <= 49 && y == 19) && colour_state) begin
                 oled_data <= 16'd0;
            end

            else if ((x >= 66 && x <= 93 && y == 19) && !colour_state) begin
                oled_data <= 16'd0;
            end

            //left arrow
            else if (freq_state != 3 && ((x == 30 && y == 35) || (x == 29 && y == 36) || (x == 28 && y == 37) ||( x == 29 && y == 38 ) || (x == 30 && y == 39))) begin
                oled_data <= 16'd0;
            end
            
            //right arrow
            else if (freq_state != 0 && ((x == 66 && y == 35) || (x == 67 && y == 36) || (x == 68 && y == 37) ||( x == 67 && y == 38 ) || (x == 66 && y == 39))) begin
                oled_data <= 16'd0;
            end
        
            else begin
                oled_data <= 16'b1111111111111111;
            end

        end
        
        
        else begin
        if (y == 31) begin
            oled_data <= 16'b1111111111111111;
        end

        
        else begin

            if (mic_arr[x * 6+: 6] > 31)
                begin
                    if (y > mic_arr[x * 6+: 6] || y < 31)
                    begin
                        oled_data <= 16'd0;
                    end

                    else
                    begin
                        if (y < 42)
                            oled_data <= sw[9] ? 16'd0: (colour_state ? 16'b1111111111111111: 16'b0000011111100000);

                        else if (y < 52)
                            oled_data <= sw[9] ? 16'd0: (colour_state ? 16'b1111111111111111: 16'b1111111111100000);
                        
                        else
                            oled_data <= sw[9] ? 16'd0:   (colour_state ? 16'b1111111111111111: 16'b1111100000000000);
                    end 
                end

            else begin
                if (y < mic_arr[x * 6+: 6] || y > 31)
                    begin
                        oled_data <= 16'd0;
                    end

                    else
                    begin
                        if (y > 21)
                            oled_data <= colour_state ? 16'b1111111111111111: 16'b0000011111100000;

                        else if (y > 10)
                            oled_data <=  (colour_state ? 16'b1111111111111111: 16'b1111111111100000);
                        
                        else
                            oled_data <=  (colour_state ? 16'b1111111111111111: 16'b1111100000000000);
                    end 
            end
        end
        end
    end

endmodule

