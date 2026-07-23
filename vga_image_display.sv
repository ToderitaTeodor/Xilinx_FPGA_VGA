module vga_image_display #(
    parameter H_ACTIVE = 640,
    parameter V_ACTIVE = 480
)(
    input  logic        clk_i       ,
    input  logic        rst_ni      ,

    input  logic [8:0]  radius_i    ,  // Current circle radius
    input  logic [2:0]  heat_level_i,  // Current heat level

    input  logic [11:0] h_counter   ,  // Current horizontal pixel
    input  logic [11:0] v_counter   ,  // Current vertical pixel

    input  logic        video_active,  // Active display region

    output logic [3:0]  red_o       ,
    output logic [3:0]  green_o     ,
    output logic [3:0]  blue_o       
);

// Circle center
localparam CENTER_X = H_ACTIVE / 2;
localparam CENTER_Y = V_ACTIVE / 2;

// Distance from the current pixel to the circle center
logic [11:0] dx;
logic [11:0] dy;
logic [25:0] distance_sq;
logic [25:0] radius_sq;

assign dx = (h_counter >= CENTER_X) ? (h_counter - CENTER_X) : (CENTER_X - h_counter);
assign dy = (v_counter >= CENTER_Y) ? (v_counter - CENTER_Y) : (CENTER_Y - v_counter);

assign distance_sq = (dx * dx) + (dy * dy);
assign radius_sq   = radius_i * radius_i;

logic [3:0] red_next, green_next, blue_next;

// Generate the pixel color
always_comb begin
    red_next   = 4'h0;
    green_next = 4'h0;
    blue_next  = 4'h0;

    if (video_active && (radius_i != 9'd0) && (distance_sq <= radius_sq)) begin

        // Inner ring
        if ((distance_sq < radius_sq / 5) && (heat_level_i >= 3'd4)) begin
            red_next   = 4'hD;
            green_next = 4'h2;
            blue_next  = 4'h1;
        end

        // Ring 2
        else if ((distance_sq < 2 * radius_sq / 5) && (heat_level_i >= 3'd3)) begin
            red_next   = 4'hD;
            green_next = 4'h4;
            blue_next  = 4'h1;
        end

        // Ring 3
        else if ((distance_sq < 3 * radius_sq / 5) && (heat_level_i >= 3'd2)) begin
            red_next   = 4'hC;
            green_next = 4'h6;
            blue_next  = 4'h2;
        end

        // Ring 4
        else if ((distance_sq < 4 * radius_sq / 5) && (heat_level_i >= 3'd1)) begin
            red_next   = 4'hC;
            green_next = 4'h8;
            blue_next  = 4'h2;
        end

        // Outer ring
        else begin
            red_next   = 4'hB;
            green_next = 4'hA;
            blue_next  = 4'h3;
        end
    end
end

// Register pixel color
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) red_o <= 4'h0; else 
                 red_o <= red_next;    
end

always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) green_o <= 4'h0; else 
                 green_o <= red_next;    
end

always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) blue_o <= 4'h0; else 
                 blue_o <= red_next;    
end

endmodule