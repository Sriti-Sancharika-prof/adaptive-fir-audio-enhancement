# Adaptive Multi-Stage FIR Speech Enhancement using Hamming and Blackman Windows

## Project Overview

This project presents the design and implementation of a **multi-stage adaptive FIR filtering framework** for speech enhancement and noise suppression in audio signals. The system dynamically selects between **Hamming and Blackman window-based FIR filters** to achieve an effective trade-off between stopband attenuation, transition sharpness, and signal preservation.

The processing pipeline consists of **localized spectral interference detection, adaptive notch filtering, speech band-pass filtering, equalization, and amplitude compensation**, resulting in progressive improvement in signal quality.

The implementation is carried out in MATLAB using window-method FIR design and periodogram-based spectral estimation.

---

## System Workflow

### 1. Signal Acquisition and Pre-Processing

- Audio signal loaded using `audioread`
- Stereo signals converted to mono via channel averaging
- Signal duration and time vector computed for visualization
- Time-domain waveform and power spectral density estimated using **periodogram**

### Noise Injection

To simulate real acoustic degradation:

- Additive white Gaussian noise introduced  
- Noise scaling factor: **0.1**
- Noisy signal playback and visualization performed

---

## 2. Adaptive Notch Filtering

### Chunk-Based Spectral Analysis

The noisy signal is divided into:

- **Number of chunks:** 10  
- Each chunk processed independently to track time-varying interference

For each chunk:

1. Apply Hamming window  
2. Estimate spectrum using periodogram  
3. Detect dominant interference frequency using **peak power estimation**

### Notch Filter Design

- **Filter Order:** 40  
- **Bandwidth:** 30 Hz  
- Ideal band-stop impulse response derived using sinc formulation
- Linear-phase FIR design using window method

Two filters are generated:

- Hamming window FIR notch filter  
- Blackman window FIR notch filter  

### Adaptive Window Selection Logic

Filtering decision is based on:

> Variance comparison of filtered chunk outputs.

- Lower variance interpreted as improved noise suppression
- Corresponding filter output selected and merged into final signal

This mechanism enables adaptive control of:

- Sidelobe suppression  
- Transition region sharpness  
- Residual noise energy  

---

## 3. Speech Band-Pass Enhancement

After interference suppression, a band-pass FIR filter enhances speech components.

- **Passband:** 50 Hz – 1000 Hz  
- **Filter Order:** 40  
- Window: Hamming  

Design approach:

- Ideal band-pass impulse response using sinc difference formulation
- Window multiplication for ripple control
- Output normalization to prevent amplitude scaling artifacts

This stage reduces:

- Low-frequency hum  
- High-frequency broadband noise  

---

## 4. Equalization Stage

A final FIR equalizer improves spectral balance and perceptual clarity.

- **Equalization Band:** 40 Hz – 1500 Hz  
- **Filter Order:** 40  
- Window-based FIR implementation

This stage compensates for:

- Passband attenuation introduced by earlier filtering  
- Residual spectral unevenness  

---

## 5. Gain Compensation

Filtering reduces signal amplitude due to energy removal.

- Gain factor applied: **1.5**
- Clipping prevention implemented using saturation constraint within [-1, 1]

---

## Performance Evaluation

### Signal-to-Noise Ratio (SNR)

System performance evaluated using:

\[
SNR = 10 \log_{10} \left( \frac{\sum s^2}{\sum (s - \hat{s})^2} \right)
\]

Measured at three stages:

- After noise addition  
- After adaptive notch filtering  
- After final equalization  

### Frequency Domain Comparison

Periodogram-based PSD plots show:

- High noise floor in corrupted signal  
- Reduction in dominant interference peaks  
- Progressive spectral smoothing after each filtering stage  

---

## Key Engineering Features

- Adaptive window selection (Hamming vs Blackman)
- Chunk-wise spectral interference tracking
- Linear-phase FIR implementation
- Multi-stage noise suppression architecture
- Variance-based adaptive decision logic
- Time-frequency visualization and analysis
- Quantitative SNR performance measurement
- Modular MATLAB DSP implementation

---

## Tools and Environment

- MATLAB
- FIR Window Design Method
- Periodogram Spectral Estimation
- Digital Signal Processing Toolbox

---

## Possible Extensions

- Real-time streaming implementation
- FPGA / fixed-point FIR architecture realization
- LMS or RLS adaptive filtering comparison
- Objective speech quality metrics (PESQ / STOI)
- Filter order optimization using Kaiser window design
- Multi-band equalization strategy

---

## Author

Sriti Sancharika  
VLSI | Digital Signal Processing | FPGA | Timing Analysis
