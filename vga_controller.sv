module vga_controller #(
    parameter H_ACTIVE  = 640,
    parameter H_F_PORCH = 16 ,
    parameter H_SYNC    = 96 ,
    parameter H_B_PORCH = 48 ,

    parameter V_ACTIVE  = 480,
    parameter V_F_PORCH = 10 ,
    parameter V_SYNC    = 2  ,
    parameter V_B_PORCH = 33 
)(    
    input              clk_i  ,
    input              rst_ni ,

    output logic       hsync_o,
    output logic       vsync_o,

    output logic [3:0] red_o  ,
    output logic [3:0] green_o,
    output logic [3:0] blue_o 
);

localparam SQUARE_SIZE = 50;

localparam H_TOTAL    = H_ACTIVE + H_F_PORCH + H_SYNC + H_B_PORCH;
localparam V_TOTAL    = V_ACTIVE + V_F_PORCH + V_SYNC + V_B_PORCH;

localparam H_SYNC_START = H_ACTIVE + H_F_PORCH;
localparam H_SYNC_END   = H_ACTIVE + H_F_PORCH + H_SYNC;

localparam V_SYNC_START = V_ACTIVE + V_F_PORCH;
localparam V_SYNC_END   = V_ACTIVE + V_F_PORCH + V_SYNC;

logic [9:0] obj_x;
logic [9:0] obj_y;
logic       dir_x;
logic       dir_y;

// Internal counters
reg [$clog2(H_TOTAL)-1:0] h_counter;
reg [$clog2(V_TOTAL)-1:0] v_counter;

// Draw a square 
logic is_square = (h_counter >= obj_x - SQUARE_SIZE & h_counter < obj_x + SQUARE_SIZE & 
                  v_counter >= obj_y - SQUARE_SIZE & v_counter < obj_y + SQUARE_SIZE);

// End of line indicator
wire h_last = (h_counter == H_TOTAL - 1);
wire v_last = (v_counter == V_TOTAL - 1);

// Active low sync pulse generation
assign hsync_o = ~((h_counter >= H_SYNC_START) &
                   (h_counter <  H_SYNC_END));

assign vsync_o = ~((v_counter >= V_SYNC_START) &
                   (v_counter <  V_SYNC_END));

// Visible screen area detection (disabled during reset)
wire video_active = (h_counter < H_ACTIVE) & (v_counter < V_ACTIVE) & rst_ni;

// Color output logic
assign red_o   = (video_active) ? 4'hF : 4'h0;
assign green_o = (video_active && is_square) ? 4'hF : 4'h0;
assign blue_o  = (video_active) ? 4'h0 : 4'h0;


// Object X position logic
always_ff @(posedge clk_i or negedge rst_ni) begin
if(!rst_ni)          obj_x <= H_ACTIVE / 2; else
if(h_last && v_last) obj_x <= (!dir_x) ? obj_x + 1 : obj_x - 1;
end

// Object Y position logic
always_ff @(posedge clk_i or negedge rst_ni) begin
if(!rst_ni)          obj_y <= V_ACTIVE / 2; else
if(h_last && v_last) obj_y <= (!dir_y) ? obj_y + 1 : obj_y - 1;
end

// X direction bounce logic
always_ff @(posedge clk_i or negedge rst_ni) begin
if(!rst_ni)                           dir_x <= 0; else
if(obj_x + SQUARE_SIZE >= H_ACTIVE-1) dir_x <= 1; else
if(obj_x <= SQUARE_SIZE)              dir_x <= 0;
end

// Y direction bounce logic
always_ff @(posedge clk_i or negedge rst_ni) begin
if(!rst_ni)                           dir_y <= 0; else
if(obj_y + SQUARE_SIZE >= V_ACTIVE-1) dir_y <= 1; else
if(obj_y <= SQUARE_SIZE)              dir_y <= 0;
end


// Horizontal counter logic
always_ff @(posedge clk_i or negedge rst_ni) begin
if(!rst_ni) h_counter <= 0; else
if(h_last)  h_counter <= 0; else
            h_counter <= h_counter + 1;
end

// Vertical counter logic
always_ff @(posedge clk_i or negedge rst_ni) begin
if(!rst_ni)          v_counter <= 0; else 
if(h_last && v_last) v_counter <= 0; else
if(h_last)           v_counter <= v_counter + 1;
end

endmodule