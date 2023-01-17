module fourdigitdriver(A, B, C, D, clk, dots, seg, an, dp);
    input clk;
    input [3:0] A, B, C, D;
    input [0:3] dots;
    output reg [3:0] an;
    output [0:6] seg;
    output reg dp;
    
    reg [17:0] refreshCount = 0;
    reg [25:0] flashingCount = 1;
    reg [1:0] select = 0;
    reg [3:0] Hex;
    
    reg flashState = 0;
    
    digit2sevenseg  digit(.seg(seg[0:6]), .Val(Hex));
    
    always @(posedge clk)
    begin
//        if(flashingCount == 0)
//            flashState = !flashState;
    
        if(refreshCount == 0)
        begin
            case(select)
                2'b00:
                begin
                    Hex = A;
                    an = 4'b0111;
                    if(!dots[0]) dp = 1;
                    else dp = 0;
                end
                2'b01:
                begin
                    Hex = B;
                    an = 4'b1011;
                    if(!dots[1]) dp = 1;
                    else dp = 0;
                end
                2'b10:
                begin
                    Hex = C;
                    an = 4'b1101;
                    if(!dots[2]) dp = 1;
                    else dp = 0;
                end
                2'b11:
                begin
                    Hex = D;
                    an = 4'b1110;
                    if(!dots[3]) dp = 1;
                    else dp = 0;
                end
            endcase
            select = select + 1'b1;
        end
        
//        if(flashState == 1 && flashing == 1)
//            an = 4'b1111;

//        // Unsigned number count rolls over to 0 automatically
        refreshCount = refreshCount + 1'b1;
//        flashingCount = flashingCount + 1'b1;
    end
endmodule