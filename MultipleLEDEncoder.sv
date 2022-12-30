module MultipleLEDEncoder #(parameter LENGTH = 10)( // Default length is 10 Pixels
    clk,
    strip,
    DO
    );

    // Inputs
    input clk;
    input reg [LENGTH * 24 - 1:0] strip; // 24 bits per pixel * LENGTH pixels

    // Outputs
    output reg DO;
    
    // Internal signals
    reg clock1220 = 0; // clock that cycles every 1220 nanoseconds. This is used to change the binary output
    reg [5:0] clock1220_counter = 60; // counter to update the clock1220. 1220/20 = 61. Therefore we need 6 bits to count to 61
    always @(posedge clk) begin
        clock1220_counter <= clock1220_counter + 1;
        if (clock1220_counter == 60) begin
            clock1220_counter <= 0;
            clock1220 <= 1;
        end
        else begin
            clock1220 <= 0;
        end
    end

    reg sending_data;
    reg [23:0] uncoded_24_bit;
    reg [23:0] temp_24_bit;
    reg clock29280 = 0;
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
    reg [LENGTH_BITS-1:0] current_pixel = 0; 

    // At posedge of clock29280, send one pixel
    // if we are from 0 to LENGTH-1, send the pixel and set sending_data to 1
    // if we are at LENGTH, set sending_data to 0 and reset current_pixel to 0
    always @(posedge clock29280) begin
        if (current_pixel < LENGTH) begin
            temp_24_bit = strip[current_pixel * 24 +: 24];
            // These are flipped because the strip is sent in reverse order
            // it is also in green, red, blue order so we need to flip it to red, green, blue
            for (int i = 0; i < 8; i = i + 1) begin
                // red
                uncoded_24_bit[i] <= temp_24_bit[15 - i];
                // green
                uncoded_24_bit[i + 8] <= temp_24_bit[23 - i];
                // blue
                uncoded_24_bit[i + 16] <= temp_24_bit[7 - i];    
            
            end // There is definitely a better way to do this, but I spent an hour trying to do it without temp_24_bit so well.
            sending_data <= 1;
            current_pixel <= current_pixel + 1;
        end
        else if (current_pixel < LENGTH + 10) begin
            sending_data <= 0;
            current_pixel <= current_pixel + 1;
        end
        else begin
            current_pixel <= 0;
        end
    end

    // Wire up single LED encoder
    SingleLEDEncoder SLE(clk, uncoded_24_bit, sending_data, DO);
    

endmodule