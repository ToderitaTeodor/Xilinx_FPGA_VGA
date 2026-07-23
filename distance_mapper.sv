module distance_mapper #(
    parameter MIN_DISTANCE_CM = 10 ,
    parameter MAX_DISTANCE_CM = 100,
    parameter MIN_RADIUS      = 20 ,
    parameter MAX_RADIUS      = 200
)(
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic [9:0]  distance_cm_i,

    output logic [8:0]  radius_o,
    output logic [2:0]  heat_level_o
);

// Distance interval
localparam int DIST_SPAN   = MAX_DISTANCE_CM - MIN_DISTANCE_CM;

// Radius interval
localparam int RADIUS_SPAN = MAX_RADIUS - MIN_RADIUS;

logic [9:0] distance_clamped_q;
logic [8:0] radius_q;
logic [7:0] level_q;
logic [2:0] heat_level_q;

// Limit the distance to the configured range
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)                          distance_clamped_q <= MIN_DISTANCE_CM; else
    if (distance_cm_i <= MIN_DISTANCE_CM) distance_clamped_q <= MIN_DISTANCE_CM; else
    if (distance_cm_i >= MAX_DISTANCE_CM) distance_clamped_q <= MAX_DISTANCE_CM; else
                                          distance_clamped_q <= distance_cm_i;
end

// Map distance to a normalized level
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) level_q <= 0; else
                 level_q <= ((MAX_DISTANCE_CM - distance_clamped_q) * 255) / DIST_SPAN;
end

// Scale the level to the display radius
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) radius_q <= MIN_RADIUS; else
                 radius_q <= MIN_RADIUS + ((level_q * RADIUS_SPAN) / 255);
end

// Divide the level into heat zones
always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)       heat_level_q <= 0; else
    if (level_q < 51)  heat_level_q <= 0; else
    if (level_q < 102) heat_level_q <= 1; else
    if (level_q < 153) heat_level_q <= 2; else
    if (level_q < 204) heat_level_q <= 3; else
                       heat_level_q <= 4;
end

assign radius_o     = radius_q;
assign heat_level_o = heat_level_q;

endmodule