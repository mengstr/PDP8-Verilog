//
// FrontPanel.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module FrontPanel(
  input REFRESHCLK,
  input [11:0]green,
  input [11:0]red,
  input [11:0]yellow,
  output GREEN1, GREEN2,
  output RED1, RED2,
  output YELLOW1, YELLOW2,
  output PLED1, PLED2, PLED3, PLED4, PLED5, PLED6
);

reg [2:0]group = 0;

always @(posedge REFRESHCLK) begin
  group <= group + 1;
end

assign GREEN1   = group==0;
assign GREEN2   = group==1;
assign RED1     = group==2;
assign RED2     = group==3;
assign YELLOW1  = group==4;
assign YELLOW2  = group==5;

assign PLED1=(group==0 &  green[0]) | (group==1 &  green[6]) |
             (group==2 &    red[0]) | (group==3 &    red[6]) |
             (group==4 & yellow[0]) | (group==5 & yellow[6]);

assign PLED2=(group==0 &  green[1]) | (group==1 &  green[7]) |
             (group==2 &    red[1]) | (group==3 &    red[7]) |
             (group==4 & yellow[1]) | (group==5 & yellow[7]);

assign PLED3=(group==0 &  green[2]) | (group==1 &  green[8]) |
             (group==2 &    red[2]) | (group==3 &    red[8]) |
             (group==4 & yellow[2]) | (group==5 & yellow[8]);

assign PLED4=(group==0 &  green[3]) | (group==1 &  green[9]) |
             (group==2 &    red[3]) | (group==3 &    red[9]) |
             (group==4 & yellow[3]) | (group==5 & yellow[9]);

assign PLED5=(group==0 &  green[4]) | (group==1 &  green[10]) |
             (group==2 &    red[4]) | (group==3 &    red[10]) |
             (group==4 & yellow[4]) | (group==5 & yellow[10]);

assign PLED6=(group==0 &  green[5]) | (group==1 &  green[11]) |
             (group==2 &    red[5]) | (group==3 &    red[11]) |
             (group==4 & yellow[5]) | (group==5 & yellow[11]);

endmodule
