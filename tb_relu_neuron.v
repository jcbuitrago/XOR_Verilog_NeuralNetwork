//===============================================================
// Testbench: relu_neuron
// Autor: Juan Camilo Buitrago Ariza + GitHub Copilot
//===============================================================

`timescale 1ns/1ps

module tb_relu_neuron;

    // Parameters
    parameter WIDTH_tb = 16;
    parameter FRAC_tb = 8;
    parameter CLK_PERIOD_tb = 10;

    // Signals
    reg                         clk_tb;
    reg                         rst_tb;
    reg signed  [WIDTH_tb-1:0]     input1_tb;
    reg signed  [WIDTH_tb-1:0]     input2_tb;
    reg signed  [WIDTH_tb-1:0]     weight1_tb;
    reg signed  [WIDTH_tb-1:0]     weight2_tb;
    reg signed  [WIDTH_tb-1:0]     bias_tb;
    wire signed [WIDTH_tb-1:0]     result_tb;

    // Instantiate the DUT (Device Under Test)
    relu_neuron #(
        .WIDTH(WIDTH_tb),
        .FRAC(FRAC_tb)
    ) dut (
        .clk(clk_tb),
        .rst(rst_tb),
        .input1(input1_tb),
        .input2(input2_tb),
        .weight1(weight1_tb),
        .weight2(weight2_tb),
        .bias(bias_tb),
        .result(result_tb)
    );

    // Clock generation
    initial begin
        clk_tb = 0;
        forever #(CLK_PERIOD_tb/2) clk_tb = ~clk_tb;
    end

    // Test scenarios
    initial begin
        $dumpfile("tb_relu_neuron.vcd");
        $dumpvars(0, tb_relu_neuron);
      
        $display("========================================");
        $display("Starting ReLU Neuron Testbench");
        $display("Format: Q8.8 (16-bit fixed point)");
        $display("========================================");

        // Initialize signals
        rst_tb = 1;
        input1_tb = 0;
        input2_tb = 0;
        weight1_tb = 0;
        weight2_tb = 0;
        bias_tb = 0;

        // Reset pulse
        #(CLK_PERIOD_tb * 2);
        rst_tb = 0;
        #(CLK_PERIOD_tb);

        //========================================
        // Test Scenario 1: Positive result (ReLU active)
        // input1=2.0, weight1=1.5, input2=1.0, weight2=0.5, bias=0.5
        // Expected: (2.0*1.5) + (1.0*0.5) + 0.5 = 3.0 + 0.5 + 0.5 = 4.0
        //========================================
        $display("\n--- Test 1: Positive Result (ReLU Active) ---");
        input1_tb  = 16'h0200;  // 2.0 in Q8.8
        weight1_tb = 16'h0180;  // 1.5 in Q8.8
        input2_tb  = 16'h0100;  // 1.0 in Q8.8
        weight2_tb = 16'h0080;  // 0.5 in Q8.8
        bias_tb    = 16'h0080;  // 0.5 in Q8.8
        
        #(CLK_PERIOD_tb * 4);  // Wait for pipeline to complete
        $display("Input1: %h (2.0), Weight1: %h (1.5)", input1_tb, weight1_tb);
        $display("Input2: %h (1.0), Weight2: %h (0.5)", input2_tb, weight2_tb);
        $display("Bias: %h (0.5)", bias_tb);
        $display("Result: %h (Expected: 0x0400 = 4.0)", result_tb);
        $display("Result as real: %f", $itor(result_tb) / 256.0);

        //========================================
        // Test Scenario 2: Negative result (ReLU clamps to 0)
        // input1=-2.0, weight1=1.0, input2=-1.0, weight2=1.0, bias=-1.0
        // Expected: (-2.0*1.0) + (-1.0*1.0) + (-1.0) = -2.0 - 1.0 - 1.0 = -4.0 → ReLU → 0.0
        //========================================
        #(CLK_PERIOD_tb * 2);
        $display("\n--- Test 2: Negative Result (ReLU Clamps to 0) ---");
        input1_tb  = 16'hFE00;  // -2.0 in Q8.8 (two's complement)
        weight1_tb = 16'h0100;  // 1.0 in Q8.8
        input2_tb  = 16'hFF00;  // -1.0 in Q8.8
        weight2_tb = 16'h0100;  // 1.0 in Q8.8
        bias_tb    = 16'hFF00;  // -1.0 in Q8.8
        
        #(CLK_PERIOD_tb * 4);  // Wait for pipeline to complete
        $display("Input1: %h (-2.0), Weight1: %h (1.0)", input1_tb, weight1_tb);
        $display("Input2: %h (-1.0), Weight2: %h (1.0)", input2_tb, weight2_tb);
        $display("Bias: %h (-1.0)", bias_tb);
        $display("Result: %h (Expected: 0x0000 = 0.0)", result_tb);
        $display("Result as real: %f", $itor(result_tb) / 256.0);

        //========================================
        // Test Scenario 3: Zero crossing case
        // input1=1.0, weight1=0.25, input2=0.5, weight2=0.5, bias=-0.5
        // Expected: (1.0*0.25) + (0.5*0.5) + (-0.5) = 0.25 + 0.25 - 0.5 = 0.0
        //========================================
        #(CLK_PERIOD_tb * 2);
        $display("\n--- Test 3: Zero Crossing Case ---");
        input1_tb  = 16'h0100;  // 1.0 in Q8.8
        weight1_tb = 16'h0040;  // 0.25 in Q8.8
        input2_tb  = 16'h0080;  // 0.5 in Q8.8
        weight2_tb = 16'h0080;  // 0.5 in Q8.8
        bias_tb    = 16'hFF80;  // -0.5 in Q8.8
        
        #(CLK_PERIOD_tb * 4);  // Wait for pipeline to complete
        $display("Input1: %h (1.0), Weight1: %h (0.25)", input1_tb, weight1_tb);
        $display("Input2: %h (0.5), Weight2: %h (0.5)", input2_tb, weight2_tb);
        $display("Bias: %h (-0.5)", bias_tb);
        $display("Result: %h (Expected: 0x0000 = 0.0)", result_tb);
        $display("Result as real: %f", $itor(result_tb) / 256.0);

        //========================================
        // End simulation
        //========================================
        #(CLK_PERIOD_tb * 5);
        $display("\n========================================");
        $display("Testbench completed");
        $display("========================================");
        $finish;
    end

endmodule