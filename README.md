# Fixed-Point Neural Network Hardware Implementation

## Project Overview

This project implements a hardware-accelerated neural network using Verilog HDL with fixed-point arithmetic (Q8.8 format). The design features a configurable 2-2-1 architecture (2 inputs → 2 hidden neurons → 1 output neuron) with support for multiple activation functions including ReLU, Sigmoid, and Tanh.

## Purpose

The primary goal is to demonstrate a synthesizable, pipelined neural network implementation suitable for FPGA deployment or ASIC design. This project serves as a foundation for embedded AI applications where low-power, deterministic inference is required.

## Implementation Summary

### Architecture

- **Network Topology**: 2-2-1 (fully connected feedforward)
- **Number Format**: Q8.8 fixed-point (16-bit: 8 integer bits, 8 fractional bits)
- **Pipeline Depth**: 3 stages per neuron (multiplication → addition → activation)
- **Total Latency**: 6 clock cycles (3 cycles for hidden layer + 3 cycles for output layer)

### Key Features

1. **Modular Neuron Design**: Each neuron is implemented as a reusable module with configurable parameters
2. **Multiple Activation Functions**:
   - **ReLU**: `f(x) = max(0, x)` - Simple threshold-based activation
   - **Sigmoid**: `f(x) = 1 / (1 + e^(-x))` - Piecewise linear LUT approximation (0.0 to 1.0)
   - **Tanh**: `f(x) = (e^x - e^(-x)) / (e^x + e^(-x))` - Piecewise linear LUT approximation (-1.0 to 1.0)
3. **Pipelined Architecture**: Maximizes throughput with synchronous register stages
4. **Fixed-Point Arithmetic**: Efficient hardware implementation without floating-point units

### File Structure

```
├── relu_neuron.v       # ReLU activation neuron
├── sigmoid_neuron.v    # Sigmoid activation neuron  
├── tanh_neuron.v       # Tanh activation neuron
├── relu_nn.v           # 2-2-1 Neural network wrapper
├── tb_relu_neuron.v    # Testbench for individual neuron
└── tb_relu_nn.v        # Testbench for complete network (XOR function)
```

## Testing Results

The neural network has been successfully tested with all three activation function types (ReLU, Sigmoid, and Tanh). The [`relu_nn`](relu_nn.v) module was validated by substituting different neuron implementations, and all configurations produced satisfactory results.

### XOR Function Test

The testbench ([`tb_relu_nn.v`](tb_relu_nn.v)) validates the network's ability to learn the XOR function, a classic non-linearly separable problem:

| Input 1 | Input 2 | Expected Output |
|---------|---------|----------------|
| 0       | 0       | 0              |
| 0       | 1       | 1              |
| 1       | 0       | 1              |
| 1       | 1       | 0              |

## Training

Network weights and biases were trained using the interactive neural network visualization tool available at:

**[Neural Network Demo - Binary Classifier for XOR](https://phiresky.github.io/neural-network-demo/?preset=Binary%20Classifier%20for%20X)**

The trained weights were then converted to Q8.8 fixed-point format and configured in the testbench.

## How to Run

### Prerequisites
- Icarus Verilog (iverilog) or any Verilog simulator
- GTKWave (optional, for waveform viewing)

### Simulation Commands

**Test individual neuron:**
```bash
iverilog -o tb_relu_neuron.vvp relu_neuron.v tb_relu_neuron.v
vvp tb_relu_neuron.vvp
```

**Test complete neural network:**
```bash
iverilog -o tb_relu_nn.vvp relu_neuron.v relu_nn.v tb_relu_nn.v
vvp tb_relu_nn.vvp
```

**View waveforms:**
```bash
gtkwave tb_relu_nn.vcd
```

## Technical Details

### Q8.8 Fixed-Point Format

- **Range**: -128.0 to 127.996
- **Resolution**: 1/256 = 0.00390625
- **Example Conversions**:
  - `1.0` → `0x0100`
  - `0.5` → `0x0080`
  - `-1.0` → `0xFF00`

### Pipeline Stages

1. **Stage 1 (Multiplication)**: Compute `input1 × weight1` and `input2 × weight2`, scale results
2. **Stage 2 (Addition)**: Sum scaled products and add bias
3. **Stage 3 (Activation)**: Apply activation function (ReLU/Sigmoid/Tanh)

### Resource Utilization

Each neuron requires:
- 2× multipliers (16-bit × 16-bit)
- 2× adders (16-bit)
- Pipeline registers
- Activation function logic (combinational for ReLU, LUT for Sigmoid/Tanh)

## Future Enhancements

- [ ] Extend to deeper architectures (3+ layers)
- [ ] Add support for more input/output neurons
- [ ] Implement batch processing
- [ ] Optimize LUT approximations for better activation function accuracy
- [ ] Add support for quantization-aware training
- [ ] FPGA synthesis and timing analysis

## Authors

**Juan Camilo Buitrago Ariza**  
Maestría en Ingeniería - IC Design Course

## Acknowledgments

This project was developed with the assistance of:
- **Claude Sonnet 4.5** - AI assistant for code generation and optimization
- **GitHub Copilot** - Code completion and testbench development

## License

This project is developed for educational purposes as part of a Master's degree program.

---

*For questions or contributions, please open an issue or submit a pull request.*