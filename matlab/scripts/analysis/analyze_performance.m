%% Analyze Performance
% This script analyzes the performance of the EV controller system
% from simulation results and generates performance metrics
%
% Author: EV Controller Team - NUST SEECS
% Date: November 2025

%% Check if simulation data exists
if ~exist('out', 'var') && ~exist('logsout', 'var')
    error('No simulation data found. Please run a simulation first.');
end

fprintf('Analyzing EV Controller Performance...\n\n');

%% Extract Time-Series Data
% Modify these variable names based on your actual Simulink logging
try
    % Attempt to extract logged signals
    time = out.tout;
    
    % Vehicle state
    vehicle_speed = out.vehicle_speed;      % [km/h]
    vehicle_accel = out.vehicle_accel;      % [m/s²]
    position = out.position;                % [m]
    
    % Motor state
    motor_torque = out.motor_torque;        % [N·m]
    motor_speed = out.motor_speed;          % [RPM]
    motor_power = out.motor_power;          % [W]
    motor_temp = out.motor_temp;            % [°C]
    
    % Battery state
    battery_soc = out.battery_soc;          % [%]
    battery_voltage = out.battery_voltage;  % [V]
    battery_current = out.battery_current;  % [A]
    
    % Control signals
    cc_active = out.cc_active;              % [boolean]
    acc_active = out.acc_active;            % [boolean]
    set_speed = out.set_speed;              % [km/h]
    
    fprintf('[OK] Simulation data loaded successfully\n\n');
catch
    warning('Could not extract all signals. Using dummy data for demonstration.');
    % Create dummy data for demonstration
    time = (0:0.01:100)';
    vehicle_speed = 50 * ones(size(time));
    motor_torque = 100 * ones(size(time));
    battery_soc = linspace(100, 80, length(time))';
end

%% Performance Metrics Calculation

% 1. Energy Consumption
energy_consumed = calculate_energy_consumption(time, motor_power);
distance_traveled = position(end) / 1000;  % Convert to km
energy_per_km = energy_consumed / distance_traveled;  % [kWh/100km]

fprintf('=== Energy Performance ===\n');
fprintf('Total Energy Consumed: %.2f kWh\n', energy_consumed);
fprintf('Distance Traveled: %.2f km\n', distance_traveled);
fprintf('Energy Consumption: %.2f kWh/100km\n', energy_per_km * 100);
fprintf('Final Battery SOC: %.1f%%\n\n', battery_soc(end));

% 2. Motor Efficiency
motor_efficiency = calculate_motor_efficiency(motor_torque, motor_speed);
avg_motor_efficiency = mean(motor_efficiency(motor_power > 1000)) * 100;  % Exclude idle

fprintf('=== Motor Performance ===\n');
fprintf('Average Motor Efficiency: %.1f%%\n', avg_motor_efficiency);
fprintf('Peak Motor Torque: %.1f Nm\n', max(abs(motor_torque)));
fprintf('Peak Motor Speed: %.0f RPM\n', max(motor_speed));
fprintf('Peak Motor Power: %.1f kW\n', max(motor_power)/1000);
fprintf('Average Motor Temperature: %.1f°C\n', mean(motor_temp));
fprintf('Peak Motor Temperature: %.1f°C\n\n', max(motor_temp));

% 3. Vehicle Performance
max_accel = max(vehicle_accel);
max_decel = min(vehicle_accel);
avg_speed = mean(vehicle_speed);

% Calculate 0-100 km/h time (if available in data)
idx_100 = find(vehicle_speed >= 100, 1, 'first');
if ~isempty(idx_100)
    time_0_100 = time(idx_100);
    fprintf('=== Vehicle Performance ===\n');
    fprintf('0-100 km/h Time: %.2f s\n', time_0_100);
else
    fprintf('=== Vehicle Performance ===\n');
    fprintf('0-100 km/h Time: N/A (not reached in simulation)\n');
end

fprintf('Maximum Acceleration: %.2f m/s²\n', max_accel);
fprintf('Maximum Deceleration: %.2f m/s²\n', abs(max_decel));
fprintf('Average Speed: %.1f km/h\n', avg_speed);
fprintf('Maximum Speed: %.1f km/h\n\n', max(vehicle_speed));

