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
    .clk_i  (vga_clk),
    .rst_ni (rst_n),

    .sw     (sw),

    .hsync_o(Hsync),
    .vsync_o(Vsync),

    .red_o  (vgaRed  ),
    .green_o(vgaGreen),
    .blue_o (vgaBlue )
);

clk_vga_wrapper clk_vga_wrapper_inst(
    .clk_out1_0(vga_clk),
    .reset     (rst_n),
    .sys_clock (sys_clock)
);

endmodule
