module Paddle(
    input clk,                    // Clock input
    input reset,                  // Reset signal
    input new_event,              // Mouse event signal
    input [11:0] x_position,      // X position from mouse
    input [5:0] current_pixel_y,  // Current Y being drawn
    input [6:0] current_pixel_x,  // Current X being drawn
    output [6:0] paddle_x_pos,    // Paddle X position (for game logic)
    output paddle_pixel           // Whether to draw paddle at current pixel
);
    
    // Module parameters
    parameter PADDLE_WIDTH = 14;
    parameter PADDLE_HEIGHT = 3;
    parameter RESET_POSITION = 48 - (PADDLE_WIDTH/2);
    parameter MOUSE_SENSITIVITY_DIVIDER = 16;
    parameter X_BOUNDARY = 96;
    parameter Y_BOUNDARY = 64;
    parameter PADDLE_OFFSET_BOUNDARY = (X_BOUNDARY - PADDLE_WIDTH) * MOUSE_SENSITIVITY_DIVIDER;
    
    // Paddle position register
    reg [6:0] paddle_x = RESET_POSITION;
    
    // Update paddle position based on mouse events
    always @(posedge clk) begin
        if (reset) begin
            paddle_x <= RESET_POSITION;
        end else if (new_event) begin
            // Keep paddle within screen boundaries
            if (x_position <= PADDLE_OFFSET_BOUNDARY)
                paddle_x <= x_position / MOUSE_SENSITIVITY_DIVIDER;
            else
                paddle_x <= X_BOUNDARY - PADDLE_WIDTH;
        end
    end
    
    // Determine if current pixel is part of the paddle
    assign paddle_pixel = (current_pixel_y >= (Y_BOUNDARY - PADDLE_HEIGHT) && 
                         current_pixel_y < Y_BOUNDARY &&
                         current_pixel_x >= paddle_x && 
                         current_pixel_x < (paddle_x + PADDLE_WIDTH));
    
    // Output paddle position for game logic
    assign paddle_x_pos = paddle_x;
    
endmodule
