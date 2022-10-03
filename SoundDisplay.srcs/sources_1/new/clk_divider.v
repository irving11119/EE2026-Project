`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.09.2022 14:29:12
// Design Name: 
// Module Name: clk_divider
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


module clk_divider(
        input CLK,
        input [31:0] m,
        output reg CLK_OUT = 0
    );
    
    
    reg [31:0] my_seq = 0;
    
    always @ (posedge CLK)
    begin
         my_seq <= (my_seq == m) ? 32'd0 : my_seq + 1;
         CLK_OUT <= (my_seq == 0) ? ~CLK_OUT : CLK_OUT;
    end
    
endmodule
