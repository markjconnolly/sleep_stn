
function cleaned = ecg_removal(signal, fs)
use_filtfilt = true;

signalhp10 = butter_filt_stabilized(signal, 10, fs, 'high', use_filtfilt, 6);

rpeaks = peak_detection(signalhp10, fs);
cleaned = adaptive_template_subtraction(signal, rpeaks, fs);

% cleaned = cleaned(101:end-100);

% data = Ch2.values;
% fs = 500;
% n_seconds = 10;
% 
% signal = data(fs*10:fs*30);
% 
% fs = 500; fpl = 50;  % fpl is powerline frequency (typically 50Hz or 60Hz)
% 
% % power line interference removal
% signal = butter_filt_stabilized(signal, [fpl-1 fpl+1], fs, 'stop', use_filtfilt, 2);

% mild high-pass filtering (two versions, one for R peak detection and one for cardiac artifact removal) 
% to remove baseline wander and some ECG interference (especially in the 20Hz version)
% signalhp10 = butter_filt_stabilized(signal, 10, fs, 'high', use_filtfilt, 6);
% signalhp20 = butter_filt_stabilized(signal, 20, fs, 'high', use_filtfilt, 6);

% plot(signal)
% hold on
% plot(signalhp10)

% R peak detection, slightly modified version of Pan-Tompkins
% rpeaks = peak_detection(signalhp10, fs);
% rpeaks = peak_detection(signal, fs);

% This is the actual cardiac artifact removal step
% cleaned = adaptive_template_subtraction(signalhp20, rpeaks, fs);
% cleaned = adaptive_template_subtraction(signal, rpeaks, fs);
% figure
% plot(signal)
% hold on
% plot(cleaned)


