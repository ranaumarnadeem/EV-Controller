%% Data Processing Utilities
% Collection of data processing functions for the EV Controller project
%
% Author: EV Controller Team - NUST SEECS
% Date: November 2025

%% Signal Filtering

function filtered = low_pass_filter(signal, cutoff_freq, sample_rate)
    % Apply low-pass Butterworth filter to signal
    % Inputs:
    %   signal: Input signal vector
    %   cutoff_freq: Cutoff frequency [Hz]
    %   sample_rate: Sample rate [Hz]
    % Output:
    %   filtered: Filtered signal
    
    % Design filter
    order = 2;
    [b, a] = butter(order, cutoff_freq/(sample_rate/2), 'low');
    
    % Apply filter
    filtered = filtfilt(b, a, signal);
end

function filtered = moving_average(signal, window_size)
    % Apply moving average filter
    % Inputs:
    %   signal: Input signal vector
    %   window_size: Number of points in window
    % Output:
    %   filtered: Filtered signal
    
    if window_size < 1
        error('Window size must be at least 1');
    end
    
    filtered = movmean(signal, window_size);
end

%% Data Interpolation

function interp_data = interpolate_data(time, data, new_time)
    % Interpolate data to new time vector
    % Inputs:
    %   time: Original time vector
    %   data: Original data vector
    %   new_time: New time vector for interpolation
    % Output:
    %   interp_data: Interpolated data
    
    interp_data = interp1(time, data, new_time, 'linear', 'extrap');
end

%% Data Resampling

function [new_time, new_data] = resample_data(time, data, new_sample_rate)
    % Resample data to new sample rate
    % Inputs:
    %   time: Original time vector [s]
    %   data: Original data vector
    %   new_sample_rate: New sample rate [Hz]
    % Outputs:
    %   new_time: New time vector
    %   new_data: Resampled data
    
    % Create new time vector
    new_time = (time(1):1/new_sample_rate:time(end))';
    
    % Interpolate data
    new_data = interp1(time, data, new_time, 'linear', 'extrap');
end

%% Derivative Calculation

function deriv = calculate_derivative(time, signal)
    % Calculate numerical derivative of signal
    % Inputs:
    %   time: Time vector
    %   signal: Signal vector
    % Output:
    %   deriv: Derivative of signal
    
    deriv = gradient(signal) ./ gradient(time);
end

%% Integration

function integral = calculate_integral(time, signal)
    % Calculate numerical integral of signal
    % Inputs:
    %   time: Time vector
    %   signal: Signal vector
    % Output:
    %   integral: Integral of signal
    
    integral = cumtrapz(time, signal);
end

%% Data Segmentation

function segments = segment_data(time, data, condition)
    % Segment data based on condition
    % Inputs:
    %   time: Time vector
    %   data: Data vector
    %   condition: Logical vector indicating segments
    % Output:
    %   segments: Cell array of data segments
    
    % Find segment boundaries
    diff_condition = diff([0; condition; 0]);
    starts = find(diff_condition == 1);
    ends = find(diff_condition == -1) - 1;
    
    % Extract segments
    segments = cell(length(starts), 1);
    for i = 1:length(starts)
        segments{i}.time = time(starts(i):ends(i));
        segments{i}.data = data(starts(i):ends(i));
    end
end

%% Statistical Analysis

function stats = calculate_statistics(data)
    % Calculate statistical measures of data
    % Input:
    %   data: Data vector
    % Output:
    %   stats: Structure with statistical measures
    
    stats.mean = mean(data);
    stats.median = median(data);
    stats.std = std(data);
    stats.min = min(data);
    stats.max = max(data);
    stats.range = range(data);
    stats.rms = rms(data);
end

%% Outlier Detection

function [clean_data, outliers] = remove_outliers(data, method, threshold)
    % Remove outliers from data
    % Inputs:
    %   data: Data vector
    %   method: 'std' (standard deviation) or 'iqr' (interquartile range)
    %   threshold: Number of std or IQR for outlier detection
    % Outputs:
    %   clean_data: Data with outliers removed
    %   outliers: Logical vector indicating outliers
    
    if nargin < 3
        threshold = 3;  % Default threshold
    end
    if nargin < 2
        method = 'std';  % Default method
    end
    
    switch method
        case 'std'
            mu = mean(data);
            sigma = std(data);
            outliers = abs(data - mu) > threshold * sigma;
        case 'iqr'
            q1 = quantile(data, 0.25);
            q3 = quantile(data, 0.75);
            iqr_val = q3 - q1;
            outliers = (data < q1 - threshold*iqr_val) | ...
                      (data > q3 + threshold*iqr_val);
        otherwise
            error('Unknown method. Use ''std'' or ''iqr''');
    end
    
    clean_data = data;
    clean_data(outliers) = NaN;
end

%% Data Smoothing

function smoothed = smooth_data(data, method, span)
    % Smooth data using various methods
    % Inputs:
    %   data: Data vector
    %   method: 'moving', 'lowess', 'loess', 'sgolay', 'rlowess', 'rloess'
    %   span: Smoothing span
    % Output:
    %   smoothed: Smoothed data
    
    if nargin < 3
        span = 5;  % Default span
    end
    if nargin < 2
        method = 'moving';  % Default method
    end
    
    smoothed = smooth(data, span, method);
end

%% Find Peaks and Valleys

function [peaks, valleys] = find_peaks_valleys(data, min_prominence)
    % Find peaks and valleys in data
    % Inputs:
    %   data: Data vector
    %   min_prominence: Minimum prominence for peak detection
    % Outputs:
    %   peaks: Structure with peak locations and values
    %   valleys: Structure with valley locations and values
    
    if nargin < 2
        min_prominence = std(data) * 0.5;
    end
    
    % Find peaks
    [peak_vals, peak_locs] = findpeaks(data, 'MinPeakProminence', min_prominence);
    peaks.values = peak_vals;
    peaks.locations = peak_locs;
    
    % Find valleys (peaks of inverted signal)
    [valley_vals, valley_locs] = findpeaks(-data, 'MinPeakProminence', min_prominence);
    valleys.values = -valley_vals;
    valleys.locations = valley_locs;
end

%% Data Export

function export_to_csv(filename, time, varargin)
    % Export data to CSV file
    % Inputs:
    %   filename: Output filename
    %   time: Time vector
    %   varargin: Pairs of signal names and data vectors
    %
    % Example: export_to_csv('results.csv', time, 'Speed', speed, 'Torque', torque)
    
    if mod(length(varargin), 2) ~= 0
        error('Signal names and data must come in pairs');
    end
    
    % Create table
    data_table = table(time, 'VariableNames', {'Time'});
    
    % Add signals
    for i = 1:2:length(varargin)
        signal_name = varargin{i};
        signal_data = varargin{i+1};
        data_table.(signal_name) = signal_data;
    end
    
    % Write to CSV
    writetable(data_table, filename);
    fprintf('Data exported to: %s\n', filename);
end

%% Data Validation

function is_valid = validate_signal(signal, min_val, max_val)
    % Validate that signal is within acceptable range
    % Inputs:
    %   signal: Signal vector
    %   min_val: Minimum acceptable value
    %   max_val: Maximum acceptable value
    % Output:
    %   is_valid: True if all values are within range
    
    is_valid = all(signal >= min_val & signal <= max_val);
    
    if ~is_valid
        warning('Signal contains values outside acceptable range [%.2f, %.2f]', ...
                min_val, max_val);
    end
end
