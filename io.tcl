# Clock and reset
set_io_pin_constraint -pin_names {clk rst} -region left:*

# Network inputs (Q8.8 buses)
set_io_pin_constraint -pin_names {f1_input1[*] f2_input2[*]} -region left:*

# Hidden layer weights and biases (Q8.8 buses)
set_io_pin_constraint -pin_names {h1_w1 h1_w2 h1_bias} -region left:*
set_io_pin_constraint -pin_names {h2_w1[*] h2_w2[*] h2_bias[*]} -region left:*
set_io_pin_constraint -pin_names {h3_w1[*] h3_w2[*] h3_bias[*]} -region left:*
set_io_pin_constraint -pin_names {h4_w1[*] h4_w2[*] h4_bias[*]} -region left:*

# Output layer weights and biases (Q8.8 buses)
set_io_pin_constraint -pin_names {out_w11[*] out_w12[*] out_w13[*] out_w14[*] out_bias1[*]} -region left:*
set_io_pin_constraint -pin_names {out_w21[*] out_w22[*] out_w23[*] out_w24[*] out_bias2[*]} -region left:*
set_io_pin_constraint -pin_names {out_w31[*] out_w32[*] out_w33[*] out_w34[*] out_bias3[*]} -region left:*
set_io_pin_constraint -pin_names {out_w41[*] out_w42[*] out_w43[*] out_w44[*] out_bias4[*]} -region left:*
set_io_pin_constraint -pin_names {out_w51[*] out_w52[*] out_w53[*] out_w54[*] out_bias5[*]} -region left:*
set_io_pin_constraint -pin_names {out_w61[*] out_w62[*] out_w63[*] out_w64[*] out_bias6[*]} -region left:*
set_io_pin_constraint -pin_names {out_w71[*] out_w72[*] out_w73[*] out_w74[*] out_bias7[*]} -region left:*
set_io_pin_constraint -pin_names {out_w81[*] out_w82[*] out_w83[*] out_w84[*] out_bias8[*]} -region left:*
set_io_pin_constraint -pin_names {out_w91[*] out_w92[*] out_w93[*] out_w94[*] out_bias9[*]} -region left:*
set_io_pin_constraint -pin_names {out_w101[*] out_w102[*] out_w103[*] out_w104[*] out_bias10[*]} -region left:*

# Network outputs (Q8.8 buses)
set_io_pin_constraint -pin_names {net_output1[*] net_output2[*] net_output3[*] net_output4[*] net_output5[*]} -region right:*
set_io_pin_constraint -pin_names {net_output6[*] net_output7[*] net_output8[*] net_output9[*] net_output10[*]} -region right:*

h1_w1 h1_w2 h1_bias h2_w1 h2_w2 h2_bias h3_w1 h3_w2 h3_bias h4_w1 h4_w2 h4_bias out_w11 out_w12 out_w13 out_w14 out_bias1 out_w21 out_w22 out_w23 out_w24 out_bias2 out_w31 out_w32 out_w33 out_w34 out_bias3 out_w41 out_w42 out_w43 out_w44 out_bias4 out_w51 out_w52 out_w53 out_w54 out_bias5 out_w61 out_w62 out_w63 out_w64 out_bias6 out_w71 out_w72 out_w73 out_w74 out_bias7 out_w81 out_w82 out_w83 out_w84 out_bias8 out_w91 out_w92 out_w93 out_w94 out_bias9 out_w101 out_w102 out_w103 out_w104 out_bias10