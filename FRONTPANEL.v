`default_nettype none

module FRONTPANEL(
  input CLK,
  input [11:0]green,
  input [11:0]red,
  input [11:0]yellow,
  output GREEN1, GREEN2,
  output RED1, RED2,
  output YELLOW1, YELLOW2,
  output PLED1, PLED2, PLED3, PLED4, PLED5, PLED6
);

reg [25:0] fakepll;
always @(posedge CLK) fakepll<=fakepll+1;
// wire tick=fakepll[0];   //    100/2  = 50 MHz
//wire tick=fakepll[1];   //    100/4  = 25 MHz
// wire tick=fakepll[2];  //    100/8  = 12.5 MHz
// wire tick=fakepll[3];  //   100/16  = 6.25 MHz
// wire tick=fakepll[4];  //   100/32  = 3.125 MHz
// wire tick=fakepll[5];  //   100/64  = 1.562 MHz
// wire tick=fakepll[6];  //  100/128  = 781.25 KHz
// wire tick=fakepll[7];  //  100/256  = 390.625 KHz
// wire tick=fakepll[8];  //  100/512  = 195.312 KHz
// wire tick=fakepll[9];  //   100/1K  = 97.656 KHz
// wire tick=fakepll[10]; //   100/2K  = 48.828 KHz
// wire tick=fakepll[11]; //   100/4K  = 24.414 KHz
// wire tick=fakepll[13]; //   100/8K  = 12.207 KHz
wire tick=fakepll[14]; //  100/16K  = 6.103 KHz
// wire tick=fakepll[15]; //  100/32K  = 3.051 KHz
// wire tick=fakepll[16]; //  100/64K  = 1.525 KHz
// wire tick=fakepll[17]; //  100/128K = 762.939 Hz
// wire tick=fakepll[18]; //  100/256K = 381.469 Hz
// wire tick=fakepll[19]; //  100/512K = 190.734 Hz
// wire tick=fakepll[20]; //    100/1M = 95.367 Hz
// wire tick=fakepll[21]; //    100/2M = 47.683 Hz
// wire tick=fakepll[22]; //    100/4M = 23.841 Hz
// wire tick=fakepll[23]; //    100/8M = 11.920 Hz
// wire tick=fakepll[24]; //   100/16M = 5.960 Hz
// wire tick=fakepll[25]; //   100/32M = 2.980 Hz
// wire tick=fakepll[26]; //   100/64M = 1.490 Hz
// wire tick=fakepll[27]; //  100/128M = 0.745 Hz


// reg [11:0] green =12'b101111111111;
// reg [11:0] red   =12'b101111111111;
// reg [11:0] yellow=12'b101111111111;

reg [2:0]group=0;
always @(posedge tick) begin
  group<=group+1;
end

assign GREEN1=group==0;
assign GREEN2=group==1;
assign RED1=group==2;
assign RED2=group==3;
assign YELLOW1=group==4;
assign YELLOW2=group==5;

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


