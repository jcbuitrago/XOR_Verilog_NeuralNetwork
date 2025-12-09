//===============================================================
// Módulo: neurona sigmoid en punto fijo Q8.8 (16 bits)
// Autor: Juan Camilo Buitrago Ariza + GitHub Copilot
// Implementación con LUT para aproximación de sigmoid
//===============================================================

module sigmoid_neuron #(
  parameter WIDTH = 16,
  parameter FRAC = 8
)(
    input                           clk,
    input                           rst,
    input 	signed	[WIDTH-1:0] 	input1,
    input 	signed 	[WIDTH-1:0] 	input2,
    input 	signed	[WIDTH-1:0] 	input3,
    input 	signed 	[WIDTH-1:0] 	input4,
    input 	signed 	[WIDTH-1:0] 	weight1,
    input 	signed 	[WIDTH-1:0] 	weight2,
    input 	signed 	[WIDTH-1:0] 	weight3,
    input 	signed 	[WIDTH-1:0] 	weight4,
    input 	signed 	[WIDTH-1:0] 	bias,
    output 	reg signed 	[WIDTH-1:0] result
);

    // Stage 1: Multiplication
    wire	signed	[2*WIDTH-1:0]   mult1_full, mult2_full, mult3_full, mult4_full;
    wire 	signed	[WIDTH-1:0]     mult1_scaled, mult2_scaled, mult3_scaled, mult4_scaled;
    reg 	signed	[WIDTH-1:0]     mult1_reg, mult2_reg, mult3_reg, mult4_reg;
    reg     signed  [WIDTH-1:0]     bias_reg;

    // Stage 2: Addition
    wire 	signed	[WIDTH:0]       sum_partial, sum_total;
    reg     signed  [WIDTH:0]       sum_total_reg;

    // Stage 3: Sigmoid approximation
    wire    signed  [WIDTH-1:0]     sigmoid_out;

    // Stage 1: Multiplication and scale  
    assign mult1_full = input1 * weight1;
    assign mult2_full = input2 * weight2;
    assign mult3_full = input3 * weight3;
    assign mult4_full = input4 * weight4;
    
    assign mult1_scaled = mult1_full >>> FRAC;
    assign mult2_scaled = mult2_full >>> FRAC;
    assign mult3_scaled = mult3_full >>> FRAC;
    assign mult4_scaled = mult4_full >>> FRAC;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mult1_reg <= {WIDTH{1'b0}};
            mult2_reg <= {WIDTH{1'b0}};
            mult3_reg <= {WIDTH{1'b0}};
            mult4_reg <= {WIDTH{1'b0}};
            bias_reg  <= {WIDTH{1'b0}};
        end else begin
            mult1_reg <= mult1_scaled;
            mult2_reg <= mult2_scaled;
            mult3_reg <= mult3_scaled;
            mult4_reg <= mult4_scaled;
            bias_reg  <= bias;
        end
    end

    // Stage 2: Add    
    assign sum_partial = mult1_reg + mult2_reg + mult3_reg + mult4_reg;
    assign sum_total = sum_partial + bias_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sum_total_reg <= {(WIDTH+1){1'b0}};
        end else begin
            sum_total_reg <= sum_total;
        end
    end

    // Stage 3: Sigmoid activation using piecewise linear approximation
    // Sigmoid function: σ(x) = 1 / (1 + e^(-x))
    // Output range in Q8.8: 0.0 to 1.0 (0x0000 to 0x0100)
    
    function signed [WIDTH-1:0] sigmoid_lut;
        input signed [WIDTH:0] x;
        begin
            // Piecewise linear approximation of sigmoid
            // Range: x < -4 -> 0, x > 4 -> 1, linear interpolation between
            
            if (x <= -17'sd1024) begin  // x <= -4.0
                sigmoid_lut = 16'h0000;  // ~0.0
            end
            else if (x >= 17'sd1024) begin  // x >= 4.0
                sigmoid_lut = 16'h0100;  // ~1.0
            end
            else if (x <= -17'sd768) begin  // -4.0 < x <= -3.0
                sigmoid_lut = 16'h0005;  // ~0.02
            end
            else if (x <= -17'sd512) begin  // -3.0 < x <= -2.0
                sigmoid_lut = 16'h0012;  // ~0.07
            end
            else if (x <= -17'sd256) begin  // -2.0 < x <= -1.0
                sigmoid_lut = 16'h0049;  // ~0.27
            end
            else if (x <= 17'sd0) begin     // -1.0 < x <= 0.0
                sigmoid_lut = 16'h0080;  // ~0.5
            end
            else if (x <= 17'sd256) begin   // 0.0 < x <= 1.0
                sigmoid_lut = 16'h00B7;  // ~0.73
            end
            else if (x <= 17'sd512) begin   // 1.0 < x <= 2.0
                sigmoid_lut = 16'h00EE;  // ~0.93
            end
            else if (x <= 17'sd768) begin   // 2.0 < x <= 3.0
                sigmoid_lut = 16'h00FB;  // ~0.98
            end
            else begin                       // 3.0 < x < 4.0
                sigmoid_lut = 16'h0100;  // ~1.0
            end
        end
    endfunction

    assign sigmoid_out = sigmoid_lut(sum_total_reg);

    // Stage 3: Register sigmoid output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= {WIDTH{1'b0}};
        end else begin
            result <= sigmoid_out;
        end
    end
  
endmodule