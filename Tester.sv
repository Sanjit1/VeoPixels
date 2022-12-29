// This is to test on the FPGA rather than on testbenches and simulations
// When we want to make this test using questa, we need to uncomment lines with // *
// `timescale 1ns/1ns // * 

module Tester(clk, DO);
    // output reg clk = 0; // 50 MHz clock // *
    input clk; // 50 MHz clock
    output reg DO;

    // clk = 50 MHz
    // always begin                // *
    //     #10 clk = ~clk;         // *
    // end                         // *

    reg [5:0] clock1220_counter = 0; // counter to update the clock1220. 1220/20 = 61. Therefore we need 6 bits to count to 61

    reg[1:0] binary_output = 0; 

    // always @(posedge clk) begin
    //     if (clock1220_counter == 0) begin
    //         clock1220 <= 1;
    //         clock1220_counter <= clock1220_counter + 1;
    //     end
    //     else if (clock1220_counter == 60) begin
    //         clock1220 <= 0;
    //         clock1220_counter <= 0;
    //     end 
    //     else begin
    //         clock1220 <= 0;
    //         clock1220_counter <= clock1220_counter + 1;
    //     end
    // end

    reg [4 * 24 - 1:0] strip; // 24 bits per LED, LENGTH LEDs
    // Lets try using Strip to turn on multiple LEDS
    initial begin // 240'h000000111111FF000000FF000000FFFFFF0000FFFFFF00FFFFFFFFFF7F00;
        // 0
        strip[23:00] = 24'hFF0000;
        // 1
        strip[47:24] = 24'h00FF00;
        // 2
        strip[71:48] = 24'h0000FF; // Red:
        // 3
        strip[95:72] = 24'hFFFFFF;
        // 4
        // strip[119:96] = 24'h0000FF;
        // 5
        // strip[143:120] = 24'hFFFF00;
        // 6
        // strip[167:144] = 24'h00FFFF;
        // 7
        // strip[191:168] = 24'hFF00FF;
        // 8
        // strip[215:192] = 24'hFFFFFF;
        // 9
        // strip[239:216] = 24'hFF7F00;
    end
    // Lets try it with 2 LEDS


    reg clock1220;
    reg sending_data;
    reg [23:0] uncoded_24_bit;
    reg clock29280;

    MultipleLEDEncoder #(.LENGTH(4)) S(clk, strip, DO, clock1220, clock29280, sending_data, uncoded_24_bit, binary_output);


endmodule