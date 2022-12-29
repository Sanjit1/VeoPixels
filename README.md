# VeoPixels
Veopixels, a library? package? collection? driver? idk... something for NeoPixels written in SystemVerilog.

## What is it?
I don't know what it is, but I will call it a library written in SystemVerilog to control WS2812 NeoPixels. 

<br> 

## Why?
Cuz I can.

<br>

## Modules
Module | Ports | Description
:---:|:---:|:---:
SingleBinaryEncoder | input **clk** - Clock: 50MHz <br> input [1:0] **data** - Binary Value including reset bit. <br> output **DO** - Encoded signal of data | We use this module to encode binary data into a [format](#formatting-data) that the WS2812 can understand. A reset bit is also included.
SingleLEDEncoder | input **clk** - Clock: 50MHz <br> input [23:0] **data** - RGB Data <br> input **clock1220** - Clock: 1220ns <br> input **sending_data** - This signal indicates whether data is being sent. <br> output **DO** - Encoded output of data to send to WS2812. <br> output [1:0] **binary** - Binary chunks of data. | This module breaks down the RGB data into 24 binary pulses of 1220ns each. Then it uses SingleBinaryEncoder to encode the binary data into a format that the WS2812 can understand and outputs it to the DO port.
MultipleLEDEncoder | parameter **LENGTH** - Number of LEDs in the strip <br> input **clk** - Clock: 50MHz <br> input [24*LENGTH-1:0] **strip** - RGB Data of the entire strip <br> input **clock1220** - Clock: 1220ns <br> input **sending_data** - Signal indicating whether data is being sent. <br> output **DO** - Encoded output of data that the WS2812 can understand. <br> output [1:0] **binary** - Binary chunks of data representing the entire length of the strip. | This module is used to encode RGB data of a multiple LEDs into a format that the WS2812 can understand.













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

0 code: `0.36us high, 0.86us low`

1 code: `0.69us high, 0.53us low`

Reset code: `29.28us low`

The 1 and 0 codes are used since they add to **1.22us**, which makes the data easier to encode, since it takes the same time to send either code. The reset code is the amount of time it takes to send 24 bits of data which is also easier to send. 

Instead of sending the data in the order of the datasheet, we will send it in the following order: `R7, R6, R5, R4, R3, R2, R1, R0, G7, G6, G5, G4, G3, G2, G1, G0, B7, B6, B5, B4, B3, B2, B1, B0`, since RGB is the most common color format. To set it to a GRB mode, we will just change the order of the data.

<br>

## Waves and Testbenches:
Refer to the testbench file: [tb_tester.sv](./tb_tester.sv)
for more information.

**Test 1**: SingleBinaryEncoder
```sv
    initial begin
        un_encoded_data = 0;
        #1220 un_encoded_data = 1;
        #1220 un_encoded_data = 0;
        #1220 un_encoded_data = 1;
        #1220 un_encoded_data = 1;
        #1220 un_encoded_data = 0;
        #1220 un_encoded_data = 0;
    end
    
    SingleBinaryEncoder SBE(clk, un_encoded_data, DO); 
```

SBE should encode un_encoded_data based on the [Our Sequence](#our-sequences) and output it to the DO port. Upon simulation, we get the following waveforms:

DO:
![Test 1 Sequence](./Waves/Test%201%20Sequence.png)

We can tell the test was successful by looking at the DO waveform. 

It is also worth observing in more close proximity:
![Test 1 Clock](./Waves/Test%201%20Clock.png)

