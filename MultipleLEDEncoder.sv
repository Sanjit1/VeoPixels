module MultipleLEDEncoder #(parameter LENGTH = 10)(clk, strip, DO, clock1220, clock29280, sending_data, uncoded_24_bit, binary); // Default length is 300 LEDs
    // Inputs
    input clk;
    input reg [LENGTH * 24 - 1:0] strip; // 24 bits per LED, LENGTH LEDs

    // Outputs
    output reg DO;
    output reg clock1220;
    output reg sending_data;
    output reg [23:0] uncoded_24_bit;
    output reg [1:0] binary;
    output reg clock29280 = 0;
    reg [4:0] clock29280_counter = 23; // Since 29280 can be divided by 1220, we can use the same clock for both. 29280/1220 = 24, therefore the number of bits we need to count 24 cycles is 5 bits.
    
    // To send one Pixel, we need to send 24 bits of data
    // it takes 29.28us = 29280ns 
    // make a clock that triggers every 29280ns
    // using the clock that triggers every 1220ns, make clock29280 posedge every 29280ns
    always @(posedge clock1220) begin
        clock29280_counter <= clock29280_counter + 1;
        if (clock29280_counter == 23) begin
            clock29280_counter <= 0;
            clock29280 <= 1;
        end
        else begin
            clock29280 <= 0;
        end
    end
    
    // at each clock29280 posedge, send one pixel, at the end of the strip we reset the counter
    
    parameter LENGTH_BITS = $clog2(LENGTH + 10); // + 1 because we need the reset bit included.
    reg [LENGTH_BITS-1:0] current_led = 0; 

    // At posedge of clock29280, send one pixel
    // if we are from 0 to LENGTH-1, send the pixel and set sending_data to 1
    // if we are at LENGTH, set sending_data to 0 and reset current_led to 0
    always @(posedge clock29280) begin
        if (current_led < LENGTH) begin
            uncoded_24_bit <= strip[LENGTH * 24 - 1 - current_led * 24 -: 24];
            // the problem with this is that this is taking it in the wrong order
            // the correct way is 
            sending_data <= 1;
            current_led <= current_led + 1;
        end
        else if (current_led < LENGTH + 10) begin
            sending_data <= 0;
            current_led <= current_led + 1;
        end
        else begin
            current_led <= 0;
        end
    end

    // Wire up single LED encoder
    SingleLEDEncoder SLE(clk, uncoded_24_bit, clock1220, sending_data, DO, binary);

    

endmodule