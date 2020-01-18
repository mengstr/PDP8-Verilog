module top(input SYSCLK, inout P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23,P24,P25,P26,P27,P28,P29,P30,P31,P32,P33,P34,P35,P36,P37,P38,P39,P40,P41,P42,P43,P44,P45,P46,P47,P48,P49,P50,P51,P52,P53,P54,P55,P56,P57,P58,P59,P60,P61,P62,P63,P64,P65,P66);
  uart_rx dut(
    P0,SYSCLK,{P10,P11,P12,P13,P14,P15,P16,P17},P1,P2
  );
endmodule

module uart_rx(
    input rx,
    input s_tick,
    output reg [7:0] dout,
    output reg rx_done_tick,
    input reset
);


reg [3:0] counter;
reg [2:0] state;
reg [3:0] bit_count;

parameter [2:0]
    IDLE   = 3'd0,
    DATA  = 3'd1,
    STOP  = 3'd2;

always@(posedge s_tick) begin
    case(state)
        IDLE:
            if(rx == 0 && counter == 4'd7) begin
                rx_done_tick <= 0;
                state <= DATA;
                counter <= 0;
                bit_count <= 0;
                dout <= 0;
            end else begin
                counter <= counter + 1;
            end
        DATA:
            if(counter == 4'd15) begin
                state <= DATA;
                dout <= {rx, dout[7:1]};
                bit_count <= bit_count + 1;
                counter <= counter + 1;
                if(bit_count == 4'd7) begin
                    state <= STOP;
                    bit_count <= 0;
                    rx_done_tick <= 0;
                end
            end else begin
                counter <= counter + 1;
            end
        STOP:
            if(counter == 4'd15) begin
                rx_done_tick <= 1;
                state <= IDLE;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
    endcase

end

always@(posedge reset) begin
	state <= IDLE;
	counter <= 4'b0;
	rx_done_tick <= 1;
end

endmodule