% 4. Cruise Control Performance (if active)
cc_time = sum(cc_active) * mean(diff(time));
if cc_time > 0
    cc_speed_error = calculate_cc_error(vehicle_speed, set_speed, cc_active);
    
    fprintf('=== Cruise Control Performance ===\n');
    fprintf('CC Active Time: %.1f s (%.1f%%)\n', cc_time, cc_time/time(end)*100);
    fprintf('Average Speed Error: %.2f km/h\n', mean(abs(cc_speed_error)));
    fprintf('Max Speed Error: %.2f km/h\n', max(abs(cc_speed_error)));
    fprintf('Speed Control RMS Error: %.2f km/h\n\n', rms(cc_speed_error));
else
    fprintf('=== Cruise Control Performance ===\n');
    fprintf('CC was not active during simulation\n\n');
end

% 5. ACC Performance (if active)
acc_time = sum(acc_active) * mean(diff(time));
if acc_time > 0
    fprintf('=== Adaptive Cruise Control Performance ===\n');
    fprintf('ACC Active Time: %.1f s (%.1f%%)\n', acc_time, acc_time/time(end)*100);
    
    % Additional ACC metrics would go here
    % (distance tracking, relative velocity, etc.)
    
    fprintf('\n');
else
    fprintf('=== Adaptive Cruise Control Performance ===\n');
    fprintf('ACC was not active during simulation\n\n');
end

% 6. System Efficiency
overall_efficiency = calculate_overall_efficiency(energy_consumed, battery_soc, distance_traveled);

fprintf('=== Overall System Efficiency ===\n');
fprintf('System Efficiency: %.1f%%\n', overall_efficiency);
fprintf('Regenerative Braking Energy: %.2f kWh (est.)\n\n', calculate_regen_energy(motor_power, time));

% 7. Safety Metrics
fprintf('=== Safety Metrics ===\n');
fprintf('Maximum Jerk: %.2f m/s³\n', max(abs(diff(vehicle_accel)./diff(time))));

% Check for violations
violations = check_safety_violations(vehicle_accel, motor_temp, battery_voltage);
fprintf('Safety Violations: %d\n\n', violations);

%% Generate Performance Report
performance_report = struct();
performance_report.timestamp = datetime('now');
performance_report.energy_consumption = energy_per_km * 100;
performance_report.motor_efficiency = avg_motor_efficiency;
performance_report.max_speed = max(vehicle_speed);
performance_report.avg_speed = avg_speed;
performance_report.distance = distance_traveled;
performance_report.final_soc = battery_soc(end);

% Save report
save('results/performance_metrics/performance_report.mat', 'performance_report');
fprintf('Performance report saved to: results/performance_metrics/performance_report.mat\n');

fprintf('\n=== Analysis Complete ===\n');

%% Helper Functions

function energy = calculate_energy_consumption(time, power)
    % Calculate total energy consumed [kWh]
    if nargin < 2 || isempty(power)
        energy = 0;
        return;
    end
    dt = mean(diff(time));
    energy = trapz(time, max(power, 0)) / 3600 / 1000;  % Convert J to kWh
end

function efficiency = calculate_motor_efficiency(torque, speed)
    % Calculate instantaneous motor efficiency
    % This is a simplified model - replace with actual lookup table
    efficiency = 0.9 * ones(size(torque));  % Placeholder
    efficiency(abs(torque) < 10) = 0.5;     % Low efficiency at low torque
end

function error = calculate_cc_error(actual_speed, set_speed, cc_active)
    % Calculate cruise control speed tracking error
    error = (actual_speed - set_speed) .* cc_active;
end

function efficiency = calculate_overall_efficiency(energy, soc, distance)
    % Calculate overall system efficiency (placeholder)
    if distance > 0
        efficiency = 85;  % Placeholder value
    else
        efficiency = 0;
    end
end

function regen_energy = calculate_regen_energy(power, time)
    % Calculate regenerative braking energy
    if nargin < 2 || isempty(power)
        regen_energy = 0;
        return;
    end
    negative_power = min(power, 0);
    regen_energy = abs(trapz(time, negative_power)) / 3600 / 1000;  % kWh
end

function violations = check_safety_violations(accel, temp, voltage)
    % Check for safety limit violations
    violations = 0;
    
    % Check acceleration limits
    if any(abs(accel) > 5.0)
        violations = violations + sum(abs(accel) > 5.0);
    end
    
    % Check temperature limits
    if any(temp > 150)
        violations = violations + sum(temp > 150);
    end
    
    % Check voltage limits
    if any(voltage < 280) || any(voltage > 420)
        violations = violations + sum(voltage < 280) + sum(voltage > 420);
    end
end
