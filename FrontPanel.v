//
// FrontPanel.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module FrontPanel(
  input clk,
  input REFRESHCLK,
  input BUTTONDELAY,
  input [11:0]green,
  input [11:0]red,
  input [11:0]yellow,
  output reg [11:0] toggles=0,
  output reg [5:0] buttons=0,
  output reg GREEN1, GREEN2,
  output reg RED1, RED2,
  output reg YELLOW1, YELLOW2,
  output reg PLED1, PLED2, PLED3, PLED4, PLED5, PLED6,
  input SW1, SW2, SW3
);

reg  [2:0] group=0;
reg [11:0] tmpToggles=0;
reg [5:0] tmpButtons=0;
reg anyon=0;
reg [2:0]cnt=0;
reg LASTBUTTONDLY=0;

always @(posedge clk) begin
  if (REFRESHCLK) begin
      group <= group + 1;
      GREEN1  <= (group==0);
      GREEN2  <= (group==1);
      RED1    <= (group==2);
      RED2    <= (group==3);
      YELLOW1 <= (group==4);
      YELLOW2 <= (group==5);

      PLED1 <=  (group==0 &  green[0]) | (group==1 &  green[6]) |
                (group==2 &    red[0]) | (group==3 &    red[6]) |
                (group==4 & yellow[0]) | (group==5 & yellow[6]);

      PLED2 <=  (group==0 &  green[1]) | (group==1 &  green[7]) |
                (group==2 &    red[1]) | (group==3 &    red[7]) |
                (group==4 & yellow[1]) | (group==5 & yellow[7]);

      PLED3 <=  (group==0 &  green[2]) | (group==1 &  green[8]) |
                (group==2 &    red[2]) | (group==3 &    red[8]) |
                (group==4 & yellow[2]) | (group==5 & yellow[8]);

      PLED4 <=  (group==0 &  green[3]) | (group==1 &  green[9]) |
                (group==2 &    red[3]) | (group==3 &    red[9]) |
                (group==4 & yellow[3]) | (group==5 & yellow[9]);

      PLED5 <=  (group==0 &  green[4]) | (group==1 &  green[10]) |
                (group==2 &    red[4]) | (group==3 &    red[10]) |
                (group==4 & yellow[4]) | (group==5 & yellow[10]);

      PLED6 <=  (group==0 &  green[5]) | (group==1 &  green[11]) |
                (group==2 &    red[5]) | (group==3 &    red[11]) |
                (group==4 & yellow[5]) | (group==5 & yellow[11]);

      if (group==1) begin tmpToggles[5]<=SW1; tmpToggles[11]<=SW2; tmpButtons[5]<=SW3; end
      if (group==2) begin tmpToggles[4]<=SW1; tmpToggles[10]<=SW2; tmpButtons[4]<=SW3; end
      if (group==3) begin tmpToggles[3]<=SW1; tmpToggles[ 9]<=SW2; tmpButtons[3]<=SW3; end
      if (group==4) begin tmpToggles[2]<=SW1; tmpToggles[ 8]<=SW2; tmpButtons[2]<=SW3; end
      if (group==5) begin tmpToggles[1]<=SW1; tmpToggles[ 7]<=SW2; tmpButtons[1]<=SW3; end
      if (group==6) begin tmpToggles[0]<=SW1; tmpToggles[ 6]<=SW2; tmpButtons[0]<=SW3; end

      anyon <= anyon | SW1 | SW2 | SW3;

      if (group==7) begin
        if (~anyon) begin
          cnt <= 0;
          buttons <= 0;
        end else begin 
          if (BUTTONDELAY & ~LASTBUTTONDLY) begin
            if (cnt<3) cnt <= cnt + 1;
            if (cnt==2) begin
              toggles <= toggles ^ tmpToggles;
              buttons  <=  tmpButtons;
            end
          end
          LASTBUTTONDLY <= BUTTONDELAY;
        end

        anyon <= 0;
        tmpToggles <= 0;
        tmpButtons <= 0;
      end
    end
end

endmodule
