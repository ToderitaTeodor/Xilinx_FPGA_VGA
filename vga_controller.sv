module vga_controller (
    input        clk_i  ,
    input        rst_ni ,

    output       hsync_o,
    output       vsync_o,

    output [3:0] red_o  ,
    output [3:0] green_o,
    output [3:0] blue_o 
);

// VGA 640x480 timing parameters
localparam H_ACTIVE  = 640;
localparam H_F_PORCH = 16;
localparam H_SYNC    = 96;
localparam H_B_PORCH = 48;
localparam H_TOTAL   = H_ACTIVE + H_F_PORCH + H_SYNC + H_B_PORCH;

localparam V_ACTIVE  = 480;
localparam V_F_PORCH = 10;
localparam V_SYNC    = 2;
localparam V_B_PORCH = 33;
localparam V_TOTAL   = V_ACTIVE + V_F_PORCH + V_SYNC + V_B_PORCH;

// Internal counters
reg [$clog2(H_TOTAL)-1:0] h_counter;
reg [$clog2(V_TOTAL)-1:0] v_counter;

// End of line indicator
wire enable = (h_counter == H_TOTAL - 1);

// Active low sync pulse generation
assign hsync_o = ~((h_counter >= (H_ACTIVE + H_F_PORCH)) &
                   (h_counter <  (H_ACTIVE + H_F_PORCH + H_SYNC)));

assign vsync_o = ~((v_counter >= (V_ACTIVE + V_F_PORCH)) &
                   (v_counter <  (V_ACTIVE + V_F_PORCH + V_SYNC)));

// Visible screen area detection
wire video_active = (h_counter < H_ACTIVE) & (v_counter < V_ACTIVE);

// Color output logic
assign red_o = (!rst_ni) ? 4'h0 : ((video_active) ? 4'hF : 4'h0);
assign green_o = 4'h0;
assign blue_o = 4'h0;

// Horizontal counter logic
always @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) 
        h_counter <= 0; 
    else if(h_counter == H_TOTAL - 1)
        h_counter <= 0;
    else
        h_counter <= h_counter + 1;
end

// Vertical counter logic
always @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni)
        v_counter <= 0;
    else if(enable) begin
        if(v_counter == V_TOTAL - 1)
            v_counter <= 0;
        else
            v_counter <= v_counter + 1;
    end
end

endmodule