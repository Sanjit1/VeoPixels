// This has the main module of the *library* and some helper modules.
module Veopixels #(parameter LENGTH = 10)( // Default length is 10 Pixels
    clk,
    strip,
    DO
    );

    // Yes this is basically a wrapper for the encoder.
    MultipleLEDEncoder #(LENGTH(LENGTH)) encoder(clk, strip, DO);

endmodule