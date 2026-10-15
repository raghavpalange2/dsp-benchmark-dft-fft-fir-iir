Comparative DSP Benchmark: DFT, FFT, FIR and IIR

A MATLAB-based Digital Signal Processing mini-project focused on the implementation, experimental benchmarking, and comparative analysis of DFT, FFT, convolution, FIR filters, and IIR filters.

Project Overview

Digital Signal Processing (DSP) is widely used in audio processing, communications, biomedical signal analysis, image processing, and embedded systems. The efficiency and accuracy of DSP algorithms are important when processing signals under different computational constraints.

This project investigates and compares selected DSP algorithms through MATLAB implementation and experimental evaluation. It examines their computational performance, numerical accuracy, and signal-processing characteristics using synthetic and, where applicable, real-world input signals.

The project aims to connect theoretical DSP concepts with practical implementation and quantitative performance analysis.

Objectives

- Implement and study the Discrete Fourier Transform (DFT) and Fast Fourier Transform (FFT).
- Compare direct and FFT-based approaches to convolution.
- Investigate the characteristics and performance of Finite Impulse Response (FIR) and Infinite Impulse Response (IIR) filters.
- Measure and compare execution time and computational complexity.
- Evaluate numerical accuracy using appropriate error metrics, including Root Mean Square Error (RMSE), where applicable.
- Study frequency resolution and frequency-response characteristics.
- Generate graphs and tables to support quantitative comparison.
- Compare the implemented approaches with appropriate reference methods.

Algorithms and Experiments

1. DFT and FFT Comparison

The DFT transforms a discrete-time signal into its frequency-domain representation. The FFT is an efficient family of algorithms for computing the DFT.

The comparison considers:

- Execution time for different input lengths.
- Computational complexity and operation-count estimates.
- Numerical agreement between the computed frequency-domain results.
- Frequency resolution for different signal lengths.

2. Convolution Benchmark

Convolution is a fundamental operation used in linear time-invariant systems and digital filtering.

The project compares applicable convolution implementations, such as direct time-domain convolution and FFT-based convolution, in terms of:

- Execution time.
- Input signal lengths.
- Numerical agreement between the output signals.
- Computational efficiency.

3. FIR and IIR Filter Comparison

FIR and IIR filters are widely used to modify the frequency content of discrete-time signals.

The comparison examines:

- Filter frequency responses.
- Time-domain output signals.
- Computational requirements.
- Numerical error against an appropriate reference implementation, where applicable.
- Relevant differences in filter structure and behavior.

4. Quantitative Performance Evaluation

The experiments use appropriate performance measures, including:

| Metric | Purpose |
|---|---|
| Execution time | Measures the time required to perform a computation. |
| Operation count | Estimates computational work using the counting method defined in the implementation. |
| RMSE | Measures the difference between an output and its reference signal. |
| Frequency resolution | Describes the frequency spacing associated with the analysis length and sampling rate. |
| Frequency response | Characterizes a filter's behavior across frequency. |

The exact metrics used for each experiment depend on the implemented algorithm and available reference method. Execution-time measurements can vary with hardware, MATLAB version, input size, and measurement conditions.

Tools and Technologies

- Programming language: MATLAB
- Environment:  MATLAB Online
- Application area:Digital Signal Processing
- Visualization: MATLAB plots and comparative graphs
- Analysis: Numerical measurements, performance tables, and graphical comparisons

Additional MATLAB toolboxes may be required depending on the functions used by the implementation.

 How to Run the Project

1. Download or clone this repository to your computer.
2. Open MATLAB.
3. Set the repository directory as the current working folder.
4. Navigate to the `src/` directory or add it and its required subdirectories to the MATLAB path.
5. Open the main benchmark script and check that the required input data and helper functions are available.
6. Run the main script or the individual experiment scripts as instructed in the source code.
7. Review the generated figures, numerical results, and performance comparisons.

If an experiment requires a particular toolbox, dataset, or configuration, consult the relevant source file before running it.

Results and Analysis

The experimental results are documented through numerical measurements, graphs, and comparative analysis.

The intended result categories include:

- DFT versus FFT execution time.
- Computational operation-count comparisons.
- Frequency-resolution analysis.
- Direct versus FFT-based convolution performance.
- FIR and IIR frequency-response comparisons.
- Time-domain filtering results.
- Numerical accuracy and error analysis, where applicable.

The measured values and conclusions should be taken from the actual MATLAB experiments and presented in the final project report.

Project Deliverables

The repository is intended to contain the following project materials:

- Complete MATLAB source code.
- Final project report.
- Project presentation.

References

The theoretical background and experimental methodology should be supported by relevant research papers, textbooks, and technical documentation.

The complete references used in the project are listed in the final report. Dataset sources and any third-party implementations should be acknowledged where applicable.

Academic Information

- Project title: Comparative DSP Benchmark: DFT, FFT, FIR and IIR
- Project type: DSP Mini-Project
- Department:Electronics and Communication Engineering
- Academic year: 2026–2027
- Implementation environment: MATLAB

Author and Acknowledgements

This project was developed as part of the academic coursework in Digital Signal Processing.

Author: Raghav Bholeshwar Palange

PRN: 1022512013

Institution: DES Pune University, Pune

Project guide: Dr. Hrishikesh Vanjari

This repository is intended to support academic evaluation, verification of the implementation, and reproducibility of the documented experiments.
