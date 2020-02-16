//
// FrontPanel.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module FrontPanel(
  input REFRESHCLK,
  input BUTTONDELAY,
  input [11:0]green,
  input [11:0]red,
  input [11:0]yellow,
  output reg [11:0] switches,
  output reg [5:0] buttons,
  output reg GREEN1, GREEN2,
  output reg RED1, RED2,
  output reg YELLOW1, YELLOW2,
  output reg PLED1, PLED2, PLED3, PLED4, PLED5, PLED6,
  input SW1, SW2, SW3
);

reg  [2:0] group = 0;
reg [11:0] tmpSwitches=0;
reg  [7:0] dly=0;
reg  [2:0] dlycnt=0;
reg lastdly=0;
reg anyon=0;


always @(posedge REFRESHCLK) begin
  group <= group + 1;

  GREEN1  <= (group==0);
  GREEN2  <= (group==1);
  RED1    <= (group==2);
  RED2    <= (group==3);
  YELLOW1 <= (group==4);
  YELLOW2 <= (group==5);

  PLED1 <=   (group==0 &  green[0]) | (group==1 &  green[6]) |
             (group==2 &    red[0]) | (group==3 &    red[6]) |
             (group==4 & yellow[0]) | (group==5 & yellow[6]);

  PLED2 <=   (group==0 &  green[1]) | (group==1 &  green[7]) |
             (group==2 &    red[1]) | (group==3 &    red[7]) |
             (group==4 & yellow[1]) | (group==5 & yellow[7]);

  PLED3 <=   (group==0 &  green[2]) | (group==1 &  green[8]) |
             (group==2 &    red[2]) | (group==3 &    red[8]) |
             (group==4 & yellow[2]) | (group==5 & yellow[8]);

  PLED4 <=   (group==0 &  green[3]) | (group==1 &  green[9]) |
             (group==2 &    red[3]) | (group==3 &    red[9]) |
             (group==4 & yellow[3]) | (group==5 & yellow[9]);

  PLED5 <=   (group==0 &  green[4]) | (group==1 &  green[10]) |
             (group==2 &    red[4]) | (group==3 &    red[10]) |
             (group==4 & yellow[4]) | (group==5 & yellow[10]);

  PLED6 <=   (group==0 &  green[5]) | (group==1 &  green[11]) |
             (group==2 &    red[5]) | (group==3 &    red[11]) |
             (group==4 & yellow[5]) | (group==5 & yellow[11]);

    if (group==1) begin tmpSwitches[5]<=SW1;  tmpSwitches[11]<=SW2; buttons[5]<=SW3; end
    if (group==2) begin tmpSwitches[4]<=SW1;  tmpSwitches[10]<=SW2; buttons[4]<=SW3; end
    if (group==3) begin tmpSwitches[3]<=SW1;  tmpSwitches[ 9]<=SW2; buttons[3]<=SW3; end
    if (group==4) begin tmpSwitches[2]<=SW1;  tmpSwitches[ 8]<=SW2; buttons[2]<=SW3; end
    if (group==5) begin tmpSwitches[1]<=SW1;  tmpSwitches[ 7]<=SW2; buttons[1]<=SW3; end
    if (group==6) begin tmpSwitches[0]<=SW1;  tmpSwitches[ 6]<=SW2; buttons[0]<=SW3; end

    anyon<=anyon|SW1|SW2|SW3;

    if (group==7) begin
      dly <= dly + 1;

      if (dlycnt==0 & anyon) begin
        tmpSwitches<=tmpSwitches^switches;
        switches<=tmpSwitches;
        dlycnt<=3;
      end

      if (dlycnt>0 & dly[7]==1 & ~lastdly) begin
        dlycnt<=dlycnt-1;
      end

      lastdly<=dly[7];
      anyon<=0;
    end

end

endmodule
