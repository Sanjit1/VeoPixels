// This has the main module of the *library* and some helper modules.
module Veopixels #(parameter LENGTH = 10)( // Default length is 10 Pixels
    clk,
    strip,
    DO
    );
    // inputs
    input clk;
    input reg [LENGTH * 24 - 1:0] strip; // 24 bits per pixel * LENGTH pixels

    // outputs
    output reg DO;

    // Yes this is basically a wrapper for the encoder.
    MultipleLEDEncoder #(.LENGTH(LENGTH)) encoder(clk, strip, DO);

endmodule
