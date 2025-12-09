`timescale 1ns/1ps

module tb_multi_vfr_nn;
  parameter WIDTH = 16;
  parameter FRAC  = 8;
  parameter CLK_PERIOD = 10;

  // Q8.8 helpers
  function signed [WIDTH-1:0] real_to_fixed;
    input real r;
    real scaled;
    begin
      scaled = r * (2.0**FRAC);
      real_to_fixed = $rtoi(scaled); // round toward zero
    end
  endfunction

  function real fixed_to_real;
    input signed [WIDTH-1:0] fx;
    begin
      fixed_to_real = $signed(fx) / (2.0**FRAC);
    end
  endfunction

  reg clk, rst;

  // Inputs
  reg  signed [WIDTH-1:0] f1_input1;
  reg  signed [WIDTH-1:0] f2_input2;

  // Hidden weights/biases (same as tn_1_vfr_nn.v from weights.csv)
  reg  signed [WIDTH-1:0] h1_w1, h1_w2, h1_bias;
  reg  signed [WIDTH-1:0] h2_w1, h2_w2, h2_bias;
  reg  signed [WIDTH-1:0] h3_w1, h3_w2, h3_bias;
  reg  signed [WIDTH-1:0] h4_w1, h4_w2, h4_bias;

  // Output layer weights/biases (same set)
  reg  signed [WIDTH-1:0] out_w11, out_w12, out_w13, out_w14, out_bias1;
  reg  signed [WIDTH-1:0] out_w21, out_w22, out_w23, out_w24, out_bias2;
  reg  signed [WIDTH-1:0] out_w31, out_w32, out_w33, out_w34, out_bias3;
  reg  signed [WIDTH-1:0] out_w41, out_w42, out_w43, out_w44, out_bias4;
  reg  signed [WIDTH-1:0] out_w51, out_w52, out_w53, out_w54, out_bias5;
  reg  signed [WIDTH-1:0] out_w61, out_w62, out_w63, out_w64, out_bias6;
  reg  signed [WIDTH-1:0] out_w71, out_w72, out_w73, out_w74, out_bias7;
  reg  signed [WIDTH-1:0] out_w81, out_w82, out_w83, out_w84, out_bias8;
  reg  signed [WIDTH-1:0] out_w91, out_w92, out_w93, out_w94, out_bias9;
  reg  signed [WIDTH-1:0] out_w101, out_w102, out_w103, out_w104, out_bias10;

  // Outputs
  wire signed [WIDTH-1:0] net_output1, net_output2, net_output3, net_output4, net_output5;
  wire signed [WIDTH-1:0] net_output6, net_output7, net_output8, net_output9, net_output10;

  // DUT
  vfr_nn #(.WIDTH(WIDTH), .FRAC(FRAC)) dut (
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

  // Clock
  always #(CLK_PERIOD/2) clk = ~clk;

  // Small set of inputs from inputs.csv
  integer i;
  real in_pairs [0:5][0:1];
  initial begin
    // Populate a few rows (add more as needed)
    in_pairs[0][0] = 0.07462686567164178; in_pairs[0][1] = 0.8037383177570093;
    in_pairs[1][0] = 0.13432835820895522; in_pairs[1][1] = 0.8598130841121495;
    in_pairs[2][0] = 0.29850746268656714; in_pairs[2][1] = 0.6869158878504673;
    in_pairs[3][0] = 0.1791044776119403;  in_pairs[3][1] = 0.6635514018691588;
    in_pairs[4][0] = 0.44776119402985076; in_pairs[4][1] = 0.6121495327102804;
    in_pairs[5][0] = 0.6567164179104478;  in_pairs[5][1] = 0.5327102803738317;
  end

  initial begin
    // Reset and init
    clk = 0; rst = 1;
    f1_input1 = 0; f2_input2 = 0;

    // Weights (same as your manual test)
    h1_w1   = real_to_fixed(4.85);
    h1_w2   = real_to_fixed(6.70);
    h1_bias = real_to_fixed(-3.30);

    h2_w1   = real_to_fixed(-0.40);
    h2_w2   = real_to_fixed(-0.40);
    h2_bias = real_to_fixed(0.00);

    h3_w1   = real_to_fixed(-0.30);
    h3_w2   = real_to_fixed(0.35);
    h3_bias = real_to_fixed(-0.35);

    h4_w1   = real_to_fixed(8.75);
    h4_w2   = real_to_fixed(-0.30);
    h4_bias = real_to_fixed(-1.45);

    // Output neuron 1
    out_w11  = real_to_fixed(-0.20);
    out_w12  = real_to_fixed(0.35);
    out_w13  = real_to_fixed(0.00);
    out_w14  = real_to_fixed(0.10);
    out_bias1= real_to_fixed(-1.75);

    // Output neuron 2
    out_w21  = real_to_fixed(-4.35);
    out_w22  = real_to_fixed(-0.20);
    out_w23  = real_to_fixed(-0.35);
    out_w24  = real_to_fixed(-3.85);
    out_bias2= real_to_fixed(3.65);

    // Output neuron 3
    out_w31  = real_to_fixed(-1.50);
    out_w32  = real_to_fixed(0.10);
    out_w33  = real_to_fixed(-0.15);
    out_w34  = real_to_fixed(0.30);
    out_bias3= real_to_fixed(-0.95);

    // Output neuron 4
    out_w41  = real_to_fixed(-7.40);
    out_w42  = real_to_fixed(-0.45);
    out_w43  = real_to_fixed(-0.50);
    out_w44  = real_to_fixed(3.85);
    out_bias4= real_to_fixed(-7.90);

    // Output neuron 5
    out_w51  = real_to_fixed(-1.80);
    out_w52  = real_to_fixed(-0.10);
    out_w53  = real_to_fixed(-0.25);
    out_w54  = real_to_fixed(3.35);
    out_bias5= real_to_fixed(-12.75);

    // Output neuron 6
    out_w61  = real_to_fixed(-0.25);
    out_w62  = real_to_fixed(0.00);
    out_w63  = real_to_fixed(0.20);
    out_w64  = real_to_fixed(0.45);
    out_bias6= real_to_fixed(-3.25);

    // Output neuron 7
    out_w71  = real_to_fixed(3.00);
    out_w72  = real_to_fixed(0.45);
    out_w73  = real_to_fixed(0.00);
    out_w74  = real_to_fixed(0.60);
    out_bias7= real_to_fixed(-13.0);

    // Output neuron 8
    out_w81  = real_to_fixed(0.70);
    out_w82  = real_to_fixed(0.00);
    out_w83  = real_to_fixed(0.45);
    out_w84  = real_to_fixed(-0.15);
    out_bias8= real_to_fixed(-4.00);

    // Output neuron 9
    out_w91  = real_to_fixed(0.50);
    out_w92  = real_to_fixed(0.50);
    out_w93  = real_to_fixed(0.30);
    out_w94  = real_to_fixed(-0.50);
    out_bias9= real_to_fixed(-2.20);

    // Output neuron 10
    out_w101  = real_to_fixed(2.40);
    out_w102  = real_to_fixed(-0.35);
    out_w103  = real_to_fixed(-0.15);
    out_w104  = real_to_fixed(-9.00);
    out_bias10= real_to_fixed(-3.90);

    #(CLK_PERIOD*2);
    rst = 0;
    #(CLK_PERIOD);

    // Loop inputs
    for (i = 0; i <= 5; i = i + 1) begin
      f1_input1 = real_to_fixed(in_pairs[i][0]);
      f2_input2 = real_to_fixed(in_pairs[i][1]);

      // Wait for pipeline (adjust to your neuron latency)
      #(CLK_PERIOD*16);

      $display("\nTest %0d: in1=%0f in2=%0f",
        i+1, fixed_to_real(f1_input1), fixed_to_real(f2_input2));

      $display("net_out1=%0f net_out2=%0f net_out3=%0f net_out4=%0f net_out5=%0f",
        fixed_to_real(net_output1), fixed_to_real(net_output2), fixed_to_real(net_output3),
        fixed_to_real(net_output4), fixed_to_real(net_output5));
      $display("net_out6=%0f net_out7=%0f net_out8=%0f net_out9=%0f net_out10=%0f",
        fixed_to_real(net_output6), fixed_to_real(net_output7), fixed_to_real(net_output8),
        fixed_to_real(net_output9), fixed_to_real(net_output10));
    end

    $finish;
  end

endmodule