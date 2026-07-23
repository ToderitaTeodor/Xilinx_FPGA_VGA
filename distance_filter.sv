module distance_filter (
    input  logic        clk_i          ,
    input  logic        rst_ni         ,
    input  logic        sample_valid_i ,
    input  logic [9:0]  raw_dist_i     ,

    output logic [9:0]  filtered_dist_o
);

// Four-sample moving average
logic [11:0] sum;
logic [9:0] sample0, sample1, sample2;

// Sample history
always_ff @(posedge clk_i or negedge rst_ni) begin
if(!rst_ni)         sample0 <= 0; else
if(sample_valid_i)  sample0 <= raw_dist_i;
end

always_ff @(posedge clk_i or negedge rst_ni) begin
if(!rst_ni)         sample1 <= 0; else
if(sample_valid_i)  sample1 <= sample0;
end

always_ff @(posedge clk_i or negedge rst_ni) begin
if(!rst_ni)         sample2 <= 0; else
if(sample_valid_i)  sample2 <= sample1;
end

// Sum the latest four samples
always_ff @(posedge clk_i or negedge rst_ni) begin
if(!rst_ni)         sum <= 0; else
if(sample_valid_i)  sum <= raw_dist_i + sample0 + sample1 + sample2;
end

// Divide by four
assign filtered_dist_o = sum >> 2;

endmodule