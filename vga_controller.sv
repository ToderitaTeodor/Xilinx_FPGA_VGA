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

localparam H_TOTAL    = H_ACTIVE + H_F_PORCH + H_SYNC + H_B_PORCH;
localparam V_TOTAL    = V_ACTIVE + V_F_PORCH + V_SYNC + V_B_PORCH;

localparam H_SYNC_START = H_ACTIVE + H_F_PORCH;
localparam H_SYNC_END   = H_ACTIVE + H_F_PORCH + H_SYNC;

localparam V_SYNC_START = V_ACTIVE + V_F_PORCH;
localparam V_SYNC_END   = V_ACTIVE + V_F_PORCH + V_SYNC;


// Internal counters
reg [$clog2(H_TOTAL)-1:0] h_counter;
reg [$clog2(V_TOTAL)-1:0] v_counter;

// Draw a square in the middle of the screen
logic is_square = (h_counter >= 250 & h_counter < 390 & v_counter >= 170 & v_counter < 310);

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



// Horizontal counter logic
always @(posedge clk_i or negedge rst_ni) begin
if(!rst_ni) h_counter <= 0; else
if(h_last)  h_counter <= 0; else
            h_counter <= h_counter + 1;
end

// Vertical counter logic
always @(posedge clk_i or negedge rst_ni) begin
if(!rst_ni)          v_counter <= 0; else 
if(h_last && v_last) v_counter <= 0; else
if(h_last)           v_counter <= v_counter + 1;
end

endmodule