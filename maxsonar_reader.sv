module maxsonar_reader #(
    parameter CLK_FREQ_MHZ = 100
)(
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic        pw_i,

    output logic [9:0] distance_cm_o
);


    // Synchronize PW input
    // First synchronizer stage
    logic pw_meta;

    // Synchronized PW signal
    logic pw_sync;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            pw_meta <= 1'b0;
        else
            pw_meta <= pw_i;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            pw_sync <= 1'b0;
        else
            pw_sync <= pw_meta;
    end

    // Edge detection

    // Previous synchronized PW state
    logic pw_prev;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            pw_prev <= 1'b0;
        else
            pw_prev <= pw_sync;
    end

    // One-clock-cycle edge pulses
    logic rising_edge;
    logic falling_edge;

    assign rising_edge  = (~pw_prev) &  pw_sync;
    assign falling_edge =  pw_prev  & (~pw_sync);

    // Pulse width measurement
    // Counts clock cycles while PW is HIGH
    logic [31:0] pulse_counter;

    // Measured pulse width in clock cycles
    logic [31:0] pulse_width_cycles;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            pulse_counter <= 32'd0;
        else if (rising_edge)
            pulse_counter <= 32'd0;
        else if (pw_sync)
            pulse_counter <= pulse_counter + 1'b1;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            pulse_width_cycles <= 32'd0;
        else if (falling_edge)
            pulse_width_cycles <= pulse_counter;
    end

    logic [15:0] distance_cm;

    always_comb begin
    distance_cm = pulse_width_cycles / (58 * CLK_FREQ_MHZ);
    end

    assign distance_cm_o = distance_cm;

endmodule