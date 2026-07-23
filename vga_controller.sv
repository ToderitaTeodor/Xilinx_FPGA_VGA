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
    input              clk_i,
    input              rst_ni,

    output logic       hsync_o,
    output logic       vsync_o,
    
    output logic       frame_tick_o,

    output logic [11:0] h_count_o,
    output logic [11:0] v_count_o,

    output logic       video_active_o
);

localparam H_TOTAL    = H_ACTIVE + H_F_PORCH + H_SYNC + H_B_PORCH;
localparam V_TOTAL    = V_ACTIVE + V_F_PORCH + V_SYNC + V_B_PORCH;

localparam H_SYNC_START = H_ACTIVE + H_F_PORCH;
localparam H_SYNC_END   = H_ACTIVE + H_F_PORCH + H_SYNC;

localparam V_SYNC_START = V_ACTIVE + V_F_PORCH;
localparam V_SYNC_END   = V_ACTIVE + V_F_PORCH + V_SYNC;

// End of line indicator
logic h_last = (h_count_o == H_TOTAL - 1);
logic v_last = (v_count_o == V_TOTAL - 1);

// Generates the horizontal synchronization pulse required to signal the end of a line scan.
assign hsync_o = ~((h_count_o >= H_SYNC_START) &
                   (h_count_o <  H_SYNC_END));

// Generates the vertical synchronization pulse required to signal the end of a frame scan.
assign vsync_o = ~((v_count_o >= V_SYNC_START) &
                   (v_count_o <  V_SYNC_END));

// Horizontal counter logic
always_ff @(posedge clk_i or negedge rst_ni) begin
if(!rst_ni) h_count_o <= 0; else
if(h_last)  h_count_o <= 0; else
            h_count_o <= h_count_o + 1;
end

// Vertical counter logic
always_ff @(posedge clk_i or negedge rst_ni) begin
if(!rst_ni)          v_count_o  <= 0; else 
if(h_last && v_last) v_count_o <= 0; else
if(h_last)           v_count_o <= v_count_o + 1;
end

// Visible screen area detection (disabled during reset)
assign video_active_o = (h_count_o < H_ACTIVE) & (v_count_o < V_ACTIVE) & rst_ni;

assign frame_tick_o = v_last && h_last;

endmodule