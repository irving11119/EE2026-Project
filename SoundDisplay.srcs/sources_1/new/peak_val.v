`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/11/2022 12:52:16 AM
// Design Name: 
// Module Name: peak_val
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


module peak_val(
    input clk, input [11:0] mic_in, output reg [7:0] led = 8'd0
    );

    wire clk_20khz;
    reg [11:0] peak_value = 12'd0;
    reg [31:0] count = 32'd0;
    
    clk_divider clk_20k(.CLK(clk),.m(2499),.CLK_OUT(clk_20khz));

    always @(posedge clk_20khz) begin
        count <= count + 1;
        if (mic_in > peak_value)
        begin
            peak_value <= mic_in;
        end

        if (count == 2000)
        begin
            if (peak_value >= 2048 && peak_value < 2458) 
            begin
                led <= 8'b00000000;
            end
            else if (peak_value >= 2458 && peak_value < 2868)
            begin
                led <= 8'b00000001;
            end
            else if (peak_value >= 2868 && peak_value < 3278)
            begin
                led <= 8'b00000011;
            end
            else if (peak_value >= 3278 && peak_value < 3688)
            begin
                led <= 8'b00000111;
            end
            else
            begin
                led <= 8'b00001111;
            end

            count <= 32'd0;
            peak_value <= 12'd0;
        end
    end
endmodule
