// 	 ICESTORM_LC:    49/ 1280     3%
// 	ICESTORM_RAM:     0/   16     0%
// 	       SB_IO:    68/  112    60%
// 	       SB_GB:     3/    8    37%
// 	ICESTORM_PLL:     0/    1     0%
// 	 SB_WARMBOOT:     0/    1     0%
// --TIMING
//         Timing estimate: 4.46 ns (224.10 MHz)


/*
 * UART transceiver. Only RXD/TXD lines and 8n1 mode is supported.
 *
 * Author: whitequark@whitequark.org (2016)
 *
 * Parameters:
 *  FREQ:       frequency of `clk`
 *  BAUD:       baud rate of serial line
 *
 * Common signals:
 *  reset:      active-low reset; only affects rx_ready_o, rx_error_o and tx_ack_o
 *  clk:        input clock, from which receiver and transmitter clocks are derived;
 *              all transitions happen on (posedge clk)
 *
 * Receiver signals:
 *  rx_i:       serial line input
 *  rx_data_o:  received octet, only valid while (rx_ack_i)
 *  rx_ready_o: whether rx_data_o contains a complete octet
 *  rx_ack_i:   clears rx_full_o and indicates that a new octet may be received
 *  rx_error_o: is asserted if a start bit arrives while (rx_full_o), or
 *              if a start bit is not followed with the stop bit at appropriate time
 *
 * Transmitter signals:
 *  tx_o:       serial line output
 *  tx_data_i:  octet to be sent, needs to be valid while (tx_ready_i && !tx_ack_o)
 *  tx_ready_i: indicates that a new octet should be sent
 *  tx_ack_o:   indicates that an octet is being sent
 *  tx_empty_o: indicates that a new octet may be sent
 */

 module top(input SYSCLK, inout P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23,P24,P25,P26,P27,P28,P29,P30,P31,P32,P33,P34,P35,P36,P37,P38,P39,P40,P41,P42,P43,P44,P45,P46,P47,P48,P49,P50,P51,P52,P53,P54,P55,P56,P57,P58,P59,P60,P61,P62,P63,P64,P65,P66);
  \UART dut(
    P0,SYSCLK,P1,{P10,P11,P12,P13,P14,P15,P16,P17},P3,P4,P5
  );
endmodule



