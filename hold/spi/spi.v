`default_nettype none

module top (
  input         CLK,    //input 100Mhz clock
  output        PIN5,   //shiftout_clock,
  output        PIN9,   //shiftout_latch,
  output        PIN7,    //shiftout_data
  output        LED1,
  output        LED2
);

localparam SPEED = 10;

    reg [SPEED-1:0] divider=0;
    reg stb=0;
    always @(posedge CLK) begin
        divider <= divider + 1;
        stb<=(divider == 0);
    end


assign LED1=PIN7;
assign LED2=PIN9;

    shift595 disp1(
        .SYSCLK(CLK),
        .tick(stb),
        .SCK(PIN5),
        .LATCH(PIN7),
        .DO(PIN9)
    );

endmodule


//
//         D2    D3    dp    g     f     e     d     c     b     a     -     -     -     -     D0    D1    D2    D3    dp    g     f     e
//         14    15    0     1     2     3     4     5     6     7     8     9     10    11    12    13    14    15    0     1     2     3    
// SCK ¯|__|¯¯|__|¯¯|__|¯¯|__|¯¯|__|¯¯|__|¯¯|__|¯¯|__|¯¯|__|¯¯|__|¯¯|__|¯¯|__|¯¯|__|¯¯|__|¯¯|__|¯¯|__|¯¯|__|¯¯|__|¯¯|__|¯¯|__|¯¯|__|¯¯|__|¯¯|_
//
// DO   ^     ^     ^     ^     ^     ^     ^     ^     ^     ^     ^     ^     ^     ^     ^     ^     ^     ^     ^     ^     ^     ^     ^ 
//
// LAT _____________|¯¯|____________________________________________________________________________________________|¯¯|_______________________ 
//
module shift595 (
  input wire       SYSCLK,    //
  input wire       tick,   //
  output reg       SCK=0,       //shiftout_clock,
  output reg       LATCH=0,     //shiftout_latch,
  output reg       DO=0         //shiftout_data
);

  reg [1:0] digit=0;
  reg [3:0] bitcnt=0; 
  reg [7:0] segs=0;

    always@(posedge SYSCLK) begin 
        if (tick==1) begin

            if (SCK==0) begin
                // Rising edge of SCK. Shifts in the value at DO
                SCK<=1;
                LATCH<=0;
                if (bitcnt==15) begin
                     digit=digit+1;
                    if (digit==0) segs<={1'b0,Lookup7Seg(2)};
                    if (digit==1) segs<={1'b1,Lookup7Seg(3)};
                    if (digit==2) segs<={1'b1,Lookup7Seg(5)};
                    if (digit==3) segs<={1'b0,Lookup7Seg(6)};
                 end
            end else begin
                // Falling edge of SCK. Update DO here
                SCK<=0;
                bitcnt=bitcnt+1;
                if (bitcnt==0) LATCH<=1;
                case (bitcnt)
                    0:  DO=~segs[7];   // Seg DP
                    1:  DO=~segs[6];   // Seg G
                    2:  DO=~segs[5];   // Seg F
                    3:  DO=~segs[4];   // Seg E
                    4:  DO=~segs[3];   // Seg D
                    5:  DO=~segs[2];   // Seg C
                    6:  DO=~segs[1];   // Seg B
                    7:  DO=~segs[0];   // Seg A
                    8:  DO=0;          // not used
                    9:  DO=0;          // not used
                    10: DO=0;          // not used
                    11: DO=0;          // not used
                    12: DO=(digit==0);     // Leftmost digit
                    13: DO=(digit==1);     // Middle left digit          
                    14: DO=(digit==2);     // Middle right digit
                    15: DO=(digit==3);    // Rightmost digit
                endcase
            end
        end
    end  



    function [6:0] Lookup7Seg;
        input wire [3:0] in;
        begin
            case (in)
                0:Lookup7Seg = 7'b0111111;
                1:Lookup7Seg = 7'b0000110;
                2:Lookup7Seg = 7'b1011011;
                3:Lookup7Seg = 7'b1001111;
                4:Lookup7Seg = 7'b1100110;
                5:Lookup7Seg = 7'b1101101;
                6:Lookup7Seg = 7'b1111101;
                7:Lookup7Seg = 7'b0000111;
                8:Lookup7Seg = 7'b1111111;
                9:Lookup7Seg = 7'b1101111;
                10:Lookup7Seg = 7'b1110111;
                11:Lookup7Seg = 7'b1111100;
                12:Lookup7Seg = 7'b0111001;
                13:Lookup7Seg = 7'b1011110;
                14:Lookup7Seg = 7'b1111001;
                15:Lookup7Seg = 7'b1110001;
            endcase
        end
    endfunction


endmodule


// module shift595X (
//   input wire       CLK10HZ,   //
//   output reg       SCK,       //shiftout_clock,
//   output reg       LATCH,     //shiftout_latch,
//   output reg       DO         //shiftout_data
// );

//     reg [15:0] shift_reg = 0;
//     assign DO = shift_reg[15];

//     assign SCK = CLK10HZ;


//     reg [1:0] digit_counter = 0;
//     reg [3:0] bit_counter = 0;
//     reg [15:0] data_out = 0;

//     reg [15:0] value = 16'hABCD;
//     wire [3:0]v0 = value[0:3];
//     wire [3:0]v1 = value[4:7];
//     wire [3:0]v2 = value[8:11];
//     wire [3:0]v3 = value[12:15];

//     always @(negedge CLK10HZ) begin
//             if (delay_counter == 0) begin
//                 shift_reg <= shift_reg << 1;
//                 bit_counter <= bit_counter + 1;
//                 if (bit_counter == 15) begin
//                     // Show the value and restart the delay counter
//                     delay_counter <= 1;
//                     // Increment data out to show increasing numbers
//                     data_out <= data_out + 1;
//                 end
//                 end else begin
//                 delay_counter <= delay_counter + 1;
//                 // When delay counter is maxed out, prepare to shift out next value
//                 if (&delay_counter) begin
//                     digit_counter <= digit_counter + 1;
//                     if (digit_counter==0) begin
//                         case (v0)
//                             4'h0:shift_reg <= {~1'b0, ~7'b0111111, 8'h11};
//                             4'h1:shift_reg <= {~1'b0, ~7'b0000110, 8'h11};
//                             4'h2:shift_reg <= {~1'b0, ~7'b1011011, 8'h11};
//                             4'h3:shift_reg <= {~1'b0, ~7'b1001111, 8'h11};
//                             4'h4:shift_reg <= {~1'b0, ~7'b1100110, 8'h11};
//                             4'h5:shift_reg <= {~1'b0, ~7'b1101101, 8'h11};
//                             4'h6:shift_reg <= {~1'b0, ~7'b1111101, 8'h11};
//                             4'h7:shift_reg <= {~1'b0, ~7'b0000111, 8'h11};
//                             4'h8:shift_reg <= {~1'b0, ~7'b1111111, 8'h11};
//                             4'h9:shift_reg <= {~1'b0, ~7'b1101111, 8'h11};
//                             4'hA:shift_reg <= {~1'b0, ~7'b1110111, 8'h11};
//                             4'hB:shift_reg <= {~1'b0, ~7'b1111100, 8'h11};
//                             4'hC:shift_reg <= {~1'b0, ~7'b0111001, 8'h11};
//                             4'hD:shift_reg <= {~1'b0, ~7'b1011110, 8'h11};
//                             4'hE:shift_reg <= {~1'b0, ~7'b1111001, 8'h11};
//                             4'hF:shift_reg <= {~1'b0, ~7'b1110001, 8'h11};
//                         endcase
//                     end
//                     if (digit_counter==1) begin
//                         case (v1)
//                             4'h0:shift_reg <= {~1'b0, ~7'b0111111, 8'h02};
//                             4'h1:shift_reg <= {~1'b0, ~7'b0000110, 8'h02};
//                             4'h2:shift_reg <= {~1'b0, ~7'b1011011, 8'h02};
//                             4'h3:shift_reg <= {~1'b0, ~7'b1001111, 8'h02};
//                             4'h4:shift_reg <= {~1'b0, ~7'b1100110, 8'h02};
//                             4'h5:shift_reg <= {~1'b0, ~7'b1101101, 8'h02};
//                             4'h6:shift_reg <= {~1'b0, ~7'b1111101, 8'h02};
//                             4'h7:shift_reg <= {~1'b0, ~7'b0000111, 8'h02};
//                             4'h8:shift_reg <= {~1'b0, ~7'b1111111, 8'h02};
//                             4'h9:shift_reg <= {~1'b0, ~7'b1101111, 8'h02};
//                             4'hA:shift_reg <= {~1'b0, ~7'b1110111, 8'h02};
//                             4'hB:shift_reg <= {~1'b0, ~7'b1111100, 8'h02};
//                             4'hC:shift_reg <= {~1'b0, ~7'b0111001, 8'h02};
//                             4'hD:shift_reg <= {~1'b0, ~7'b1011110, 8'h02};
//                             4'hE:shift_reg <= {~1'b0, ~7'b1111001, 8'h02};
//                             4'hF:shift_reg <= {~1'b0, ~7'b1110001, 8'h02};
//                         endcase
//                     end
//                     if (digit_counter==2) begin
//                         case (v2)
//                             4'h0:shift_reg <= {~1'b0, ~7'b0111111, 8'h04};
//                             4'h1:shift_reg <= {~1'b0, ~7'b0000110, 8'h04};
//                             4'h2:shift_reg <= {~1'b0, ~7'b1011011, 8'h04};
//                             4'h3:shift_reg <= {~1'b0, ~7'b1001111, 8'h04};
//                             4'h4:shift_reg <= {~1'b0, ~7'b1100110, 8'h04};
//                             4'h5:shift_reg <= {~1'b0, ~7'b1101101, 8'h04};
//                             4'h6:shift_reg <= {~1'b0, ~7'b1111101, 8'h04};
//                             4'h7:shift_reg <= {~1'b0, ~7'b0000111, 8'h04};
//                             4'h8:shift_reg <= {~1'b0, ~7'b1111111, 8'h04};
//                             4'h9:shift_reg <= {~1'b0, ~7'b1101111, 8'h04};
//                             4'hA:shift_reg <= {~1'b0, ~7'b1110111, 8'h04};
//                             4'hB:shift_reg <= {~1'b0, ~7'b1111100, 8'h04};
//                             4'hC:shift_reg <= {~1'b0, ~7'b0111001, 8'h04};
//                             4'hD:shift_reg <= {~1'b0, ~7'b1011110, 8'h04};
//                             4'hE:shift_reg <= {~1'b0, ~7'b1111001, 8'h04};
//                             4'hF:shift_reg <= {~1'b0, ~7'b1110001, 8'h04};
//                         endcase
//                     end
//                     if (digit_counter==3) begin
//                         case (v3)
//                             4'h0:shift_reg <= {~1'b0, ~7'b0111111, 8'h08};
//                             4'h1:shift_reg <= {~1'b0, ~7'b0000110, 8'h08};
//                             4'h2:shift_reg <= {~1'b0, ~7'b1011011, 8'h08};
//                             4'h3:shift_reg <= {~1'b0, ~7'b1001111, 8'h08};
//                             4'h4:shift_reg <= {~1'b0, ~7'b1100110, 8'h08};
//                             4'h5:shift_reg <= {~1'b0, ~7'b1101101, 8'h08};
//                             4'h6:shift_reg <= {~1'b0, ~7'b1111101, 8'h08};
//                             4'h7:shift_reg <= {~1'b0, ~7'b0000111, 8'h08};
//                             4'h8:shift_reg <= {~1'b0, ~7'b1111111, 8'h08};
//                             4'h9:shift_reg <= {~1'b0, ~7'b1101111, 8'h08};
//                             4'hA:shift_reg <= {~1'b0, ~7'b1110111, 8'h08};
//                             4'hB:shift_reg <= {~1'b0, ~7'b1111100, 8'h08};
//                             4'hC:shift_reg <= {~1'b0, ~7'b0111001, 8'h08};
//                             4'hD:shift_reg <= {~1'b0, ~7'b1011110, 8'h08};
//                             4'hE:shift_reg <= {~1'b0, ~7'b1111001, 8'h08};
//                             4'hF:shift_reg <= {~1'b0, ~7'b1110001, 8'h08};
//                         endcase
//                     end
//                 end
//             end
//         end
// endmodule
