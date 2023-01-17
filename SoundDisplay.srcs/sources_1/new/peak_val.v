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
    input clk, input [11:0] mic_in, output reg [7:0] led = 8'd0, output reg [6:0] seg, output [3:0] an, output reg[3:0] vol
    );

    wire clk_20khz;
    reg [11:0] peak_value = 12'd0;
    reg [31:0] count = 32'd0;
    
    clk_divider clk_20k(.CLK(clk),.m(2499),.CLK_OUT(clk_20khz));
    assign an = 4'b1110;
    always @(posedge clk_20khz) begin
        count <= count + 1;
        if (mic_in > peak_value)
        begin
            peak_value <= mic_in;
        end

        if (count == 2000)
        begin
            if (peak_value >= 2048 && peak_value < 2376) begin
                    led <= 8'b00000000;
                    seg <= 7'b1000000;
                    vol <= 0;
                end
                else if (peak_value >= 2376 && peak_value < 2704) 
                begin
                    led <= 8'b00000001;
                    seg <= 7'b1111001;
                    vol <= 1;
                end
                else if (peak_value >= 2704 && peak_value < 3032)
                begin
                    led <= 8'b00000011;
                    seg <= 7'b0100100;
                    vol <= 2;
                end
                else if (peak_value >= 3032 && peak_value < 3360)
                begin
                    led <= 8'b00000111;
                    seg <= 7'b0110000;
                    vol <= 3;
                end
                else if (peak_value >= 3360 && peak_value < 3688)
                begin
                    led <= 8'b00001111;
                    seg <= 7'b0011001;
                    vol <= 4;
                end
                else
                begin
                    led <= 8'b00011111;
                    seg <= 7'b0010010;
                    vol <= 5;
                end

            count <= 32'd0;
            peak_value <= 12'd0;
        end
    end
endmodule
