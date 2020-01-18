// 	 ICESTORM_LC:    67/ 1280     5%
// 	ICESTORM_RAM:     0/   16     0%
// 	       SB_IO:    68/  112    60%
// 	       SB_GB:     1/    8    12%
// 	ICESTORM_PLL:     0/    1     0%
// 	 SB_WARMBOOT:     0/    1     0%
// --TIMING
//         Timing estimate: 5.98 ns (167.10 MHz)
        
module top(input SYSCLK, inout P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23,P24,P25,P26,P27,P28,P29,P30,P31,P32,P33,P34,P35,P36,P37,P38,P39,P40,P41,P42,P43,P44,P45,P46,P47,P48,P49,P50,P51,P52,P53,P54,P55,P56,P57,P58,P59,P60,P61,P62,P63,P64,P65,P66);
  receiver dut(
    P0,P1,P3,SYSCLK,P3, {P10,P11,P12,P13,P14,P15,P16,P17}
  );
endmodule



module receiver(
        input wire rx,
		output reg rdy,
		input wire rdy_clr,
		input wire clk_50m,
		input wire clken,
		output reg [7:0] data);

initial begin
	rdy = 0;
	data = 8'b0;
end

parameter RX_STATE_START	= 2'b00;
parameter RX_STATE_DATA		= 2'b01;
parameter RX_STATE_STOP		= 2'b10;

reg [1:0] state = RX_STATE_START;
reg [3:0] sample = 0;
reg [3:0] bitpos = 0;
reg [7:0] scratch = 8'b0;

always @(posedge clk_50m) begin
	if (rdy_clr)
		rdy <= 0;

	if (clken) begin
		case (state)
		RX_STATE_START: begin
			/*
			* Start counting from the first low sample, once we've
			* sampled a full bit, start collecting data bits.
			*/
			if (!rx || sample != 0)
				sample <= sample + 4'b1;

			if (sample == 15) begin
				state <= RX_STATE_DATA;
				bitpos <= 0;
				sample <= 0;
				scratch <= 0;
			end
		end
		RX_STATE_DATA: begin
			sample <= sample + 4'b1;
			if (sample == 4'h8) begin
				scratch[bitpos[2:0]] <= rx;
				bitpos <= bitpos + 4'b1;
			end
			if (bitpos == 8 && sample == 15)
				state <= RX_STATE_STOP;
		end
		RX_STATE_STOP: begin
			/*
			 * Our baud clock may not be running at exactly the
			 * same rate as the transmitter.  If we thing that
			 * we're at least half way into the stop bit, allow
			 * transition into handling the next start bit.
			 */
			if (sample == 15 || (sample >= 8 && !rx)) begin
				state <= RX_STATE_START;
				data <= scratch;
				rdy <= 1'b1;
				sample <= 0;
			end else begin
				sample <= sample + 4'b1;
			end
		end
		default: begin
			state <= RX_STATE_START;
		end
		endcase
	end
end

endmodule
