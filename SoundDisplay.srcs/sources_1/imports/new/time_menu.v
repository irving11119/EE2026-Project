`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2022 15:59:04
// Design Name: 
// Module Name: time_menu
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


module time_menu(
       input CLOCK,
       input [12:0] my_pixel_index,
       input [9:0] mouse_x, 
       input [9:0] mouse_y,
       input left_click,
       input [3:0] msec, // Hold up to 9
       input [3:0] onesec, // Hold up to 9
       input [3:0] tenthsec, //Hold up to 5
       input [3:0] min, //Hold up to 9
       input [11:0] mic_in,
       output RST,
       output mainstartcontrol,
       output mainpausecontrol,
       output reg [15:0] oled_data,
       output [3:0] led
    );
    reg voicestartcontrol = 0;
    reg startcontrol = 0;
    reg voicepausecontrol = 0;
    reg pausecontrol = 0;
    
    reg reset = 0;
    wire db_left_click;
    mdebouncer t(.SIGNAL_I(left_click), .CLK_I(CLOCK), .SIGNAL_O(db_left_click));
    
    // To store current lap information
//    reg [3:0] lapms;
//    reg [3:0] laponethsec;
//    reg [3:0] laptenthsec;
//    reg [3:0] lapmin;
    
    wire [15:0] black = 16'd0;
    wire [15:0] yellow = 16'b1111111111100000;
    wire [15:0] green = 16'b0000011111100000;
    wire [15:0] white = ~black;
    wire [15:0] red = 16'b11111_000000_00000;
    parameter brown = 16'b11000_010010_00000;
    parameter dark_yellow = 16'b11001_110011_00000; 
    parameter blue = 16'b00101_011010_11000;
    parameter purple = 16'b11001_011010_11101;
    wire [6:0] x; //from 0 to 95
    wire [5:0] y; //
    reg [9:0] cursor_x;
    reg [9:0] cursor_y;
    assign x = my_pixel_index%96;
    assign y = my_pixel_index/96;
    // Store Lap Pixel Information
        wire [99:0] mainlapcount;
        reg [99:0] lapcount;
        reg [99:0] voicelapcount;
        
        // Store Lap Time Pixel State
        reg [1:0] lapONEA;
        reg [1:0] lapONEB;
        reg [1:0] lapONEC;
        reg [1:0] lapONED;
        
        reg [1:0] lapTWOA;
        reg [1:0] lapTWOB;
        reg [1:0] lapTWOC;
        reg [1:0] lapTWOD;
         
        reg [1:0]lapTHREEA;
        reg [1:0]lapTHREEB;
        reg [1:0]lapTHREEC;
        reg [1:0]lapTHREED;
        
        reg [1:0]firstcolonONE;
        reg [1:0]secondcolonONE;
        reg [1:0]firstcolonTWO;
        reg [1:0]secondcolonTWO;
        reg [1:0]firstcolonTHREE;
        reg [1:0]secondcolonTHREE;
        
        
        // Store Lap Time
        wire [3:0]mainFIRSTlapms;
        wire [3:0]mainFIRSTlaponethsec;
        wire [3:0]mainFIRSTlaptenthsec;
        wire [3:0]mainFIRSTlapmin;
     
        wire [3:0]mainSECONDlapms;
        wire [3:0]mainSECONDlaponethsec;
        wire [3:0]mainSECONDlaptenthsec;
        wire [3:0]mainSECONDlapmin;
        
        wire [3:0]mainTHIRDlapms;
        wire [3:0]mainTHIRDlaponethsec;
        wire [3:0]mainTHIRDlaptenthsec;
        wire [3:0]mainTHIRDlapmin;
        
        reg [3:0]FIRSTlapms;
        reg [3:0]FIRSTlaponethsec;
        reg [3:0]FIRSTlaptenthsec;
        reg [3:0]FIRSTlapmin;
     
        reg [3:0]SECONDlapms;
        reg [3:0]SECONDlaponethsec;
        reg [3:0]SECONDlaptenthsec;
        reg [3:0]SECONDlapmin;
        
        reg [3:0]THIRDlapms;
        reg [3:0]THIRDlaponethsec;
        reg [3:0]THIRDlaptenthsec;
        reg [3:0]THIRDlapmin;
        
        reg [3:0]voiceFIRSTlapms;
        reg [3:0]voiceFIRSTlaponethsec;
        reg [3:0]voiceFIRSTlaptenthsec;
        reg [3:0]voiceFIRSTlapmin;
     
        reg [3:0]voiceSECONDlapms;
        reg [3:0]voiceSECONDlaponethsec;
        reg [3:0]voiceSECONDlaptenthsec;
        reg [3:0]voiceSECONDlapmin;
        
        reg [3:0]voiceTHIRDlapms;
        reg [3:0]voiceTHIRDlaponethsec;
        reg [3:0]voiceTHIRDlaptenthsec;
        reg [3:0]voiceTHIRDlapmin;
        
        // Current Lap Arrows
        reg lap1arrow;
        reg lap2arrow;
        reg lap3arrow;
        
        // Mic Detection Mode
        reg micicon;
        reg micmode = 0;
        reg [15:0] miccolor;
        //wire [2:0] mode;
        
        //Controllers
        assign mainstartcontrol = micmode ? voicestartcontrol : startcontrol;
        assign mainpausecontrol = micmode ? voicepausecontrol : pausecontrol;
        assign mainlapcount = micmode ? voicelapcount : lapcount;
        assign mainFIRSTlapms = micmode ? voiceFIRSTlapms : FIRSTlapms;
        assign mainFIRSTlaponethsec = micmode ? voiceFIRSTlaponethsec: FIRSTlaponethsec;
        assign mainFIRSTlaptenthsec = micmode ? voiceFIRSTlaptenthsec: FIRSTlaptenthsec;
        assign mainFIRSTlapmin = micmode ? voiceFIRSTlapmin: FIRSTlapmin;
     
        assign mainSECONDlapms = micmode ? voiceSECONDlapms : SECONDlapms ;
        assign mainSECONDlaponethsec = micmode ? voiceSECONDlaponethsec : SECONDlaponethsec;
        assign mainSECONDlaptenthsec = micmode ? voiceSECONDlaptenthsec : SECONDlaptenthsec;
        assign mainSECONDlapmin = micmode ? voiceSECONDlapmin : SECONDlapmin;
        
        assign mainTHIRDlapms = micmode ? voiceTHIRDlapms : THIRDlapms;
        assign mainTHIRDlaponethsec = micmode ? voiceTHIRDlaponethsec : THIRDlaponethsec;
        assign mainTHIRDlaptenthsec = micmode ? voiceTHIRDlaptenthsec : THIRDlaptenthsec;
        assign mainTHIRDlapmin = micmode ? voiceTHIRDlapmin : THIRDlapmin;
        
    initial begin
            //reset = 0;
            miccolor = red;
            lapcount = 0;
            voicelapcount = 0;
            lapONEA = 0;
            lapONEB = 0;
            lapONEC = 0;
            lapONED = 0;
            
            lapTWOA = 0;
            lapTWOB = 0;
            lapTWOC = 0;
            lapTWOD = 0;
            
            lapTHREEA = 0;
            lapTHREEB = 0;
            lapTHREEC = 0;
            lapTHREED = 0;
            
            firstcolonONE = 0;
            secondcolonONE = 0;
            firstcolonTWO = 0;
            secondcolonTWO = 0;
            firstcolonTHREE = 0;
            secondcolonTHREE = 0;
    end
    
    // LEFT CLICK DETECTION CLOCK
    always @ (posedge db_left_click ) begin
     // Lap Button
     if (cursor_x >= 15 && cursor_x < 35 && cursor_y >= 51 && cursor_y < 61 && !micmode) begin
        if (mainstartcontrol && !mainpausecontrol) begin
            lapcount = (mainlapcount == 3) ? 1 : lapcount + 1;
            // Lap Timers
            FIRSTlapms = lapcount == 1 ? msec : FIRSTlapms;
            FIRSTlaponethsec = lapcount == 1 ? onesec : FIRSTlaponethsec;
            FIRSTlaptenthsec = lapcount == 1 ? tenthsec: FIRSTlaptenthsec;
            FIRSTlapmin = lapcount == 1 ? min :FIRSTlapmin ; 
            
            SECONDlapms =  lapcount == 2 ?msec :SECONDlapms;
            SECONDlaponethsec = lapcount == 2 ?onesec: SECONDlaponethsec;
            SECONDlaptenthsec = lapcount == 2 ?tenthsec: SECONDlaptenthsec;
            SECONDlapmin = lapcount == 2 ?min: SECONDlapmin;
            
            THIRDlapms = lapcount == 3 ? msec:THIRDlapms;
            THIRDlaponethsec = lapcount == 3 ?onesec:THIRDlaponethsec;
            THIRDlaptenthsec = lapcount == 3 ?tenthsec:THIRDlaptenthsec ;
            THIRDlapmin = lapcount == 3 ?min:THIRDlapmin; 
        end
    end 
        // Detect Start/Pause Button Click
         if (cursor_x >= 54 && cursor_x < 81 && cursor_y >= 51 && cursor_y < 61 && !micmode) begin
            if (mainstartcontrol) begin //If Started and not in mic 
                    startcontrol <= 0;
                    pausecontrol <= 1;
            end else begin //Not started yet
                    startcontrol <= 1;
                    pausecontrol <= 0;
            end
         end
        // Sound Detection Mode Click
        if (cursor_x >= 81 && cursor_x < 90 && cursor_y >= 5 && cursor_y < 13) begin
            micmode = ~micmode;
        end
    end
    wire startmode;
    wire lapmode;
    wire lapselect;
    // micmode - Pass in current status for micmode - True means listen to whistle
    // voicestartcontrol - input to check if timer is running currently
    // lapmode - Current status whether it is in lap whistle mode or start/pause whistle mode
    whistledetect wd(.CLOCK(CLOCK), .mic_in(mic_in), .micmode(micmode), .running(voicestartcontrol), .lapmode(lapselect), .pulse_lapcontrol(lapmode), .pulse_startcontrol(startmode) , .led(led));
    
    always @ (posedge startmode) begin
    if (micmode) begin
        if (mainstartcontrol) begin //If Started and not in mic 
                voicestartcontrol <= 0;
                voicepausecontrol <= 1;
        end else begin //Not started yet
                voicestartcontrol <= 1;
                voicepausecontrol <= 0;
        end
        end
    end
    
    always @ (posedge lapmode) begin
        if (micmode) begin
                    if (mainstartcontrol && !mainpausecontrol) begin
                                voicelapcount = (mainlapcount == 3) ? 1 : voicelapcount + 1;
                                // Lap Timers
                                voiceFIRSTlapms = voicelapcount == 1 ? msec : voiceFIRSTlapms;
                                voiceFIRSTlaponethsec = voicelapcount == 1 ? onesec : voiceFIRSTlaponethsec;
                                voiceFIRSTlaptenthsec = voicelapcount == 1 ? tenthsec: voiceFIRSTlaptenthsec;
                                voiceFIRSTlapmin = voicelapcount == 1 ? min :voiceFIRSTlapmin ; 
                                
                                voiceSECONDlapms =  voicelapcount == 2 ?msec :voiceSECONDlapms;
                                voiceSECONDlaponethsec = voicelapcount == 2 ?onesec: voiceSECONDlaponethsec;
                                voiceSECONDlaptenthsec = voicelapcount == 2 ?tenthsec: voiceSECONDlaptenthsec;
                                voiceSECONDlapmin = voicelapcount == 2 ?min: voiceSECONDlapmin;
                                
                                voiceTHIRDlapms = voicelapcount == 3 ? msec:voiceTHIRDlapms;
                                voiceTHIRDlaponethsec = voicelapcount == 3 ?onesec:voiceTHIRDlaponethsec;
                                voiceTHIRDlaptenthsec = voicelapcount == 3 ?tenthsec:voiceTHIRDlaptenthsec ;
                                voiceTHIRDlapmin = voicelapcount == 3 ?min:voiceTHIRDlapmin; 
                            end
                    end
    end
    
    
    always @ (posedge CLOCK) begin
    // RESET Button Click
    if (db_left_click && cursor_x >= 83 && cursor_x <= 94 && cursor_y >= 50 && cursor_y <= 61 && !micmode) begin
        reset <= 1;
    end else begin
        reset <= 0;
    end
     cursor_x = mouse_x/10;
     cursor_y = mouse_y/10;
     micicon <= ((x == 81 && y == 8) || (x == 81 && y == 9) || (x == 82 && y == 8) || (x == 82 && y == 9) || (x == 84 && y == 5) || (x == 84 && y == 7) || (x == 84 && y == 10) || (x == 84 && y == 12) || (x == 85 && y == 5) || (x == 85 && y == 8) || (x == 85 && y == 9) || (x == 85 && y == 12) || (x == 86 && y == 6) || (x == 86 && y == 11) || (x == 87 && y == 7) || (x == 87 && y == 8) || (x == 87 && y == 9) || (x == 87 && y == 10));
     lap1arrow <= ((x == 9 && y == 17) || (x == 9 && y == 18) || (x == 9 && y == 19) || (x == 9 && y == 20) || (x == 9 && y == 21) || (x == 9 && y == 22) || (x == 9 && y == 23) || (x == 10 && y == 18) || (x == 10 && y == 19) || (x == 10 && y == 20) || (x == 10 && y == 21) || (x == 10 && y == 22) || (x == 11 && y == 19) || (x == 11 && y == 20) || (x == 11 && y == 21) || (x == 12 && y == 20));
     lap2arrow <= ((x == 9 && y == 29) || (x == 9 && y == 30) || (x == 9 && y == 31) || (x == 9 && y == 32) || (x == 9 && y == 33) || (x == 9 && y == 34) || (x == 9 && y == 35) || (x == 10 && y == 30) || (x == 10 && y == 31) || (x == 10 && y == 32) || (x == 10 && y == 33) || (x == 10 && y == 34) || (x == 11 && y == 31) || (x == 11 && y == 32) || (x == 11 && y == 33) || (x == 12 && y == 32));
     lap3arrow <= ((x == 9 && y == 41) || (x == 9 && y == 42) || (x == 9 && y == 43) || (x == 9 && y == 44) || (x == 9 && y == 45) || (x == 9 && y == 46) || (x == 9 && y == 47) || (x == 10 && y == 42) || (x == 10 && y == 43) || (x == 10 && y == 44) || (x == 10 && y == 45) || (x == 10 && y == 46) || (x == 11 && y == 43) || (x == 11 && y == 44) || (x == 11 && y == 45) || (x == 12 && y == 44));
     
    firstcolonONE <= (mainlapcount >= 1) && (x == 24 && y ==  17) || (x == 24 && y ==  18) || (x == 24 && y ==  20) || (x == 24 && y ==  21) || (x == 25 && y ==  17) || (x == 25 && y ==  18) || (x == 25 && y ==  20) || (x == 25 && y ==  21);
    secondcolonONE <= (mainlapcount >= 1) && ((x == 36 && y ==  17) || (x == 36 && y ==  18) || (x == 36 && y ==  20) || (x == 36 && y ==  21) || (x == 37 && y ==  17) || (x == 37 && y ==  18) || (x == 37 && y ==  20) || (x == 37 && y ==  21)) ;
    firstcolonTWO <= (mainlapcount >= 2) && (x == 24 && y == 12 + 17) || (x == 24 && y == 12 + 18) || (x == 24 && y == 12 + 20) || (x == 24 && y == 12 + 21) || (x == 25 && y == 12 + 17) || (x == 25 && y == 12 + 18) || (x == 25 && y == 12 + 20) || (x == 25 && y == 12 + 21);
    secondcolonTWO <= (mainlapcount >= 2) && ((x == 36 && y == 12 + 17) || (x == 36 && y == 12 + 18) || (x == 36 && y == 12 + 20) || (x == 36 && y == 12 + 21) || (x == 37 && y == 12 + 17) || (x == 37 && y == 12 + 18) || (x == 37 && y == 12 + 20) || (x == 37 && y == 12 + 21)) ;
    firstcolonTHREE <= (mainlapcount == 3) && (x == 24 && y == 24 + 17) || (x == 24 && y == 24 + 18) || (x == 24 && y == 24 + 20) || (x == 24 && y == 24 + 21) || (x == 25 && y == 24 + 17) || (x == 25 && y == 24 + 18) || (x == 25 && y == 24 + 20) || (x == 25 && y == 24 + 21);
    secondcolonTHREE <= (mainlapcount == 3) && ((x == 36 && y == 24 + 17) || (x == 36 && y == 24 + 18) || (x == 36 && y == 24 + 20) || (x == 36 && y == 24 + 21) || (x == 37 && y == 24 + 17) || (x == 37 && y == 24 + 18) || (x == 37 && y == 24 + 20) || (x == 37 && y == 24 + 21)) ;
    
    if (micmode) begin
        miccolor = green;
    end else begin
        miccolor = red;
    end
            
     case(mainFIRSTlapmin)
          4'd0: lapONEA = ((x == 20 && y ==  17) || (x == 21 && y ==  17) || (x == 22 && y ==  17) || (x == 20 && y ==  18) || (x == 22 && y ==  18) || (x == 20 && y ==  19) || (x == 22 && y ==  19) || (x == 20 && y ==  20) || (x == 22 && y ==  20) || (x == 20 && y ==  21) || (x == 21 && y ==  21) || (x == 22 && y ==  21));
          4'd1: lapONEA = ((x == 21 && y ==  17) || (x == 20 && y ==  18) || (x == 21 && y ==  18) || (x == 21 && y ==  19) || (x == 21 && y ==  20) || (x == 20 && y ==  21) || (x == 21 && y ==  21) || (x == 22 && y ==  21));
          4'd2: lapONEA = ((x == 20 && y ==  17) || (x == 21 && y ==  17) || (x == 22 && y ==  17) || (x == 22 && y ==  18) || (x == 20 && y ==  19) || (x == 21 && y ==  19) || (x == 22 && y ==  19) || (x == 20 && y ==  20) || (x == 20 && y ==  21) || (x == 21 && y ==  21) || (x == 22 && y ==  21));
          4'd3: lapONEA = ((x == 20 && y ==  17) || (x == 21 && y ==  17) || (x == 22 && y ==  17) || (x == 22 && y ==  18) || (x == 20 && y ==  19) || (x == 21 && y ==  19) || (x == 22 && y ==  19) || (x == 22 && y ==  20) || (x == 20 && y ==  21) || (x == 21 && y ==  21) || (x == 22 && y ==  21));
          4'd4: lapONEA = ((x == 20 && y ==  17) || (x == 22 && y ==  17) || (x == 20 && y ==  18) || (x == 22 && y ==  18) || (x == 20 && y ==  19) || (x == 21 && y ==  19) || (x == 22 && y ==  19) || (x == 22 && y ==  20) || (x == 22 && y ==  21));
          4'd5: lapONEA = ((x == 20 && y ==  17) || (x == 21 && y ==  17) || (x == 22 && y ==  17) || (x == 20 && y ==  18) || (x == 20 && y ==  19) || (x == 21 && y ==  19) || (x == 22 && y ==  19) || (x == 22 && y ==  20) || (x == 20 && y ==  21) || (x == 21 && y ==  21) || (x == 22 && y ==  21));
          4'd6: lapONEA = ((x == 20 && y ==  17) || (x == 21 && y ==  17) || (x == 22 && y ==  17) || (x == 20 && y ==  18) || (x == 20 && y ==  19) || (x == 21 && y ==  19) || (x == 22 && y ==  19) || (x == 20 && y ==  20) || (x == 22 && y ==  20) || (x == 20 && y ==  21) || (x == 21 && y ==  21) || (x == 22 && y ==  21));
          4'd7: lapONEA = ((x == 20 && y ==  17) || (x == 21 && y ==  17) || (x == 22 && y ==  17) || (x == 22 && y ==  18) || (x == 22 && y ==  19) || (x == 22 && y ==  20) || (x == 22 && y ==  21));
          4'd8: lapONEA = ((x == 20 && y ==  17) || (x == 21 && y ==  17) || (x == 22 && y ==  17) || (x == 20 && y ==  18) || (x == 22 && y ==  18) || (x == 20 && y ==  19) || (x == 21 && y ==  19) || (x == 22 && y ==  19) || (x == 20 && y ==  20) || (x == 22 && y ==  20) || (x == 20 && y ==  21) || (x == 21 && y ==  21) || (x == 22 && y ==  21));
          4'd9: lapONEA = ((x == 20 && y ==  17) || (x == 21 && y ==  17) || (x == 22 && y ==  17) || (x == 20 && y ==  18) || (x == 22 && y ==  18) || (x == 20 && y ==  19) || (x == 21 && y ==  19) || (x == 22 && y ==  19) || (x == 22 && y ==  20) || (x == 20 && y ==  21) || (x == 21 && y ==  21) || (x == 22 && y ==  21));
       endcase
     case(mainFIRSTlaptenthsec)
         4'd0: lapONEB = (x == 27 && y ==  17) || (x == 28 && y ==  17) || (x == 29 && y ==  17) || (x == 27 && y ==  18) || (x == 29 && y ==  18) || (x == 27 && y ==  19) || (x == 29 && y ==  19) || (x == 27 && y ==  20) || (x == 29 && y ==  20) || (x == 27 && y ==  21) || (x == 28 && y ==  21) || (x == 29 && y ==  21);
         4'd1: lapONEB = ((x == 28 && y ==  17) || (x == 27 && y ==  18) || (x == 28 && y ==  18) || (x == 28 && y ==  19) || (x == 28 && y ==  20) || (x == 27 && y ==  21) || (x == 28 && y ==  21) || (x == 29 && y ==  21));
         4'd2: lapONEB = (x == 27 && y ==  17) || (x == 28 && y ==  17) || (x == 29 && y ==  17) || (x == 29 && y ==  18) || (x == 27 && y ==  19) || (x == 28 && y ==  19) || (x == 29 && y ==  19) || (x == 27 && y ==  20) || (x == 27 && y ==  21) || (x == 28 && y ==  21) || (x == 29 && y ==  21);
         4'd3: lapONEB = (x == 27 && y ==  17) || (x == 28 && y ==  17) || (x == 29 && y ==  17) || (x == 29 && y ==  18) || (x == 27 && y ==  19) || (x == 28 && y ==  19) || (x == 29 && y ==  19) || (x == 29 && y ==  20) || (x == 27 && y ==  21) || (x == 28 && y ==  21) || (x == 29 && y ==  21);
         4'd4: lapONEB = (x == 27 && y ==  17) || (x == 29 && y ==  17) || (x == 27 && y ==  18) || (x == 29 && y ==  18) || (x == 27 && y ==  19) || (x == 28 && y ==  19) || (x == 29 && y ==  19) || (x == 29 && y ==  20) || (x == 29 && y ==  21);
         4'd5: lapONEB = (x == 27 && y ==  17) || (x == 28 && y ==  17) || (x == 29 && y ==  17) || (x == 27 && y ==  18) || (x == 27 && y ==  19) || (x == 28 && y ==  19) || (x == 29 && y ==  19) || (x == 29 && y ==  20) || (x == 27 && y ==  21) || (x == 28 && y ==  21) || (x == 29 && y ==  21);
      endcase
     case(mainFIRSTlaponethsec)
         4'd0: lapONEC = ((x == 31 && y ==  17) || (x == 32 && y ==  17) || (x == 33 && y ==  17) || (x == 31 && y ==  18) || (x == 33 && y ==  18) || (x == 31 && y ==  19) || (x == 33 && y ==  19) || (x == 31 && y ==  20) || (x == 33 && y ==  20) || (x == 31 && y ==  21) || (x == 32 && y ==  21) || (x == 33 && y ==  21));
         4'd1: lapONEC = ((x == 32 && y ==  17) || (x == 31 && y ==  18) || (x == 32 && y ==  18) || (x == 32 && y ==  19) || (x == 32 && y ==  20) || (x == 31 && y ==  21) || (x == 32 && y ==  21) || (x == 33 && y ==  21));
         4'd2: lapONEC = ((x == 31 && y ==  17) || (x == 32 && y ==  17) || (x == 33 && y ==  17) || (x == 33 && y ==  18) || (x == 31 && y ==  19) || (x == 32 && y ==  19) || (x == 33 && y ==  19) || (x == 31 && y ==  20) || (x == 31 && y ==  21) || (x == 32 && y ==  21) || (x == 33 && y ==  21));
         4'd3: lapONEC = ((x == 31 && y ==  17) || (x == 32 && y ==  17) || (x == 33 && y ==  17) || (x == 33 && y ==  18) || (x == 31 && y ==  19) || (x == 32 && y ==  19) || (x == 33 && y ==  19) || (x == 33 && y ==  20) || (x == 31 && y ==  21) || (x == 32 && y ==  21) || (x == 33 && y ==  21));
         4'd4: lapONEC = ((x == 31 && y ==  17) || (x == 33 && y ==  17) || (x == 31 && y ==  18) || (x == 33 && y ==  18) || (x == 31 && y ==  19) || (x == 32 && y ==  19) || (x == 33 && y ==  19) || (x == 33 && y ==  20) || (x == 33 && y ==  21));
         4'd5: lapONEC = ((x == 31 && y ==  17) || (x == 32 && y ==  17) || (x == 33 && y ==  17) || (x == 31 && y ==  18) || (x == 31 && y ==  19) || (x == 32 && y ==  19) || (x == 33 && y ==  19) || (x == 33 && y ==  20) || (x == 31 && y ==  21) || (x == 32 && y ==  21) || (x == 33 && y ==  21));
         4'd6: lapONEC = ((x == 31 && y ==  17) || (x == 32 && y ==  17) || (x == 33 && y ==  17) || (x == 31 && y ==  18) || (x == 31 && y ==  19) || (x == 32 && y ==  19) || (x == 33 && y ==  19) || (x == 31 && y ==  20) || (x == 33 && y ==  20) || (x == 31 && y ==  21) || (x == 32 && y ==  21) || (x == 33 && y ==  21));
         4'd7: lapONEC = ((x == 31 && y ==  17) || (x == 32 && y ==  17) || (x == 33 && y ==  17) || (x == 33 && y ==  18) || (x == 33 && y ==  19) || (x == 33 && y ==  20) || (x == 33 && y ==  21));
         4'd8: lapONEC = ((x == 31 && y ==  17) || (x == 32 && y ==  17) || (x == 33 && y ==  17) || (x == 31 && y ==  18) || (x == 33 && y ==  18) || (x == 31 && y ==  19) || (x == 32 && y ==  19) || (x == 33 && y ==  19) || (x == 31 && y ==  20) || (x == 33 && y ==  20) || (x == 31 && y ==  21) || (x == 32 && y ==  21) || (x == 33 && y ==  21));
         4'd9: lapONEC = ((x == 31 && y ==  17) || (x == 32 && y ==  17) || (x == 33 && y ==  17) || (x == 31 && y ==  18) || (x == 33 && y ==  18) || (x == 31 && y ==  19) || (x == 32 && y ==  19) || (x == 33 && y ==  19) || (x == 33 && y ==  20) || (x == 31 && y ==  21) || (x == 32 && y ==  21) || (x == 33 && y ==  21));
      endcase
     case(mainFIRSTlapms) //Start at 40
         4'd0: lapONED = ((x == 40 && y ==  17) || (x == 41 && y ==  17) || (x == 42 && y ==  17) || (x == 40 && y ==  18) || (x == 42 && y ==  18) || (x == 40 && y ==  19) || (x == 42 && y ==  19) || (x == 40 && y ==  20) || (x == 42 && y ==  20) || (x == 40 && y ==  21) || (x == 41 && y ==  21) || (x == 42 && y ==  21));
         4'd1: lapONED = ((x == 41 && y ==  17) || (x == 40 && y ==  18) || (x == 41 && y ==  18) || (x == 41 && y ==  19) || (x == 41 && y ==  20) || (x == 40 && y ==  21) || (x == 41 && y ==  21) || (x == 42 && y ==  21));
         4'd2: lapONED = ((x == 40 && y ==  17) || (x == 41 && y ==  17) || (x == 42 && y ==  17) || (x == 42 && y ==  18) || (x == 40 && y ==  19) || (x == 41 && y ==  19) || (x == 42 && y ==  19) || (x == 40 && y ==  20) || (x == 40 && y ==  21) || (x == 41 && y ==  21) || (x == 42 && y ==  21));
         4'd3: lapONED = ((x == 40 && y ==  17) || (x == 41 && y ==  17) || (x == 42 && y ==  17) || (x == 42 && y ==  18) || (x == 40 && y ==  19) || (x == 41 && y ==  19) || (x == 42 && y ==  19) || (x == 42 && y ==  20) || (x == 40 && y ==  21) || (x == 41 && y ==  21) || (x == 42 && y ==  21));
         4'd4: lapONED = ((x == 40 && y ==  17) || (x == 42 && y ==  17) || (x == 40 && y ==  18) || (x == 42 && y ==  18) || (x == 40 && y ==  19) || (x == 41 && y ==  19) || (x == 42 && y ==  19) || (x == 42 && y ==  20) || (x == 42 && y ==  21));
         4'd5: lapONED = ((x == 40 && y ==  17) || (x == 41 && y ==  17) || (x == 42 && y ==  17) || (x == 40 && y ==  18) || (x == 40 && y ==  19) || (x == 41 && y ==  19) || (x == 42 && y ==  19) || (x == 42 && y ==  20) || (x == 40 && y ==  21) || (x == 41 && y ==  21) || (x == 42 && y ==  21));
         4'd6: lapONED = ((x == 40 && y ==  17) || (x == 41 && y ==  17) || (x == 42 && y ==  17) || (x == 40 && y ==  18) || (x == 40 && y ==  19) || (x == 41 && y ==  19) || (x == 42 && y ==  19) || (x == 40 && y ==  20) || (x == 42 && y ==  20) || (x == 40 && y ==  21) || (x == 41 && y ==  21) || (x == 42 && y ==  21));
         4'd7: lapONED = ((x == 40 && y ==  17) || (x == 41 && y ==  17) || (x == 42 && y ==  17) || (x == 42 && y ==  18) || (x == 42 && y ==  19) || (x == 42 && y ==  20) || (x == 42 && y ==  21));
         4'd8: lapONED = ((x == 40 && y ==  17) || (x == 41 && y ==  17) || (x == 42 && y ==  17) || (x == 40 && y ==  18) || (x == 42 && y ==  18) || (x == 40 && y ==  19) || (x == 41 && y ==  19) || (x == 42 && y ==  19) || (x == 40 && y ==  20) || (x == 42 && y ==  20) || (x == 40 && y ==  21) || (x == 41 && y ==  21) || (x == 42 && y ==  21));
         4'd9: lapONED = ((x == 40 && y ==  17) || (x == 41 && y ==  17) || (x == 42 && y ==  17) || (x == 40 && y ==  18) || (x == 42 && y ==  18) || (x == 40 && y ==  19) || (x == 41 && y ==  19) || (x == 42 && y ==  19) || (x == 42 && y ==  20) || (x == 40 && y ==  21) || (x == 41 && y ==  21) || (x == 42 && y ==  21));
      endcase
     case(mainSECONDlapmin)
           4'd0: lapTWOA = ((x == 20 && y == 12 + 17) || (x == 21 && y == 12 + 17) || (x == 22 && y == 12 + 17) || (x == 20 && y == 12 + 18) || (x == 22 && y == 12 + 18) || (x == 20 && y == 12 + 19) || (x == 22 && y == 12 + 19) || (x == 20 && y == 12 + 20) || (x == 22 && y == 12 + 20) || (x == 20 && y == 12 + 21) || (x == 21 && y == 12 + 21) || (x == 22 && y == 12 + 21));
           4'd1: lapTWOA = ((x == 21 && y == 12 + 17) || (x == 20 && y == 12 + 18) || (x == 21 && y == 12 + 18) || (x == 21 && y == 12 + 19) || (x == 21 && y == 12 + 20) || (x == 20 && y == 12 + 21) || (x == 21 && y == 12 + 21) || (x == 22 && y == 12 + 21));
           4'd2: lapTWOA = ((x == 20 && y == 12 + 17) || (x == 21 && y == 12 + 17) || (x == 22 && y == 12 + 17) || (x == 22 && y == 12 + 18) || (x == 20 && y == 12 + 19) || (x == 21 && y == 12 + 19) || (x == 22 && y == 12 + 19) || (x == 20 && y == 12 + 20) || (x == 20 && y == 12 + 21) || (x == 21 && y == 12 + 21) || (x == 22 && y == 12 + 21));
           4'd3: lapTWOA = ((x == 20 && y == 12 + 17) || (x == 21 && y == 12 + 17) || (x == 22 && y == 12 + 17) || (x == 22 && y == 12 + 18) || (x == 20 && y == 12 + 19) || (x == 21 && y == 12 + 19) || (x == 22 && y == 12 + 19) || (x == 22 && y == 12 + 20) || (x == 20 && y == 12 + 21) || (x == 21 && y == 12 + 21) || (x == 22 && y == 12 + 21));
           4'd4: lapTWOA = ((x == 20 && y == 12 + 17) || (x == 22 && y == 12 + 17) || (x == 20 && y == 12 + 18) || (x == 22 && y == 12 + 18) || (x == 20 && y == 12 + 19) || (x == 21 && y == 12 + 19) || (x == 22 && y == 12 + 19) || (x == 22 && y == 12 + 20) || (x == 22 && y == 12 + 21));
           4'd5: lapTWOA = ((x == 20 && y == 12 + 17) || (x == 21 && y == 12 + 17) || (x == 22 && y == 12 + 17) || (x == 20 && y == 12 + 18) || (x == 20 && y == 12 + 19) || (x == 21 && y == 12 + 19) || (x == 22 && y == 12 + 19) || (x == 22 && y == 12 + 20) || (x == 20 && y == 12 + 21) || (x == 21 && y == 12 + 21) || (x == 22 && y == 12 + 21));
           4'd6: lapTWOA = ((x == 20 && y == 12 + 17) || (x == 21 && y == 12 + 17) || (x == 22 && y == 12 + 17) || (x == 20 && y == 12 + 18) || (x == 20 && y == 12 + 19) || (x == 21 && y == 12 + 19) || (x == 22 && y == 12 + 19) || (x == 20 && y == 12 + 20) || (x == 22 && y == 12 + 20) || (x == 20 && y == 12 + 21) || (x == 21 && y == 12 + 21) || (x == 22 && y == 12 + 21));
           4'd7: lapTWOA = ((x == 20 && y == 12 + 17) || (x == 21 && y == 12 + 17) || (x == 22 && y == 12 + 17) || (x == 22 && y == 12 + 18) || (x == 22 && y == 12 + 19) || (x == 22 && y == 12 + 20) || (x == 22 && y == 12 + 21));
           4'd8: lapTWOA = ((x == 20 && y == 12 + 17) || (x == 21 && y == 12 + 17) || (x == 22 && y == 12 + 17) || (x == 20 && y == 12 + 18) || (x == 22 && y == 12 + 18) || (x == 20 && y == 12 + 19) || (x == 21 && y == 12 + 19) || (x == 22 && y == 12 + 19) || (x == 20 && y == 12 + 20) || (x == 22 && y == 12 + 20) || (x == 20 && y == 12 + 21) || (x == 21 && y == 12 + 21) || (x == 22 && y == 12 + 21));
           4'd9: lapTWOA = ((x == 20 && y == 12 + 17) || (x == 21 && y == 12 + 17) || (x == 22 && y == 12 + 17) || (x == 20 && y == 12 + 18) || (x == 22 && y == 12 + 18) || (x == 20 && y == 12 + 19) || (x == 21 && y == 12 + 19) || (x == 22 && y == 12 + 19) || (x == 22 && y == 12 + 20) || (x == 20 && y == 12 + 21) || (x == 21 && y == 12 + 21) || (x == 22 && y == 12 + 21));
        endcase
     case(mainSECONDlaptenthsec)
          4'd0: lapTWOB = (x == 27 && y == 12 + 17) || (x == 28 && y == 12 + 17) || (x == 29 && y == 12 + 17) || (x == 27 && y == 12 + 18) || (x == 29 && y == 12 + 18) || (x == 27 && y == 12 + 19) || (x == 29 && y == 12 + 19) || (x == 27 && y == 12 + 20) || (x == 29 && y == 12 + 20) || (x == 27 && y == 12 + 21) || (x == 28 && y == 12 + 21) || (x == 29 && y == 12 + 21);
          4'd1: lapTWOB = ((x == 28 && y == 12 + 17) || (x == 27 && y == 12 + 18) || (x == 28 && y == 12 + 18) || (x == 28 && y == 12 + 19) || (x == 28 && y == 12 + 20) || (x == 27 && y == 12 + 21) || (x == 28 && y == 12 + 21) || (x == 29 && y == 12 + 21));
          4'd2: lapTWOB = (x == 27 && y == 12 + 17) || (x == 28 && y == 12 + 17) || (x == 29 && y == 12 + 17) || (x == 29 && y == 12 + 18) || (x == 27 && y == 12 + 19) || (x == 28 && y == 12 + 19) || (x == 29 && y == 12 + 19) || (x == 27 && y == 12 + 20) || (x == 27 && y == 12 + 21) || (x == 28 && y == 12 + 21) || (x == 29 && y == 12 + 21);
          4'd3: lapTWOB = (x == 27 && y == 12 + 17) || (x == 28 && y == 12 + 17) || (x == 29 && y == 12 + 17) || (x == 29 && y == 12 + 18) || (x == 27 && y == 12 + 19) || (x == 28 && y == 12 + 19) || (x == 29 && y == 12 + 19) || (x == 29 && y == 12 + 20) || (x == 27 && y == 12 + 21) || (x == 28 && y == 12 + 21) || (x == 29 && y == 12 + 21);
          4'd4: lapTWOB = (x == 27 && y == 12 + 17) || (x == 29 && y == 12 + 17) || (x == 27 && y == 12 + 18) || (x == 29 && y == 12 + 18) || (x == 27 && y == 12 + 19) || (x == 28 && y == 12 + 19) || (x == 29 && y == 12 + 19) || (x == 29 && y == 12 + 20) || (x == 29 && y == 12 + 21);
          4'd5: lapTWOB = (x == 27 && y == 12 + 17) || (x == 28 && y == 12 + 17) || (x == 29 && y == 12 + 17) || (x == 27 && y == 12 + 18) || (x == 27 && y == 12 + 19) || (x == 28 && y == 12 + 19) || (x == 29 && y == 12 + 19) || (x == 29 && y == 12 + 20) || (x == 27 && y == 12 + 21) || (x == 28 && y == 12 + 21) || (x == 29 && y == 12 + 21);
       endcase
     case(mainSECONDlaponethsec)
          4'd0: lapTWOC = ((x == 31 && y == 12 + 17) || (x == 32 && y == 12 + 17) || (x == 33 && y == 12 + 17) || (x == 31 && y == 12 + 18) || (x == 33 && y == 12 + 18) || (x == 31 && y == 12 + 19) || (x == 33 && y == 12 + 19) || (x == 31 && y == 12 + 20) || (x == 33 && y == 12 + 20) || (x == 31 && y == 12 + 21) || (x == 32 && y == 12 + 21) || (x == 33 && y == 12 + 21));
          4'd1: lapTWOC = ((x == 32 && y == 12 + 17) || (x == 31 && y == 12 + 18) || (x == 32 && y == 12 + 18) || (x == 32 && y == 12 + 19) || (x == 32 && y == 12 + 20) || (x == 31 && y == 12 + 21) || (x == 32 && y == 12 + 21) || (x == 33 && y == 12 + 21));
          4'd2: lapTWOC = ((x == 31 && y == 12 + 17) || (x == 32 && y == 12 + 17) || (x == 33 && y == 12 + 17) || (x == 33 && y == 12 + 18) || (x == 31 && y == 12 + 19) || (x == 32 && y == 12 + 19) || (x == 33 && y == 12 + 19) || (x == 31 && y == 12 + 20) || (x == 31 && y == 12 + 21) || (x == 32 && y == 12 + 21) || (x == 33 && y == 12 + 21));
          4'd3: lapTWOC = ((x == 31 && y == 12 + 17) || (x == 32 && y == 12 + 17) || (x == 33 && y == 12 + 17) || (x == 33 && y == 12 + 18) || (x == 31 && y == 12 + 19) || (x == 32 && y == 12 + 19) || (x == 33 && y == 12 + 19) || (x == 33 && y == 12 + 20) || (x == 31 && y == 12 + 21) || (x == 32 && y == 12 + 21) || (x == 33 && y == 12 + 21));
          4'd4: lapTWOC = ((x == 31 && y == 12 + 17) || (x == 33 && y == 12 + 17) || (x == 31 && y == 12 + 18) || (x == 33 && y == 12 + 18) || (x == 31 && y == 12 + 19) || (x == 32 && y == 12 + 19) || (x == 33 && y == 12 + 19) || (x == 33 && y == 12 + 20) || (x == 33 && y == 12 + 21));
          4'd5: lapTWOC = ((x == 31 && y == 12 + 17) || (x == 32 && y == 12 + 17) || (x == 33 && y == 12 + 17) || (x == 31 && y == 12 + 18) || (x == 31 && y == 12 + 19) || (x == 32 && y == 12 + 19) || (x == 33 && y == 12 + 19) || (x == 33 && y == 12 + 20) || (x == 31 && y == 12 + 21) || (x == 32 && y == 12 + 21) || (x == 33 && y == 12 + 21));
          4'd6: lapTWOC = ((x == 31 && y == 12 + 17) || (x == 32 && y == 12 + 17) || (x == 33 && y == 12 + 17) || (x == 31 && y == 12 + 18) || (x == 31 && y == 12 + 19) || (x == 32 && y == 12 + 19) || (x == 33 && y == 12 + 19) || (x == 31 && y == 12 + 20) || (x == 33 && y == 12 + 20) || (x == 31 && y == 12 + 21) || (x == 32 && y == 12 + 21) || (x == 33 && y == 12 + 21));
          4'd7: lapTWOC = ((x == 31 && y == 12 + 17) || (x == 32 && y == 12 + 17) || (x == 33 && y == 12 + 17) || (x == 33 && y == 12 + 18) || (x == 33 && y == 12 + 19) || (x == 33 && y == 12 + 20) || (x == 33 && y == 12 + 21));
          4'd8: lapTWOC = ((x == 31 && y == 12 + 17) || (x == 32 && y == 12 + 17) || (x == 33 && y == 12 + 17) || (x == 31 && y == 12 + 18) || (x == 33 && y == 12 + 18) || (x == 31 && y == 12 + 19) || (x == 32 && y == 12 + 19) || (x == 33 && y == 12 + 19) || (x == 31 && y == 12 + 20) || (x == 33 && y == 12 + 20) || (x == 31 && y == 12 + 21) || (x == 32 && y == 12 + 21) || (x == 33 && y == 12 + 21));
          4'd9: lapTWOC = ((x == 31 && y == 12 + 17) || (x == 32 && y == 12 + 17) || (x == 33 && y == 12 + 17) || (x == 31 && y == 12 + 18) || (x == 33 && y == 12 + 18) || (x == 31 && y == 12 + 19) || (x == 32 && y == 12 + 19) || (x == 33 && y == 12 + 19) || (x == 33 && y == 12 + 20) || (x == 31 && y == 12 + 21) || (x == 32 && y == 12 + 21) || (x == 33 && y == 12 + 21));
       endcase
     case(mainSECONDlapms) //Start at 40
          4'd0: lapTWOD = ((x == 40 && y == 12 + 17) || (x == 41 && y == 12 + 17) || (x == 42 && y == 12 + 17) || (x == 40 && y == 12 + 18) || (x == 42 && y == 12 + 18) || (x == 40 && y == 12 + 19) || (x == 42 && y == 12 + 19) || (x == 40 && y == 12 + 20) || (x == 42 && y == 12 + 20) || (x == 40 && y == 12 + 21) || (x == 41 && y == 12 + 21) || (x == 42 && y == 12 + 21));
          4'd1: lapTWOD = ((x == 41 && y == 12 + 17) || (x == 40 && y == 12 + 18) || (x == 41 && y == 12 + 18) || (x == 41 && y == 12 + 19) || (x == 41 && y == 12 + 20) || (x == 40 && y == 12 + 21) || (x == 41 && y == 12 + 21) || (x == 42 && y == 12 + 21));
          4'd2: lapTWOD = ((x == 40 && y == 12 + 17) || (x == 41 && y == 12 + 17) || (x == 42 && y == 12 + 17) || (x == 42 && y == 12 + 18) || (x == 40 && y == 12 + 19) || (x == 41 && y == 12 + 19) || (x == 42 && y == 12 + 19) || (x == 40 && y == 12 + 20) || (x == 40 && y == 12 + 21) || (x == 41 && y == 12 + 21) || (x == 42 && y == 12 + 21));
          4'd3: lapTWOD = ((x == 40 && y == 12 + 17) || (x == 41 && y == 12 + 17) || (x == 42 && y == 12 + 17) || (x == 42 && y == 12 + 18) || (x == 40 && y == 12 + 19) || (x == 41 && y == 12 + 19) || (x == 42 && y == 12 + 19) || (x == 42 && y == 12 + 20) || (x == 40 && y == 12 + 21) || (x == 41 && y == 12 + 21) || (x == 42 && y == 12 + 21));
          4'd4: lapTWOD = ((x == 40 && y == 12 + 17) || (x == 42 && y == 12 + 17) || (x == 40 && y == 12 + 18) || (x == 42 && y == 12 + 18) || (x == 40 && y == 12 + 19) || (x == 41 && y == 12 + 19) || (x == 42 && y == 12 + 19) || (x == 42 && y == 12 + 20) || (x == 42 && y == 12 + 21));
          4'd5: lapTWOD = ((x == 40 && y == 12 + 17) || (x == 41 && y == 12 + 17) || (x == 42 && y == 12 + 17) || (x == 40 && y == 12 + 18) || (x == 40 && y == 12 + 19) || (x == 41 && y == 12 + 19) || (x == 42 && y == 12 + 19) || (x == 42 && y == 12 + 20) || (x == 40 && y == 12 + 21) || (x == 41 && y == 12 + 21) || (x == 42 && y == 12 + 21));
          4'd6: lapTWOD = ((x == 40 && y == 12 + 17) || (x == 41 && y == 12 + 17) || (x == 42 && y == 12 + 17) || (x == 40 && y == 12 + 18) || (x == 40 && y == 12 + 19) || (x == 41 && y == 12 + 19) || (x == 42 && y == 12 + 19) || (x == 40 && y == 12 + 20) || (x == 42 && y == 12 + 20) || (x == 40 && y == 12 + 21) || (x == 41 && y == 12 + 21) || (x == 42 && y == 12 + 21));
          4'd7: lapTWOD = ((x == 40 && y == 12 + 17) || (x == 41 && y == 12 + 17) || (x == 42 && y == 12 + 17) || (x == 42 && y == 12 + 18) || (x == 42 && y == 12 + 19) || (x == 42 && y == 12 + 20) || (x == 42 && y == 12 + 21));
          4'd8: lapTWOD = ((x == 40 && y == 12 + 17) || (x == 41 && y == 12 + 17) || (x == 42 && y == 12 + 17) || (x == 40 && y == 12 + 18) || (x == 42 && y == 12 + 18) || (x == 40 && y == 12 + 19) || (x == 41 && y == 12 + 19) || (x == 42 && y == 12 + 19) || (x == 40 && y == 12 + 20) || (x == 42 && y == 12 + 20) || (x == 40 && y == 12 + 21) || (x == 41 && y == 12 + 21) || (x == 42 && y == 12 + 21));
          4'd9: lapTWOD = ((x == 40 && y == 12 + 17) || (x == 41 && y == 12 + 17) || (x == 42 && y == 12 + 17) || (x == 40 && y == 12 + 18) || (x == 42 && y == 12 + 18) || (x == 40 && y == 12 + 19) || (x == 41 && y == 12 + 19) || (x == 42 && y == 12 + 19) || (x == 42 && y == 12 + 20) || (x == 40 && y == 12 + 21) || (x == 41 && y == 12 + 21) || (x == 42 && y == 12 + 21));
       endcase              
     case(mainTHIRDlapmin)
          4'd0: lapTHREEA = ((x == 20 && y == 24 + 17) || (x == 21 && y == 24 + 17) || (x == 22 && y == 24 + 17) || (x == 20 && y == 24 + 18) || (x == 22 && y == 24 + 18) || (x == 20 && y == 24 + 19) || (x == 22 && y == 24 + 19) || (x == 20 && y == 24 + 20) || (x == 22 && y == 24 + 20) || (x == 20 && y == 24 + 21) || (x == 21 && y == 24 + 21) || (x == 22 && y == 24 + 21));
          4'd1: lapTHREEA = ((x == 21 && y == 24 + 17) || (x == 20 && y == 24 + 18) || (x == 21 && y == 24 + 18) || (x == 21 && y == 24 + 19) || (x == 21 && y == 24 + 20) || (x == 20 && y == 24 + 21) || (x == 21 && y == 24 + 21) || (x == 22 && y == 24 + 21));
          4'd2: lapTHREEA = ((x == 20 && y == 24 + 17) || (x == 21 && y == 24 + 17) || (x == 22 && y == 24 + 17) || (x == 22 && y == 24 + 18) || (x == 20 && y == 24 + 19) || (x == 21 && y == 24 + 19) || (x == 22 && y == 24 + 19) || (x == 20 && y == 24 + 20) || (x == 20 && y == 24 + 21) || (x == 21 && y == 24 + 21) || (x == 22 && y == 24 + 21));
          4'd3: lapTHREEA = ((x == 20 && y == 24 + 17) || (x == 21 && y == 24 + 17) || (x == 22 && y == 24 + 17) || (x == 22 && y == 24 + 18) || (x == 20 && y == 24 + 19) || (x == 21 && y == 24 + 19) || (x == 22 && y == 24 + 19) || (x == 22 && y == 24 + 20) || (x == 20 && y == 24 + 21) || (x == 21 && y == 24 + 21) || (x == 22 && y == 24 + 21));
          4'd4: lapTHREEA = ((x == 20 && y == 24 + 17) || (x == 22 && y == 24 + 17) || (x == 20 && y == 24 + 18) || (x == 22 && y == 24 + 18) || (x == 20 && y == 24 + 19) || (x == 21 && y == 24 + 19) || (x == 22 && y == 24 + 19) || (x == 22 && y == 24 + 20) || (x == 22 && y == 24 + 21));
          4'd5: lapTHREEA = ((x == 20 && y == 24 + 17) || (x == 21 && y == 24 + 17) || (x == 22 && y == 24 + 17) || (x == 20 && y == 24 + 18) || (x == 20 && y == 24 + 19) || (x == 21 && y == 24 + 19) || (x == 22 && y == 24 + 19) || (x == 22 && y == 24 + 20) || (x == 20 && y == 24 + 21) || (x == 21 && y == 24 + 21) || (x == 22 && y == 24 + 21));
          4'd6: lapTHREEA = ((x == 20 && y == 24 + 17) || (x == 21 && y == 24 + 17) || (x == 22 && y == 24 + 17) || (x == 20 && y == 24 + 18) || (x == 20 && y == 24 + 19) || (x == 21 && y == 24 + 19) || (x == 22 && y == 24 + 19) || (x == 20 && y == 24 + 20) || (x == 22 && y == 24 + 20) || (x == 20 && y == 24 + 21) || (x == 21 && y == 24 + 21) || (x == 22 && y == 24 + 21));
          4'd7: lapTHREEA = ((x == 20 && y == 24 + 17) || (x == 21 && y == 24 + 17) || (x == 22 && y == 24 + 17) || (x == 22 && y == 24 + 18) || (x == 22 && y == 24 + 19) || (x == 22 && y == 24 + 20) || (x == 22 && y == 24 + 21));
          4'd8: lapTHREEA = ((x == 20 && y == 24 + 17) || (x == 21 && y == 24 + 17) || (x == 22 && y == 24 + 17) || (x == 20 && y == 24 + 18) || (x == 22 && y == 24 + 18) || (x == 20 && y == 24 + 19) || (x == 21 && y == 24 + 19) || (x == 22 && y == 24 + 19) || (x == 20 && y == 24 + 20) || (x == 22 && y == 24 + 20) || (x == 20 && y == 24 + 21) || (x == 21 && y == 24 + 21) || (x == 22 && y == 24 + 21));
          4'd9: lapTHREEA = ((x == 20 && y == 24 + 17) || (x == 21 && y == 24 + 17) || (x == 22 && y == 24 + 17) || (x == 20 && y == 24 + 18) || (x == 22 && y == 24 + 18) || (x == 20 && y == 24 + 19) || (x == 21 && y == 24 + 19) || (x == 22 && y == 24 + 19) || (x == 22 && y == 24 + 20) || (x == 20 && y == 24 + 21) || (x == 21 && y == 24 + 21) || (x == 22 && y == 24 + 21));
       endcase
     case(mainTHIRDlaptenthsec)
         4'd0: lapTHREEB = (x == 27 && y == 24 + 17) || (x == 28 && y == 24 + 17) || (x == 29 && y == 24 + 17) || (x == 27 && y == 24 + 18) || (x == 29 && y == 24 + 18) || (x == 27 && y == 24 + 19) || (x == 29 && y == 24 + 19) || (x == 27 && y == 24 + 20) || (x == 29 && y == 24 + 20) || (x == 27 && y == 24 + 21) || (x == 28 && y == 24 + 21) || (x == 29 && y == 24 + 21);
         4'd1: lapTHREEB = ((x == 28 && y == 24 + 17) || (x == 27 && y == 24 + 18) || (x == 28 && y == 24 + 18) || (x == 28 && y == 24 + 19) || (x == 28 && y == 24 + 20) || (x == 27 && y == 24 + 21) || (x == 28 && y == 24 + 21) || (x == 29 && y == 24 + 21));
         4'd2: lapTHREEB = (x == 27 && y == 24 + 17) || (x == 28 && y == 24 + 17) || (x == 29 && y == 24 + 17) || (x == 29 && y == 24 + 18) || (x == 27 && y == 24 + 19) || (x == 28 && y == 24 + 19) || (x == 29 && y == 24 + 19) || (x == 27 && y == 24 + 20) || (x == 27 && y == 24 + 21) || (x == 28 && y == 24 + 21) || (x == 29 && y == 24 + 21);
         4'd3: lapTHREEB = (x == 27 && y == 24 + 17) || (x == 28 && y == 24 + 17) || (x == 29 && y == 24 + 17) || (x == 29 && y == 24 + 18) || (x == 27 && y == 24 + 19) || (x == 28 && y == 24 + 19) || (x == 29 && y == 24 + 19) || (x == 29 && y == 24 + 20) || (x == 27 && y == 24 + 21) || (x == 28 && y == 24 + 21) || (x == 29 && y == 24 + 21);
         4'd4: lapTHREEB = (x == 27 && y == 24 + 17) || (x == 29 && y == 24 + 17) || (x == 27 && y == 24 + 18) || (x == 29 && y == 24 + 18) || (x == 27 && y == 24 + 19) || (x == 28 && y == 24 + 19) || (x == 29 && y == 24 + 19) || (x == 29 && y == 24 + 20) || (x == 29 && y == 24 + 21);
         4'd5: lapTHREEB = (x == 27 && y == 24 + 17) || (x == 28 && y == 24 + 17) || (x == 29 && y == 24 + 17) || (x == 27 && y == 24 + 18) || (x == 27 && y == 24 + 19) || (x == 28 && y == 24 + 19) || (x == 29 && y == 24 + 19) || (x == 29 && y == 24 + 20) || (x == 27 && y == 24 + 21) || (x == 28 && y == 24 + 21) || (x == 29 && y == 24 + 21);
      endcase
     case(mainTHIRDlaponethsec)
         4'd0: lapTHREEC = ((x == 31 && y == 24 + 17) || (x == 32 && y == 24 + 17) || (x == 33 && y == 24 + 17) || (x == 31 && y == 24 + 18) || (x == 33 && y == 24 + 18) || (x == 31 && y == 24 + 19) || (x == 33 && y == 24 + 19) || (x == 31 && y == 24 + 20) || (x == 33 && y == 24 + 20) || (x == 31 && y == 24 + 21) || (x == 32 && y == 24 + 21) || (x == 33 && y == 24 + 21));
         4'd1: lapTHREEC = ((x == 32 && y == 24 + 17) || (x == 31 && y == 24 + 18) || (x == 32 && y == 24 + 18) || (x == 32 && y == 24 + 19) || (x == 32 && y == 24 + 20) || (x == 31 && y == 24 + 21) || (x == 32 && y == 24 + 21) || (x == 33 && y == 24 + 21));
         4'd2: lapTHREEC = ((x == 31 && y == 24 + 17) || (x == 32 && y == 24 + 17) || (x == 33 && y == 24 + 17) || (x == 33 && y == 24 + 18) || (x == 31 && y == 24 + 19) || (x == 32 && y == 24 + 19) || (x == 33 && y == 24 + 19) || (x == 31 && y == 24 + 20) || (x == 31 && y == 24 + 21) || (x == 32 && y == 24 + 21) || (x == 33 && y == 24 + 21));
         4'd3: lapTHREEC = ((x == 31 && y == 24 + 17) || (x == 32 && y == 24 + 17) || (x == 33 && y == 24 + 17) || (x == 33 && y == 24 + 18) || (x == 31 && y == 24 + 19) || (x == 32 && y == 24 + 19) || (x == 33 && y == 24 + 19) || (x == 33 && y == 24 + 20) || (x == 31 && y == 24 + 21) || (x == 32 && y == 24 + 21) || (x == 33 && y == 24 + 21));
         4'd4: lapTHREEC = ((x == 31 && y == 24 + 17) || (x == 33 && y == 24 + 17) || (x == 31 && y == 24 + 18) || (x == 33 && y == 24 + 18) || (x == 31 && y == 24 + 19) || (x == 32 && y == 24 + 19) || (x == 33 && y == 24 + 19) || (x == 33 && y == 24 + 20) || (x == 33 && y == 24 + 21));
         4'd5: lapTHREEC = ((x == 31 && y == 24 + 17) || (x == 32 && y == 24 + 17) || (x == 33 && y == 24 + 17) || (x == 31 && y == 24 + 18) || (x == 31 && y == 24 + 19) || (x == 32 && y == 24 + 19) || (x == 33 && y == 24 + 19) || (x == 33 && y == 24 + 20) || (x == 31 && y == 24 + 21) || (x == 32 && y == 24 + 21) || (x == 33 && y == 24 + 21));
         4'd6: lapTHREEC = ((x == 31 && y == 24 + 17) || (x == 32 && y == 24 + 17) || (x == 33 && y == 24 + 17) || (x == 31 && y == 24 + 18) || (x == 31 && y == 24 + 19) || (x == 32 && y == 24 + 19) || (x == 33 && y == 24 + 19) || (x == 31 && y == 24 + 20) || (x == 33 && y == 24 + 20) || (x == 31 && y == 24 + 21) || (x == 32 && y == 24 + 21) || (x == 33 && y == 24 + 21));
         4'd7: lapTHREEC = ((x == 31 && y == 24 + 17) || (x == 32 && y == 24 + 17) || (x == 33 && y == 24 + 17) || (x == 33 && y == 24 + 18) || (x == 33 && y == 24 + 19) || (x == 33 && y == 24 + 20) || (x == 33 && y == 24 + 21));
         4'd8: lapTHREEC = ((x == 31 && y == 24 + 17) || (x == 32 && y == 24 + 17) || (x == 33 && y == 24 + 17) || (x == 31 && y == 24 + 18) || (x == 33 && y == 24 + 18) || (x == 31 && y == 24 + 19) || (x == 32 && y == 24 + 19) || (x == 33 && y == 24 + 19) || (x == 31 && y == 24 + 20) || (x == 33 && y == 24 + 20) || (x == 31 && y == 24 + 21) || (x == 32 && y == 24 + 21) || (x == 33 && y == 24 + 21));
         4'd9: lapTHREEC = ((x == 31 && y == 24 + 17) || (x == 32 && y == 24 + 17) || (x == 33 && y == 24 + 17) || (x == 31 && y == 24 + 18) || (x == 33 && y == 24 + 18) || (x == 31 && y == 24 + 19) || (x == 32 && y == 24 + 19) || (x == 33 && y == 24 + 19) || (x == 33 && y == 24 + 20) || (x == 31 && y == 24 + 21) || (x == 32 && y == 24 + 21) || (x == 33 && y == 24 + 21));
      endcase
     case(mainTHIRDlapms) //Start at 40
         4'd0: lapTHREED = ((x == 40 && y == 24 + 17) || (x == 41 && y == 24 + 17) || (x == 42 && y == 24 + 17) || (x == 40 && y == 24 + 18) || (x == 42 && y == 24 + 18) || (x == 40 && y == 24 + 19) || (x == 42 && y == 24 + 19) || (x == 40 && y == 24 + 20) || (x == 42 && y == 24 + 20) || (x == 40 && y == 24 + 21) || (x == 41 && y == 24 + 21) || (x == 42 && y == 24 + 21));
         4'd1: lapTHREED = ((x == 41 && y == 24 + 17) || (x == 40 && y == 24 + 18) || (x == 41 && y == 24 + 18) || (x == 41 && y == 24 + 19) || (x == 41 && y == 24 + 20) || (x == 40 && y == 24 + 21) || (x == 41 && y == 24 + 21) || (x == 42 && y == 24 + 21));
         4'd2: lapTHREED = ((x == 40 && y == 24 + 17) || (x == 41 && y == 24 + 17) || (x == 42 && y == 24 + 17) || (x == 42 && y == 24 + 18) || (x == 40 && y == 24 + 19) || (x == 41 && y == 24 + 19) || (x == 42 && y == 24 + 19) || (x == 40 && y == 24 + 20) || (x == 40 && y == 24 + 21) || (x == 41 && y == 24 + 21) || (x == 42 && y == 24 + 21));
         4'd3: lapTHREED = ((x == 40 && y == 24 + 17) || (x == 41 && y == 24 + 17) || (x == 42 && y == 24 + 17) || (x == 42 && y == 24 + 18) || (x == 40 && y == 24 + 19) || (x == 41 && y == 24 + 19) || (x == 42 && y == 24 + 19) || (x == 42 && y == 24 + 20) || (x == 40 && y == 24 + 21) || (x == 41 && y == 24 + 21) || (x == 42 && y == 24 + 21));
         4'd4: lapTHREED = ((x == 40 && y == 24 + 17) || (x == 42 && y == 24 + 17) || (x == 40 && y == 24 + 18) || (x == 42 && y == 24 + 18) || (x == 40 && y == 24 + 19) || (x == 41 && y == 24 + 19) || (x == 42 && y == 24 + 19) || (x == 42 && y == 24 + 20) || (x == 42 && y == 24 + 21));
         4'd5: lapTHREED = ((x == 40 && y == 24 + 17) || (x == 41 && y == 24 + 17) || (x == 42 && y == 24 + 17) || (x == 40 && y == 24 + 18) || (x == 40 && y == 24 + 19) || (x == 41 && y == 24 + 19) || (x == 42 && y == 24 + 19) || (x == 42 && y == 24 + 20) || (x == 40 && y == 24 + 21) || (x == 41 && y == 24 + 21) || (x == 42 && y == 24 + 21));
         4'd6: lapTHREED = ((x == 40 && y == 24 + 17) || (x == 41 && y == 24 + 17) || (x == 42 && y == 24 + 17) || (x == 40 && y == 24 + 18) || (x == 40 && y == 24 + 19) || (x == 41 && y == 24 + 19) || (x == 42 && y == 24 + 19) || (x == 40 && y == 24 + 20) || (x == 42 && y == 24 + 20) || (x == 40 && y == 24 + 21) || (x == 41 && y == 24 + 21) || (x == 42 && y == 24 + 21));
         4'd7: lapTHREED = ((x == 40 && y == 24 + 17) || (x == 41 && y == 24 + 17) || (x == 42 && y == 24 + 17) || (x == 42 && y == 24 + 18) || (x == 42 && y == 24 + 19) || (x == 42 && y == 24 + 20) || (x == 42 && y == 24 + 21));
         4'd8: lapTHREED = ((x == 40 && y == 24 + 17) || (x == 41 && y == 24 + 17) || (x == 42 && y == 24 + 17) || (x == 40 && y == 24 + 18) || (x == 42 && y == 24 + 18) || (x == 40 && y == 24 + 19) || (x == 41 && y == 24 + 19) || (x == 42 && y == 24 + 19) || (x == 40 && y == 24 + 20) || (x == 42 && y == 24 + 20) || (x == 40 && y == 24 + 21) || (x == 41 && y == 24 + 21) || (x == 42 && y == 24 + 21));
         4'd9: lapTHREED = ((x == 40 && y == 24 + 17) || (x == 41 && y == 24 + 17) || (x == 42 && y == 24 + 17) || (x == 40 && y == 24 + 18) || (x == 42 && y == 24 + 18) || (x == 40 && y == 24 + 19) || (x == 41 && y == 24 + 19) || (x == 42 && y == 24 + 19) || (x == 42 && y == 24 + 20) || (x == 40 && y == 24 + 21) || (x == 41 && y == 24 + 21) || (x == 42 && y == 24 + 21));
      endcase
     
     
     // Oled Display Renderings
     if (mainlapcount >= 1 && (lapONEA || firstcolonONE || secondcolonONE || lapONEB || lapONEC || lapONED)) begin
         oled_data <= white; 
     // Lap Time Display #2
      end else
      if (mainlapcount >= 2 && (lapTWOA || firstcolonTWO || secondcolonTWO || lapTWOB || lapTWOC || lapTWOD )) begin
         oled_data <= white;
      // Lap Time Display #3
      end else
      if (mainlapcount == 3 && (lapTHREEA ||firstcolonTHREE || secondcolonTHREE || lapTHREEB || lapTHREEC || lapTHREED)) begin
         oled_data <= white;
      end else
     // Cursor Display
     if (x >= cursor_x && x < cursor_x + 3 && y >= cursor_y && y < cursor_y + 3) begin
        oled_data <= green;
      // Display "Current Laps"
     end else if ((x == 22 && y == 5) || (x == 23 && y == 5) || (x == 21 && y == 6) || (x == 24 && y == 6) || (x == 21 && y == 7) || (x == 21 && y == 8) || (x == 24 && y == 8) || (x == 22 && y == 9) || (x == 23 && y == 9) || (x == 26 && y == 5) || (x == 29 && y == 5) || (x == 26 && y == 6) || (x == 29 && y == 6) || (x == 26 && y == 7) || (x == 29 && y == 7) || (x == 26 && y == 8) || (x == 29 && y == 8) || (x == 27 && y == 9) || (x == 28 && y == 9) || (x == 31 && y == 5) || (x == 32 && y == 5) || (x == 33 && y == 5) || (x == 31 && y == 6) || (x == 34 && y == 6) || (x == 31 && y == 7) || (x == 32 && y == 7) || (x == 33 && y == 7) || (x == 31 && y == 8) || (x == 33 && y == 8) || (x == 31 && y == 9) || (x == 34 && y == 9) || (x == 36 && y == 5) || (x == 37 && y == 5) || (x == 38 && y == 5) || (x == 36 && y == 6) || (x == 39 && y == 6) || (x == 36 && y == 7) || (x == 37 && y == 7) || (x == 38 && y == 7) || (x == 36 && y == 8) || (x == 38 && y == 8) || (x == 36 && y == 9) || (x == 39 && y == 9) || (x == 41 && y == 5) || (x == 42 && y == 5) || (x == 43 && y == 5) || (x == 44 && y == 5) || (x == 41 && y == 6) || (x == 41 && y == 7) || (x == 42 && y == 7) || (x == 43 && y == 7) || (x == 44 && y == 7) || (x == 41 && y == 8) || (x == 41 && y == 9) || (x == 42 && y == 9) || (x == 43 && y == 9) || (x == 44 && y == 9) || (x == 46 && y == 5) || (x == 49 && y == 5) || (x == 46 && y == 6) || (x == 47 && y == 6) || (x == 49 && y == 6) || (x == 46 && y == 7) || (x == 48 && y == 7) || (x == 49 && y == 7) || (x == 46 && y == 8) || (x == 49 && y == 8) || (x == 46 && y == 9) || (x == 49 && y == 9) || (x == 51 && y == 5) || (x == 52 && y == 5) || (x == 53 && y == 5) || (x == 52 && y == 6) || (x == 52 && y == 7) || (x == 52 && y == 8) || (x == 52 && y == 9) || (x == 56 && y == 5) || (x == 56 && y == 6) || (x == 56 && y == 7) || (x == 56 && y == 8) || (x == 56 && y == 9) || (x == 57 && y == 9) || (x == 58 && y == 9) || (x == 59 && y == 9) || (x == 62 && y == 5) || (x == 63 && y == 5) || (x == 61 && y == 6) || (x == 64 && y == 6) || (x == 61 && y == 7) || (x == 62 && y == 7) || (x == 63 && y == 7) || (x == 64 && y == 7) || (x == 61 && y == 8) || (x == 64 && y == 8) || (x == 61 && y == 9) || (x == 64 && y == 9) || (x == 66 && y == 5) || (x == 67 && y == 5) || (x == 68 && y == 5) || (x == 66 && y == 6) || (x == 69 && y == 6) || (x == 66 && y == 7) || (x == 67 && y == 7) || (x == 68 && y == 7) || (x == 66 && y == 8) || (x == 66 && y == 9) || (x == 71 && y == 5) || (x == 72 && y == 5) || (x == 73 && y == 5) || (x == 74 && y == 5) || (x == 71 && y == 6) || (x == 71 && y == 7) || (x == 72 && y == 7) || (x == 73 && y == 7) || (x == 74 && y == 7) || (x == 74 && y == 8) || (x == 71 && y == 9) || (x == 72 && y == 9) || (x == 73 && y == 9) || (x == 74 && y == 9)) begin
        oled_data <= black;
     end else if (mainlapcount == 1 && lap1arrow) begin
        oled_data <= green;
     end else if (mainlapcount == 2 && lap2arrow) begin
        oled_data <= green; 
     end else if (mainlapcount == 3 && lap3arrow) begin
        oled_data <= green;
     // Display Mic Mode
     end else if (micicon) begin
        oled_data <= miccolor;
     //Display Box
     end else if (x >= 15 && x < 81 && y >= 15 && y < 25) begin
        oled_data <= black;
     end else if (x >= 15 && x < 81 && y >= 27 && y < 37) begin
           oled_data <= black;
     end else if (x >= 15 && x < 81 && y >= 39 && y < 49) begin
           oled_data <= black;
     // Whistle Mode Dipslay - Lapselect is current whistle mode status 0 is start/pause & 1 is lap
     // Display Whistle Start Mode
     end else if (micmode && !lapselect && ((x == 9 && y == 55) || (x == 13 && y == 55) || (x == 9 && y == 56) || (x == 13 && y == 56) || (x == 9 && y == 57) || (x == 13 && y == 57) || (x == 9 && y == 58) || (x == 11 && y == 58) || (x == 13 && y == 58) || (x == 10 && y == 59) || (x == 12 && y == 59) || (x == 15 && y == 55) || (x == 18 && y == 55) || (x == 15 && y == 56) || (x == 18 && y == 56) || (x == 15 && y == 57) || (x == 16 && y == 57) || (x == 17 && y == 57) || (x == 18 && y == 57) || (x == 15 && y == 58) || (x == 18 && y == 58) || (x == 15 && y == 59) || (x == 18 && y == 59) || (x == 20 && y == 55) || (x == 20 && y == 56) || (x == 20 && y == 57) || (x == 20 && y == 58) || (x == 20 && y == 59) || (x == 22 && y == 55) || (x == 23 && y == 55) || (x == 24 && y == 55) || (x == 25 && y == 55) || (x == 22 && y == 56) || (x == 22 && y == 57) || (x == 23 && y == 57) || (x == 24 && y == 57) || (x == 25 && y == 57) || (x == 25 && y == 58) || (x == 22 && y == 59) || (x == 23 && y == 59) || (x == 24 && y == 59) || (x == 25 && y == 59) || (x == 27 && y == 55) || (x == 28 && y == 55) || (x == 29 && y == 55) || (x == 28 && y == 56) || (x == 28 && y == 57) || (x == 28 && y == 58) || (x == 28 && y == 59) || (x == 31 && y == 55) || (x == 31 && y == 56) || (x == 31 && y == 57) || (x == 31 && y == 58) || (x == 31 && y == 59) || (x == 32 && y == 59) || (x == 33 && y == 59) || (x == 34 && y == 59) || (x == 36 && y == 55) || (x == 37 && y == 55) || (x == 38 && y == 55) || (x == 39 && y == 55) || (x == 36 && y == 56) || (x == 36 && y == 57) || (x == 37 && y == 57) || (x == 38 && y == 57) || (x == 39 && y == 57) || (x == 36 && y == 58) || (x == 36 && y == 59) || (x == 37 && y == 59) || (x == 38 && y == 59) || (x == 39 && y == 59) || (x == 42 && y == 55) || (x == 43 && y == 55) || (x == 44 && y == 55) || (x == 45 && y == 55) || (x == 42 && y == 56) || (x == 42 && y == 57) || (x == 43 && y == 57) || (x == 44 && y == 57) || (x == 45 && y == 57) || (x == 45 && y == 58) || (x == 42 && y == 59) || (x == 43 && y == 59) || (x == 44 && y == 59) || (x == 45 && y == 59) || (x == 47 && y == 55) || (x == 48 && y == 55) || (x == 49 && y == 55) || (x == 48 && y == 56) || (x == 48 && y == 57) || (x == 48 && y == 58) || (x == 48 && y == 59) || (x == 52 && y == 55) || (x == 53 && y == 55) || (x == 51 && y == 56) || (x == 54 && y == 56) || (x == 51 && y == 57) || (x == 52 && y == 57) || (x == 53 && y == 57) || (x == 54 && y == 57) || (x == 51 && y == 58) || (x == 54 && y == 58) || (x == 51 && y == 59) || (x == 54 && y == 59) || (x == 56 && y == 55) || (x == 57 && y == 55) || (x == 58 && y == 55) || (x == 56 && y == 56) || (x == 59 && y == 56) || (x == 56 && y == 57) || (x == 57 && y == 57) || (x == 58 && y == 57) || (x == 56 && y == 58) || (x == 58 && y == 58) || (x == 56 && y == 59) || (x == 59 && y == 59) || (x == 61 && y == 55) || (x == 62 && y == 55) || (x == 63 && y == 55) || (x == 62 && y == 56) || (x == 62 && y == 57) || (x == 62 && y == 58) || (x == 62 && y == 59) || (x == 66 && y == 55) || (x == 70 && y == 55) || (x == 66 && y == 56) || (x == 67 && y == 56) || (x == 69 && y == 56) || (x == 70 && y == 56) || (x == 66 && y == 57) || (x == 68 && y == 57) || (x == 70 && y == 57) || (x == 66 && y == 58) || (x == 70 && y == 58) || (x == 66 && y == 59) || (x == 70 && y == 59) || (x == 73 && y == 55) || (x == 74 && y == 55) || (x == 72 && y == 56) || (x == 75 && y == 56) || (x == 72 && y == 57) || (x == 75 && y == 57) || (x == 72 && y == 58) || (x == 75 && y == 58) || (x == 73 && y == 59) || (x == 74 && y == 59) || (x == 77 && y == 55) || (x == 78 && y == 55) || (x == 79 && y == 55) || (x == 77 && y == 56) || (x == 80 && y == 56) || (x == 77 && y == 57) || (x == 80 && y == 57) || (x == 77 && y == 58) || (x == 80 && y == 58) || (x == 77 && y == 59) || (x == 78 && y == 59) || (x == 79 && y == 59) || (x == 82 && y == 55) || (x == 83 && y == 55) || (x == 84 && y == 55) || (x == 85 && y == 55) || (x == 82 && y == 56) || (x == 82 && y == 57) || (x == 83 && y == 57) || (x == 84 && y == 57) || (x == 85 && y == 57) || (x == 82 && y == 58) || (x == 82 && y == 59) || (x == 83 && y == 59) || (x == 84 && y == 59) || (x == 85 && y == 59))) begin
           oled_data <= black;
     // Display Whistle Lap Mode
     end else if (micmode && lapselect && ((x == 13 && y == 55) || (x == 17 && y == 55) || (x == 13 && y == 56) || (x == 17 && y == 56) || (x == 13 && y == 57) || (x == 17 && y == 57) || (x == 13 && y == 58) || (x == 15 && y == 58) || (x == 17 && y == 58) || (x == 14 && y == 59) || (x == 16 && y == 59) || (x == 19 && y == 55) || (x == 22 && y == 55) || (x == 19 && y == 56) || (x == 22 && y == 56) || (x == 19 && y == 57) || (x == 20 && y == 57) || (x == 21 && y == 57) || (x == 22 && y == 57) || (x == 19 && y == 58) || (x == 22 && y == 58) || (x == 19 && y == 59) || (x == 22 && y == 59) || (x == 24 && y == 55) || (x == 24 && y == 56) || (x == 24 && y == 57) || (x == 24 && y == 58) || (x == 24 && y == 59) || (x == 26 && y == 55) || (x == 27 && y == 55) || (x == 28 && y == 55) || (x == 29 && y == 55) || (x == 26 && y == 56) || (x == 26 && y == 57) || (x == 27 && y == 57) || (x == 28 && y == 57) || (x == 29 && y == 57) || (x == 29 && y == 58) || (x == 26 && y == 59) || (x == 27 && y == 59) || (x == 28 && y == 59) || (x == 29 && y == 59) || (x == 31 && y == 55) || (x == 32 && y == 55) || (x == 33 && y == 55) || (x == 32 && y == 56) || (x == 32 && y == 57) || (x == 32 && y == 58) || (x == 32 && y == 59) || (x == 35 && y == 55) || (x == 35 && y == 56) || (x == 35 && y == 57) || (x == 35 && y == 58) || (x == 35 && y == 59) || (x == 36 && y == 59) || (x == 37 && y == 59) || (x == 38 && y == 59) || (x == 40 && y == 55) || (x == 41 && y == 55) || (x == 42 && y == 55) || (x == 43 && y == 55) || (x == 40 && y == 56) || (x == 40 && y == 57) || (x == 41 && y == 57) || (x == 42 && y == 57) || (x == 43 && y == 57) || (x == 40 && y == 58) || (x == 40 && y == 59) || (x == 41 && y == 59) || (x == 42 && y == 59) || (x == 43 && y == 59) || (x == 46 && y == 55) || (x == 46 && y == 56) || (x == 46 && y == 57) || (x == 46 && y == 58) || (x == 46 && y == 59) || (x == 47 && y == 59) || (x == 48 && y == 59) || (x == 49 && y == 59) || (x == 52 && y == 55) || (x == 53 && y == 55) || (x == 51 && y == 56) || (x == 54 && y == 56) || (x == 51 && y == 57) || (x == 52 && y == 57) || (x == 53 && y == 57) || (x == 54 && y == 57) || (x == 51 && y == 58) || (x == 54 && y == 58) || (x == 51 && y == 59) || (x == 54 && y == 59) || (x == 56 && y == 55) || (x == 57 && y == 55) || (x == 58 && y == 55) || (x == 56 && y == 56) || (x == 59 && y == 56) || (x == 56 && y == 57) || (x == 57 && y == 57) || (x == 58 && y == 57) || (x == 56 && y == 58) || (x == 56 && y == 59) || (x == 62 && y == 55) || (x == 66 && y == 55) || (x == 62 && y == 56) || (x == 63 && y == 56) || (x == 65 && y == 56) || (x == 66 && y == 56) || (x == 62 && y == 57) || (x == 64 && y == 57) || (x == 66 && y == 57) || (x == 62 && y == 58) || (x == 66 && y == 58) || (x == 62 && y == 59) || (x == 66 && y == 59) || (x == 69 && y == 55) || (x == 70 && y == 55) || (x == 68 && y == 56) || (x == 71 && y == 56) || (x == 68 && y == 57) || (x == 71 && y == 57) || (x == 68 && y == 58) || (x == 71 && y == 58) || (x == 69 && y == 59) || (x == 70 && y == 59) || (x == 73 && y == 55) || (x == 74 && y == 55) || (x == 75 && y == 55) || (x == 73 && y == 56) || (x == 76 && y == 56) || (x == 73 && y == 57) || (x == 76 && y == 57) || (x == 73 && y == 58) || (x == 76 && y == 58) || (x == 73 && y == 59) || (x == 74 && y == 59) || (x == 75 && y == 59) || (x == 78 && y == 55) || (x == 79 && y == 55) || (x == 80 && y == 55) || (x == 81 && y == 55) || (x == 78 && y == 56) || (x == 78 && y == 57) || (x == 79 && y == 57) || (x == 80 && y == 57) || (x == 81 && y == 57) || (x == 78 && y == 58) || (x == 78 && y == 59) || (x == 79 && y == 59) || (x == 80 && y == 59) || (x == 81 && y == 59))) begin
           oled_data <= black;
     // Display Banners
     end else if (micmode && lapselect && (x >= 10 && x < 84 && y >= 52 && y <= 62)) begin
           oled_data <= brown;
     end else if (micmode && !lapselect && ((x >= 6 && x < 88 && y >= 52 && y <= 62))) begin
           oled_data <= blue;
           
     end else if (((x == 7 && y == 5) || (x == 6 && y == 6) || (x == 5 && y == 7) || (x == 6 && y == 8) || (x == 7 && y == 9))) begin
         oled_data <= black;
     
     // Lap text
     end else if (!micmode && ((x == 18 && y == 53) || (x == 18 && y == 54) || (x == 18 && y == 55) || (x == 18 && y == 56) || (x == 18 && y == 57) || (x == 19 && y == 57) || (x == 20 && y == 57) || (x == 21 && y == 57) || (x == 24 && y == 53) || (x == 25 && y == 53) || (x == 23 && y == 54) || (x == 26 && y == 54) || (x == 23 && y == 55) || (x == 24 && y == 55) || (x == 25 && y == 55) || (x == 26 && y == 55) || (x == 23 && y == 56) || (x == 26 && y == 56) || (x == 23 && y == 57) || (x == 26 && y == 57) || (x == 28 && y == 53) || (x == 29 && y == 53) || (x == 30 && y == 53) || (x == 28 && y == 54) || (x == 31 && y == 54) || (x == 28 && y == 55) || (x == 29 && y == 55) || (x == 30 && y == 55) || (x == 28 && y == 56) || (x == 28 && y == 57))) begin
        oled_data <= black;
     // Lap button box
     end else if (!micmode && x >= 15 && x < 35 && y >= 51 && y < 61) begin
        oled_data <= yellow;
     // START TEXT
     end else if (!micmode && !mainstartcontrol && ((x == 53 && y == 53) || (x == 54 && y == 53) || (x == 55 && y == 53) || (x == 56 && y == 53) || (x == 53 && y == 54) || (x == 53 && y == 55) || (x == 54 && y == 55) || (x == 55 && y == 55) || (x == 56 && y == 55) || (x == 56 && y == 56) || (x == 53 && y == 57) || (x == 54 && y == 57) || (x == 55 && y == 57) || (x == 56 && y == 57) || (x == 58 && y == 53) || (x == 59 && y == 53) || (x == 60 && y == 53) || (x == 59 && y == 54) || (x == 59 && y == 55) || (x == 59 && y == 56) || (x == 59 && y == 57) || (x == 63 && y == 53) || (x == 64 && y == 53) || (x == 62 && y == 54) || (x == 65 && y == 54) || (x == 62 && y == 55) || (x == 63 && y == 55) || (x == 64 && y == 55) || (x == 65 && y == 55) || (x == 62 && y == 56) || (x == 65 && y == 56) || (x == 62 && y == 57) || (x == 65 && y == 57) || (x == 67 && y == 53) || (x == 68 && y == 53) || (x == 69 && y == 53) || (x == 67 && y == 54) || (x == 70 && y == 54) || (x == 67 && y == 55) || (x == 68 && y == 55) || (x == 69 && y == 55) || (x == 67 && y == 56) || (x == 69 && y == 56) || (x == 67 && y == 57) || (x == 70 && y == 57) || (x == 72 && y == 53) || (x == 73 && y == 53) || (x == 74 && y == 53) || (x == 73 && y == 54) || (x == 73 && y == 55) || (x == 73 && y == 56) || (x == 73 && y == 57))) begin
            oled_data <= white;
     // PAUSE TEXT
     end else if (!micmode && mainstartcontrol && ((x == 53 && y == 53) || (x == 54 && y == 53) || (x == 55 && y == 53) || (x == 53 && y == 54) || (x == 56 && y == 54) || (x == 53 && y == 55) || (x == 54 && y == 55) || (x == 55 && y == 55) || (x == 53 && y == 56) || (x == 53 && y == 57) || (x == 59 && y == 53) || (x == 60 && y == 53) || (x == 58 && y == 54) || (x == 61 && y == 54) || (x == 58 && y == 55) || (x == 59 && y == 55) || (x == 60 && y == 55) || (x == 61 && y == 55) || (x == 58 && y == 56) || (x == 61 && y == 56) || (x == 58 && y == 57) || (x == 61 && y == 57) || (x == 63 && y == 53) || (x == 66 && y == 53) || (x == 63 && y == 54) || (x == 66 && y == 54) || (x == 63 && y == 55) || (x == 66 && y == 55) || (x == 63 && y == 56) || (x == 66 && y == 56) || (x == 64 && y == 57) || (x == 65 && y == 57) || (x == 68 && y == 53) || (x == 69 && y == 53) || (x == 70 && y == 53) || (x == 71 && y == 53) || (x == 68 && y == 54) || (x == 68 && y == 55) || (x == 69 && y == 55) || (x == 70 && y == 55) || (x == 71 && y == 55) || (x == 71 && y == 56) || (x == 68 && y == 57) || (x == 69 && y == 57) || (x == 70 && y == 57) || (x == 71 && y == 57) || (x == 73 && y == 53) || (x == 74 && y == 53) || (x == 75 && y == 53) || (x == 76 && y == 53) || (x == 73 && y == 54) || (x == 73 && y == 55) || (x == 74 && y == 55) || (x == 75 && y == 55) || (x == 76 && y == 55) || (x == 73 && y == 56) || (x == 73 && y == 57) || (x == 74 && y == 57) || (x == 75 && y == 57) || (x == 76 && y == 57))) begin
            oled_data <= white;
     // Start Button 
     end else if (!micmode && !mainstartcontrol && x >= 50 && x < 81 && y >= 51 && y < 61) begin
        oled_data <= green;
     end else if (!micmode && mainstartcontrol && x >= 50 && x < 81 && y >= 51 && y < 61) begin
        oled_data <= red;
     // Reset Cross
     end else if (!micmode && ((x == 84 && y == 51) || (x == 85 && y == 51) || (x == 91 && y == 51) || (x == 92 && y == 51) || (x == 84 && y == 52) || (x == 85 && y == 52) || (x == 86 && y == 52) || (x == 90 && y == 52) || (x == 91 && y == 52) || (x == 92 && y == 52) || (x == 85 && y == 53) || (x == 86 && y == 53) || (x == 87 && y == 53) || (x == 89 && y == 53) || (x == 90 && y == 53) || (x == 91 && y == 53) || (x == 86 && y == 54) || (x == 87 && y == 54) || (x == 88 && y == 54) || (x == 89 && y == 54) || (x == 90 && y == 54) || (x == 87 && y == 55) || (x == 88 && y == 55) || (x == 89 && y == 55) || (x == 86 && y == 56) || (x == 87 && y == 56) || (x == 88 && y == 56) || (x == 89 && y == 56) || (x == 90 && y == 56) || (x == 85 && y == 57) || (x == 86 && y == 57) || (x == 87 && y == 57) || (x == 89 && y == 57) || (x == 90 && y == 57) || (x == 91 && y == 57) || (x == 84 && y == 58) || (x == 85 && y == 58) || (x == 86 && y == 58) || (x == 90 && y == 58) || (x == 91 && y == 58) || (x == 92 && y == 58) || (x == 84 && y == 59) || (x == 85 && y == 59) || (x == 91 && y == 59) || (x == 92 && y == 59))) begin
        oled_data <= black;
     // Reset Box Button
     end else if (!micmode && ((x == 83 && y == 50) || (x == 84 && y == 50) || (x == 85 && y == 50) || (x == 86 && y == 50) || (x == 87 && y == 50) || (x == 88 && y == 50) || (x == 89 && y == 50) || (x == 90 && y == 50) || (x == 91 && y == 50) || (x == 92 && y == 50) || (x == 93 && y == 50) || (x == 83 && y == 51) || (x == 86 && y == 51) || (x == 87 && y == 51) || (x == 88 && y == 51) || (x == 89 && y == 51) || (x == 90 && y == 51) || (x == 93 && y == 51) || (x == 83 && y == 52) || (x == 87 && y == 52) || (x == 88 && y == 52) || (x == 89 && y == 52) || (x == 93 && y == 52) || (x == 83 && y == 53) || (x == 84 && y == 53) || (x == 88 && y == 53) || (x == 92 && y == 53) || (x == 93 && y == 53) || (x == 83 && y == 54) || (x == 84 && y == 54) || (x == 85 && y == 54) || (x == 91 && y == 54) || (x == 92 && y == 54) || (x == 93 && y == 54) || (x == 83 && y == 55) || (x == 84 && y == 55) || (x == 85 && y == 55) || (x == 86 && y == 55) || (x == 90 && y == 55) || (x == 91 && y == 55) || (x == 92 && y == 55) || (x == 93 && y == 55) || (x == 83 && y == 56) || (x == 84 && y == 56) || (x == 85 && y == 56) || (x == 91 && y == 56) || (x == 92 && y == 56) || (x == 93 && y == 56) || (x == 83 && y == 57) || (x == 84 && y == 57) || (x == 88 && y == 57) || (x == 92 && y == 57) || (x == 93 && y == 57) || (x == 83 && y == 58) || (x == 87 && y == 58) || (x == 88 && y == 58) || (x == 89 && y == 58) || (x == 93 && y == 58) || (x == 83 && y == 59) || (x == 86 && y == 59) || (x == 87 && y == 59) || (x == 88 && y == 59) || (x == 89 && y == 59) || (x == 90 && y == 59) || (x == 93 && y == 59) || (x == 83 && y == 60) || (x == 84 && y == 60) || (x == 85 && y == 60) || (x == 86 && y == 60) || (x == 87 && y == 60) || (x == 88 && y == 60) || (x == 89 && y == 60) || (x == 90 && y == 60) || (x == 91 && y == 60) || (x == 92 && y == 60) || (x == 93 && y == 60))) begin
        oled_data <= red;
     end else begin
        oled_data <= white;
     end
   end
    
endmodule
