`default_nettype none
/* verilator lint_off DECLFILENAME */

module unlinkbug(input i, output o);
  bug b(i, o);
endmodule

module bug(input i, output o);
  assign o = (i===1'bz) ? 1'b0 : i;
endmodule
