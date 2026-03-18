clc;
clear;  
close all;

%% --- 1. Load Audio Signal ---
try
    [audio_signal, fs] = audioread('hello_me.wav');
    if size(audio_signal, 2) > 1
        audio_signal = mean(audio_signal, 2); % Converted to mono
    end
catch ME
    error('Error reading audio file: %s', ME.message);
end

duration_audio = length(audio_signal) / fs;
t_audio = linspace(0, duration_audio, length(audio_signal));


%% --- Display Original Signal ---
figure;
subplot(2,1,1);
plot(t_audio, audio_signal, 'k');
title('Original Audio Signal (Time Domain)');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2,1,2);
[pxx_original, f_original] = periodogram(audio_signal, [], length(audio_signal), fs);
plot(f_original, 10*log10(pxx_original), 'k');
title('Original Audio Signal (Frequency Domain)');
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');


%% --- 2. Add Random Noise ---
noise_level = 0.1;
random_noise = noise_level * randn(size(audio_signal));
noisy_signal = audio_signal + random_noise;

disp('Playing Noisy Audio Signal...');
soundsc(noisy_signal, fs);
pause(duration_audio + 1);

%% Time Plot - Noisy
figure;
plot(t_audio, noisy_signal);
title('Noisy Signal - Time Domain');
xlabel('Time (s)'); ylabel('Amplitude');

%% --- 3. Adaptive Notch Filtering with Custom Windows ---
num_chunks = 10;
chunk_length = floor(length(noisy_signal) / num_chunks);
filtered_signal = noisy_signal;

