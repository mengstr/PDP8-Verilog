//`default_nettype none

module top (
    input SYSCLK,       // 100MHz
    input P0,           // Buton1
    input P1,           // Buton2
    output P2,          // LED1
    output P3           // LED2
);

// reg [15:0] tuning_word=12345;
// reg [19:0] phase_register = 20'h0;
// reg clk_reg = 1'b0;
// wire clk_ref;

// always @(posedge SYSCLK)
// 	phase_register <= phase_register + tuning_word;

// // Phase to frequency convertor
// always @(posedge clk_ref)
// 	clk_reg <= ~clk_reg;

//assign clk_ref = (phase_register[19]) ? 1 : 0;
        //  ICESTORM_LC:    25/ 1280     1%
        // ICESTORM_RAM:     0/   16     0%
        //        SB_IO:     5/  112     4%
        //        SB_GB:     2/    8    25%
        // ICESTORM_PLL:     0/    1     0%
        //  SB_WARMBOOT:     0/    1     0%
        // Timing estimate: 4.63 ns (215.95 MHz)

// assign clk_ref = phase_register[19];
        //  ICESTORM_LC:    25/ 1280     1%
        // ICESTORM_RAM:     0/   16     0%
        //        SB_IO:     5/  112     4%
        //        SB_GB:     2/    8    25%
        // ICESTORM_PLL:     0/    1     0%
        //  SB_WARMBOOT:     0/    1     0%
        // Timing estimate: 4.63 ns (215.95 MHz)


//        assign P2 = clk_reg;
        // assign P2 = clk_ref;



// reg [7:0] clk;
// reg blip;
// always @(posedge SYSCLK) begin
//     clk<=clk+1;
//     if (clk==0) blip<=1;
//     else blip<=0;
// end
// assign P2=blip;
// assign P3=blip;



// reg Q;
// always @(P0 or P1) begin
//     if (!P0) Q<=!P1;
// end
// assign P2=Q;
// assign P3=~Q;


// reg Q1,Q2;
// wire [1:0] but;egin
// wire but1,but2;
// wire butx;
// assign but1=~P0;
// assign but2=~P1;
// always @(posedge SYSCLK, posedge but1) begin
//     Q1<=1;
//     Q2<=0;
// end
// always @(posedge SYSCLK, posedge but2) begin
//     Q1<=0;
//     Q2<=1;
// end

// assign P2=Q1;
// assign P3=Q2;

//----------------------


    // OK
    // assign but1=~P0;
    // assign but2=~P1;
    // or(butx, but1,but2);
    // always @(posedge butx) begin
    //     if (but1) Q<=1;
    //     if (but2) Q<=0;
    // end



    // assign but={~P0,~P1};
    // always @(posedge SYSCLK) begin
    //     case (but)
    //         2'b01: Q=1;
    //         2'b10: Q=0;
    //     endcase
    // end

    // always @(posedge SYSCLK, posedge but1, posedge but2) begin
    // if (but1)
    //     Q <= 1;
    // else if (but2)
    //     Q <= 0;
    // else
    //     Q <= Q;
    // end

//   always @(posedge SYSCLK) begin
//     case({but1,but2})
//       2'b0_0 : Q <= Q   ;
//       2'b0_1 : Q <= 1'b0;
//       2'b1_0 : Q <= 1'b1;
//       2'b1_1 : Q <= ~Q  ;
//     endcase
//   end

//  always @(posedge SYSCLK) begin
//     if(but1==1'b0 && but2==1'b1) begin
//       Q <= 'b0;
//     end
//     else if(but1==1'b1 && but2==1'b0) begin
//       Q <= 1'b1;
//     end
//     else if(but1==1'b1 && but2==1'b1) begin
//       Q <= ~Q;
//     end
//   end

// assign P2=Q;
// assign P3=~Q;

// assign P2=but[0];
// assign P3=but[1];


endmodule

