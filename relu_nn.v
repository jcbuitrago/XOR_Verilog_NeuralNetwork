//===============================================================
// Módulo: Relu Neural Network (2-2-1 architecture)
// Autor: Juan Camilo Buitrago Ariza + GitHub Copilot
// Architecture: 2 inputs -> 2 hidden neurons -> 1 output neuron
//===============================================================

`include "relu_neuron.v"

module relu_nn #(
    parameter WIDTH = 16,
    parameter FRAC = 8
)(
    input                           clk,
    input                           rst,
    // Network inputs
    input signed    [WIDTH-1:0]     net_input1,
    input signed    [WIDTH-1:0]     net_input2,
    // Hidden layer weights and biases
    input signed    [WIDTH-1:0]     h1_w1,      // Hidden neuron 1, weight 1
    input signed    [WIDTH-1:0]     h1_w2,      // Hidden neuron 1, weight 2
    input signed    [WIDTH-1:0]     h1_bias,    // Hidden neuron 1, bias
    input signed    [WIDTH-1:0]     h2_w1,      // Hidden neuron 2, weight 1
    input signed    [WIDTH-1:0]     h2_w2,      // Hidden neuron 2, weight 2
    input signed    [WIDTH-1:0]     h2_bias,    // Hidden neuron 2, bias
    // Output layer weights and bias
    input signed    [WIDTH-1:0]     out_w1,     // Output neuron, weight 1
    input signed    [WIDTH-1:0]     out_w2,     // Output neuron, weight 2
    input signed    [WIDTH-1:0]     out_bias,   // Output neuron, bias
    // Network output
    output signed   [WIDTH-1:0]     net_output
);

    // Hidden layer outputs
    wire signed [WIDTH-1:0] hidden1_out;
    wire signed [WIDTH-1:0] hidden2_out;

    // Hidden Layer - Neuron 1
    relu_neuron #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) hidden_neuron1 (
        .clk(clk),
        .rst(rst),
        .input1(net_input1),
        .input2(net_input2),
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
        .input1(net_input1),
        .input2(net_input2),
        .weight1(h2_w1),
        .weight2(h2_w2),
        .bias(h2_bias),
        .result(hidden2_out)
    );

    // Output Layer - Neuron
    relu_neuron #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) output_neuron (
        .clk(clk),
        .rst(rst),
        .input1(hidden1_out),
        .input2(hidden2_out),
        .weight1(out_w1),
        .weight2(out_w2),
        .bias(out_bias),
        .result(net_output)
    );

endmodule