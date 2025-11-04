//===============================================================
// Testbench: XOR Neural Network
// Autor: Juan Camilo Buitrago Ariza + GitHub Copilot
// Tests XOR function: [0,0]->0, [0,1]->1, [1,0]->1, [1,1]->0
//===============================================================

`timescale 1ns/1ps

module tb_relu_nn;

    // Parameters
    parameter WIDTH = 16;
    parameter FRAC = 8;
    parameter CLK_PERIOD = 10;

    // Signals
    reg                         clk;
    reg                         rst;
    reg signed  [WIDTH-1:0]     net_input1;
    reg signed  [WIDTH-1:0]     net_input2;
    reg signed  [WIDTH-1:0]     h1_w1, h1_w2, h1_bias;
    reg signed  [WIDTH-1:0]     h2_w1, h2_w2, h2_bias;
    reg signed  [WIDTH-1:0]     out_w1, out_w2, out_bias;
    wire signed [WIDTH-1:0]     net_output;

    // Instantiate the DUT
    relu_nn #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) dut (
        .clk(clk),
        .rst(rst),
        .net_input1(net_input1),
        .net_input2(net_input2),
        .h1_w1(h1_w1),
        .h1_w2(h1_w2),
        .h1_bias(h1_bias),
        .h2_w1(h2_w1),
        .h2_w2(h2_w2),
        .h2_bias(h2_bias),
        .out_w1(out_w1),
        .out_w2(out_w2),
        .out_bias(out_bias),
        .net_output(net_output)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Helper function to convert fixed point to real
    function real fixed_to_real;
        input signed [WIDTH-1:0] fixed_val;
        begin
            fixed_to_real = $itor(fixed_val) / 256.0;
        end
    endfunction

    // Helper function to convert real to fixed point Q8.8
    function signed [WIDTH-1:0] real_to_fixed;
        input real real_val;
        begin
            real_to_fixed = $rtoi(real_val * 256.0);
        end
    endfunction

    // Test scenarios
    initial begin
        $dumpfile("tb_relu_nn.vcd");
        $dumpvars(0, tb_relu_nn);
        $display("========================================");
        $display("XOR Neural Network Testbench");
        $display("Architecture: 2 inputs -> 2 hidden -> 1 output");
        $display("Format: Q8.8 (16-bit fixed point)");
        $display("Pipeline latency: 6 cycles (3 per layer)");
        $display("========================================");
        $display("\nXOR Truth Table:");
        $display("Input1 | Input2 | Expected Output");
        $display("   0   |   0    |       0");
        $display("   0   |   1    |       1");
        $display("   1   |   0    |       1");
        $display("   1   |   1    |       0");
        $display("========================================");

        // Initialize signals
        rst = 1;
        net_input1 = 0;
        net_input2 = 0;
        h1_w1 = 0; h1_w2 = 0; h1_bias = 0;
        h2_w1 = 0; h2_w2 = 0; h2_bias = 0;
        out_w1 = 0; out_w2 = 0; out_bias = 0;

        // Reset pulse
        #(CLK_PERIOD * 2);
        rst = 0;
        #(CLK_PERIOD);

        // Configure network weights for XOR function
        // Hidden neuron 1: h1_w1 = 0.825, h1_w2 = 0.95, h1_bias = 1.2
        h1_w1 = real_to_fixed(0.825);    // 0.825 -> 0x00D3
        h1_w2 = real_to_fixed(-0.95);     // 0.95  -> 0x00F3
        h1_bias = real_to_fixed(0);    // 1.2   -> 0x0133
        
        // Hidden neuron 2: h2_w1 = -0.825, h2_w2 = -0.95, h2_bias = 1.0
        h2_w1 = real_to_fixed(-0.825);   // -0.825 -> 0xFF2D
        h2_w2 = real_to_fixed(0.95);    // -0.95  -> 0xFF0D
        h2_bias = real_to_fixed(0);    // 1.0    -> 0x0100
        
        // Output neuron weights (typically 1.0, 1.0, and small bias for XOR)
        out_w1 = real_to_fixed(1.2);     // 1.2   -> 0x0133
        out_w2 = real_to_fixed(1.0);     // 1.0    -> 0x0100
        out_bias = real_to_fixed(0);  // 0

        $display("\nNetwork Configuration:");
        $display("Hidden Layer 1: w1=%f, w2=%f, bias=%f", 
                 fixed_to_real(h1_w1), fixed_to_real(h1_w2), fixed_to_real(h1_bias));
        $display("Hidden Layer 2: w1=%f, w2=%f, bias=%f", 
                 fixed_to_real(h2_w1), fixed_to_real(h2_w2), fixed_to_real(h2_bias));
        $display("Output Layer: w1=%f, w2=%f, bias=%f", 
                 fixed_to_real(out_w1), fixed_to_real(out_w2), fixed_to_real(out_bias));

        //========================================
        // Test Scenario 1: [0, 0] -> Expected: 0
        //========================================
        #(CLK_PERIOD * 2);
        $display("\n========================================");
        $display("Test 1: XOR(0, 0) -> Expected: 0");
        $display("========================================");
        
        net_input1 = real_to_fixed(0.0); // 0.0
        net_input2 = real_to_fixed(0.0); // 0.0
        
        #(CLK_PERIOD * 7); // Wait for pipeline
        $display("Inputs: [%f, %f]", fixed_to_real(net_input1), fixed_to_real(net_input2));
        $display("Output: %h (%f)", net_output, fixed_to_real(net_output));
        $display("Expected: 0.0");
        if (fixed_to_real(net_output) < 0.5)
            $display("PASS: Output is close to 0");
        else
            $display("FAIL: Output should be close to 0");

        //========================================
        // Test Scenario 2: [0, 1] -> Expected: 1
        //========================================
        #(CLK_PERIOD * 2);
        $display("\n========================================");
        $display("Test 2: XOR(0, 1) -> Expected: 1");
        $display("========================================");
        
        net_input1 = real_to_fixed(0.0); // 0.0
        net_input2 = real_to_fixed(1.0); // 1.0
        
        #(CLK_PERIOD * 7); // Wait for pipeline
        $display("Inputs: [%f, %f]", fixed_to_real(net_input1), fixed_to_real(net_input2));
        $display("Output: %h (%f)", net_output, fixed_to_real(net_output));
        $display("Expected: 1.0");
        if (fixed_to_real(net_output) > 0.5)
            $display("PASS: Output is close to 1");
        else
            $display("FAIL: Output should be close to 1");

        //========================================
        // Test Scenario 3: [1, 0] -> Expected: 1
        //========================================
        #(CLK_PERIOD * 2);
        $display("\n========================================");
        $display("Test 3: XOR(1, 0) -> Expected: 1");
        $display("========================================");
        
        net_input1 = real_to_fixed(1.0); // 1.0
        net_input2 = real_to_fixed(0.0); // 0.0
        
        #(CLK_PERIOD * 7); // Wait for pipeline
        $display("Inputs: [%f, %f]", fixed_to_real(net_input1), fixed_to_real(net_input2));
        $display("Output: %h (%f)", net_output, fixed_to_real(net_output));
        $display("Expected: 1.0");
        if (fixed_to_real(net_output) > 0.5)
            $display("PASS: Output is close to 1");
        else
            $display("FAIL: Output should be close to 1");

        //========================================
        // Test Scenario 4: [1, 1] -> Expected: 0
        //========================================
        #(CLK_PERIOD * 2);
        $display("\n========================================");
        $display("Test 4: XOR(1, 1) -> Expected: 0");
        $display("========================================");
        
        net_input1 = real_to_fixed(1.0); // 1.0
        net_input2 = real_to_fixed(1.0); // 1.0
        
        #(CLK_PERIOD * 7); // Wait for pipeline
        $display("Inputs: [%f, %f]", fixed_to_real(net_input1), fixed_to_real(net_input2));
        $display("Output: %h (%f)", net_output, fixed_to_real(net_output));
        $display("Expected: 0.0");
        if (fixed_to_real(net_output) < 0.5)
            $display("PASS: Output is close to 0");
        else
            $display("FAIL: Output should be close to 0");

        //========================================
        // Summary
        //========================================
        #(CLK_PERIOD * 5);
        $display("\n========================================");
        $display("XOR Neural Network Test Completed");
        $display("========================================");
        $finish;
    end

endmodule