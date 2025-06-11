%% Read EMG data
clear;clc;
load('sub01.mat', 'emg', 'gait_phase');
% Previously, the data only had sensors on the right leg. Here, it is assumed that 1, 3, 5, 7 are on the left side, and 2, 4, 6, 8 are on the right side.
gait_phase_R = EMG_C(:, 6);
EMG = EMG_C(1:length(gait_phase_R(:, 1)), 2:3);
% clear emg
clear median_frequency_R seg_points_R median_frequency_L seg_points_L

%% Segment according to gait phase labels
% Find segmentation points for right leg
j = 1;
for i = 1:length(gait_phase_R) - 1
    if gait_phase_R(i) == 4 && gait_phase_R(i + 1) == 1
        seg_points_R(j) = i + 1;
        j = j + 1;
    end
end
n_gaits_R = length(seg_points_R) - 1;

%% Some preprocessing
% Filtering
fs = 1111.11;
% Bandpass filter
[b, a] = butter(4, [2*20/fs, 2*300/fs], 'bandpass');
EMG_f = filtfilt(b, a, EMG);
% Notch filter
b = fir1(100, [2*49/fs, 2*51/fs], 'stop');
EMG_f = filtfilt(b, 1, EMG_f);

%% Calculate features for each gait on the right leg
median_frequency_R = zeros(n_gaits_R, 2);
for i = 1:n_gaits_R
    EMG_gait_R = EMG_f(seg_points_R(i):seg_points_R(i + 1), 1:2);
    % Time domain features
    % RMS-EMG ratio
    % RMS(i, 1:2) = sqrt(mean(EMG_gait_R.^2, 1));
    % RMS_ratio(i, :) = RMS(1:2:end)./RMS(2:2:end);
    % Frequency domain features
    [p1, f1] = pwelch(EMG_gait_R(:, 1), [], [], [], fs); % fs is the sampling frequency
    cumulative_power1 = cumsum(p1);
    median_frequency_index1 = find(cumulative_power1 >= 0.5*sum(p1), 1, 'first');
    median_frequency_R(i, 1) = f1(median_frequency_index1);

    [p2, f2] = pwelch(EMG_gait_R(:, 2), [], [], [], fs); % fs is the sampling frequency
    cumulative_power2 = cumsum(p2);
    median_frequency_index2 = find(cumulative_power2 >= 0.5*sum(p2), 1, 'first');
    median_frequency_R(i, 2) = f2(median_frequency_index2);
end

%% Save the calculated features
save('emg_features.mat', 'median_frequency_R', 'RMS', 'seg_points_R');