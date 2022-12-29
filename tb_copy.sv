`timescale 1ns/1ns
// This is a testbench
module tb_tester(clock, uncoded_data, uncoded_24_bit, clock1220, clock29280, DO, sending_data, binary);
    // We want to view DO on the waveform
    reg clk;
    output reg clock, DO;
    output reg [1:0] uncoded_data; 
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
        #10 clk = ~clk; // This is a 10ns clock = 100MHz
    end

    assign clock = clk; // I dont know why i did this lmfao.
	
    // actual testbench
    // We currently want to test the SingleBinaryEncoder

    
    // ? initial begin
    // ?     uncoded_data = 0;
    // ?     #1220 uncoded_data = 1;
    // ?     #1220 uncoded_data = 0;
    // ?     #1220 uncoded_data = 1;
    // ?     #1220 uncoded_data = 1;
    // ?     #1220 uncoded_data = 0;
    // ?     #1220 uncoded_data = 0;
    // ? end
    
    // ? SingleBinaryEncoder SBE(clk, uncoded_data, DO); // We want to test what happens to DO when we change uncoded_data
    // * It works! 

    // lets now test turning on one led to red using the SingleBinaryEncoder
    // To turn on one led to red, we need to send 00000000 11111111 00000000. (Rembember that I am using a GRB led)
    // ? initial begin
    // ?     uncoded_data = 0;
    // ?     #1220 uncoded_data = 0;
    // ?     #1220 uncoded_data = 0;
    // ?     #1220 uncoded_data = 0;
    // ?     #1220 uncoded_data = 0;
    // ?     #1220 uncoded_data = 0;
    // ?     #1220 uncoded_data = 0;
    // ?     #1220 uncoded_data = 0; // The first 8 bits for G
    // ?     #1220 uncoded_data = 1;
    // ?     #1220 uncoded_data = 1;
    // ?     #1220 uncoded_data = 1;
    // ?     #1220 uncoded_data = 1;
    // ?     #1220 uncoded_data = 1;
    // ?     #1220 uncoded_data = 1;
    // ?     #1220 uncoded_data = 1;
    // ?     #1220 uncoded_data = 1; // The second 8 bits for R
    // ?     #1220 uncoded_data = 0;
    // ?     #1220 uncoded_data = 0;
    // ?     #1220 uncoded_data = 0;
    // ?     #1220 uncoded_data = 0;
    // ?     #1220 uncoded_data = 0;
    // ?     #1220 uncoded_data = 0;
    // ?     #1220 uncoded_data = 0;
    // ?     #1220 uncoded_data = 0; // The third 8 bits for B
    // ?     #1220 uncoded_data = 2'b11; // This is the reset bit
    // ? end

    // ? SingleBinaryEncoder SBE(clk, uncoded_data, DO); // This test revealed a slight design flaw: We need to have a reset in the BinaryEncoder.
    // * It works! (at least on wave), it needs to be tested with an actual NeoPixel Strip. 

    // ? Lets now test using SingleLEDEncoder to turn on one led to red
    // ? initial begin
    // ?     // start with sending data = 0
    // ?     sending_data = 0;
    // ?     // set sending_data = 1
    // ?     sending_data = 1;
    // ?     // make uncoded_24_bit = 24'h00FF00 
    // ?     uncoded_24_bit = 24'h00FF00;
    // ?     // we need to wait for 1220ns per bit, so we need to wait for 1220*24ns = 29.28us
    // ?     #29280;
    // ?     // set sending_data = 0
    // ?     sending_data = 0;
    // ?     // wait for 25us
    // ?     #25000;

    // ? end

    // ? // uncoded_data is a 24 bit number, where the first 8 bits are for G, the second 8 bits are for R, the third 8 bits are for B, and the last 7 bits are for the reset bit.
    // ? // clock1220 is a reg with posedge every 1220ns 
    // ? // sending_data is a reg that is 1 when we are sending data and 0 when we are not sending data
    // ? // DO is the data line.
    // ? SingleLEDEncoder SLE(clk, uncoded_24_bit, clock1220, sending_data, DO, binary); 
    // * It works!, again it needs to be tested with an actual NeoPixel Strip.

    
    // Another nice thing to test is powering multiple Pixels at the same time, so lets test that
    // ? initial begin
    // ?     // set sending_data = 1: since we will start sending data.
    // ?     sending_data = 1;
    // ?     // make uncoded_24_bit = 24'h00FF00 
    // ?     uncoded_24_bit = 24'h00FF00;
    // ?     // we need to wait for 1220ns per bit, so we need to wait for 1220*24ns = 29.28us
    // ?     #29280;
    // ?     // at this point the data for the first Pixel should be sent, so we can send the next Pixel
    // ?     // we don't need to do anything to sending data, since it is already 1
    // ?     // make uncoded_24_bit = 24'hABCDEF // lets make this one fun, why not
    // ?     uncoded_24_bit = 24'h1bcdef;
    // ?     // we need to wait for 1220ns per bit, so we need to wait for 1220*24ns = 29.28us
    // ?     #29280;
    // ?     // To test more of these values, we simply use
    // ?     uncoded_24_bit = 24'hbdc345;
    // ?     #29280;
    // ?     uncoded_24_bit = 24'h1b4322;
    // ?     #29280;
    // ?     uncoded_24_bit = 24'h9bd942;
    // ?     #29280;
    // ?     // set sending_data = 0
    // ?     sending_data = 0;
    // ?     // wait for 25us
    // ?     #25000;
    // ? end // also note to self 23 != 24. thanks for wasting 30 minutes of my life.

    // ? SingleLEDEncoder SLE(clk, uncoded_24_bit, clock1220, sending_data, DO, binary);

    // ? // if this works then its a sufficient test of reusing the SingleLEDEncoder.
    // * It works!, dont think i need to say it again, but it needs to be tested with an actual NeoPixel Strip.
    
    // ? reg [4 * 24 - 1:0] strip; // 24 bits per LED, LENGTH LEDs
    // ? // Lets try using Strip to turn on multiple LEDS
    // ? initial begin
    // ?     // set the first 24 bits to 24'h00FF00
    // ?     strip[23:0] = 24'h00FF00;
    // ?     // set the second 24 bits to 24'hFF00FF
    // ?     strip[47:24] = 24'hFF00FF;
    // ?     // set the third 24 bits to 24'hBDC345
    // ?     strip[71:48] = 24'hBDC345;
    // ?     // set the fourth 24 bits to 24'h1B4322
    // ?     strip[95:72] = 24'h1B4322;  
    // ?     // The module should do all the work.
    // ?     // DO *should* automatically be set to 0 when sending_data is 0 but if not we can do that here.
    // ?     // There should automatically be a delay after that.        
    // ? end
    // ? // Lets try it with 2 LEDS
    // ? MultipleLEDEncoder #(.LENGTH(4)) S(clk, strip, DO, clock1220, clock29280, sending_data, uncoded_24_bit, binary);
    // * It works! Again... yea.
    
    
endmodule
