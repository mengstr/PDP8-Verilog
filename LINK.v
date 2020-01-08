`default_nettype none

module LINK (
input SYSCLK,
input CLEAR,
input LINK_CK,
input CLL,        // Clear link
input CML,        // Complement link
input SET,        // Update L to be FROM_ROTATER
input FROM_ROTATER,
output reg L,
output TO_ROTATER
);

reg lastCML;
reg lastSET;

// always @(posedge SYSCLK) lastCML<=CML;
// always @(posedge SYSCLK) lastSET<=SET;

always @(posedge SYSCLK) begin
  if (CLEAR) L<=0;
  // if (CLEAR || CLL) L<=0;
//  if (CML==1 && lastCML==0) L<=~L;
//  if (SET==1 && lastSET==0) L<=FROM_ROTATER;
end

always @(posedge LINK_CK) begin 
  if (SET==1) L<=FROM_ROTATER;
  else begin
    if (CLL==1 && CML==0) L<=0;
    if (CLL==1 && CML==1) L<=1;
    if (CLL==0 && CML==1) L<=~L;
  end
end

// assign TO_ROTATER=L;
assign TO_ROTATER=((L&(~CLL))^CML);


endmodule


`ifdef DISABLED

module DIG_D_FF_AS_1bit
#(
    parameter Default = 0
)
(
   input Set,
   input D,
   input C,
   input Clr,
   output Q,
   output \~Q
);
    reg state;

    assign Q = state;
    assign \~Q  = ~state;

    always @ (posedge C or posedge Clr or posedge Set)
    begin
        if (Set)
            state <= 1'b1;
        else if (Clr)
            state <= 'h0;
        else
            state <= D;
    end

    initial begin
        state = Default;
    end
endmodule

// dual D-flip-flop
module \7474  (
  input \1~SD ,
  input \1D ,
  input \1CP ,
  input \1~RD ,
  input \2~SD ,
  input \2D ,
  input \2CP ,
  input \2~RD ,
  input VCC,
  input GND,
  output \1Q ,
  output \1~Q ,
  output \2Q ,
  output \2~Q 
);
  wire s0;
  wire s1;
  wire s2;
  wire s3;
  wire s4;
  wire s5;
  DIG_D_FF_AS_1bit #(
    .Default(0)
  )
  DIG_D_FF_AS_1bit_i0 (
    .Set( \1~SD  ),
    .D( \1D  ),
    .C( \1CP  ),
    .Clr( \1~RD  ),
    .Q( \1Q  ),
    .\~Q ( s0 )
  );
  DIG_D_FF_AS_1bit #(
    .Default(0)
  )
  DIG_D_FF_AS_1bit_i1 (
    .Set( \2~SD  ),
    .D( \2D  ),
    .C( \2CP  ),
    .Clr( \2~RD  ),
    .Q( \2Q  ),
    .\~Q ( s1 )
  );
  assign s2 = ~ \1~SD ;
  assign s3 = ~ \1~RD ;
  assign s4 = ~ \2~SD ;
  assign s5 = ~ \2~RD ;
  assign \1~Q  = (s0 | (~ \1~SD  & ~ \1~RD ));
  assign \2~Q  = (s1 | (~ \2~SD  & ~ \2~RD ));
endmodule

module LINK (
  input ANDADD_Carry,
  input RAMD2AC_ADD,
  input LINK_CK,
  input OPR_CLL,
  input CLL,
  input RTF_LINK,
  input OPR_CML,
  input INC_carry,
  input OPR_IAC,
  input ROTATE_OUT,
  input STB_1,
  input CLEAR,
  output L,
  output ROTATE_IN
);
  wire LINK_temp;
  wire s0;
  wire s1;
  wire s2;
  wire s3;
  assign s2 = (ANDADD_Carry & RAMD2AC_ADD);
  assign s3 = ~ CLEAR;
  assign ROTATE_IN = (((LINK_temp & ~ (CLL | OPR_CLL)) ^ (RTF_LINK | OPR_CML)) ^ (INC_carry & OPR_IAC));
  assign s1 = (ROTATE_OUT ^ s0);
  \7474  \7474_i0 (
    .\1~SD ( 1'b1 ),
    .\1D ( s2 ),
    .\1CP ( STB_1 ),
    .\1~RD ( s3 ),
    .\2~SD ( 1'b1 ),
    .\2D ( s1 ),
    .\2CP ( LINK_CK ),
    .\2~RD ( s3 ),
    .VCC( 1'b1 ),
    .GND( 1'b0 ),
    .\1Q ( s0 ),
    .\2Q ( LINK_temp )
  );
  assign L = LINK_temp;
endmodule
`endif



`ifdef TOP
module top(input CLK, inout P0,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23,P24,P25,P26,P27,P28,P29,P30,P31,P32,P33,P34,P35,P36,P37,P38,P39,P40,P41,P42,P43,P44,P45,P46,P47,P48,P49,P50,P51,P52,P53,P54,P55,P56,P57,P58,P59,P60,P61,P62,P63,P64,P65,P66);
  LINK dut(
    P0,P1,P2,P3, 
    P4,P5,P6,P7, 
    P8,P9,P10,P11,
    P12,P13
  );
endmodule
`endif

  