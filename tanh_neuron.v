//===============================================================
// Módulo: neurona tanh en punto fijo Q8.8 (16 bits)
// Autor: Juan Camilo Buitrago Ariza + GitHub Copilot
// Implementación con LUT para aproximación de tanh
//===============================================================

module tanh_neuron #(
    parameter WIDTH = 16,
    parameter FRAC = 8
)(
    input                           clk,
    input                           rst,
    input   signed  [WIDTH-1:0]     input1,
    input   signed  [WIDTH-1:0]     input2,
    input   signed  [WIDTH-1:0]     weight1,
    input   signed  [WIDTH-1:0]     weight2,
    input   signed  [WIDTH-1:0]     bias,
    output reg signed [WIDTH-1:0]   result
);

    // Stage 1: Multiplication
    wire	signed	[2*WIDTH-1:0]   mult1_full, mult2_full;
    wire 	signed	[WIDTH-1:0]     mult1_scaled, mult2_scaled;
    reg 	signed	[WIDTH-1:0]     mult1_reg, mult2_reg;
    reg     signed  [WIDTH-1:0]     bias_reg;

    // Stage 2: Addition
    wire 	signed	[WIDTH:0]       sum_partial, sum_total;
    reg     signed  [WIDTH:0]       sum_total_reg;

    // Stage 3: Tanh approximation
    wire    signed  [WIDTH-1:0]     tanh_out;

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

    // Stage 3: Tanh activation using piecewise linear approximation
    // Tanh function: σ(x) = (e^(x) - e^(-x)) / (e^(x) + e^(-x))
    // Output range in Q8.8: -1.0 to 1.0 (0xFF00 to 0x0100)
    
    function signed [WIDTH-1:0] tanh_lut;
        input signed [WIDTH:0] x;
        begin
            // Piecewise linear approximation of tanh
        
            // Range: x < -4 -> 0, x > 4 -> 1, linear interpolation between
            
            if (x <= -17'sd768) begin       // x <= -3.0
                tanh_lut = 16'hFF00;        // -1.0
            end
            else if (x >= 17'sd768) begin   // x >= 3.0
                tanh_lut = 16'h0100;        // 1.0
            end
            else if (x <= -17'sd512) begin  // -3.0 < x <= -2.0
                tanh_lut = 16'hFF1A;        // -0.96
            end
            else if (x <= -17'sd256) begin  // -2.0 < x <= -1.0
                tanh_lut = 16'hFF42;        // -0.76
            end
            else if (x < 17'sd0) begin      // -1.0 < x < 0.0
                tanh_lut = 16'hFFB0;        // -0.31
            end
            else if (x == 17'sd0) begin     // x = 0.0
                tanh_lut = 16'h0000;        // 0.0
            end
            else if (x <= 17'sd256) begin   // 0.0 < x <= 1.0
                tanh_lut = 16'h0050;        // 0.31
            end
            else if (x <= 17'sd512) begin   // 1.0 < x <= 2.0
                tanh_lut = 16'h00BE;        // 0.76
            end
            else begin                       // 2.0 < x < 3.0
                tanh_lut = 16'h00E6;        // 0.96
            end
        end
    endfunction

    assign tanh_out = tanh_lut(sum_total_reg);

    // Stage 3: Register tanh output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= {WIDTH{1'b0}};
        end else begin
            result <= tanh_out;
        end
    end
  
endmodule