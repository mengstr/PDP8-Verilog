//
// INSTFETCHIND.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module INSTFETCHIND (
  input stbFetch,
  input ckFetch,
  input instIsIND,
  input instIsPPIND,
  input ckIndirect,
  input stbIndirect,
  input ckAutoinc1,
  input stbAutoinc2,
  input ckAutoinc2,
  input stbAutoinc1,
  output inc2ramd,
  output ind_ck,
  output ind2inc,
  output ir2rama,
  output pc_ck,
  output ram_oe,
  output ram_we
);

wire         inc2ramdPPIND;
or(inc2ramd, inc2ramdPPIND);

wire       ind_ckIND, ind_ckPPIND;
or(ind_ck, ind_ckIND, ind_ckPPIND);

wire        ind2incPPIND;
or(ind2inc, ind2incPPIND);

wire        ir2ramaIND, ir2ramaPPIND;
or(ir2rama, ir2ramaIND, ir2ramaPPIND);

wire      pc_ckFETCH;
or(pc_ck, pc_ckFETCH);

wire       ram_oeFETCH, ram_oeIND, ram_oePPIND;
or(ram_oe, ram_oeFETCH, ram_oeIND, ram_oePPIND);

wire       ram_wePPIND;
or(ram_we, ram_wePPIND);

// 
// ▁ ▂ ▄ ▅ ▆ ▇ █ FETCH CYCLE █ ▇ ▆ ▅ ▄ ▂ ▁
// 
assign pc_ckFETCH=    stbFetch;
assign ram_oeFETCH=   ckFetch;

// 
// ▁ ▂ ▄ ▅ ▆ ▇ █ INDIRECT CYCLE █ ▇ ▆ ▅ ▄ ▂ ▁
// 
assign ir2ramaIND=   instIsIND & (ckIndirect);
assign ram_oeIND=    instIsIND & (ckIndirect);
assign ind_ckIND=    instIsIND & (stbIndirect);

// 
// ▁ ▂ ▄ ▅ ▆ ▇ █ INDIRECT W. AUTOINC CYCLE █ ▇ ▆ ▅ ▄ ▂ ▁
// 
assign ir2ramaPPIND= instIsPPIND & (ckAutoinc1 | ckAutoinc2 | ckIndirect);
assign ram_oePPIND=  instIsPPIND & (ckAutoinc1 | ckIndirect);
assign ind2incPPIND= instIsPPIND & (ckAutoinc1 | ckAutoinc2);
assign ind_ckPPIND=  instIsPPIND & (stbAutoinc1 | stbIndirect);
assign inc2ramdPPIND=instIsPPIND & (ckAutoinc2);
assign ram_wePPIND=  instIsPPIND & (stbAutoinc2);

endmodule
