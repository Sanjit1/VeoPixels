// This module will handle encoding binary data into waves
// if data is 0, we send 300ns high, 920ns low = 1220ns
// if data is 1, we send 800ns high, 420ns low = 1220ns
module SingleBinaryEncoder(
    clk, 
    data, 
    DO
    );

    // inputs
    input clk; // 50 MHz = 20 ns
    input [1:0] data; // 2 bits of data to include reset bit.

    // outputs
    output reg DO; // 1 bit of encoded data and set it to 1 to start.

    // internal signals
    reg [7:0] clk_count = 0; // we need to count from 0 to 128 -> 0 - 127 = 7 bits
    
    // initial state
    initial begin
        DO = 1'b1;
    end

    // main logic
    always @(posedge clk) begin // this happens every 20ns
        if (clk_count == 7'd122) begin // if we have reached the end of the 122th clock cycle
            clk_count = 0; // reset the clock count
        end
        if (data == 0) begin
            // send 300ns high, 920ns low
            if (clk_count < 7'd29) begin
                DO = 1'b1;
            end
            else begin
                DO = 1'b0;
            end
        end 
        else if (data == 1) begin
            // send 800ns high, 420ns low
            if (clk_count < 7'd79) begin
                DO = 1'b1;
            end
            else begin
                DO = 1'b0;      
            end
        end
        else begin
            DO = 1'b0;
        end
        clk_count = clk_count + 2; // We only add one because its a 50 MHz clock
    end

endmodule