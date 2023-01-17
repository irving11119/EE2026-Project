`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//
//  LAB SESSION DAY (Delete where applicable): MONDAY P.M, TUESDAY P.M, WEDNESDAY P.M, THURSDAY A.M., THURSDAY P.M
//
//  STUDENT A NAME: POH WEI PIN
//  STUDENT A MATRICULATION NUMBER: A0233849U 
//
//  STUDENT B NAME: IRVING DE BOER
//  STUDENT B MATRICULATION NUMBER: A0238894J 
//
//////////////////////////////////////////////////////////////////////////////////
// PIN 1 - JB[0]


module Top_Student (
    input CLK100MHZ,
    input btnD,
    input [15:0] sw,
    input btnC,
    input btnU,
    inout PS2_CLK,
    inout PS2_DATA,
    input  J_MIC3_Pin3,   // Connect from this signal to Audio_Capture.v
    output J_MIC3_Pin1,   // Connect to this signal from Audio_Capture.v
    output J_MIC3_Pin4,  // Connect to this signal from Audio_Capture.v
    output [15:0] led,
    output rgb_cs, rgb_stdin, rgb_sclk, rgb_d_cn, rgb_resn, rgb_vccen, rgb_pmoden,
    output [6:0] seg, output [3:0] an, output dp
    // Delete this comment and include other inputs and outputs here
    );
    
    // Interfaces
    wire [9:0] MOUSE_X_POS, MOUSE_Y_POS;
    wire L_CLICK, M_CLICK, R_CLICK, MOUSE_NEW_EVENT;
    wire [11:0] mic_in;
    wire [15:0] oled_data;
//        assign led[2] =  L_CLICK;
//    assign led[1] =  M_CLICK;
//    assign led[0] =  R_CLICK;
    
    mouse_bridge mdriver(
         .PS2_CLK(PS2_CLK),
         .PS2_DATA(PS2_DATA),
         .CLK(CLK100MHZ),
         .MOUSE_X_POS(MOUSE_X_POS),
         .MOUSE_Y_POS(MOUSE_Y_POS),
         .LEFT_CLICK(L_CLICK),
         .RIGHT_CLICK(R_CLICK),
         .MIDDLE_CLICK(M_CLICK),
         .MOUSE_NEW_EVENT(MOUSE_NEW_EVENT)
     );
    
    wire clk_20khz;
    wire clk_10hz;
    wire clk6p25m;
    wire my_frame_begin, my_sendpix, my_sample_pixel;
    wire [12:0] my_pixel_index;
    wire my_chosen_clk;
//    wire [13:0]led_output;
    //wire [3:0] vol;
    //reg [3:0] currVolume = 3'd0;

    clk_divider clk_20k(.CLK(CLK100MHZ),.m(2499),.CLK_OUT(clk_20khz));
    clk_divider clk_6p25(.CLK(CLK100MHZ),.m(7),.CLK_OUT(clk6p25m));
    
    Oled_Display od(.clk(clk6p25m),.reset(0),
    .frame_begin(my_frame_begin), .sending_pixels(my_sendpix),
    .sample_pixel(my_sample_pixel), .pixel_index(my_pixel_index), .pixel_data(oled_data), .cs(rgb_cs), .sdin(rgb_stdin), .sclk(rgb_sclk), .d_cn(rgb_d_cn), .resn(rgb_resn), .vccen(rgb_vccen),
    .pmoden(rgb_pmoden),.teststate(0));
    
    Audio_Capture ac(
        .CLK(CLK100MHZ),
        .cs(clk_20khz),
        .MISO(J_MIC3_Pin3),                
        .clk_samp(J_MIC3_Pin1),           
        .sclk(J_MIC3_Pin4),           
        .sample(mic_in)
     );
    
    
    top_menu tm(
         .CLOCK(CLK100MHZ), 
         .sw(sw),
         .mic_in(mic_in), 
         .btnC(btnC),
         .btnU(btnU),
         .btnD(btnD),
         .mouse_x(MOUSE_X_POS), 
         .mouse_y(MOUSE_Y_POS),
         .left_click(L_CLICK),
         .right_click(R_CLICK),
         .my_pixel_index(my_pixel_index),
         .oled_data(oled_data), 
         .led(led), 
         .seg(seg), 
         .an(an),
         .dp(dp)
     );
    
endmodule