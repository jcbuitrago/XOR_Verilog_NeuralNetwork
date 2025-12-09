//===============================================================
// Módulo: Relu Neural Network (2-2-1 architecture)
// Autor: Juan Camilo Buitrago Ariza + GitHub Copilot
// Architecture: 2 inputs -> 2 hidden neurons -> 1 output neuron
//===============================================================

`include "relu_neuron.sv"
`include "sigmoid_neuron.sv"

module vfr_nn #(
    parameter WIDTH = 16,
    parameter FRAC = 8
)(
    input                           clk,
    input                           rst,
    // Network inputs
    input signed    [WIDTH-1:0]     f1_input1,
    input signed    [WIDTH-1:0]     f2_input2,
    // Hidden layer weights and biases
    input signed    [WIDTH-1:0]     h1_w1,      // Hidden neuron 1, weight 1
    input signed    [WIDTH-1:0]     h1_w2,      // Hidden neuron 1, weight 2
    input signed    [WIDTH-1:0]     h1_bias,    // Hidden neuron 1, bias
    input signed    [WIDTH-1:0]     h2_w1,      // Hidden neuron 2, weight 1
    input signed    [WIDTH-1:0]     h2_w2,      // Hidden neuron 2, weight 2
    input signed    [WIDTH-1:0]     h2_bias,    // Hidden neuron 2, bias
    input signed    [WIDTH-1:0]     h3_w1,      // Hidden neuron 3, weight 1
    input signed    [WIDTH-1:0]     h3_w2,      // Hidden neuron 3, weight 2
    input signed    [WIDTH-1:0]     h3_bias,    // Hidden neuron 3, bias
    input signed    [WIDTH-1:0]     h4_w1,      // Hidden neuron 4, weight 1
    input signed    [WIDTH-1:0]     h4_w2,      // Hidden neuron 4, weight 2
    input signed    [WIDTH-1:0]     h4_bias,    // Hidden neuron 4, bias
    // Output layer weights and bias
    input signed    [WIDTH-1:0]     out_w11,     // Output neuron, weight 1
    input signed    [WIDTH-1:0]     out_w12,     // Output neuron, weight 2
    input signed    [WIDTH-1:0]     out_w13,     // Output neuron, weight 3
    input signed    [WIDTH-1:0]     out_w14,     // Output neuron, weight 4
    input signed    [WIDTH-1:0]     out_bias1,   // Output neuron, bias

    input signed    [WIDTH-1:0]     out_w21,     // Output neuron, weight 1
    input signed    [WIDTH-1:0]     out_w22,     // Output neuron, weight 2
    input signed    [WIDTH-1:0]     out_w23,     // Output neuron, weight 3
    input signed    [WIDTH-1:0]     out_w24,     // Output neuron, weight 4
    input signed    [WIDTH-1:0]     out_bias2,   // Output neuron, bias

    input signed    [WIDTH-1:0]     out_w31,     // Output neuron, weight 1
    input signed    [WIDTH-1:0]     out_w32,     // Output neuron, weight 2
    input signed    [WIDTH-1:0]     out_w33,     // Output neuron, weight 3
    input signed    [WIDTH-1:0]     out_w34,     // Output neuron, weight 4
    input signed    [WIDTH-1:0]     out_bias3,   // Output neuron, bias

    input signed    [WIDTH-1:0]     out_w41,     // Output neuron, weight 1
    input signed    [WIDTH-1:0]     out_w42,     // Output neuron, weight 2
    input signed    [WIDTH-1:0]     out_w43,     // Output neuron, weight 3
    input signed    [WIDTH-1:0]     out_w44,     // Output neuron, weight 4
    input signed    [WIDTH-1:0]     out_bias4,   // Output neuron, bias

    input signed    [WIDTH-1:0]     out_w51,     // Output neuron, weight 1
    input signed    [WIDTH-1:0]     out_w52,     // Output neuron, weight 2
    input signed    [WIDTH-1:0]     out_w53,     // Output neuron, weight 3
    input signed    [WIDTH-1:0]     out_w54,     // Output neuron, weight 4
    input signed    [WIDTH-1:0]     out_bias5,   // Output neuron, bias

    input signed    [WIDTH-1:0]     out_w61,     // Output neuron, weight 1
    input signed    [WIDTH-1:0]     out_w62,     // Output neuron, weight 2
    input signed    [WIDTH-1:0]     out_w63,     // Output neuron, weight 3
    input signed    [WIDTH-1:0]     out_w64,     // Output neuron, weight 4
    input signed    [WIDTH-1:0]     out_bias6,   // Output neuron, bias

    input signed    [WIDTH-1:0]     out_w71,     // Output neuron, weight 1
    input signed    [WIDTH-1:0]     out_w72,     // Output neuron, weight 2
    input signed    [WIDTH-1:0]     out_w73,     // Output neuron, weight 3
    input signed    [WIDTH-1:0]     out_w74,     // Output neuron, weight 4
    input signed    [WIDTH-1:0]     out_bias7,   // Output neuron, bias

    input signed    [WIDTH-1:0]     out_w81,     // Output neuron, weight 1
    input signed    [WIDTH-1:0]     out_w82,     // Output neuron, weight 2
    input signed    [WIDTH-1:0]     out_w83,     // Output neuron, weight 3
    input signed    [WIDTH-1:0]     out_w84,     // Output neuron, weight 4
    input signed    [WIDTH-1:0]     out_bias8,   // Output neuron, bias

    input signed    [WIDTH-1:0]     out_w91,     // Output neuron, weight 1
    input signed    [WIDTH-1:0]     out_w92,     // Output neuron, weight 2
    input signed    [WIDTH-1:0]     out_w93,     // Output neuron, weight 3
    input signed    [WIDTH-1:0]     out_w94,     // Output neuron, weight 4
    input signed    [WIDTH-1:0]     out_bias9,   // Output neuron, bias

    input signed    [WIDTH-1:0]     out_w101,     // Output neuron, weight 1
    input signed    [WIDTH-1:0]     out_w102,     // Output neuron, weight 2
    input signed    [WIDTH-1:0]     out_w103,     // Output neuron, weight 3
    input signed    [WIDTH-1:0]     out_w104,     // Output neuron, weight 4
    input signed    [WIDTH-1:0]     out_bias10,   // Output neuron, bias

    // Network output
    output signed   [WIDTH-1:0]     net_output1,
    output signed   [WIDTH-1:0]     net_output2,
    output signed   [WIDTH-1:0]     net_output3,
    output signed   [WIDTH-1:0]     net_output4,
    output signed   [WIDTH-1:0]     net_output5,
    output signed   [WIDTH-1:0]     net_output6,
    output signed   [WIDTH-1:0]     net_output7,
    output signed   [WIDTH-1:0]     net_output8,
    output signed   [WIDTH-1:0]     net_output9,
    output signed   [WIDTH-1:0]     net_output10
);

    // Hidden layer outputs
    wire signed [WIDTH-1:0] hidden1_out;
    wire signed [WIDTH-1:0] hidden2_out;
    wire signed [WIDTH-1:0] hidden3_out;
    wire signed [WIDTH-1:0] hidden4_out;

    // Hidden Layer - Neuron 1
    relu_neuron #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) hidden_neuron1 (
        .clk(clk),
        .rst(rst),
        .input1(f1_input1),
        .input2(f2_input2),
        .weight1(h1_w1),
        .weight2(h1_w2),
        .bias(h1_bias),
        .result(hidden1_out)
    );

    // Hidden Layer - Neuron 2
    relu_neuron #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) hidden_neuron2 (
        .clk(clk),
        .rst(rst),
        .input1(f1_input1),
        .input2(f2_input2),
        .weight1(h2_w1),
        .weight2(h2_w2),
        .bias(h2_bias),
        .result(hidden2_out)
    );

     // Hidden Layer - Neuron 3
    relu_neuron #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) hidden_neuron3 (
        .clk(clk),
        .rst(rst),
        .input1(f1_input1),
        .input2(f2_input2),
        .weight1(h3_w1),
        .weight2(h3_w2),
        .bias(h3_bias),
        .result(hidden3_out)
    );

    // Hidden Layer - Neuron 4
    relu_neuron #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) hidden_neuron4 (
        .clk(clk),
        .rst(rst),
        .input1(f1_input1),
        .input2(f2_input2),
        .weight1(h4_w1),
        .weight2(h4_w2),
        .bias(h4_bias),
        .result(hidden4_out)
    );

    // Output Layer - Neuron 1
    sigmoid_neuron #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) output_neuron1 (
        .clk(clk),
        .rst(rst),
        .input1(hidden1_out),
        .input2(hidden2_out),
        .input3(hidden3_out),
        .input4(hidden4_out),
        .weight1(out_w11),
        .weight2(out_w12),
        .weight3(out_w13),
        .weight4(out_w14),
        .bias(out_bias1),
        .result(net_output1)
    );
    
    // Output Layer - Neuron 2
    sigmoid_neuron #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) output_neuron2 (
        .clk(clk),
        .rst(rst),
        .input1(hidden1_out),
        .input2(hidden2_out),
        .input3(hidden3_out),
        .input4(hidden4_out),
        .weight1(out_w21),
        .weight2(out_w22),
        .weight3(out_w23),
        .weight4(out_w24),
        .bias(out_bias2),
        .result(net_output2)
    );

    // Output Layer - Neuron 3
    sigmoid_neuron #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) output_neuron3 (
        .clk(clk),
        .rst(rst),
        .input1(hidden1_out),
        .input2(hidden2_out),
        .input3(hidden3_out),
        .input4(hidden4_out),
        .weight1(out_w31),
        .weight2(out_w32),
        .weight3(out_w33),
        .weight4(out_w34),
        .bias(out_bias3),
        .result(net_output3)
    );

    // Output Layer - Neuron 4
    sigmoid_neuron #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) output_neuron4 (
        .clk(clk),
        .rst(rst),
        .input1(hidden1_out),
        .input2(hidden2_out),
        .input3(hidden3_out),
        .input4(hidden4_out),
        .weight1(out_w41),
        .weight2(out_w42),
        .weight3(out_w43),
        .weight4(out_w44),
        .bias(out_bias4),
        .result(net_output4)
    );

    // Output Layer - Neuron 5
    sigmoid_neuron #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) output_neuron5 (
        .clk(clk),
        .rst(rst),
        .input1(hidden1_out),
        .input2(hidden2_out),
        .input3(hidden3_out),
        .input4(hidden4_out),
        .weight1(out_w51),
        .weight2(out_w52),
        .weight3(out_w53),
        .weight4(out_w54),
        .bias(out_bias5),
        .result(net_output5)
    );

    // Output Layer - Neuron 6
    sigmoid_neuron #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) output_neuron6 (
        .clk(clk),
        .rst(rst),
        .input1(hidden1_out),
        .input2(hidden2_out),
        .input3(hidden3_out),
        .input4(hidden4_out),
        .weight1(out_w61),
        .weight2(out_w62),
        .weight3(out_w63),
        .weight4(out_w64),
        .bias(out_bias6),
        .result(net_output6)
    );
    
    // Output Layer - Neuron 7
    sigmoid_neuron #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) output_neuron7 (
        .clk(clk),
        .rst(rst),
        .input1(hidden1_out),
        .input2(hidden2_out),
        .input3(hidden3_out),
        .input4(hidden4_out),
        .weight1(out_w71),
        .weight2(out_w72),
        .weight3(out_w73),
        .weight4(out_w74),
        .bias(out_bias7),
        .result(net_output7)
    );

    // Output Layer - Neuron 8
    sigmoid_neuron #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) output_neuron8 (
        .clk(clk),
        .rst(rst),
        .input1(hidden1_out),
        .input2(hidden2_out),
        .input3(hidden3_out),
        .input4(hidden4_out),
        .weight1(out_w81),
        .weight2(out_w82),
        .weight3(out_w83),
        .weight4(out_w84),
        .bias(out_bias8),
        .result(net_output8)
    );

    // Output Layer - Neuron 9
    sigmoid_neuron #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) output_neuron9 (
        .clk(clk),
        .rst(rst),
        .input1(hidden1_out),
        .input2(hidden2_out),
        .input3(hidden3_out),
        .input4(hidden4_out),
        .weight1(out_w91),
        .weight2(out_w92),
        .weight3(out_w93),
        .weight4(out_w94),
        .bias(out_bias9),
        .result(net_output9)
    );

    // Output Layer - Neuron 10
    sigmoid_neuron #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) output_neuron10 (
        .clk(clk),
        .rst(rst),
        .input1(hidden1_out),
        .input2(hidden2_out),
        .input3(hidden3_out),
        .input4(hidden4_out),
        .weight1(out_w101),
        .weight2(out_w102),
        .weight3(out_w103),
        .weight4(out_w104),
        .bias(out_bias10),
        .result(net_output10)
    );


endmodule