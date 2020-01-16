`timescale 1ns/1ps

module CPU_tb();
    reg SYSCLK=0;
    reg clear=0,run=0, halt=0;
    reg mstep=0, istep=0;
    wire [11:0] dutBusPC, dutBusData;
    wire instAND, instTAD, instISZ, instDCA, instJMS, instJMP, instIOT, instOPR;

    CPU dut(
        .SYSCLK(SYSCLK),
        .sw_CLEAR(clear),
        .sw_RUN(run), .sw_HALT(halt),
        .sw_STEPM(mstep), .sw_STEPI(istep),
        .pBusPC(dutBusPC),
        .pBusData(dutBusData),
        .pInstAND(instAND), .pInstTAD(instTAD), .pInstISZ(instISZ), .pInstDCA(instDCA), .pInstJMS(instJMS), .pInstJMP(instJMP), .pInstIOT(instIOT), .pInstOPR(instOPR)
    );
    
 
    initial begin
        $dumpfile("CPU.vcd");
        $dumpvars;
        #20000 $finish;
    end

//    reg [3:0] oprcode;
    reg [7:0] opr [0:23];

    always begin
        #0.1 SYSCLK<=~SYSCLK;
    end

    always @(dut.theSEQUENCER.stepCnt) begin
        if (dut.theSEQUENCER.stepCnt==5'b00001) begin:PRN
            $display("PC=%04o L=%d ACC=%04o MQ=%04o IR=%04o",
                dut.thePC.PC,
                dut.link,
                dut.theACC.data,
                dut.theMQ.data,
                dut.busIR 
            );
            if (dut.busIR==12'o7402) begin $display("end by HLT"); $finish; end
            if ((dut.busIR>>9)==6) begin $display("end by IOT"); $finish; end
            if ((dut.theSEQUENCER.running==1'b1) && (dut.theACC.data[0:0]===1'bx)) begin $display("X in theACC.data"); $finish; end
            if ((dut.theSEQUENCER.running==1'b1) && (dut.theACC.data[0:0]===1'bz)) begin $display("Z in theACC.data"); $finish; end
        end
    end
    

    initial begin #0.5 clear=1; #5 clear=0; end  // Clear/reset the entire system

// RUN and HALT
    initial begin #10 run=1; #0.5 run=0; end
//    initial begin #3333.05 halt=1; #2 halt=0; end

// Microcycle step
    // initial begin #1.05 mstep=1; #0.5 mstep=0; end
    // initial begin #11.05 mstep=1; #0.5 mstep=0; end
    // initial begin #21.05 mstep=1; #0.5 mstep=0; end
    // initial begin #31.05 mstep=1; #0.5 mstep=0; end
    // initial begin #41.05 mstep=1; #20 mstep=0; end

    // initial begin #100.05 istep=1; #0.5 istep=0; end
    // initial begin #200.05 istep=1; #0.5 istep=0; end


endmodule