for i = 1:num_chunks
    chunk_start = (i - 1) * chunk_length + 1;
    chunk_end = min(i * chunk_length, length(noisy_signal));
    chunk = noisy_signal(chunk_start:chunk_end);
    
    N = length(chunk);
    hamming_window = 0.54 - 0.46 * cos(2 * pi * (0:N-1)' / (N-1));
    [pxx, f] = periodogram(chunk .* hamming_window, [], N, fs);
    
    [~, peak_idx] = max(pxx);
    notch_freq = f(peak_idx);
    
    bw = 30;
    lowcut = max(0, (notch_freq - bw/2) / (fs/2));
    highcut = min(1, (notch_freq + bw/2) / (fs/2));
    
    filter_order_notch = 40;
    n = 0:filter_order_notch;
    mid = filter_order_notch / 2;

    h_low = 2 * lowcut * sinc(2 * lowcut * (n - mid));
    h_high = 2 * highcut * sinc(2 * highcut * (n - mid));
    h_ideal = -(h_high - h_low);
    h_ideal(mid+1) = h_ideal(mid+1) + 1;

    hamming_window_filter = 0.54 - 0.46 * cos(2 * pi * n / filter_order_notch);
    fir_hamming = h_ideal .* hamming_window_filter';
    fir_hamming = fir_hamming / sum(fir_hamming);

    chunk_hamming_filtered = filter(fir_hamming, 1, chunk);

    blackman_window_filter = 0.42 - 0.5 * cos(2 * pi * n / filter_order_notch) + 0.08 * cos(4 * pi * n / filter_order_notch);
    fir_blackman = h_ideal .* blackman_window_filter';
    fir_blackman = fir_blackman / sum(fir_blackman);

    chunk_blackman_filtered = filter(fir_blackman, 1, chunk);

    if var(chunk_hamming_filtered) > var(chunk_blackman_filtered)
        filtered_signal(chunk_start:chunk_end) = chunk_hamming_filtered;
        disp(['Chunk ', num2str(i), ': Hamming window chosen.']);
    else
        filtered_signal(chunk_start:chunk_end) = chunk_blackman_filtered;
        disp(['Chunk ', num2str(i), ': Blackman window chosen.']);
    end
end

filtered_signal = filtered_signal / max(abs(filtered_signal));
disp('Playing Filtered Audio Signal...');
soundsc(filtered_signal, fs);
pause(duration_audio + 1);

%% Time Plot - Filtered
figure;
plot(t_audio, filtered_signal);
title('Filtered Signal - Time Domain');
xlabel('Time (s)'); 
ylabel('Amplitude');

%% Frequency Response - Notch Filter (example)
figure;
freqz(fir_hamming, 1, 1024, fs);
title('Notch Filter Frequency Response (Example Chunk)');

%% --- 4. Bandpass Filter for Speech Enhancement ---
lowcut_speech = 50 / (fs/2);
highcut_speech = 1000 / (fs/2);
filter_order_speech = 40;
n = 0:filter_order_speech;
mid = filter_order_speech / 2;

h_low = 2 * lowcut_speech * sinc(2 * lowcut_speech * (n - mid));
h_high = 2 * highcut_speech * sinc(2 * highcut_speech * (n - mid));
h_ideal_bandpass = h_high - h_low;

hamming_window_speech = 0.54 - 0.46 * cos(2 * pi * n / filter_order_speech);
fir_speech = h_ideal_bandpass .* hamming_window_speech';
fir_speech = fir_speech / sum(fir_speech);

enhanced_speech = filter(fir_speech, 1, filtered_signal);
enhanced_speech = enhanced_speech / max(abs(enhanced_speech));

disp('Playing Speech-Enhanced Audio...');
soundsc(enhanced_speech, fs);
pause(duration_audio + 1);

%% Time Plot - Enhanced Speech
figure;
plot(t_audio, enhanced_speech);
title('Enhanced Speech - Time Domain');
xlabel('Time (s)'); ylabel('Amplitude');

%% Frequency Response - Bandpass Filter
figure;
freqz(fir_speech, 1, 1024, fs);
title('Bandpass Filter Frequency Response (Speech Enhancement)');

%% --- 5. Equalization ---
n_eq = 0:40;
mid_eq = 40/2;

low_eq = 40 / (fs/2);
high_eq = 1500 / (fs/2);

h_low_eq = 2 * low_eq * sinc(2 * low_eq * (n_eq - mid_eq));
h_high_eq = 2 * high_eq * sinc(2 * high_eq * (n_eq - mid_eq));
h_ideal_eq = h_high_eq - h_low_eq;

hamming_window_eq = 0.54 - 0.46 * cos(2 * pi * n_eq / 40);
equalizer = h_ideal_eq .* hamming_window_eq';
equalizer = equalizer / sum(equalizer);

equalized_signal = filter(equalizer, 1, enhanced_speech);
equalized_signal = equalized_signal / max(abs(equalized_signal));

disp('Playing Equalized Audio...');
soundsc(equalized_signal, fs);
pause(duration_audio + 1);

%% Time Plot - Equalized Signal
figure;
plot(t_audio, equalized_signal);
title('Equalized Signal - Time Domain');
xlabel('Time (s)'); ylabel('Amplitude');

%% Frequency Response - Equalizer
figure;
freqz(equalizer, 1, 800, fs);
title('Equalizer Frequency Response');

%% --- 6. SNR Feedback ---
snr_noisy = 10 * log10(sum(audio_signal.^2) / sum((audio_signal - noisy_signal).^2));
snr_filtered = 10 * log10(sum(audio_signal.^2) / sum((audio_signal - filtered_signal).^2));
snr_final = 10 * log10(sum(audio_signal.^2) / sum((audio_signal - equalized_signal).^2));

fprintf('\n--- SNR Results ---\n');
fprintf('SNR after adding noise: %.2f dB\n', snr_noisy);
fprintf('SNR after filtering: %.2f dB\n', snr_filtered);
fprintf('SNR after final processing: %.2f dB\n', snr_final);

%% --- 7. Frequency Domain Comparison ---
figure;
[pxx_noisy, f_noisy] = periodogram(noisy_signal, [], length(noisy_signal), fs);
[pxx_filtered, f_filtered] = periodogram(filtered_signal, [], length(filtered_signal), fs);
[pxx_final, f_final] = periodogram(equalized_signal, [], length(equalized_signal), fs);

plot(f_noisy, 10*log10(pxx_noisy), 'r');
hold on;
plot(f_filtered, 10*log10(pxx_filtered), 'g');
plot(f_final, 10*log10(pxx_final), 'b');
title('Frequency-Domain Comparison');
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
legend('Noisy', 'Filtered', 'Final');
grid on;

%% ---Gain Boost ---
gain_factor = 1.5; 
amplified_signal = equalized_signal * gain_factor;

% Prevent clipping by ensuring values stay within [-1, 1]
amplified_signal = max(min(amplified_signal, 1), -1);

disp('Playing Amplified Audio...');
soundsc(amplified_signal, fs);
pause(duration_audio + 1);