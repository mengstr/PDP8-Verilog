`default_nettype none

module UART (
);
endmodule



`ifndef NOTOP
module top(input CLK, output TX, input RX);
  UART uart();
    reg [13:0] divider=0;
    reg [15:0] bits=16'b111111_1_0100_0000_0;
    reg [3:0] bitcnt=0;
    reg baudtick=0;

    always @(posedge CLK) begin
        divider<=(divider==10400)?0:divider+1;
        baudtick<=(divider==0);
        if (baudtick) begin
            bitcnt<=bitcnt+1;
        end
    end 

    assign TX=bits>>bitcnt;

endmodule
`endif

