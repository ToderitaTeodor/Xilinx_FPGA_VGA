module vga_controller_top #(
    parameter H_ACTIVE  = 1920,
    parameter H_F_PORCH = 88 ,
    parameter H_SYNC    = 44 ,
    parameter H_B_PORCH = 148 ,

    parameter V_ACTIVE  = 1080,
    parameter V_F_PORCH = 4 ,
    parameter V_SYNC    = 5  ,
    parameter V_B_PORCH = 36
)(
    input  logic       sys_clock,
    input  logic       reset    ,

    input  logic [1:0] sw       ,
    output logic       Hsync    ,
    output logic       Vsync    ,

    output logic [3:0] vgaRed   ,
    output logic [3:0] vgaGreen ,
    output logic [3:0] vgaBlue   
);

// 25.175 Mhz clock
logic vga_clk;

// reset active low
logic rst_n = ~reset;

logic [11:0] w_h_counter;
logic [11:0] w_v_counter;
logic       w_video_active;

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
    .clk_i          (vga_clk),
    .rst_ni         (rst_n),
    .hsync_o        (Hsync),
    .vsync_o        (Vsync),
    .h_count_o      (w_h_counter),
    .v_count_o      (w_v_counter),
    .video_active_o (w_video_active)
);

vga_image_display #(
    .H_ACTIVE (H_ACTIVE ),
    .H_F_PORCH(H_F_PORCH),
    .H_SYNC   (H_SYNC   ),
    .H_B_PORCH(H_B_PORCH),
    .V_ACTIVE (V_ACTIVE ),
    .V_F_PORCH(V_F_PORCH),
    .V_SYNC   (V_SYNC   ),
    .V_B_PORCH(V_B_PORCH)
) vga_image_display_inst (
    .clk_i        (vga_clk),
    .rst_ni       (rst_n),
    .sw           (sw),
    .h_counter    (w_h_counter),
    .v_counter    (w_v_counter),
    .video_active (w_video_active),
    .red_o        (vgaRed),
    .green_o      (vgaGreen),
    .blue_o       (vgaBlue)
);

clk_vga_wrapper clk_vga_wrapper_inst(
    .clk_out1_0(vga_clk),
    .reset     (rst_n),
    .sys_clock (sys_clock)
);

endmodule