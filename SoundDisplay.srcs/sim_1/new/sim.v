`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.09.2022 14:41:29
// Design Name: 
// Module Name: sim
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



module sim( );
 reg CLK100MHZ; wire SLOW_CLOCK;

 Top_Student dut (CLK100MHZ, SLOW_CLOCK);

 initial begin
  CLK100MHZ = 0;
 end

always begin
 #5 CLK100MHZ = ~CLK100MHZ;
end
endmodule

