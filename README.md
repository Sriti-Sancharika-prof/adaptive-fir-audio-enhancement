Adaptive FIR Audio Enhancement using Hamming and Blackman Windows
Overview

This project presents the design and analysis of a multi-stage FIR filtering framework for audio signal enhancement and noise suppression. The system employs classical window-based FIR filter design techniques, where Hamming and Blackman windows are applied adaptively to improve spectral performance.

The processing pipeline progressively enhances speech quality through successive filtering stages including notch filtering, band-pass filtering, and equalization.

📄 Detailed methodology, analysis, and performance plots are available in the project report:
adaptive_fir_audio_enhancement_report.pdf

Objectives

Analyze clean and noisy audio signals in time and frequency domains

Design FIR filters using windowing techniques

Implement adaptive window selection for improved noise suppression

Enhance speech clarity through multi-stage filtering

Evaluate performance using spectral comparison

Methodology

The signal processing framework consists of the following stages:

Signal Analysis

The original and noisy audio signals are examined in both time domain and frequency domain to identify dominant noise components and useful speech bandwidth.

FIR Notch Filter

A window-based FIR notch filter is designed to suppress narrowband interference and tonal noise components.

FIR Band-Pass Filter

A band-pass FIR filter is implemented to retain primary speech frequency components while attenuating out-of-band noise.

FIR Equalizer

A final FIR equalizer stage is used to improve spectral balance and perceptual quality of the processed signal.

Adaptive Window Selection

Blackman Window → Higher stopband attenuation and improved sidelobe suppression

Hamming Window → Narrower transition band and better signal preservation

Adaptive selection enables an effective trade-off between noise suppression and signal distortion.

Tools and Technologies

MATLAB

Digital Signal Processing (DSP)

FIR Filter Design

Window Functions (Hamming and Blackman)

Time–Frequency Analysis

Results

The proposed filtering framework demonstrates:

Reduction of broadband and tonal noise components

Improvement in speech intelligibility

Smoother spectral response after equalization

Progressive signal enhancement across filtering stages

Frequency-domain comparison plots in the report show clear reduction in noise power after each stage of filtering.

Repository Status

⚠️ MATLAB implementation files will be uploaded in a future update.
Currently, the repository contains the complete project report including design methodology, analysis, and results.

Author

Sriti Sancharika
VLSI | Digital Signal Processing | FPGA | Timing Analysis
