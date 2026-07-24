module vga_controller_top #(
    parameter H_ACTIVE  = 640,
    parameter H_F_PORCH = 16 ,
    parameter H_SYNC    = 96 ,
    parameter H_B_PORCH = 48 ,

    parameter V_ACTIVE  = 480,
    parameter V_F_PORCH = 10 ,
    parameter V_SYNC    = 2  ,
    parameter V_B_PORCH = 33
)(
    input  logic       sys_clock,
    input  logic       reset     ,

    input  logic       sonar_pw_i,
    output logic       sonar_rx_o,

    output logic       Hsync     ,
    output logic       Vsync     ,

    output logic [3:0] vgaRed    ,
    output logic [3:0] vgaGreen  ,
    output logic [3:0] vgaBlue   
);

localparam MIN_DISTANCE = 10;
localparam MAX_DISTANCE = 100;

localparam MIN_RADIUS = 20;
localparam MAX_RADIUS = 200;

// Pixel clock for the VGA 
logic clk_25m;

// Active-low reset
logic rst_n = ~reset;

logic [11:0] h_counter;
logic [11:0] v_counter;
logic        video_active;
logic        frame_tick;

logic [9:0] distance_cm;
logic [9:0] filtered_distance;

logic [8:0] radius;
logic [2:0] heat_level;

logic valid;

// Keep the ultrasonic sensor enabled
assign sonar_rx_o = 1'b1;

// VGA timing generator
vga_controller #(
    .H_ACTIVE (H_ACTIVE ),
    .H_F_PORCH(H_F_PORCH),
    .H_SYNC   (H_SYNC   ),
    .H_B_PORCH(H_B_PORCH),
    .V_ACTIVE (V_ACTIVE ),
    .V_F_PORCH(V_F_PORCH),
    .V_SYNC   (V_SYNC   ),
    .V_B_PORCH(V_B_PORCH)
) vga_controller_inst (
    .clk_i          (clk_25m),
    .rst_ni         (rst_n),
    .hsync_o        (Hsync),
    .vsync_o        (Vsync),
    .frame_tick_o   (frame_tick),
    .h_count_o      (h_counter),
    .v_count_o      (v_counter),
    .video_active_o (video_active)
);

// Render the selected scene
vga_image_display #(
    .H_ACTIVE(H_ACTIVE),
    .V_ACTIVE(V_ACTIVE)
) vga_image_display_inst (

    .clk_i(clk_25m),
    .rst_ni(rst_n),

    .radius_i(radius),
    .heat_level_i(heat_level),

    .h_counter_i(h_counter),
    .v_counter_i(v_counter),

    .video_active_i(video_active),

    .red_o(vgaRed),
    .green_o(vgaGreen),
    .blue_o(vgaBlue)
);

// Measure the distance from the ultrasonic sensor
maxsonar_reader #(
    .CLK_FREQ_MHZ(25)
) maxsonar_reader_inst (
    .clk_i         (clk_25m),
    .rst_ni        (rst_n),
    .pw_i          (sonar_pw_i),
    .distance_cm_o (distance_cm),
    .valid_o       (valid)
);

// Smooth consecutive distance measurements
distance_filter distance_filter_inst(
    .clk_i            (clk_25m),
    .rst_ni           (rst_n),
    .sample_valid_i   (valid),
    .raw_dist_i       (distance_cm),
    .filtered_dist_o  (filtered_distance)
);

// Convert distance into display parameters
distance_mapper #(
    .MIN_DISTANCE_CM(MIN_DISTANCE),
    .MAX_DISTANCE_CM(MAX_DISTANCE),
    .MIN_RADIUS(MIN_RADIUS),
    .MAX_RADIUS(MAX_RADIUS)
) distance_mapper_inst (
    .clk_i         (clk_25m),
    .rst_ni        (rst_n),
    .distance_cm_i (filtered_distance),
    .radius_o      (radius),
    .heat_level_o  (heat_level)
);

// Generate the VGA pixel clock
clk_vga_wrapper clk_vga_wrapper_inst(
    .clk_out1_0(clk_25m),
    .reset     (rst_n),
    .sys_clock (sys_clock)
);

endmodule