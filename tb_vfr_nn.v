//===============================================================
// Testbench for Módulo: VFR Neural Network (2-4-10 architecture)
// Autor: Juan Camilo Buitrago Ariza + GitHub Copilot
// Reads test vectors and weights from CSV files.
//===============================================================

`timescale 1ns / 1ps

module tb_vfr_nn;

    // Parameters
    parameter WIDTH = 16;
    parameter FRAC = 8;
    parameter CLK_PERIOD = 10; // 10 ns clock period

    // Helper function to convert real to fixed point Q8.8
    function signed [WIDTH-1:0] real_to_fixed;
        input real real_val;
        begin
            real_to_fixed = $rtoi(real_val * (2.0**FRAC));
        end
    endfunction

    // Helper function to convert fixed point to real
    function real fixed_to_real;
        input signed [WIDTH-1:0] fixed_val;
        begin
            fixed_to_real = $signed(fixed_val) / (2.0**FRAC);
        end
    endfunction

    // Testbench signals
    reg                         clk;
    reg                         rst;
    
    // Network inputs
    reg signed [WIDTH-1:0] f1_input1;
    reg signed [WIDTH-1:0] f2_input2;

    // Weights and Biases Registers
    // Hidden Layer
    reg signed [WIDTH-1:0] h1_w1, h1_w2, h1_bias;
    reg signed [WIDTH-1:0] h2_w1, h2_w2, h2_bias;
    reg signed [WIDTH-1:0] h3_w1, h3_w2, h3_bias;
    reg signed [WIDTH-1:0] h4_w1, h4_w2, h4_bias;
    // Output Layer
    reg signed [WIDTH-1:0] out_w11, out_w12, out_w13, out_w14, out_bias1;
    reg signed [WIDTH-1:0] out_w21, out_w22, out_w23, out_w24, out_bias2;
    reg signed [WIDTH-1:0] out_w31, out_w32, out_w33, out_w34, out_bias3;
    reg signed [WIDTH-1:0] out_w41, out_w42, out_w43, out_w44, out_bias4;
    reg signed [WIDTH-1:0] out_w51, out_w52, out_w53, out_w54, out_bias5;
    reg signed [WIDTH-1:0] out_w61, out_w62, out_w63, out_w64, out_bias6;
    reg signed [WIDTH-1:0] out_w71, out_w72, out_w73, out_w74, out_bias7;
    reg signed [WIDTH-1:0] out_w81, out_w82, out_w83, out_w84, out_bias8;
    reg signed [WIDTH-1:0] out_w91, out_w92, out_w93, out_w94, out_bias9;
    reg signed [WIDTH-1:0] out_w101, out_w102, out_w103, out_w104, out_bias10;

    // Network outputs
    wire signed [WIDTH-1:0] net_output1, net_output2, net_output3, net_output4, net_output5;
    wire signed [WIDTH-1:0] net_output6, net_output7, net_output8, net_output9, net_output10;

    // Instantiate the DUT
    vfr_nn #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) dut (
        .clk(clk), .rst(rst),
        .f1_input1(f1_input1), .f2_input2(f2_input2),
        .h1_w1(h1_w1), .h1_w2(h1_w2), .h1_bias(h1_bias),
        .h2_w1(h2_w1), .h2_w2(h2_w2), .h2_bias(h2_bias),
        .h3_w1(h3_w1), .h3_w2(h3_w2), .h3_bias(h3_bias),
        .h4_w1(h4_w1), .h4_w2(h4_w2), .h4_bias(h4_bias),
        .out_w11(out_w11), .out_w12(out_w12), .out_w13(out_w13), .out_w14(out_w14), .out_bias1(out_bias1),
        .out_w21(out_w21), .out_w22(out_w22), .out_w23(out_w23), .out_w24(out_w24), .out_bias2(out_bias2),
        .out_w31(out_w31), .out_w32(out_w32), .out_w33(out_w33), .out_w34(out_w34), .out_bias3(out_bias3),
        .out_w41(out_w41), .out_w42(out_w42), .out_w43(out_w43), .out_w44(out_w44), .out_bias4(out_bias4),
        .out_w51(out_w51), .out_w52(out_w52), .out_w53(out_w53), .out_w54(out_w54), .out_bias5(out_bias5),
        .out_w61(out_w61), .out_w62(out_w62), .out_w63(out_w63), .out_w64(out_w64), .out_bias6(out_bias6),
        .out_w71(out_w71), .out_w72(out_w72), .out_w73(out_w73), .out_w74(out_w74), .out_bias7(out_bias7),
        .out_w81(out_w81), .out_w82(out_w82), .out_w83(out_w83), .out_w84(out_w84), .out_bias8(out_bias8),
        .out_w91(out_w91), .out_w92(out_w92), .out_w93(out_w93), .out_w94(out_w94), .out_bias9(out_bias9),
        .out_w101(out_w101), .out_w102(out_w102), .out_w103(out_w103), .out_w104(out_w104), .out_bias10(out_bias10),
        .net_output1(net_output1), .net_output2(net_output2), .net_output3(net_output3), .net_output4(net_output4), .net_output5(net_output5),
        .net_output6(net_output6), .net_output7(net_output7), .net_output8(net_output8), .net_output9(net_output9), .net_output10(net_output10)
    );

    // Clock generator
    always #((CLK_PERIOD)/2) clk = ~clk;

    // Helper array for outputs (use regs for procedural comparisons)
    reg signed [WIDTH-1:0] out_buf [1:10];

    // Test sequence
    initial begin
        integer     weights_file, inputs_file, code, i;
        reg [8*50:1] param_name, description;
        real         weight_val;
        integer test_vector_num;
        integer correct_count;
        integer incorrect_count;
        real    csv_in1, csv_in2;
        integer exp_out[1:10]; // one-hot expected
        integer max_idx_expected, max_idx_actual;
        reg signed [WIDTH-1:0] max_val_actual;
        
        // --- 1. Load Weights from CSV ---
        weights_file = $fopen("weights.csv", "r");
        if (weights_file == 0) begin
            $display("Error: Could not open weights.csv");
            $finish;
        end
        
        // Skip header line
        code = $fscanf(weights_file, "%s,%s,%s\n", param_name, description, param_name);

        while (!$feof(weights_file)) begin
            code = $fscanf(weights_file, "%s,%s,%f\n", param_name, description, weight_val);
            if (code == 3) begin
                if      (param_name == "h1_w1")    h1_w1   = real_to_fixed(weight_val);
                else if (param_name == "h1_w2")    h1_w2   = real_to_fixed(weight_val);
                else if (param_name == "h1_bias")  h1_bias = real_to_fixed(weight_val);
                else if (param_name == "h2_w1")    h2_w1   = real_to_fixed(weight_val);
                else if (param_name == "h2_w2")    h2_w2   = real_to_fixed(weight_val);
                else if (param_name == "h2_bias")  h2_bias = real_to_fixed(weight_val);
                else if (param_name == "h3_w1")    h3_w1   = real_to_fixed(weight_val);
                else if (param_name == "h3_w2")    h3_w2   = real_to_fixed(weight_val);
                else if (param_name == "h3_bias")  h3_bias = real_to_fixed(weight_val);
                else if (param_name == "h4_w1")    h4_w1   = real_to_fixed(weight_val);
                else if (param_name == "h4_w2")    h4_w2   = real_to_fixed(weight_val);
                else if (param_name == "h4_bias")  h4_bias = real_to_fixed(weight_val);

                else if (param_name == "out_w11")  out_w11  = real_to_fixed(weight_val);
                else if (param_name == "out_w12")  out_w12  = real_to_fixed(weight_val);
                else if (param_name == "out_w13")  out_w13  = real_to_fixed(weight_val);
                else if (param_name == "out_w14")  out_w14  = real_to_fixed(weight_val);
                else if (param_name == "out_bias1") out_bias1 = real_to_fixed(weight_val);

                else if (param_name == "out_w21")  out_w21  = real_to_fixed(weight_val);
                else if (param_name == "out_w22")  out_w22  = real_to_fixed(weight_val);
                else if (param_name == "out_w23")  out_w23  = real_to_fixed(weight_val);
                else if (param_name == "out_w24")  out_w24  = real_to_fixed(weight_val);
                else if (param_name == "out_bias2") out_bias2 = real_to_fixed(weight_val);

                else if (param_name == "out_w31")  out_w31  = real_to_fixed(weight_val);
                else if (param_name == "out_w32")  out_w32  = real_to_fixed(weight_val);
                else if (param_name == "out_w33")  out_w33  = real_to_fixed(weight_val);
                else if (param_name == "out_w34")  out_w34  = real_to_fixed(weight_val);
                else if (param_name == "out_bias3") out_bias3 = real_to_fixed(weight_val);

                else if (param_name == "out_w41")  out_w41  = real_to_fixed(weight_val);
                else if (param_name == "out_w42")  out_w42  = real_to_fixed(weight_val);
                else if (param_name == "out_w43")  out_w43  = real_to_fixed(weight_val);
                else if (param_name == "out_w44")  out_w44  = real_to_fixed(weight_val);
                else if (param_name == "out_bias4") out_bias4 = real_to_fixed(weight_val);

                else if (param_name == "out_w51")  out_w51  = real_to_fixed(weight_val);
                else if (param_name == "out_w52")  out_w52  = real_to_fixed(weight_val);
                else if (param_name == "out_w53")  out_w53  = real_to_fixed(weight_val);
                else if (param_name == "out_w54")  out_w54  = real_to_fixed(weight_val);
                else if (param_name == "out_bias5") out_bias5 = real_to_fixed(weight_val);

                else if (param_name == "out_w61")  out_w61  = real_to_fixed(weight_val);
                else if (param_name == "out_w62")  out_w62  = real_to_fixed(weight_val);
                else if (param_name == "out_w63")  out_w63  = real_to_fixed(weight_val);
                else if (param_name == "out_w64")  out_w64  = real_to_fixed(weight_val);
                else if (param_name == "out_bias6") out_bias6 = real_to_fixed(weight_val);

                else if (param_name == "out_w71")  out_w71  = real_to_fixed(weight_val);
                else if (param_name == "out_w72")  out_w72  = real_to_fixed(weight_val);
                else if (param_name == "out_w73")  out_w73  = real_to_fixed(weight_val);
                else if (param_name == "out_w74")  out_w74  = real_to_fixed(weight_val);
                else if (param_name == "out_bias7") out_bias7 = real_to_fixed(weight_val);

                else if (param_name == "out_w81")  out_w81  = real_to_fixed(weight_val);
                else if (param_name == "out_w82")  out_w82  = real_to_fixed(weight_val);
                else if (param_name == "out_w83")  out_w83  = real_to_fixed(weight_val);
                else if (param_name == "out_w84")  out_w84  = real_to_fixed(weight_val);
                else if (param_name == "out_bias8") out_bias8 = real_to_fixed(weight_val);

                else if (param_name == "out_w91")  out_w91  = real_to_fixed(weight_val);
                else if (param_name == "out_w92")  out_w92  = real_to_fixed(weight_val);
                else if (param_name == "out_w93")  out_w93  = real_to_fixed(weight_val);
                else if (param_name == "out_w94")  out_w94  = real_to_fixed(weight_val);
                else if (param_name == "out_bias9") out_bias9 = real_to_fixed(weight_val);

                else if (param_name == "out_bias10") out_bias10 = real_to_fixed(weight_val);
                else $display("Warning: Unknown weight parameter '%s'", param_name);
            end
        end
        $fclose(weights_file);
        $display("--- Weights loaded successfully ---");

        // --- 2. Initialize and Reset DUT ---
        clk = 0;

        // Initialize counters
        test_vector_num = 0;
        correct_count   = 0;
        incorrect_count = 0;

        inputs_file = $fopen("inputs.csv", "r");
        if (inputs_file == 0) begin
            $display("Error: Could not open inputs.csv");
            $finish;
        end

        // Skip header
        code = $fscanf(inputs_file, "%s\n", param_name);

        while (!$feof(inputs_file)) begin
            test_vector_num = test_vector_num + 1;
            code = $fscanf(inputs_file, "%f,%f,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",
                csv_in1, csv_in2, exp_out[10], exp_out[9], exp_out[8], exp_out[7], exp_out[6],
                exp_out[5], exp_out[4], exp_out[3], exp_out[2], exp_out[1]);

            if (code == 12) begin
                // Apply inputs
                f1_input1 = real_to_fixed(csv_in1);
                f2_input2 = real_to_fixed(csv_in2);

                // Wait for propagation (adjust if your pipeline is deeper)
                # (CLK_PERIOD * 12);

                // Snapshot outputs into regs (avoids wire-array indexing issues)
                out_buf[1]  = net_output1;
                out_buf[2]  = net_output2;
                out_buf[3]  = net_output3;
                out_buf[4]  = net_output4;
                out_buf[5]  = net_output5;
                out_buf[6]  = net_output6;
                out_buf[7]  = net_output7;
                out_buf[8]  = net_output8;
                out_buf[9]  = net_output9;
                out_buf[10] = net_output10;

                // Find index of max value in expected output (one-hot)
                max_idx_expected = 0;
                for (i = 1; i <= 10; i = i + 1) begin
                    if (exp_out[i] == 1) max_idx_expected = i;
                end

                // Find index of max value in actual buffered outputs
                max_val_actual = -16'sd32768; // min 16-bit
                max_idx_actual = 1;           // default to 1

                for (i = 1; i <= 10; i = i + 1) begin
                    // Treat X/Z as very small to avoid false max
                    if (^out_buf[i] === 1'bx) begin
                        // skip unknowns
                    end else if (out_buf[i] > max_val_actual) begin
                        max_val_actual = out_buf[i];
                        max_idx_actual = i;
                    end
                end

                // Compare and report
                $write("Test %0d: Inputs(%f, %f) -> ", test_vector_num, csv_in1, csv_in2);
                if (max_idx_actual == max_idx_expected) begin
                    $display("PASS (Expected: %0d, Got: %0d)", max_idx_expected, max_idx_actual);
                    correct_count = correct_count + 1;
                end else begin
                    $display("FAIL (Expected: %0d, Got: %0d)  Values: [%0f %0f %0f %0f %0f %0f %0f %0f %0f %0f]",
                        max_idx_expected, max_idx_actual,
                        fixed_to_real(out_buf[1]), fixed_to_real(out_buf[2]), fixed_to_real(out_buf[3]), fixed_to_real(out_buf[4]),
                        fixed_to_real(out_buf[5]), fixed_to_real(out_buf[6]), fixed_to_real(out_buf[7]), fixed_to_real(out_buf[8]),
                        fixed_to_real(out_buf[9]), fixed_to_real(out_buf[10]));
                    incorrect_count = incorrect_count + 1;
                end
            end
        end
        $fclose(inputs_file);

        // --- 4. Final Report ---
        $display("\n--- Test Summary ---");
        $display("Total vectors tested: %d", test_vector_num);
        $display("Correct classifications: %d", correct_count);
        $display("Incorrect classifications: %d", incorrect_count);
        if (test_vector_num > 0) begin
            $display("Accuracy: %f %%", (correct_count * 100.0) / test_vector_num);
        end
        $display("--------------------");

        $finish;
    end

endmodule