`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.10.2022 19:48:56
// Design Name: 
// Module Name: whistle_peak_val
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


module whistle_peak_val(
    input clk, input [11:0] mic_in, output reg active
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
            if (peak_value >= 2900)
                begin
                    active <= 1;
                end
                else
                begin
                    active <= 0;
                end

            count <= 32'd0;
            peak_value <= 12'd0;
        end
    end
endmodule
