// This is the testbench for the Veopixels
// The test in this module should work both in simulation and on the FPGA
// To use this with Questa, you will need to load the testbench and force a clock with a period of 20ns

module testbench(
    clk,
    // sending_data, // For Test 2: SingleLEDEncoder
    DO_cp,
    DO
    );

    // inputs
    input clk; // clk: clock input 50MHz (20ns period)

    // outputs
    output DO; // DO:  output from the Veopixels this
    output DO_cp;
    // output sending_data; // For Test 2: SingleLEDEncoder

    // internal signals
    reg clock1220 = 0; // clock1220: 1220ns clock 
    reg [5:0] clock1220_counter = 0; // counter: used to count up to 2^6=64
    wire DO_cp = DO; // We wire them together so that we can hook up one to the neopixel and the other to a logic analyzer

    always @(posedge clk) begin
        if (clock1220_counter == 60) begin
            clock1220_counter = 0;
        end
        else if (clock1220_counter == 0) begin
            clock1220 = 1;
            clock1220_counter = clock1220_counter + 1;
        end
        else begin
            clock1220 = 0;
            clock1220_counter = clock1220_counter + 1;
        end
    end

    // ^ Test 1: SingleBinaryEncoder
    // ? reg [1:0] un_encoded_data = 0; // un_encoded_data: input to the SingleBinaryEncoder
    // ? reg [2:0] counter = 0; // counter: used to count up to 2^3=8
    // ? always @(posedge clock1220) begin
    // ?     // Test sorta random values of un_encoded_data: 1011001
    // ?     counter = counter + 1;
    // ?     if (counter == 1) un_encoded_data = 1;
    // ?     else if (counter == 2) un_encoded_data = 0;
    // ?     else if (counter == 3) un_encoded_data = 1;
    // ?     else if (counter == 4) un_encoded_data = 1;
    // ?     else if (counter == 5) un_encoded_data = 0;
    // ?     else if (counter == 6) un_encoded_data = 0;
    // ?     else if (counter == 7) un_encoded_data = 1;
    // ?     else counter = 0;
    // ? end
    // ? 
    // ? SingleBinaryEncoder SBE(clk, un_encoded_data, DO); // We want to test what happens to DO when we change un_encoded_data
    // * It works!

    // ^ Test 2: SingleLEDEncoder
    // ? reg [23:0] data = 24'hFBAED2; // Lets use Lavender as our test color: 24'hFBAED2 = 11111011 10101110 11010010.
    // ? output reg sending_data; // sending_data: output from the SingleLEDEncoder
    // ? // To use this testbench with Questa, you will force the following signals:
    // ? // clk: 50MHz (20ns period)
    // ? // sending_data: test various values with 1220*24=29,280ns between each change.
    // ? // // Yes, I know that this is a lazy test.
    // ? SingleLEDEncoder SLE(clk, data, sending_data, DO);
    // * It works!
    
    // ^ Test 3: MultiLEDEncoder
    // ? reg [4 * 24 - 1 : 0] strip = 0; // strip: 5 colors of 24 bits each
    // ? initial begin // Lets encode Red, Green, Blue, White(101010) and Dim White(010101)
    // ?     strip[023:000] = 24'hFA0000;
    // ?     strip[047:024] = 24'h00FB00;
    // ?     strip[071:048] = 24'h0000FC;
    // ?     strip[095:072] = 24'hABCDEF;
    // ? end
    // ? // FA0000 = 00000000 11111010 00000000
    // ? // 00FB00 = 11111011 00000000 00000000
    // ? // 0000FC = 00000000 00000000 11111100
    // ? // ABCDEF = 11001101 10101011 11101111
    // ? // Remember R and G are swapped
    // ? MultipleLEDEncoder #(.LENGTH(4)) MLE(clk, strip, DO);
    // * It works!

    // ^ Test 4: Veopixels
    // ? reg [4 * 24 - 1 : 0] strip = 0; // strip: 4 colors of 24 bits each
    // ? initial begin // Lets encode Red, Green, Blue, White(101010) and Dim White(010101)
    // ?     strip[023:000] = 24'hFA0000;
    // ?     strip[047:024] = 24'h00FB00;
    // ?     strip[071:048] = 24'h0000FC;
    // ?     strip[095:072] = 24'hABCDEF;
    // ? end
    // ? // FA0000 = 00000000 11111010 00000000
    // ? // 00FB00 = 11111011 00000000 00000000
    // ? // 0000FC = 00000000 00000000 11111100
    // ? // ABCDEF = 11001101 10101011 11101111
    // ? // Remember R and G are swapped
    // ? Veopixels #(.LENGTH(4)) MLE(clk, strip, DO);
    // * It works! As pointless as this test is, it does work.

    // ^ Test 5: Chase
    reg [16 * 24 - 1 : 0] strip = 0; // strip: 5 colors of 24 bits each
    initial begin // Lets encode Red, Green, Blue, White(101010) and Dim White(010101)
        strip[023:000] = 24'hFA0000;
        strip[047:024] = 24'h00FB00;
        strip[071:048] = 24'h0000FC;
        strip[095:072] = 24'hABCDEF;
        strip[119:096] = 24'hFFFF00;
        strip[143:120] = 24'h000000;
        strip[167:144] = 24'h000000;
        strip[191:168] = 24'h000000;
        strip[215:192] = 24'h000000;
        strip[239:216] = 24'h000000;
        strip[263:240] = 24'h000000;
        strip[287:264] = 24'h000000;
        strip[311:288] = 24'h000000;
        strip[335:312] = 24'h000000;
        strip[359:336] = 24'h000000;
        strip[383:360] = 24'h000000;
    end
    Veopixels #(.LENGTH(16)) MLE(clk, strip, DO);

    // Use a clock divider to do stuff every 100ms = 100,000,000ns, or 100,000,000ns/20ns = 5,000,000
    reg [23:0] clock100ms = 0;
    reg [23:0] clock100ms_counter = 0;
    always @(posedge clk) begin
        if (clock100ms_counter == 2500000) begin
            clock100ms_counter = 0;
        end
        else if (clock100ms_counter == 0) begin
            clock100ms = 1;
            clock100ms_counter = clock100ms_counter + 1;
        end
        else begin
            clock100ms = 0;
            clock100ms_counter = clock100ms_counter + 1;
        end
    end

    reg [23:0] temp = 0;
    always @(posedge clock100ms) begin
        // shift the strip
        // set the temp to the last value
        temp = strip[16 * 24 - 1 : 16 * 24 - 24];
        // set the last pixel to the second to last pixel
        strip[16 * 24 - 1 : 16 * 24 - 24] = strip[16 * 24 - 24 - 1 : 16 * 24 - 48];
        // set the second to last pixel to the third to last pixel
        strip[16 * 24 - 24 - 1 : 16 * 24 - 48] = strip[16 * 24 - 48 - 1 : 16 * 24 - 72];
        // and so on
        strip[16 * 24 - 48 - 1 : 16 * 24 - 72] = strip[16 * 24 - 72 - 1 : 16 * 24 - 96];
        strip[16 * 24 - 72 - 1 : 16 * 24 - 96] = strip[16 * 24 - 96 - 1 : 16 * 24 - 120];
        strip[16 * 24 - 96 - 1 : 16 * 24 - 120] = strip[16 * 24 - 120 - 1 : 16 * 24 - 144];
        strip[16 * 24 - 120 - 1 : 16 * 24 - 144] = strip[16 * 24 - 144 - 1 : 16 * 24 - 168];
        strip[16 * 24 - 144 - 1 : 16 * 24 - 168] = strip[16 * 24 - 168 - 1 : 16 * 24 - 192];
        strip[16 * 24 - 168 - 1 : 16 * 24 - 192] = strip[16 * 24 - 192 - 1 : 16 * 24 - 216];
        strip[16 * 24 - 192 - 1 : 16 * 24 - 216] = strip[16 * 24 - 216 - 1 : 16 * 24 - 240];
        strip[16 * 24 - 216 - 1 : 16 * 24 - 240] = strip[16 * 24 - 240 - 1 : 16 * 24 - 264];
        strip[16 * 24 - 240 - 1 : 16 * 24 - 264] = strip[16 * 24 - 264 - 1 : 16 * 24 - 288];
        strip[16 * 24 - 264 - 1 : 16 * 24 - 288] = strip[16 * 24 - 288 - 1 : 16 * 24 - 312];
        strip[16 * 24 - 288 - 1 : 16 * 24 - 312] = strip[16 * 24 - 312 - 1 : 16 * 24 - 336];
        strip[16 * 24 - 312 - 1 : 16 * 24 - 336] = strip[16 * 24 - 336 - 1 : 16 * 24 - 360];
        strip[16 * 24 - 336 - 1 : 16 * 24 - 360] = strip[16 * 24 - 360 - 1 : 16 * 24 - 384];
        // set the first pixel to the temp
        strip[16 * 24 - 360 - 1 : 16 * 24 - 384] = temp;
    end

endmodule