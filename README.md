# VeoPixels
Veopixels, a library? package? collection? driver? idk... something for NeoPixels written in SystemVerilog.

<br>

## TOC
- [VeoPixels](#veopixels)
  - [TOC](#toc)
  - [Why?](#why)
  - [Modules](#modules)
  - [Formatting Data](#formatting-data)
    - [Binary Sequence:](#binary-sequence)
    - [Data Sequence:](#data-sequence)
    - [Our Sequences:](#our-sequences)
  - [Waves and Testbenches:](#waves-and-testbenches)
    - [Clocks](#clocks)
    - [Tests:](#tests)
      - [**Test 1**: SingleBinaryEncoder](#test-1-singlebinaryencoder)
      - [**Test 2**: SingleLEDEncoder](#test-2-singleledencoder)
      - [**Test 3**: MultipleLEDEncoder](#test-3-multipleledencoder)
      - [**Test 4**: Veopixels](#test-4-veopixels)
      - [**Test 5**: Chase](#test-5-chase)

## Why?
Cuz I can.

<br>

## Modules
Module | Ports | Description
:---:|:---:|:---:
SingleBinaryEncoder | input **clk** - Clock: 50MHz <br> input [1:0] **data** - Binary Value including reset bit. <br> output **DO** - Encoded signal of data | We use this module to encode binary data into a [format](#formatting-data) that the WS2812 can understand. A reset bit is also included.
SingleLEDEncoder | input **clk** - Clock: 50MHz <br> input [23:0] **data** - RGB Data <br> input **sending_data** - This signal indicates whether data is being sent. <br> output **DO** - Encoded output of data to send to WS2812. | This module breaks down the RGB data into 24 binary pulses of 1220ns each. Then it uses SingleBinaryEncoder to encode the binary data into a format that the WS2812 can understand and outputs it to the DO port.
MultipleLEDEncoder | parameter **LENGTH** - Number of LEDs in the strip <br> input **clk** - Clock: 50MHz <br> input [24*LENGTH-1:0] **strip** - RGB Data of the entire strip <br> output **DO** - Encoded output of data that the WS2812 can understand. | This module loops through the strip and sends the data to the SingleLEDEncoder module which outputs the encoded data to the DO port.
Veopixels | parameter **LENGTH** - Number of LEDs in the strip <br> input **clk** - Clock: 50MHz <br> input [24*LENGTH-1:0] **strip** - RGB Data of the entire strip <br> output **DO** - Encoded output of data that the WS2812 can understand. | This literally just wraps the MultipleLEDEncoder module. 











<br>

## Formatting Data
\**Note*: We will not be using this format entirely. We will be using a modified version of it. I will explain it after explaining the correct format.


Refering to the [WS2812 Datasheet](https://cdn-shop.adafruit.com/datasheets/WS2812.pdf), we can see that the WS2812 expects a single data line:
### Binary Sequence:

0 Code: `0.35us high, 0.8us low`

1 Code: `0.7us high, 0.6us low`

Reset Code: `50us low`

### Data Sequence:
For each LED, we send 24 bits of data, followed by a reset code after the last LED.
We send the data in the following order:  `G7, G6, G5, G4, G3, G2, G1, G0, R7, R6, R5, R4, R3, R2, R1, R0, B7, B6, B5, B4, B3, B2, B1, B0`

### Our Sequences:
For our binary sequences we use the following:

0 code: `0.3us high, 0.92us low`

1 code: `0.8us high, 0.42us low`

Reset code: `292.8us low`

The 1 and 0 codes are used since they add to **1.22us**, which makes the data easier to encode, since it takes the same time to send either code. The reset code is the amount of time it takes to send 10 pixels of data, which is easier to implement and still quite fast.

Instead of sending the data in the order of the datasheet, we will send it in the following order: `R7, R6, R5, R4, R3, R2, R1, R0, G7, G6, G5, G4, G3, G2, G1, G0, B7, B6, B5, B4, B3, B2, B1, B0`, since RGB is the most common color format. To set it to a GRB mode, we will just change the order of the data.

<br>

## Waves and Testbenches:
Refer to the testbench file: [testbench.sv](./testbench.sv)
for more information.
To run these testbenches, you will need to add a 50MHz clock to clk in your simulator. For questa, you can do that with the command `force -freeze sim:/testbench/clk 1 0, 0 {10 ns} -r 20`, or simply adding a clock with a period of 20ns.

<br>

### Clocks
We use various clocks in our testbenches. The clocks are as follows:
 - ``clk``: 50MHz clock: $\frac12$ duty cycle: This represents the actual clock on the FPGA.
 - ``clock1220``: 1220ns clock: $\frac1{61}$ duty cycle: During the period of each clock1220, a single bit of data is sent to the WS2812. The duty cycle is not important but is easier to implement.

Implementation of the clock1220 clock: Note that we start the clock at 1, to synchronize it with the SingleBinaryEncoder module. If this is not done, binary data will be sent out of phase with the SingleBinaryEncoder which will cause the SingleBinaryEncoder to fail.
```sv
reg clock1220 = 0; // clock1220: 1220ns clock 
reg [5:0] clock1220_counter = 0; // counter: used to count up to 2^6=64
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
```

<br>

### Tests:
#### **Test 1**: SingleBinaryEncoder
```sv
reg [1:0] un_encoded_data = 0; // un_encoded_data: input to the SingleBinaryEncoder
reg [2:0] counter = 0; // counter: used to count up to 2^3=8
always @(posedge clock1220) begin
    // Test sorta random values of un_encoded_data: 1011001
    counter = counter + 1;
    if (counter == 1) un_encoded_data = 1;
    else if (counter == 2) un_encoded_data = 0;
    else if (counter == 3) un_encoded_data = 1;
    else if (counter == 4) un_encoded_data = 1;
    else if (counter == 5) un_encoded_data = 0;
    else if (counter == 6) un_encoded_data = 0;
    else if (counter == 7) un_encoded_data = 1;
    else counter = 0;
end
SingleBinaryEncoder SBE(clk, un_encoded_data, DO);
```
Use `run 8540` to simulate 1220*7=8540ns.
SBE should encode un_encoded_data based on the [Our Sequence](#our-sequences) and output it to the DO port. Upon simulation, we get the following waveforms:


Observing DO and clk:


![Test 1](./Waves/Test%201.png)


If we look at the waveform we see 1011001 being sent out. 


Zooming in:


![Test 1 Zoomed](./Waves/Test%201%20zoomed.png)


Zooming in gives us a better look at the one bit and the zero bit. We can see that the one bit is 0.8us high and 0.42us low, and the zero bit is 0.3us high and 0.92us low. This is correct. Each bit is 1.22us long, which is correct. Furthermore the clock is visible and 20ns long, which is correct.






<br>












#### **Test 2**: SingleLEDEncoder
```sv
reg [23:0] data = 24'hFBAED2; // Lets use Lavender as our test color: 24'hFBAED2 = 11111011 10101110 11010010.
output reg sending_data; // sending_data: output from the SingleLEDEncoder
// To use this testbench with Questa, you will force the following signals:
// clk: 50MHz (20ns period)
// sending_data: test various values with 1220*24=29,280ns between each change.
// // Yes, I know that this is a lazy test.
SingleLEDEncoder SLE(clk, data, sending_data, DO);
```

Using the instructions to view the waveforms.


Observing DO:


![Test 2](./Waves/Test%202.png)


Observing the waves, we can see that there are 24 bits: `01001011 01110101 11011111`. This is the reverse of `#FBAED2`, which is not *particularly* wrong. We can work with this, and correct this in MultipleLEDEncoder.


Observing sending_data:


![Test 2 sending_data](./Waves/Test%202%20sending%20data.png)


As observed, sending_data controls wether a signal is sent or not. This is correct.





<br>




#### **Test 3**: MultipleLEDEncoder
```sv
reg [4 * 24 - 1 : 0] strip = 0; // strip: 5 colors of 24 bits each
initial begin // Lets encode Red, Green, Blue, White(101010) and Dim White(010101)
    strip[023:000] = 24'hFA0000;
    strip[047:024] = 24'h00FB00;
    strip[071:048] = 24'h0000FC;
    strip[095:072] = 24'hABCDEF;
end
// FA0000 = 00000000 11111010 00000000
// 00FB00 = 11111011 00000000 00000000
// 0000FC = 00000000 00000000 11111100
// ABCDEF = 11001101 10101011 11101111
// Remember R and G are swapped
MultipleLEDEncoder #(.LENGTH(4)) MLE(clk, strip, DO);
```

This time we test it on the testbench and the FPGA.


Observing DO:


![Test 3](./Waves/Test%203.png)


Zooming in:


![Test 3 Zoomed](./Waves/Test%203%20zoomed.png)

These are a bit hard to look at but when we pay attention to DO, it is correct!


<br>


#### **Test 4**: Veopixels
```sv
reg [4 * 24 - 1 : 0] strip = 0; // strip: 4 colors of 24 bits each
initial begin // Lets encode Red, Green, Blue, White(101010) and Dim White(010101)
    strip[023:000] = 24'hFA0000;
    strip[047:024] = 24'h00FB00;
    strip[071:048] = 24'h0000FC;
    strip[095:072] = 24'hABCDEF;
end
// FA0000 = 00000000 11111010 00000000
// 00FB00 = 11111011 00000000 00000000
// 0000FC = 00000000 00000000 11111100
// ABCDEF = 11001101 10101011 11101111
// Remember R and G are swapped
Veopixels #(.LENGTH(4)) MLE(clk, strip, DO);
```

This time we just test on the FPGA, and it works.


<br>


#### **Test 5**: Chase
```sv
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
```
This time we just test on the FPGA, and it works: its beautiful.
![Chase](./Waves/Chase.gif)