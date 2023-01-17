`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.10.2022 18:35:05
// Design Name: 
// Module Name: stopwatch
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


module stopwatch(
        input CLOCK,
        input [9:0] mouse_x, 
        input [9:0] mouse_y,
        input left_click,
        input [12:0] my_pixel_index,
        input [11:0]mic_in,
        output [6:0] seg,
        output [15:0] oled_data,
        output [3:0] an,
        output [0:0] dp,
        output [4:0] led
    );

//    wire [11:0] mic_in;
    wire clk_10hz; // This is the stopwatch clock (0.1s accuracy)
    //wire startpb;
    wire startbtn;
    wire pausebtn;
    wire pausepb;
    wire RST;
    
    wire clk6p25m;
    reg flashing = 1'b0;
    reg [0:3] dots = 4'b1010;
    wire overflow;
    // Current time
    wire [3:0] ms;
    wire [3:0] onethsec;
    wire [3:0] tenthsec;
    wire [3:0] min;
    
    wire [3:0] lapcount;
    //State Variables
    reg running = 1'b0;
    reg started = 1'b0;
    reg lap = 1'b0;
    
    wire clk_20khz;
    clk_divider clk_20k(.CLK(CLOCK),.m(2499),.CLK_OUT(clk_20khz));
    clk_divider clk_6p25(.CLK(CLOCK),.m(7),.CLK_OUT(clk6p25m));

    always @ (posedge CLOCK) begin
        if (startbtn) begin
            started <= 1;
            running <= 1;
            lap <= 0;
        end
        if (pausebtn) begin
            running <= 0;
        end
        if (RST) begin
            started <= 0;
            running <= 0;
            lap <= 0;
        end
    end

    time_menu tmenu(.CLOCK(CLOCK),
         .my_pixel_index(my_pixel_index),
         .mouse_x(mouse_x), 
         .mouse_y(mouse_y),
         .left_click(left_click),
         .msec(ms), 
         .onesec(onethsec),
         .tenthsec(tenthsec),
         .min(min),
         .mainstartcontrol(startbtn),
         .mainpausecontrol(pausebtn),
         .RST(RST),
         .oled_data(oled_data),
         .mic_in(mic_in),
         .led(led[3:0])
      );    
    clk_divider clk_10k(.CLK(CLOCK),.m(5000000),.CLK_OUT(clk_10hz));
    stopwatch_counter(
            .clk_10hz(clk_10hz), 
            .running(running),
            .msec(ms), // Hold up to 9
            .onesec(onethsec), // Hold up to 9
            .tenthsec(tenthsec), //Hold up to 5
            .min(min), //Hold up to 9
            .overflow(overflow)
        );
     fourdigitdriver driver1(min, tenthsec, onethsec, ms, CLOCK, dots, seg, an, dp);
     
     // Mouse Component
//      mouse_bridge mdriver(
//           .PS2_CLK(PS2_CLK),
//           .PS2_DATA(PS2_DATA),
//           .CLK(CLOCK),
//           .MOUSE_X_POS(MOUSE_X_POS),
//           .MOUSE_Y_POS(MOUSE_Y_POS),
//           .LEFT_CLICK(L_CLICK),
//           .RIGHT_CLICK(R_CLICK),
//           .MIDDLE_CLICK(M_CLICK),
//           .MOUSE_NEW_EVENT(MOUSE_NEW_EVENT)
//       );
     
endmodule
