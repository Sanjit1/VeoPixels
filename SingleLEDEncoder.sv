// This module takes in RGB data input and use the SingleBitEncoder module to convert it to a data line output.
module SingleLEDEncoder(
    clk,
    data,
    sending_data,
    DO
    );
    
    // Inputs
    input clk; // 50MHz clock
    input sending_data; // 1 if we are sending data, 0 if we are not
    input [23:0] data; // for the RGB data


    // Outputs
    output DO; // data line output
    reg clock1220 = 0; // clock that cycles every 1220 nanoseconds. This is used to change the binary output

    // Internal signals
    reg [23:0] clk_counter = 0; // counter to keep track of the data we are sending
    reg [1:0] binary; // binary output 2 bits to include reset

    reg [5:0] clock1220_counter = 60; // counter to update the clock1220. 1220/20 = 61. Therefore we need 6 bits to count to 61

    // we can only send data every 1220 nanoseconds. So every 1220 nanoseconds, we change the binary output
    // make a clock with posedge every 1220 nanoseconds.
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

    // main logic
    // at the edge of the clock1220, we change the binary output and use clk_counter to keep track of the data we are sending
    always @(posedge clock1220) begin
        if (sending_data) begin
           if (clk_counter == 23) begin
                clk_counter <= 0;
            end
            else begin
                clk_counter <= clk_counter + 1;
            end
            binary <= data[clk_counter];
        end
        else begin
            binary <= 2'b11;
        end
    end

    // Wire everything up
    SingleBinaryEncoder SBE(clk, binary, DO);

endmodule