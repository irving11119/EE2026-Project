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
    input [15:0] sw,
    input btnC,
    input bntU,
    input  J_MIC3_Pin3,   // Connect from this signal to Audio_Capture.v
    output J_MIC3_Pin1,   // Connect to this signal from Audio_Capture.v
    output J_MIC3_Pin4,  // Connect to this signal from Audio_Capture.v
    output reg [11:0] led,
    output rgb_cs, rgb_stdin, rgb_sclk, rgb_d_cn, rgb_resn, rgb_vccen, rgb_pmoden
    // Delete this comment and include other inputs and outputs here
    );
    wire [11:0] mic_in;
    reg [15:0] oled_data = 16'h07E0;
    
    wire clk_20khz;
    wire clk_10hz;
    wire clk6p25m;
    wire my_frame_begin, my_sendpix, my_sample_pixel;
    wire [12:0] my_pixel_index;
    wire my_chosen_clk;
    wire [12:0]x;
    wire [12:0]y;
    
    reg [3:0] count = 3'd0;

    clk_divider clk_20k(.CLK(CLK100MHZ),.m(2499),.CLK_OUT(clk_20khz));
    clk_divider clk_10(.CLK(CLK100MHZ),.m(4999999),.CLK_OUT(clk_10hz));
    clk_divider clk_6p25(.CLK(CLK100MHZ),.m(7),.CLK_OUT(clk6p25m));
    
    Oled_Display od(.clk(clk6p25m),.reset(btnC),
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

    assign my_chosen_clk = sw[0] ? clk_10hz : clk_20khz;
    assign x = my_pixel_index % 96;
    assign y = my_pixel_index / 96;

    always @ (posedge my_chosen_clk) begin
        led <= mic_in; //sum = 9+4 = 13 (R and B)
    end

    always @ (posedge CLK100MHZ) begin
        if (((x == 2 || x == 93) && (y >= 2 && y <= 60)) || ((y == 2 || y == 60) && (x > 2 && x < 93 )))
        begin
            oled_data <= {5'b11111, 6'd0, 5'd0};
        end
        
        else if (((x >=4 && x<=6 || x>=89 && x<=91) && (y >=4 && y <=58)) || ((y >= 4 && y <=6 || y <= 58 && y >= 56)) && (x >= 4 && x <= 91))
        begin
            oled_data <= 16'hFFA500; 
        end
    
        else 
        begin
            oled_data <= 16'd0;
        end
    end

    always @(posedge CLK100MHZ, posedge bntU)
    begin
        if (bntU)
            count <= 1;
    end

endmodule