`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2022 21:19:13
// Design Name: 
// Module Name: debouncer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Debouncer for OTA, OTB - Programmed using 2 D-FF and a slow clock
// 
//////////////////////////////////////////////////////////////////////////////////

// Pass in pushbutton signal, and 100MHZ clk, output debounced signal
module debouncer(
        input pb, clk, output sig
    );
    wire clk_4hz;
    // Create a 4hz clock
    clk_divider clk_divider_inst(
        .CLK(clk),
        .m(12_500_000),
        .CLK_OUT(clk_4hz)
    );
    wire Q1, Q2, Qbar1, Qbar2;
    DFF dff1( .D(pb), .clk(clk_4hz), .Q(Q1), .Qbar(Qbar1) );
    DFF dff2( .D(Q1), .clk(clk_4hz), .Q(Q2), .Qbar(Qbar2) );

    assign sig = Q1 & Qbar2;

endmodule
