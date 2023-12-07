function peaks = peak_detection(signal, fs, time_ms)
%PEAK_DETECTION Two-stage peak detection
%
% Pan-Tompkins R peak detection algorithm essentially detects peaks in a
% variously filtered version of the ECG signal.
% Sometimes, the beat shape changes such that a different peak becomes the
% maximum than before, which leads to the R peaks being detected at a
% different relative position in the beat. To recover from this, we perform 
% a two-stage procedure:
% 1) perform classical Pan-Tompkins peak detection algorithm
% 2) re-align each detected peak by correlation with the average peak.
%
% Copyright 2021 Institute for Electrical Engineering in Medicine, 
% University of Luebeck
% Eike Petersen, Julia Sauer
% 
% Permission is hereby granted, free of charge, to any person obtaining a 
% copy of this software and associated documentation files (the 
% "Software"), to deal in the Software without restriction, including 
% without limitation the rights to use, copy, modify, merge, publish, 
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the 
% following conditions:
% 
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
% OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR 
% THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[rPeaks, polarity] = peak_detection_pan_tompkin(signal, fs, .150, {}, {}, 0.3);

if polarity
    peak_sign = 1;
else
    peak_sign = -1;
end

% First, construct the average beat / QRS segment
rPeakIdces = find(rPeaks);
num_peaks = length(rPeakIdces);
% use a narrow section around R peak for alignment
lengthLeft = 200;
lengthRight = 200;
avgPeak = build_template(rPeakIdces, lengthLeft, lengthRight, signal, num_peaks, num_peaks, false);

peaks = rPeaks;
last_peak = -inf;
for ii = 2:(num_peaks-1)
    
    % Re-align beats by maximizing correlation with the average beat
%     window_start = max(1, rPeakIdces(ii)-lengthLeft);
%     window_end = min(size(signal,1), rPeakIdces(ii)+lengthRight);
%     current_peak = signal(window_start:window_end);


    current_peak = signal(rPeakIdces(ii)-lengthLeft:rPeakIdces(ii)+lengthRight);
    [correlation, lags] = xcorr(current_peak, avgPeak, 'coeff');
    [~, indexmax] = max(correlation);
    lag_corr = lags(indexmax); % lag > 0 => template must be shifted to the right
    
    % Finally, shift to the local optimum
    % To prevent getting stuck in *really* local optima, search the 11
    % surrounding samples
%     window_start = max(-5 + lengthLeft + 1 + lag_corr, 1);
%     window_end = min(5 + lengthLeft + 1 + lag_corr, size(current_peak,1));
%     peak_window = window_start:window_end;
%     [~, idxopt] = max(peak_sign * current_peak(peak_window));

    [~, idxopt] = max(peak_sign * current_peak((-5:5) + lengthLeft + 1 + lag_corr));
    lag_opt = lag_corr + idxopt - 6;
    
    peaks(rPeakIdces(ii)) = 0;
    if rPeakIdces(ii) + lag_opt - last_peak > 10
        peaks(rPeakIdces(ii)+lag_opt) = 1;
        last_peak = rPeakIdces(ii)+lag_opt;
    end
end

% In the end, all detected R peaks should be local maxima!
[~, idces] = findpeaks(peak_sign * signal);
sum_non_peaks = 0;
for idx = rPeakIdces
    if ~any(idx == idces)
        sum_non_peaks = sum_non_peaks + 1;
    end
end

if sum_non_peaks > 0
    fprintf('Found %d peaks which are not local maxima, which is unexpected.\n', sum_non_peaks);
end

if nargin > 2
    rPeakTimes = time_ms(rPeakIdces) / 1000;
else
    t = 0:1/fs:(length(signal)-1)/fs;
    rPeakTimes = t(rPeakIdces);
end
rPeakTimesRestricted = rPeakTimes(rPeakTimes > 1);
drPeakTimesRestricted = diff(rPeakTimesRestricted);
[val, idx] = min(drPeakTimesRestricted);
% disp(['Min RR interval is ', num2str(val), 's at ', num2str(rPeakTimesRestricted(idx)), 's.']);
[val, idx] = max(drPeakTimesRestricted);
% disp(['Max RR interval is ', num2str(val), 's at ', num2str(rPeakTimesRestricted(idx)), 's.']);    

end