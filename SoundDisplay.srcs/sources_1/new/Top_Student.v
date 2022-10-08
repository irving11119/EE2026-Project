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
//  STUDENT B NAME: 
//  STUDENT B MATRICULATION NUMBER: 
//
//////////////////////////////////////////////////////////////////////////////////
// PIN 1 - JB[0]


module Top_Student (
    input CLK100MHZ,
    input btnD,
    input [15:0] sw,
    input  J_MIC3_Pin3,   // Connect from this signal to Audio_Capture.v
    output J_MIC3_Pin1,   // Connect to this signal from Audio_Capture.v
    output J_MIC3_Pin4,  // Connect to this signal from Audio_Capture.v
    output [13:0] led,
    output rgb_cs, rgb_stdin, rgb_sclk, rgb_d_cn, rgb_resn, rgb_vccen, rgb_pmoden
    // Delete this comment and include other inputs and outputs here
    );
    wire [11:0] mic_in;
    wire [15:0] oled_data;

    wire clk_20khz;
    wire clk_10hz;
    wire clk6p25m;
    wire my_frame_begin, my_sendpix, my_sample_pixel;
    wire [12:0] my_pixel_index;
    reg my_chosen_clk;
    
    clk_divider clk_20k(.CLK(CLK100MHZ),.m(2500),.CLK_OUT(clk_20khz));
    clk_divider clk_10(.CLK(CLK100MHZ),.m(5000000),.CLK_OUT(clk_10hz));
    clk_divider clk_6p25(.CLK(CLK100MHZ),.m(8),.CLK_OUT(clk6p25m));
    
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
    OLED_TB tb(
        .my_pixel_index(my_pixel_index), 
        .pbd(btnD),
        .clk(CLK100MHZ),
        .oled_data(oled_data)
    );
    always @ (posedge CLK100MHZ) begin
        my_chosen_clk <= sw[0] ? clk_10hz : clk_20khz;
    end
    
//    always @ (posedge my_chosen_clk) begin
//        led <= mic_in;
//    end
    
    // Delete this comment and write your codes and instantiations here

endmodule