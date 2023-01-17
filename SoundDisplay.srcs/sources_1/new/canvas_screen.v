// Module Name: canvas_screen
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


module canvas_screen(
        input [12:0] my_pixel_index, 
        input [9:0] mouse_x, 
        input [9:0] mouse_y,
        input left_click, 
        input right_click,
        input clk,
        //input sw,
        output reg [15:0] oled_data
    );
    wire [15:0] black = 16'd0;
    wire [15:0] yellow = 16'b1111111111100000;
    wire [15:0] green = 16'b0000011111100000;
    wire [15:0] white = ~black;
    parameter orange = 16'b11111_101010_00110;
    parameter brown = 16'b11000_010010_00000;
    parameter red = 16'b11111_000000_00000;
    parameter purple = 16'b11001_011010_11101;
    parameter blue = 16'b00101_011010_11000;
    parameter grey = 16'b11000_110000_11000;
    
    parameter NEON_GREEN = 16'b00111_111111_00010;
    wire [6:0] x; //from 0 to 95
    wire [5:0] y; //
    reg [9:0] cursor_x;
    reg [9:0] cursor_y;
    reg within_canvas = 0;
    reg prev_state = 0;
    reg [6:0] start_x;
    reg [5:0] start_y;
    
    wire debounced_left;
    wire debounced_right;

    reg button_statel = 0;
    reg button_stater = 0;

    reg [6:0] end_x;
    reg [5:0] end_y;
    
    assign x = my_pixel_index%96;
    assign y = my_pixel_index/96;
    reg [2:0] canvas[35:0][35:0];
    reg [2:0] selectedColor = 0;
    reg [2:0] currBrushsize = 2;
    reg [15:0] cursorColor = 16'd1;
    reg squaretoolmode = 0;
    
    parameter X_OFFSET = 30; //35 for 26 size, 30 for 36 size
    parameter Y_OFFSET = 15; //20 for 26 size, 15 for 36 size

    debouncer u1(left_click, clk, debounced_left);
    debouncer u2(right_click, clk, debounced_right);

    integer i, j, k, l;
    always @ (posedge debounced_left) begin
            if (cursor_x >= 70 && cursor_x <= 80 && cursor_y >= 5 && cursor_y <= 15) begin
                selectedColor <= 1;
                cursorColor <= red;
            end else if (cursor_x >= 83 && cursor_x <= 93 && cursor_y >= 5 && cursor_y <= 15) begin
                selectedColor <= 2;
                cursorColor <= orange;
            end else if (cursor_x >= 70 && cursor_x <= 80 && cursor_y >= 19 && cursor_y <= 29) begin
                selectedColor <= 3;
                cursorColor <= yellow;
            end else if (cursor_x >= 83 && cursor_x <= 93 && cursor_y >= 19 && cursor_y <= 29) begin
                selectedColor <= 4;
                cursorColor <= green;
            end else if (cursor_x >= 70 && cursor_x <= 80 && cursor_y >= 33 && cursor_y <= 43) begin
                selectedColor <= 5;
                cursorColor <= blue;
            end else if (cursor_x >= 83 && cursor_x <= 93 && cursor_y >= 33 && cursor_y <= 43) begin
                selectedColor <= 6; 
                cursorColor <= purple;
            
            // Brush cursor detection                                                                                                                                                                                                                                                   
            end else if (cursor_x >= 30 && cursor_x <= 40 && cursor_y >= 53 && cursor_y <= 63) begin
                currBrushsize <= 0;
            end else if (cursor_x >= 43 && cursor_x <= 53 && cursor_y >= 53 && cursor_y <= 63) begin
                currBrushsize <= 1;
            end else if (cursor_x >= 56 && cursor_x <= 66 && cursor_y >= 53 && cursor_y <= 63) begin      
                currBrushsize <= 2;
            
            // Square tool cursor detection                                                                                                                                                                                                      
            end else if (cursor_x >= 7 && cursor_x <= 21 && cursor_y >=46 && cursor_y <= 60) begin
                squaretoolmode <= ~squaretoolmode;
            end
    end
  
    always @ (posedge clk) begin
           cursor_x = mouse_x/10;
           cursor_y = mouse_y/10;
           
           if (x >= X_OFFSET && x <=  95 - X_OFFSET && y >= Y_OFFSET && y <= 62- Y_OFFSET) begin
                // Canvas zone
                if (canvas[(x-X_OFFSET)][(y-Y_OFFSET)] == 1) begin
                    oled_data <= red;
                end else if (canvas[(x-X_OFFSET)][(y-Y_OFFSET)] == 2) begin
                    oled_data <= orange;
                end else if (canvas[(x-X_OFFSET)][(y-Y_OFFSET)] == 3) begin
                    oled_data <= yellow;
                end else if (canvas[(x-X_OFFSET)][(y-Y_OFFSET)] == 4) begin
                     oled_data <= green;
                end else if (canvas[(x-X_OFFSET)][(y-Y_OFFSET)] == 5) begin
                    oled_data <= blue;
                end else if (canvas[(x-X_OFFSET)][(y-Y_OFFSET)] == 6) begin
                    oled_data <= purple;
                end else begin
                   oled_data <= white;
                end
           // Render Color Palette
           end else if (x >= 70 && x <= 80 && y >= 5 && y <= 15) begin
                oled_data <= red;
           end else if (x >= 83 && x <= 93 && y >= 5 && y <= 15) begin
               oled_data <= orange;
           end else if (x >= 70 && x <= 80 && y >= 19 && y <= 29) begin
                 oled_data <= yellow;
           end else if (x >= 83 && x <= 93 && y >= 19 && y <= 29) begin
                 oled_data <= green;
           end else if (x >= 70 && x <= 80 && y >= 33 && y <= 43) begin
                  oled_data <= blue;
           end else if (x >= 83 && x <= 93 && y >= 33 && y <= 43) begin
                   oled_data <= purple;
           // Current Selected Color Box                  
           end else if (x >= 70 && x <= 93 && y >= 47 && y <= 62) begin
                   oled_data <= cursorColor;
           // Brush Selection Icons        
           //1
           end else if ((x == 35 && y == 55) || (x == 34 && y == 56) || (x == 35 && y == 56) || (x == 35 && y == 57) || (x == 35 && y == 58) || (x == 34 && y == 59) || (x == 35 && y == 59) || (x == 36 && y == 59)) begin
               oled_data <= black;
           //2
           end else if ((x == 46 && y == 55) || (x == 47 && y == 55) || (x == 48 && y == 55) || (x == 48 && y == 56) || (x == 46 && y == 57) || (x == 47 && y == 57) || (x == 48 && y == 57) || (x == 46 && y == 58) || (x == 46 && y == 59) || (x == 47 && y == 59) || (x == 48 && y == 59)) begin
               oled_data <= black;
           //3
           end else if ((x == 59 && y == 55) || (x == 60 && y == 55) || (x == 61 && y == 55) || (x == 61 && y == 56) || (x == 59 && y == 57) || (x == 60 && y == 57) || (x == 61 && y == 57) || (x == 61 && y == 58) || (x == 59 && y == 59) || (x == 60 && y == 59) || (x == 61 && y == 59)) begin
               oled_data <= black;
           // Brush Selection Boxes
           //1st selection                                                                                                                                                                                                               
          end else if (currBrushsize == 0 &&((x == 29 && y == 53) || (x == 30 && y == 53) || (x == 31 && y == 53) || (x == 32 && y == 53) || (x == 33 && y == 53) || (x == 34 && y == 53) || (x == 35 && y == 53) || (x == 36 && y == 53) || (x == 37 && y == 53) || (x == 38 && y == 53) || (x == 39 && y == 53) || (x == 29 && y == 54) || (x == 39 && y == 54) || (x == 29 && y == 55) || (x == 39 && y == 55) || (x == 29 && y == 56) || (x == 39 && y == 56) || (x == 29 && y == 57) || (x == 39 && y == 57) || (x == 29 && y == 58) || (x == 39 && y == 58) || (x == 29 && y == 59) || (x == 39 && y == 59) || (x == 29 && y == 60) || (x == 39 && y == 60) || (x == 29 && y == 61) || (x == 39 && y == 61) || (x == 29 && y == 62) || (x == 39 && y == 62) || (x == 29 && y == 63) || (x == 30 && y == 63) || (x == 31 && y == 63) || (x == 32 && y == 63) || (x == 33 && y == 63) || (x == 34 && y == 63) || (x == 35 && y == 63) || (x == 36 && y == 63) || (x == 37 && y == 63) || (x == 38 && y == 63) || (x == 39 && y == 63))) begin
               oled_data <= red;
          //2nd selection
          end else if (currBrushsize == 1 &&((x == 42 && y == 53) || (x == 43 && y == 53) || (x == 44 && y == 53) || (x == 45 && y == 53) || (x == 46 && y == 53) || (x == 47 && y == 53) || (x == 48 && y == 53) || (x == 49 && y == 53) || (x == 50 && y == 53) || (x == 51 && y == 53) || (x == 52 && y == 53) || (x == 42 && y == 54) || (x == 52 && y == 54) || (x == 42 && y == 55) || (x == 52 && y == 55) || (x == 42 && y == 56) || (x == 52 && y == 56) || (x == 42 && y == 57) || (x == 52 && y == 57) || (x == 42 && y == 58) || (x == 52 && y == 58) || (x == 42 && y == 59) || (x == 52 && y == 59) || (x == 42 && y == 60) || (x == 52 && y == 60) || (x == 42 && y == 61) || (x == 52 && y == 61) || (x == 42 && y == 62) || (x == 52 && y == 62) || (x == 42 && y == 63) || (x == 43 && y == 63) || (x == 44 && y == 63) || (x == 45 && y == 63) || (x == 46 && y == 63) || (x == 47 && y == 63) || (x == 48 && y == 63) || (x == 49 && y == 63) || (x == 50 && y == 63) || (x == 51 && y == 63) || (x == 52 && y == 63)))begin
               oled_data <= red;  
          //3rd selection    
          end else if (currBrushsize == 2 && ((x == 55 && y == 53) || (x == 56 && y == 53) || (x == 57 && y == 53) || (x == 58 && y == 53) || (x == 59 && y == 53) || (x == 60 && y == 53) || (x == 61 && y == 53) || (x == 62 && y == 53) || (x == 63 && y == 53) || (x == 64 && y == 53) || (x == 65 && y == 53) || (x == 55 && y == 54) || (x == 65 && y == 54) || (x == 55 && y == 55) || (x == 65 && y == 55) || (x == 55 && y == 56) || (x == 65 && y == 56) || (x == 55 && y == 57) || (x == 65 && y == 57) || (x == 55 && y == 58) || (x == 65 && y == 58) || (x == 55 && y == 59) || (x == 65 && y == 59) || (x == 55 && y == 60) || (x == 65 && y == 60) || (x == 55 && y == 61) || (x == 65 && y == 61) || (x == 55 && y == 62) || (x == 65 && y == 62) || (x == 55 && y == 63) || (x == 56 && y == 63) || (x == 57 && y == 63) || (x == 58 && y == 63) || (x == 59 && y == 63) || (x == 60 && y == 63) || (x == 61 && y == 63) || (x == 62 && y == 63) || (x == 63 && y == 63) || (x == 64 && y == 63) || (x == 65 && y == 63))) begin
               oled_data <= red; 
           end else if (x >= 29 && x <= 39 && y >= 53 && y <= 63) begin
                oled_data <= white;
           end else if (x >= 42 && x <= 52 && y >= 53 && y <= 63) begin
                oled_data <= white;
           end else if (x >= 55 && x <= 65 && y >= 53 && y <= 63) begin      
                oled_data <= white;
           
          
             // Square tool icon
           end else if (((x == 9 && y == 50) || (x == 10 && y == 50) || (x == 11 && y == 50) || (x == 12 && y == 50) || (x == 13 && y == 50) || (x == 14 && y == 50) || (x == 15 && y == 50) || (x == 16 && y == 50) || (x == 17 && y == 50) || (x == 18 && y == 50) || (x == 19 && y == 50) || (x == 9 && y == 51) || (x == 19 && y == 51) || (x == 9 && y == 52) || (x == 19 && y == 52) || (x == 9 && y == 53) || (x == 19 && y == 53) || (x == 9 && y == 54) || (x == 19 && y == 54) || (x == 9 && y == 55) || (x == 19 && y == 55) || (x == 9 && y == 56) || (x == 10 && y == 56) || (x == 11 && y == 56) || (x == 12 && y == 56) || (x == 13 && y == 56) || (x == 14 && y == 56) || (x == 15 && y == 56) || (x == 16 && y == 56) || (x == 17 && y == 56) || (x == 18 && y == 56) || (x == 19 && y == 56))) begin
                oled_data <= black;
           //Square Tool Button Box
           end else if (x >= 7 && x <= 21 && y >=46 && y < 60) begin
                oled_data <= white;
           // On select
           end else if (squaretoolmode && ((x == 6 && y == 45) || (x == 7 && y == 45) || (x == 8 && y == 45) || (x == 9 && y == 45) || (x == 10 && y == 45) || (x == 11 && y == 45) || (x == 12 && y == 45) || (x == 13 && y == 45) || (x == 14 && y == 45) || (x == 15 && y == 45) || (x == 16 && y == 45) || (x == 17 && y == 45) || (x == 18 && y == 45) || (x == 19 && y == 45) || (x == 20 && y == 45) || (x == 21 && y == 45) || (x == 22 && y == 45) || (x == 6 && y == 46) || (x == 22 && y == 46) || (x == 6 && y == 47) || (x == 22 && y == 47) || (x == 6 && y == 48) || (x == 22 && y == 48) || (x == 6 && y == 49) || (x == 22 && y == 49) || (x == 6 && y == 50) || (x == 22 && y == 50) || (x == 6 && y == 51) || (x == 22 && y == 51) || (x == 6 && y == 52) || (x == 22 && y == 52) || (x == 6 && y == 53) || (x == 22 && y == 53) || (x == 6 && y == 54) || (x == 22 && y == 54) || (x == 6 && y == 55) || (x == 22 && y == 55) || (x == 6 && y == 56) || (x == 22 && y == 56) || (x == 6 && y == 57) || (x == 22 && y == 57) || (x == 6 && y == 58) || (x == 22 && y == 58) || (x == 6 && y == 59) || (x == 22 && y == 59) || (x == 6 && y == 60) || (x == 7 && y == 60) || (x == 8 && y == 60) || (x == 9 && y == 60) || (x == 10 && y == 60) || (x == 11 && y == 60) || (x == 12 && y == 60) || (x == 13 && y == 60) || (x == 14 && y == 60) || (x == 15 && y == 60) || (x == 16 && y == 60) || (x == 17 && y == 60) || (x == 18 && y == 60) || (x == 19 && y == 60) || (x == 20 && y == 60) || (x == 21 && y == 60) || (x == 22 && y == 60))) begin
                oled_data <= red;

           end else if (((x == 7 && y == 5) || (x == 6 && y == 6) || (x == 5 && y == 7) || (x == 6 && y == 8) || (x == 7 && y == 9))) begin
                oled_data <= white;

           end else begin
                // Outside canvas
               oled_data <= black;
