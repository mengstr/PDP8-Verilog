//
// RIMloader.v - for the PDP-8 in Verilog project
//
// github.com/SmallRoomLabs/PDP8-Verilog
// Mats Engstrom - mats.engstrom@gmail.com
//

`default_nettype none


//
// Halt CPU
// Aquire control over RAM address and data busses
// Set internal addr to 0
// Loop
//   Assert address and data onto busses
//   Strobe WE
//   Increment internal addr
// Until addr[4]==1
// Set PC to 7756
// Release control over RAM address and data busses
//

module RIMloader(
 output [11:0] address,
 output reg [11:0] data,
 output we
);

reg [4:0] addr=0;

always @* begin
  case (addr[3:0])
    4'd0:   data = 12'o6032;
    4'd1:   data = 12'o6031;
    4'd2:   data = 12'o5357;
    4'd3:   data = 12'o6036;
    4'd4:   data = 12'o7106;
    4'd5:   data = 12'o7006;
    4'd6:   data = 12'o7510;
    4'd7:   data = 12'o5357;
    4'd8:   data = 12'o7006;
    4'd9:   data = 12'o6031;
    4'd10:  data = 12'o5367;
    4'd11:  data = 12'o6034;
    4'd12:  data = 12'o7420;
    4'd13:  data = 12'o3776;
    4'd14:  data = 12'o3376;
    4'd15:  data = 12'o5356;
    default:data = 12'o0000;
  endcase
end

assign address=12'o7756 + {8'b0,addr[3:0]};


endmodule



//   RIM Loader       RIM Loader         RIM Loader                RIM Loader         
//   (Low Speed)     (High Speed)        (Low Speed)               (High Speed)
// --------------------------------------------------------------------------------------
//   7756 / 6032      7756 / 6014        07756: 6032  KCC          7756: 6014  RFC
//   7757 / 6031      7757 / 6011        07757: 6031  KSF          7757: 6011  RSF
//   7760 / 5357      7760 / 5357        07760: 5357  JMP  -1      7760: 5357  JMP 7757
//   7761 / 6036      7761 / 6016        07761: 6036  KRB          7761: 6016  RFC RRB
//   7762 / 7106      7762 / 7106        07762: 7106  CLL RTL      7762: 7106  CLL RTL
//   7763 / 7006      7763 / 7006        07763: 7006  RTL          7763: 7006  RTL
//   7764 / 7510      7764 / 7510        07764: 7510  SPA          7764: 7510  SPA
//   7765 / 5357      7765 / 5374        07765: 5357  JMP 7757     7765: 5374  JMP 7757
//   7766 / 7006      7766 / 7006        07766: 7006  RTL          7766: 7006  RTL
//   7767 / 6031      7767 / 6011        07767: 6031  KSF          7767: 6011  RSF
//   7770 / 5367      7770 / 5367        07770: 5367  JMP  -1      7770: 5367  JMP 7767
//   7771 / 6034      7771 / 6016        07771: 6034  KRS          7771: 6016  RFC RRB
//   7772 / 7420      7772 / 7420        07772: 7420  SNL          7772: 7420  SNL
//   7773 / 3776      7773 / 3776        07773: 3776  DCA I 7776   7773: 3776  DCA I 7776
//   7774 / 3376      7774 / 3376        07774: 3376  DCA 7776     7774: 3376  DCA 7776
//   7775 / 5356      7775 / 5357        07775: 5356  JMP 7756     7775: 5357  JMP 7757
//   7776 / 0000      7776 / 0000        07776: 0000  AND 0        7776: 0000  AND 0
//   7777 / 0000      7777 / 0000        07777: 0000  AND 0        7777: 0000  AND 0
//
//
//
//
//    1             TITLE   "DEC STD RIM loader"
//    2             
//    3       7756  *7756               / standard starting address
//    4             
//    5 07756 6032  BEGIN,  KCC         / clear AC and flag
//    6 
//    7 07757 6031  MORE,   KSF         / skip if character available
//    8 07760 5357          JMP  -1     / wait for character
//    9                                 
//   10 07761 6036          KRB         / read buffer and clear flag
//   11 07762 7106          CLL RTL     / ch<8:1> in AC<2:9>
//   12 07763 7006          RTL         / ch<8:1> in AC<0:7>
//   13 07764 7510          SPA         / skip if not leader
//   14 07765 5357          JMP MORE    / jmp if leader seen
//   15 07766 7006          RTL         / ch<7> L, ch<6:1> in AC<0:5>
//   16                                 
//   17 07767 6031          KSF         / skip if character available
//   18 07770 5367          JMP  -1     / wait for character
//   19                                  
//   20 07771 6034          KRS         / IOR buffer into AC<6:11>
//   21 07772 7420          SNL         / check for address (L=1)
//   22 07773 3776          DCA I ADDR  / store data
//   23 07774 3376          DCA ADDR    / store address
//   24                                   
//   25 07775 5356          JMP BEGIN   / loop
//   26                                     
//   27 07776 0000  ADDR,   0           / address saved here
//   28             
