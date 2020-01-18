`default_nettype none

module top (
  input     CLK,    //input 100Mhz clock
  input     BUT1, BUT2,
  output    [14:0] PIXEL,
  output    DIGIT0, DIGIT1
);

localparam SPEED = 20;

    reg [SPEED-1:0] divider=0;
    reg stb=0;
    reg [3:0] led=0;
    wire line;
    reg lastBUT1=1;

    always @(posedge CLK) begin
        divider <= divider + 1;
        stb<=(divider == 0);
    end

    assign line=divider[19];

    always @(posedge CLK) begin
        if (stb) begin
            if (!BUT1 && lastBUT1) begin 
                lastBUT1<=1'b0;
                led<=led+1;
            end else if (BUT1 && !lastBUT1) begin
                lastBUT1<=1;
            end
        end
    end

    assign PIXEL[0]=(led==0) ? 1'b1 : !BUT2;
    assign PIXEL[1]=(led==1) ? 1'b1 : !BUT2;
    assign PIXEL[2]=(led==2) ? 1'b1 : !BUT2;
    assign PIXEL[3]=(led==3) ? 1'b1 : !BUT2;
    assign PIXEL[4]=(led==4) ? 1'b1 : !BUT2;
    assign PIXEL[5]=(led==5) ? 1'b1 : !BUT2;
    assign PIXEL[6]=(led==6) ? 1'b1 : !BUT2;
    assign PIXEL[7]=(led==7) ? 1'b1 : !BUT2;
    assign PIXEL[8]=(led==8) ? 1'b1 : !BUT2;
    assign PIXEL[9]=(led==9) ? 1'b1 : !BUT2;
    assign PIXEL[10]=(led==10) ? 1'b1 : !BUT2;
    assign PIXEL[11]=(led==11) ? 1'b1 : !BUT2;
    assign PIXEL[12]=(led==12) ? 1'b1 : !BUT2;
    assign PIXEL[13]=(led==13) ? 1'b1 : !BUT2;
    assign PIXEL[14]=(led==14) ? 1'b1 : !BUT2;

    assign DIGIT0=(line==0) ? 1'b1 : 1'b0;
    assign DIGIT1=(line==1) ? 1'b1 : 1'b0;


endmodule
