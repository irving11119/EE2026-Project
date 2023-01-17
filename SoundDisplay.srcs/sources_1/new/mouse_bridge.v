`timescale 1ns / 1ps

module mouse_bridge(
        input PS2_CLK,
        input PS2_DATA,
        input CLK,
        output [9:0] MOUSE_X_POS,
        output [9:0] MOUSE_Y_POS,
        output LEFT_CLICK,
        output RIGHT_CLICK,
        output MIDDLE_CLICK,
        output MOUSE_NEW_EVENT
    );
    
    wire [3:0] MOUSE_Z_POS; // Z-POS is scrolling which we don't need, excluded
    
	 MouseCtl #(
         .SYSCLK_FREQUENCY_HZ(200000000),
         .CHECK_PERIOD_MS(100),
         .TIMEOUT_PERIOD_MS(20)
       )MC1(
           .clk(CLK),
           .rst(1'b0),
           .xpos(MOUSE_X_POS),
           .ypos(MOUSE_Y_POS),
           .zpos(MOUSE_Z_POS),
           .left(LEFT_CLICK),
           .middle(MIDDLE_CLICK),
           .right(RIGHT_CLICK),
           .new_event(MOUSE_NEW_EVENT),
           .value(12'd0),
           .setx(1'b0),
           .sety(1'b0),
           .setmax_x(1'b0),
           .setmax_y(1'b0),
           .ps2_clk(PS2_CLK),
           .ps2_data(PS2_DATA)
       );
endmodule