//end
           end
           
           
           
           //Check if cursor inside canvas are
           if (cursor_x >= X_OFFSET && cursor_x <= 95 - X_OFFSET && cursor_y >= Y_OFFSET && cursor_y <= 62 - Y_OFFSET) begin
                within_canvas <= 1;
           end else begin
                within_canvas <= 0;
           end
           
           //cursor rendering
           if (!squaretoolmode) begin
            if (x >= cursor_x && x < cursor_x + 3 && y >= cursor_y && y < cursor_y + 3) begin 
                if (left_click && within_canvas) begin
                    if (currBrushsize == 2) begin
                        canvas[(cursor_x-X_OFFSET) ][ (cursor_y-Y_OFFSET)] = selectedColor;
                        canvas[((cursor_x-X_OFFSET) + 1) ][ (cursor_y-Y_OFFSET)] = selectedColor;
                        canvas[((cursor_x-X_OFFSET) + 2) ][ (cursor_y-Y_OFFSET)] = selectedColor;
                        canvas[(cursor_x-X_OFFSET) ][ ((cursor_y-Y_OFFSET) + 1)] = selectedColor;
                        canvas[((cursor_x-X_OFFSET) + 1) ][ ((cursor_y-Y_OFFSET) + 1)] = selectedColor;
                        canvas[((cursor_x-X_OFFSET) + 2) ][((cursor_y-Y_OFFSET) + 1)] = selectedColor;
                        canvas[(cursor_x-X_OFFSET) ][ ((cursor_y-Y_OFFSET) + 2)] = selectedColor;
                        canvas[((cursor_x-X_OFFSET) + 1) ][ ((cursor_y-Y_OFFSET) + 2)] = selectedColor;
                        canvas[((cursor_x-X_OFFSET) + 2) ][ ((cursor_y-Y_OFFSET) + 2)] = selectedColor;
                    end else if (currBrushsize == 1) begin
                        canvas[(cursor_x-X_OFFSET) ][ (cursor_y-Y_OFFSET)] = selectedColor;
                        canvas[(cursor_x-X_OFFSET) ][ ((cursor_y-Y_OFFSET) + 1)] = selectedColor;
                        canvas[((cursor_x-X_OFFSET) + 1) ][ ((cursor_y-Y_OFFSET) + 1)] = selectedColor;
                        canvas[(cursor_x-X_OFFSET) + 1][ ((cursor_y-Y_OFFSET))] = selectedColor;              
                    end else if (currBrushsize == 0) begin
                        canvas[(cursor_x-X_OFFSET) ][ (cursor_y-Y_OFFSET)] = selectedColor;
                    end
                // Clear
                end else if (right_click && within_canvas) begin
                    if (currBrushsize == 2) begin
                        canvas [(cursor_x-X_OFFSET) ][ (cursor_y-Y_OFFSET)] = 0;
                        canvas [((cursor_x-X_OFFSET) + 1) ][ (cursor_y-Y_OFFSET)] = 0;
                        canvas [((cursor_x-X_OFFSET) + 2) ][ (cursor_y-Y_OFFSET)] = 0;
                        canvas [(cursor_x-X_OFFSET) ][ ((cursor_y-Y_OFFSET) + 1)] = 0;
                        canvas [((cursor_x-X_OFFSET) + 1) ][ ((cursor_y-15) + 1)] = 0;
                        canvas [((cursor_x-X_OFFSET) + 2) ][ ((cursor_y-Y_OFFSET) + 1)] = 0;
                        canvas [(cursor_x-X_OFFSET) ][ ((cursor_y-Y_OFFSET) + 2)] = 0;
                        canvas [((cursor_x-X_OFFSET) + 1)][((cursor_y - Y_OFFSET) + 2)] = 0;
                        canvas [((cursor_x-X_OFFSET) + 2)] [((cursor_y- Y_OFFSET) + 2)] = 0;
                    end else if (currBrushsize == 1) begin
                        canvas[(cursor_x-X_OFFSET) ][ (cursor_y-Y_OFFSET)] = 0;
                        canvas[(cursor_x-X_OFFSET) ][ ((cursor_y-Y_OFFSET) + 1)] = 0;
                        canvas[((cursor_x-X_OFFSET) + 1) ][ ((cursor_y-Y_OFFSET) + 1)] = 0;
                        canvas[(cursor_x-X_OFFSET) + 1][ ((cursor_y-Y_OFFSET))] = 0;   
                    end else if (currBrushsize == 0) begin
                        canvas[(cursor_x-X_OFFSET) ][ (cursor_y-Y_OFFSET)] = 0;
                    end
                end else begin
                    oled_data <= green;
                end
           end
           end 

           else begin
            // Square tool Feature
            if (debounced_left) begin
                button_statel <= 1;
            end 
            else 
                button_statel <= 0;

            if (debounced_right) begin
                button_stater <= 1;
            end
            else
                button_stater <= 0;
             
             if (x >= cursor_x && x < cursor_x + 3 && y >= cursor_y && y < cursor_y + 3) begin
                oled_data <= green;
             end

            if (debounced_left && !button_statel && within_canvas) begin

                prev_state <= ~prev_state;

                if (!prev_state) begin
                    start_x <= cursor_x;
                    start_y <= cursor_y;
                end

                else if (prev_state) begin
                    end_x <= cursor_x;
                    end_y <= cursor_y;
                end

            end

            if (prev_state) begin
                end_x = cursor_x;
                end_y = cursor_y;

               for (i = X_OFFSET; i <= 95 - X_OFFSET; i = i + 1) begin
                    for (j = Y_OFFSET; j <= 63 - Y_OFFSET; j = j + 1) begin
                        
                        if (cursor_x > start_x) begin
                            if (cursor_y > start_y) begin
                                if ((i <= end_x && i >= start_x) && (j == end_y || j == start_y)) begin
                                        canvas[(i - X_OFFSET)][ (j - Y_OFFSET)] <= 1;
                                    end

                                    else if ((j <= end_y && j >= start_y) && (i == end_x || i == start_x)) begin
                                        canvas[(i - X_OFFSET)][ (j - Y_OFFSET)] <= 1;
                                    end

                                    else
                                        canvas[(i-X_OFFSET)][ (j-Y_OFFSET)] <= 0;
                            end

                            else begin
                                if ((i <= end_x && i >= start_x) && (j == end_y || j == start_y)) begin
                                        canvas[(i - X_OFFSET)][ (j - Y_OFFSET)] <= 1;
                                    end

                                    else if ((j <= start_y && j >= end_y) && (i == end_x || i == start_x)) begin
                                        canvas[(i - X_OFFSET)][ (j - Y_OFFSET)] <= 1;
                                    end

                                    else
                                        canvas[(i-X_OFFSET)][ (j-Y_OFFSET )]<= 0;
                            end
                        end

                        else begin
                            
                            if (cursor_y > start_y) begin
                                if ((i <= start_x && i >= end_x) && (j == end_y || j == start_y)) begin
                                        canvas[(i - X_OFFSET)][ (j - Y_OFFSET)] <= 1;
                                    end

                                    else if ((j <= end_y && j >= start_y) && (i == end_x || i == start_x)) begin
                                        canvas[(i - X_OFFSET)][ (j - Y_OFFSET)] <= 1;
                                    end

                                    else
                                        canvas[(i -X_OFFSET)][ (j-Y_OFFSET)] <= 0;
                            end

                            else begin
                                if ((i <= start_x && i >= end_x) && (j == end_y || j == start_y)) begin
                                        canvas[(i - X_OFFSET)][ (j - Y_OFFSET)] <= 1;
                                    end

                                    else if ((j <= start_y && j >= end_y) && (i == end_x || i == start_x)) begin
                                        canvas[(i - X_OFFSET)][ (j - Y_OFFSET)] <= 1;
                                    end

                                    else
                                        canvas[(i-X_OFFSET)][ (j-Y_OFFSET )]<= 0;
                            end
                        end

                            
                        end
                    
                    end
               end
               else begin
                    end_x <= end_x;
                    end_y <= end_y;
               end 
            end

          

           end
           
endmodule
