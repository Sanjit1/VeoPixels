`timescale 1ns/1ns
// This is a testbench
module tb_tester(clock, un_encoded_data, uncoded_24_bit, clock1220, clock29280, DO, sending_data, binary);
    // We want to view DO on the waveform
    reg clk;
    output reg clock, DO;
    output reg [1:0] un_encoded_data; 
    output reg [23:0] uncoded_24_bit; // This is the 24 bit number that we will send to the SingleLEDEncoder. The first 8 bits are for G, the second 8 bits are for R, the third 8 bits are for B, and the last 7 bits are for the reset bit.
    output reg clock1220; // this should be a reg with posedge every 1220ns
    output reg clock29280; // this should be a reg with posedge every 29280ns
    output reg sending_data; // this should be a reg that is 1 when we are sending data and 0 when we are not sending data

    // temporarily use binary
    output reg [1:0] binary; // this is the binary number that we will send to the SingleLEDEncoder. The first 8 bits are for G, the second 8 bits are for R, the third 8 bits are for B, and the last 7 bits are for the reset bit.

    // clock stuff
    initial begin
        clk = 1;
        #300001 $stop;
    end
    
    always begin
        #10 clk = ~clk; // This is a 10ns clock = 50MHz
    end

    assign clock = clk; // I don't know why I did this lmfao.

    // ^ Test 1
    // * Testing the SingleBinaryEncoder
    initial begin
        un_encoded_data = 0;
        #1220 un_encoded_data = 1;
        #1220 un_encoded_data = 0;
        #1220 un_encoded_data = 1;
        #1220 un_encoded_data = 1;
        #1220 un_encoded_data = 0;
        #1220 un_encoded_data = 0;
    end
    
    SingleBinaryEncoder SBE(clk, un_encoded_data, DO); // We want to test what happens to DO when we change un_encoded_data


endmodule
