module vga_image_display #(
    parameter H_ACTIVE = 1920,
    parameter V_ACTIVE = 1080
)(
    input  logic        clk_i,
    input  logic        rst_ni,

    input  logic [1:0]  sw,

    input  logic [8:0]  radius_i,      // Current circle radius
    input  logic [2:0]  heat_level_i,  // Current "heat level"

    input  logic [11:0] h_counter,     // Current horizontal pixel coordinate
    input  logic [11:0] v_counter,     // Current vertical pixel coordinate

    input  logic        video_active,  // Active display area signal

    output logic [3:0]  red_o,
    output logic [3:0]  green_o,
    output logic [3:0]  blue_o
);

    localparam CENTER_X = H_ACTIVE / 2;
    localparam CENTER_Y = V_ACTIVE / 2;

    logic [11:0] dx;          
    logic [11:0] dy;          
    logic [25:0] distance_sq; 
    logic [25:0] radius_sq;   

    // Calculul geometriei (neschimbat)
    assign dx = (h_counter >= CENTER_X) ? (h_counter - CENTER_X) : (CENTER_X - h_counter);
    assign dy = (v_counter >= CENTER_Y) ? (v_counter - CENTER_Y) : (CENTER_Y - v_counter);

    assign distance_sq = (dx * dx) + (dy * dy);
    assign radius_sq   = radius_i * radius_i;
    
    // Semnale temporare pentru culori
    logic [3:0] red_next, green_next, blue_next;

    always_comb begin
        red_next   = 4'h0;
        green_next = 4'h0;
        blue_next  = 4'h0;

        if (video_active && (radius_i != 9'd0) && (distance_sq <= radius_sq)) begin
            
            // Ring 1 
            if ((distance_sq < radius_sq / 5) && (heat_level_i >= 3'd4)) begin
                red_next   = 4'hD; 
                green_next = 4'h1;
                blue_next  = 4'h1;
            end
            // Ring 2 
            else if ((distance_sq < 2 * radius_sq / 5) && (heat_level_i >= 3'd3)) begin
                red_next   = 4'hC; 
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
                red_next   = 4'hB; 
                green_next = 4'h8;
                blue_next  = 4'h3;
            end
            // Ring 5
            else begin
                red_next   = 4'hA;
                green_next = 4'hA;
                blue_next  = 4'h5;
            end
            
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            red_o   <= 4'h0;
            green_o <= 4'h0;
            blue_o  <= 4'h0;
        end else begin
            red_o   <= red_next;
            green_o <= green_next;
            blue_o  <= blue_next;
        end
    end

endmodule