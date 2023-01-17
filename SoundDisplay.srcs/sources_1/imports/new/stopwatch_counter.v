`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2022 22:05:11
// Design Name: 
// Module Name: stopwatch_counter
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


module stopwatch_counter(
        input clk_10hz, 
        input running,
        output reg [3:0] msec, // Hold up to 9
        output reg [3:0] onesec, // Hold up to 9
        output reg [3:0] tenthsec, //Hold up to 5
        output reg [3:0] min, //Hold up to 9
        output reg [1:0] overflow
    );
    always @ (posedge clk_10hz) begin
       
        if (running) begin
                if (msec == 9) begin
                    msec <= 0;
                    if (onesec == 9) begin
                        onesec <= 0;
                        if (tenthsec == 5) begin
                            tenthsec <= 0;
                            if (min == 9) begin
                                overflow <= 1;
                            end else begin
                                min <= min + 1;
                            end
                        end else begin
                            tenthsec <= tenthsec + 1;
                        end
                    end else begin
                        onesec <= onesec + 1;
                    end
                end else begin
                    msec <= msec + 1;
                end
            end
          end
endmodule
