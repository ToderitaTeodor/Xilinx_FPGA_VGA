module distance_mapper #(
    parameter MIN_DISTANCE_CM = 10,
    parameter MAX_DISTANCE_CM = 100,

    parameter MIN_RADIUS = 20,
    parameter MAX_RADIUS = 300
)(
    input  logic [9:0] distance_cm_i,

    output logic [8:0]  radius_o,
    output logic [2:0]  heat_level_o
);

logic [9:0] distance_clamped;
logic [7:0] level;

// If distance is above or below limit assign it max or min value
assign distance_clamped = (distance_cm_i <= MIN_DISTANCE_CM) ? MIN_DISTANCE_CM :
                          (distance_cm_i >= MAX_DISTANCE_CM) ? MAX_DISTANCE_CM :
                          distance_cm_i;

// If the object is close, make the object large. If the object is far,make the object small
assign level = ((MAX_DISTANCE_CM - distance_clamped) * 255) / (MAX_DISTANCE_CM - MIN_DISTANCE_CM);

   
assign radius_o = MIN_RADIUS + (level * (MAX_RADIUS - MIN_RADIUS)) / 255;
    
always_comb begin
    if (level < 51)
        heat_level_o = 3'd0;
    else if (level < 102)
        heat_level_o = 3'd1;
    else if (level < 153)
        heat_level_o = 3'd2;
    else if (level < 204)
        heat_level_o = 3'd3;
    else
        heat_level_o = 3'd4;
end

endmodule