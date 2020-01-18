module top(inout P10,P11,P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23,P24,P25,P26,P27,P28,P29);
   assign P19 = ((P10 & P17 & P12) | (~ P11 & P17 & P12) | (P17 & ~ P18 & P12)); //ICESTORM_LC:     4/ 1280     0%
   assign P29 = P22 & (((P20 & P27) | (~ P21 & P27) | (P27 & ~ P28)));
endmodule  