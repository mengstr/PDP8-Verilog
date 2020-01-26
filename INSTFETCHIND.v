//
// INSTFETCHIND.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none

module INSTFETCHIND (
  input instIsIND,
  input instIsPPIND,
  input ckFetch, ckAuto1, ckAuto2, ckInd,
  input stbFetch, stbAuto1, stbAuto2, stbInd, 
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
assign ir2ramaIND=   instIsIND & (ckInd);
assign ram_oeIND=    instIsIND & (ckInd);
assign ind_ckIND=    instIsIND & (stbInd);

// 
// ▁ ▂ ▄ ▅ ▆ ▇ █ INDIRECT W. AUTOINC CYCLE █ ▇ ▆ ▅ ▄ ▂ ▁
// 
assign ir2ramaPPIND= instIsPPIND & (ckAuto1 | ckAuto2 | ckInd);
assign ram_oePPIND=  instIsPPIND & (ckAuto1 | ckInd);
assign ind2incPPIND= instIsPPIND & (ckAuto1 | ckAuto2);
assign ind_ckPPIND=  instIsPPIND & (stbAuto1 | stbInd);
assign inc2ramdPPIND=instIsPPIND & (ckAuto2);
assign ram_wePPIND=  instIsPPIND & (stbAuto2);

endmodule