module UART #(
        parameter FREQ  = 6_000_000,
        parameter BAUD  = 1_000_000
    ) (
        input           reset,
        input           clk,
        // Receiver half
        input           rx_i,
        output [7:0]    rx_data_o,
        output          rx_ready_o,
        input           rx_ack_i,
        output          rx_error_o
    );


    // RX oversampler
    reg        rx_sampler_reset = 1'b0;
    wire       rx_sampler_clk;
    ClockDiv #(
        .FREQ_I(FREQ),
        .FREQ_O(BAUD * 3),
        .PHASE(1'b1),
        .MAX_PPM(50_000)
    ) rx_sampler_clk_div (
        .reset(rx_sampler_reset),
        .clk_i(clk),
        .clk_o(rx_sampler_clk)
    );

    reg  [2:0] rx_sample  = 3'b000;
    wire       rx_sample1 = (rx_sample == 3'b111 ||
                             rx_sample == 3'b110 ||
                             rx_sample == 3'b101 ||
                             rx_sample == 3'b011);
    always @(posedge rx_sampler_clk or negedge rx_sampler_reset)
        if(!rx_sampler_reset)
            rx_sample <= 3'b000;
        else
            rx_sample <= {rx_sample[1:0], rx_i};

    (* fsm_encoding="one-hot" *)
    reg  [1:0] rx_sampleno  = 2'd2;
    wire       rx_samplerdy = (rx_sampleno == 2'd2);
    always @(posedge rx_sampler_clk or negedge rx_sampler_reset)
        if(!rx_sampler_reset)
            rx_sampleno <= 2'd2;
        else case(rx_sampleno)
            2'd0: rx_sampleno <= 2'd1;
            2'd1: rx_sampleno <= 2'd2;
            2'd2: rx_sampleno <= 2'd0;
        endcase

    // RX strobe generator
    reg  [1:0] rx_strobereg = 2'b00;
    wire       rx_strobe    = (rx_strobereg == 2'b01);
    always @(posedge clk or negedge reset)
        if(!reset)
            rx_strobereg <= 2'b00;
        else
            rx_strobereg <= {rx_strobereg[0], rx_samplerdy};

    // RX state machine
    localparam RX_IDLE  = 3'd0,
               RX_START = 3'd1,
               RX_DATA  = 3'd2,
               RX_STOP  = 3'd3,
               RX_FULL  = 3'd4,
               RX_ERROR = 3'd5;
    reg  [2:0] rx_state = 3'd0;
    reg  [7:0] rx_data  = 8'b00000000;
    reg  [2:0] rx_bitno = 3'd0;
    always @(posedge clk or negedge reset)
        if(!reset) begin
            rx_sampler_reset <= 1'b0;
            rx_state <= RX_IDLE;
            rx_data <= 8'b00000000;
            rx_bitno <= 3'd0;
        end else case(rx_state)
            RX_IDLE:
                if(!rx_i) begin
                    rx_sampler_reset <= 1'b1;
                    rx_state <= RX_START;
                end
            RX_START:
                if(rx_strobe)
                    rx_state <= RX_DATA;
            RX_DATA:
                if(rx_strobe) begin
                    if(rx_bitno == 3'd7)
                        rx_state <= RX_STOP;
                    rx_data <= {rx_sample1, rx_data[7:1]};
                    rx_bitno <= rx_bitno + 3'd1;
                end
            RX_STOP:
                if(rx_strobe) begin
                    rx_sampler_reset <= 1'b0;
                    if(rx_sample1 == 1'b0)
                        rx_state <= RX_ERROR;
                    else
                        rx_state <= RX_FULL;
                end
            RX_FULL:
                if(rx_ack_i)
                    rx_state <= RX_IDLE;
                else if(!rx_i)
                    rx_state <= RX_ERROR;
        endcase

    assign rx_data_o  = rx_data;
    assign rx_ready_o = (rx_state == RX_FULL);
    assign rx_error_o = (rx_state == RX_ERROR);

endmodule


/*
 * Static clock divider. Displays deviation from target output frequency during synthesis.
 *
 * Author: whitequark@whitequark.org (2016)
 *
 * Parameters:
 *  FREQ_I:  input frequency
 *  FREQ_O:  target output frequency
 *  PHASE:   polarity of the output clock after reset
 *  MAX_PPM: maximum frequency deviation; produces an error if not met
 *
 * Signals:
 *  reset:   active-low reset
 *  clk_i:   input clock
 *  clk_o:   output clock
 */
module ClockDiv #(
        parameter FREQ_I  = 2,
        parameter FREQ_O  = 1,
        parameter PHASE   = 1'b0,
        parameter MAX_PPM = 1_000_000
    ) (
        input  reset,
        input  clk_i,
        output clk_o
    );

    // This calculation always rounds frequency up.
    localparam INIT = FREQ_I / FREQ_O / 2 - 1;
    localparam ACTUAL_FREQ_O = FREQ_I / ((INIT + 1) * 2);
    localparam PPM = 64'd1_000_000 * (ACTUAL_FREQ_O - FREQ_O) / FREQ_O;
    initial $display({"ClockDiv #(.FREQ_I(%d), .FREQ_O(%d),\n",
                      "           .INIT(%d), .ACTUAL_FREQ_O(%d), .PPM(%d))"},
                     FREQ_I, FREQ_O, INIT, ACTUAL_FREQ_O, PPM);
    generate
        if(INIT < 0)
            _ERROR_FREQ_TOO_HIGH_ error();
        if(PPM > MAX_PPM)
            _ERROR_FREQ_DEVIATION_TOO_HIGH_ error();
    endgenerate

    reg [$clog2(INIT):0] cnt = 0;
    reg                  clk = PHASE;
    always @(posedge clk_i or negedge reset)
        if(!reset) begin
            cnt <= 0;
            clk <= PHASE;
        end else begin
            if(cnt == 0) begin
                clk <= ~clk;
                cnt <= INIT;
            end else begin
                cnt <= cnt - 1;
            end
        end

    assign clk_o = clk;

endmodule