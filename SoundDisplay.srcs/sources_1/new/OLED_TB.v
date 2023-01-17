`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2022 15:28:14
// Design Name: 
// Module Name: OLED_TB
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


module OLED_TB(
        input [12:0] my_pixel_index, input pbd, input clk, output reg [15:0] oled_data, output led
    );
    wire [15:0] black = 16'd0;
    wire [15:0] red = 16'b1111100000000000;
    wire [15:0] greenll = 16'b0011111111100111;
    wire [15:0] greenl = 16'b0001111111100011;
    wire [15:0] green = 16'b0000011111100000;
    wire [15:0] yellow = 16'b1111111111100000;
    wire [6:0] x; //from 0 to 95
    wire [5:0] y; //
    assign x = my_pixel_index%96;
    assign y = my_pixel_index/96;
    reg [2:0] counter = 0;
    reg [1:0] btnState = 0;
    reg [31:0] timer = 32'd0;
    wire sig;
    
    debouncer debouncer_inst(
        .pb(pbd),
        .clk(clk),
        .sig(sig)
    );
    
   
   always @ (posedge clk) begin
       if ((x >= 43) && (x <= 53) && (y >= 55) && (y < 60)) begin
           oled_data <= red;
       end else if ((x >= 43) && (x <= 53) && (y >= 47) && (y < 52)) begin
           oled_data <= yellow;
       end else if ((x >= 43) && (x <= 53) && (y >= 39) && (y < 44) && counter >= 1) begin
           oled_data <= green;
       end else if ((x >= 43) && (x <= 53) && (y >= 31) && (y < 36) && counter >= 2) begin
           oled_data <= greenl;
       end else if ((x >= 43) && (x <= 53) && (y >= 23) && (y < 28) && counter >= 3) begin
           oled_data <= greenll;
       end else begin
           oled_data <= black;
       end

        if (timer != 0)
        begin
            timer <= (timer == 500000000) ? 32'd0 : timer + 1;
        end

       if (sig) begin
            if (btnState && timer == 0) begin
                btnState <= 0; //Reset button state to 0
                if (counter == 3) begin
                    counter <= 0; // Reset counter
                end else begin
                    counter <= counter + 1;
                end
                timer <= timer + 1;
            end
       end else begin
            btnState <= 1;
       end
   end

   assign led = (timer == 0) ? 0 : 1;
endmodule
