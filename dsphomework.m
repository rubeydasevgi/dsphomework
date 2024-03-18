duration = 3; % Duration of the recording in seconds
filename_prefix = 'output'; % Prefix for the output filename
sampling_rates = [8000, 16000, 44100, 48000]; % Sampling rates to test

results = table('Size', [length(sampling_rates), 3], 'VariableTypes', {'double', 'string', 'double'}, ...
    'VariableNames', {'SamplingRate', 'Filename', 'SNR_dB'});

for i = 1:length(sampling_rates)
    samplerate = sampling_rates(i);
    disp(['Recording audio for ', num2str(duration), ' seconds at ', num2str(samplerate), ' Hz...']);
    recObj = audiorecorder(samplerate, 16, 1); % Create audio recorder object
    recordblocking(recObj, duration); % Record audio
    audio_data = getaudiodata(recObj); % Get recorded audio data
    
    % Calculate SNR
    signal_start = round(length(audio_data) * 0.04); % Start of signal (40% into the recording)
    signal_end = round(length(audio_data) * 0.99); % End of signal (99% into the recording)
    snr_value = calculate_snr(audio_data, signal_start, signal_end);
    disp(['SNR: ', num2str(snr_value), ' dB']);
    
    % Save audio data to WAV file
    filename = [filename_prefix, '_', num2str(samplerate), 'Hz.wav']; % Construct output filename
    audiowrite(filename, audio_data, samplerate); % Save audio data to WAV file
    disp(['Audio saved as ', filename]);
    
    % Update results table
    results.SamplingRate(i) = samplerate;
    results.Filename(i) = filename;
    results.SNR_dB(i) = snr_value;
end

disp(results);

% Plotting
figure;
plot(results.SamplingRate, results.SNR_dB, 'o-');
xlabel('Sampling Rate (Hz)');
ylabel('SNR (dB)');
title('SNR vs. Sampling Rate');
grid on;

function snr_value = calculate_snr(audio_data, signal_start, signal_end)
    % Calculate the power of the signal
    signal_power = sum(abs(audio_data(signal_start:signal_end)).^2);

    % Calculate the power of the noise (before the signal)
    noise_power_before = sum(abs(audio_data(1:signal_start-1)).^2);

    % Calculate the power of the noise (after the signal)
    noise_power_after = sum(abs(audio_data(signal_end+1:end)).^2);

    % Calculate the total noise power
    noise_power = noise_power_before + noise_power_after;

    % Calculate the SNR
    snr_value = 10 * log10(signal_power / noise_power);
end
