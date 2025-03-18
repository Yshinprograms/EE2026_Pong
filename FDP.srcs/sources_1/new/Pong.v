`timescale 1ns / 1ps

module Pong(
    input clk_100MHz,
    input btnC,
    inout PS2Clk,
    inout PS2Data,
    output [7:0] JC
    );
    wire clk_6p25MHz;
    Clock_Divider divider_6p25MHz (clk_100MHz, 7, clk_6p25MHz);

    // OLED signals
    wire [15:0] oled_data;
    wire [12:0] pixel_index;
    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    // Extract x and y coordinates from pixel_index
    wire [6:0] pixel_x = pixel_index % 96;
    wire [5:0] pixel_y = pixel_index / 96;    
    // Instantiate the OLED display module
    Oled_Display oled_display(
        .clk(clk_6p25MHz),
        .reset(btnC),
        .frame_begin(frame_begin),
        .sending_pixels(sending_pixels),
        .sample_pixel(sample_pixel),
        .pixel_index(pixel_index),
        .pixel_data(oled_data),
        .cs(JC[0]),
        .sdin(JC[1]),
        .sclk(JC[3]),
        .d_cn(JC[4]),
        .resn(JC[5]),
        .vccen(JC[6]),
        .pmoden(JC[7])
    );    
    
    // Mouse signals
    wire left, middle, right;
    wire [11:0] xpos, ypos;
    wire [3:0] zpos;
    wire new_event;
    parameter MOUSE_SENSITIVITY_DIVIDER = 16;
    parameter X_BOUNDARY = 96;
    parameter Y_BOUNDARY = 64;
    parameter SCALED_X_BOUNDARY = (X_BOUNDARY * MOUSE_SENSITIVITY_DIVIDER) - 1;
    
    MouseCtl mouse_control (
        .clk(clk_100MHz), .rst(1'b0),
        .value(SCALED_X_BOUNDARY),
        .setx(1'b0), .sety(1'b0), .setmax_x(1'b1), .setmax_y(1'b0),
        .xpos(xpos), .ypos(ypos), .zpos(zpos),
        .left(left), .right(right), .middle(middle),
        .new_event(new_event),
        .ps2_clk(PS2Clk), .ps2_data(PS2Data)
    );
    
    // Paddle signals
    wire paddle_pixel;
    wire [6:0] paddle_x_pos;
    
    // Instantiate the paddle module
    Paddle #(
        .MOUSE_SENSITIVITY_DIVIDER()
    )
    paddle_instance(
        .clk(clk_100MHz),
        .reset(btnC),
        .new_event(new_event),
        .x_position(xpos),
        .current_pixel_y(pixel_y),
        .current_pixel_x(pixel_x),
        .paddle_x_pos(paddle_x_pos),
        .paddle_pixel(paddle_pixel)
    );
    
    // Determine pixel color based on paddle position
    assign oled_data = paddle_pixel ? 16'hFFFF : 16'h0000;

endmodule
