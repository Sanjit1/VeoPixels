// This is to test on the FPGA rather than on testbenches and simulations

module Tester(clk, DO);
    input clk; // 50 MHz clock
    output reg DO;
    
    // ^ Test 1
    // 1 Pixel Test
    reg [24*2-1:0] strip; 

    initial begin
        strip[23:0] = 24'hABCD00; 
        strip[47:23] = 24'h00ABCD; 
    end

    // Registers for MLE
    reg clock1220;
    reg clock29280;
    reg sending_data;
    reg [23:0] uncoded_24_bit;
    reg [1:0] binary;
    MultipleLEDEncoder #(.LENGTH(2)) MLE(clk, strip, DO, clock1220, clock29280, sending_data, uncoded_24_bit, binary);

endmodule