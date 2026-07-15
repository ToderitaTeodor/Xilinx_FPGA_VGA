module vga_image_display #(
    parameter H_ACTIVE  = 1920,
    parameter H_F_PORCH = 88 ,
    parameter H_SYNC    = 44 ,
    parameter H_B_PORCH = 148 ,

    parameter V_ACTIVE  = 1080,
    parameter V_F_PORCH = 4 ,
    parameter V_SYNC    = 5  ,
    parameter V_B_PORCH = 36
)(    
    input              clk_i  ,
    input              rst_ni ,

    input logic [1:0]  sw     ,

    input logic [11:0]  h_counter,
    input logic [11:0]  v_counter,
    input logic        video_active,

    output logic [3:0] red_o  ,
    output logic [3:0] green_o,
    output logic [3:0] blue_o 
);

localparam H_TOTAL = H_ACTIVE + H_F_PORCH + H_SYNC + H_B_PORCH;
localparam V_TOTAL = V_ACTIVE + V_F_PORCH + V_SYNC + V_B_PORCH;

// End of line indicator calculat intern
logic h_last = (h_counter == H_TOTAL - 1);
logic v_last = (v_counter == V_TOTAL - 1);

// Signals for bounce logic
logic [11:0] obj_x;              // object x coordinates
logic [11:0] obj_y;              // object y coordinates

logic       dir_x;              // moving direction on x (0 - right, 1 - left)
logic       dir_y;              // moving direction on y (0 - down, 1 - up)         

// Object half size
localparam SQUARE_HALF_SIZE = 50;

// Change animation speed
logic [1:0] speed_step = (sw[0]) ? 3 : 1;

// Bounding box condition to determine if the current beam coordinates fall within the square area.
logic is_square = ((h_counter >= (obj_x - SQUARE_HALF_SIZE)) & (h_counter < (obj_x + SQUARE_HALF_SIZE)) & 
                  (v_counter >= (obj_y - SQUARE_HALF_SIZE)) & (v_counter < (obj_y + SQUARE_HALF_SIZE)));

// Color output logic
always_comb begin
    red_o   = 4'h0;
    green_o = 4'h0;
    blue_o  = 4'h0;
    if (video_active) begin
        if (is_square) begin
            if (sw[1]) begin
                red_o   = 4'h0;
                green_o = 4'hF;
                blue_o  = 4'hF;
            end else begin
                red_o   = 4'hF;
                green_o = 4'hF;
                blue_o  = 4'h0;
            end
        end else begin
            red_o   = 4'hF;
            green_o = 4'h0;
            blue_o  = 4'h0;
        end
    end
end

// Object X position logic
always_ff @(posedge clk_i or negedge rst_ni) begin
if(!rst_ni)          obj_x <= H_ACTIVE / 2; else
if(h_last && v_last) obj_x <= (!dir_x) ? (obj_x + speed_step) : (obj_x - speed_step);
end

// Object Y position logic
always_ff @(posedge clk_i or negedge rst_ni) begin
if(!rst_ni)          obj_y <= V_ACTIVE / 2; else
if(h_last && v_last) obj_y <= (!dir_y) ? (obj_y + speed_step) : (obj_y - speed_step);
end

// X direction bounce logic
always_ff @(posedge clk_i or negedge rst_ni) begin
if(!rst_ni)                                             dir_x <= 0; else
if((obj_x + SQUARE_HALF_SIZE + speed_step) >= H_ACTIVE) dir_x <= 1; else
if(obj_x <= (SQUARE_HALF_SIZE + speed_step))            dir_x <= 0;
end

// Y direction bounce logic 
always_ff @(posedge clk_i or negedge rst_ni) begin
if(!rst_ni)                                             dir_y <= 0; else
if((obj_y + SQUARE_HALF_SIZE + speed_step) >= V_ACTIVE) dir_y <= 1; else
if(obj_y <= (SQUARE_HALF_SIZE + speed_step))            dir_y <= 0;
end

endmodule