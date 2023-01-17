`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2022 13:02:04
// Design Name: 
// Module Name: single_pulse
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


module single_pulse(
        input CLOCK, 
        input in_signal,
        output out_signal
    );
    wire Q1, Q2, Qbar1, Qbar2;
    
    DFF dff1( .D(in_signal), .clk(CLOCK), .Q(Q1), .Qbar(Qbar1) );
    DFF dff2( .D(Q1), .clk(CLOCK), .Q(Q2), .Qbar(Qbar2) );
    
    assign out_signal = Q1 & Qbar2;
endmodule
