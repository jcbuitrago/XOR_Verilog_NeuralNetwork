//===============================================================
// Módulo: neurona relu en punto fijo Q8.8 (16 bits)
// Autor: Juan Camilo Buitrago Ariza + ChatGPT (GPT-5)
//===============================================================

module relu_neuron #(
  parameter WIDTH = 16,
  parameter FRAC = 8
)(
    input                           clk,
    input                           rst,
    input 	signed	[WIDTH-1:0] 	input1,
    input 	signed 	[WIDTH-1:0] 	input2,
    input 	signed 	[WIDTH-1:0] 	weight1,
    input 	signed 	[WIDTH-1:0] 	weight2,
    input 	signed 	[WIDTH-1:0] 	bias,
    output 	reg signed 	[WIDTH-1:0] result
);

    // Stage 1: Multiplication
    wire	signed	[2*WIDTH-1:0]   mult1_full, mult2_full;
    wire 	signed	[WIDTH-1:0]     mult1_scaled, mult2_scaled;
    reg 	signed	[WIDTH-1:0]     mult1_reg, mult2_reg;
    reg     signed  [WIDTH-1:0]     bias_reg;

    // Stage 2: Addition
    wire 	signed	[WIDTH:0]       sum_partial, sum_total;
    reg     signed  [WIDTH:0]       sum_total_reg;

    // Stage 1: Multiplication and scale  
    assign mult1_full = input1 * weight1;
    assign mult2_full = input2 * weight2;
    
    assign mult1_scaled = mult1_full >>> FRAC;
    assign mult2_scaled = mult2_full >>> FRAC;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mult1_reg <= {WIDTH{1'b0}};
            mult2_reg <= {WIDTH{1'b0}};
            bias_reg  <= {WIDTH{1'b0}};
        end else begin
            mult1_reg <= mult1_scaled;
            mult2_reg <= mult2_scaled;
            bias_reg  <= bias;
        end
    end

    // Stage 2: Add    
    assign sum_partial = mult1_reg + mult2_reg;
    assign sum_total = sum_partial + bias_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sum_total_reg <= {(WIDTH+1){1'b0}};
        end else begin
            sum_total_reg <= sum_total;
        end
    end

    // Stage 3: Relu  
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= {WIDTH{1'b0}};
        end else begin
            result <= sum_total_reg[WIDTH] ? {WIDTH{1'b0}} : sum_total_reg[WIDTH-1:0];
        end
    end
  
endmodule