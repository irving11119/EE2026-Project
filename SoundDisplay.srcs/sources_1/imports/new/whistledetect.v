`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.10.2022 16:09:51
// Design Name: 
// Module Name: whistledetect
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

// Mode
// 1 - Start/Pause
// 2 - Lap

module whistledetect(
        input CLOCK, input [11:0] mic_in, input micmode, input running, output pulse_lapcontrol,output pulse_startcontrol,output reg lapmode = 0, output reg [3:0] led
    );
    wire active;
    reg [31:0]counter = 0;
    reg startwait = 0;
    reg [1:0] beepcount = 0;
    reg currState = 0;
    reg within_1sec = 0;
    whistle_peak_val pk(.clk(CLOCK), .mic_in(mic_in), .active(active));
    
    wire clk_1hz;
    clk_divider clk_11(.CLK(CLOCK),.m(50000000),.CLK_OUT(clk_1hz));
    

    reg [1:0] whistlecount = 0;
    reg within1sec = 0;
    reg within_1_sec = 0;
    reg lapcontrol = 0;
    reg startcontrol = 0;

    single_pulse sp1(
            .CLOCK(CLOCK), 
            .in_signal(lapcontrol),
            .out_signal(pulse_lapcontrol)
        ); 
        
     single_pulse sp2(
           .CLOCK(CLOCK), 
           .in_signal(startcontrol),
           .out_signal(pulse_startcontrol)
     );
    always @ (negedge active) begin
        if (counter <= 40000000) begin
            within_1_sec <= 1;
        end else if (counter > 40000000) begin //If signal end after >3mil
            within_1_sec <= 0;
        end
    end    
     
    always @ (posedge CLOCK) begin
        if (lapmode == 0 && active && within_1_sec) begin // If currently is non-lap mode, 
                startcontrol <= 1;
        end else if(lapmode == 1 && active && within_1_sec) begin
                lapcontrol <= 1;
                if (!running) begin
                    startcontrol <= 1;
                end
        end else begin
                startcontrol <= 0;
                lapcontrol <= 0;
        end
        led[0] <= lapmode;
       if (counter > 40000000 && !active) begin
         counter <= 0; //Reset
         lapmode <= ~lapmode;
       end else begin
         if (active && within_1_sec) begin
            counter <= counter + 1;
         end else begin
            counter  <= 0;
         end
       end
    end
    
endmodule
