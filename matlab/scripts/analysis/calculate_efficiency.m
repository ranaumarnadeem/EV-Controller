%% Calculate Energy Efficiency
% This script calculates various efficiency metrics for the EV system
% including motor efficiency, regenerative braking efficiency, and overall system efficiency
%
% Author: EV Controller Team - NUST SEECS
% Date: November 2025

%% Check prerequisites
if ~exist('out', 'var')
    warning('No simulation data found. Loading sample data...');
    load_sample_data();
end

fprintf('Calculating Energy Efficiency Metrics...\n\n');

%% Extract Required Signals
try
    time = out.tout;
    dt = mean(diff(time));
    
    % Power signals
    motor_power = out.motor_power;              % [W]
    battery_power = out.battery_power;          % [W]
    
    % Motor signals
    motor_torque = out.motor_torque;            % [Nm]
    motor_speed = out.motor_speed;              % [RPM]
    
    % Vehicle signals
    vehicle_speed = out.vehicle_speed;          % [km/h]
    distance = out.position(end) / 1000;        % [km]
    
    % Battery signals
    battery_soc_initial = out.battery_soc(1);   % [%]
    battery_soc_final = out.battery_soc(end);   % [%]
    
catch
    error('Required signals not found in simulation output.');
end

%% 1. Motor Efficiency Calculation

fprintf('=== Motor Efficiency ===\n');

% Calculate mechanical power output
motor_speed_rads = motor_speed * (2*pi/60);     % Convert RPM to rad/s
motor_mech_power = motor_torque .* motor_speed_rads;  % [W]

% Calculate motor efficiency (simplified)
% Efficiency = Mechanical Power Output / Electrical Power Input
motor_efficiency = zeros(size(motor_power));
active_idx = abs(motor_power) > 100;  % Only calculate when motor is significantly active

motor_efficiency(active_idx) = abs(motor_mech_power(active_idx)) ./ ...
                                abs(motor_power(active_idx));

% Limit efficiency to realistic range [0, 1]
motor_efficiency = min(max(motor_efficiency, 0), 1);

% Calculate average efficiency during active operation
avg_motor_efficiency = mean(motor_efficiency(active_idx)) * 100;
peak_efficiency = max(motor_efficiency) * 100;

fprintf('Average Motor Efficiency: %.2f%%\n', avg_motor_efficiency);
fprintf('Peak Motor Efficiency: %.2f%%\n', peak_efficiency);

% Efficiency vs Speed
speed_bins = 0:500:8000;
eff_vs_speed = zeros(length(speed_bins)-1, 1);
for i = 1:length(speed_bins)-1
    idx = (motor_speed >= speed_bins(i)) & (motor_speed < speed_bins(i+1)) & active_idx;
    if any(idx)
        eff_vs_speed(i) = mean(motor_efficiency(idx)) * 100;
    end
end

fprintf('Efficiency by Speed Range:\n');
for i = 1:length(speed_bins)-1
    if eff_vs_speed(i) > 0
        fprintf('  %d-%d RPM: %.1f%%\n', speed_bins(i), speed_bins(i+1), eff_vs_speed(i));
    end
end
fprintf('\n');

%% 2. Regenerative Braking Efficiency

fprintf('=== Regenerative Braking ===\n');

% Identify regenerative braking periods (negative motor power)
regen_idx = motor_power < -100;  % Threshold for regen detection

if any(regen_idx)
    % Energy recovered during regeneration
    energy_regen = abs(trapz(time(regen_idx), motor_power(regen_idx))) / 3.6e6;  % [kWh]
    
    % Theoretical maximum recoverable energy (based on vehicle deceleration)
    vehicle_accel = gradient(vehicle_speed / 3.6) ./ dt;  % [m/s²]
    decel_idx = vehicle_accel < -0.1;
    
    vehicle_mass = 1500;  % [kg]
    energy_decel = vehicle_mass * trapz(time(decel_idx), ...
                   abs(vehicle_accel(decel_idx)) .* (vehicle_speed(decel_idx)/3.6)) / 2 / 3.6e6;  % [kWh]
    
    % Regenerative braking efficiency
    if energy_decel > 0
        regen_efficiency = (energy_regen / energy_decel) * 100;
    else
        regen_efficiency = 0;
    end
    
    fprintf('Energy Recovered: %.3f kWh\n', energy_regen);
    fprintf('Total Deceleration Energy: %.3f kWh\n', energy_decel);
    fprintf('Regenerative Braking Efficiency: %.1f%%\n', regen_efficiency);
    fprintf('Regen Time: %.1f s (%.1f%% of total)\n', ...
            sum(regen_idx)*dt, sum(regen_idx)*dt/time(end)*100);
else
    energy_regen = 0;
    regen_efficiency = 0;
    fprintf('No regenerative braking detected in simulation\n');
end
fprintf('\n');

%% 3. Battery Efficiency

fprintf('=== Battery Performance ===\n');

% Total energy from battery
energy_from_battery = trapz(time, max(battery_power, 0)) / 3.6e6;  % [kWh]

% Energy returned to battery (charging)
energy_to_battery = abs(trapz(time, min(battery_power, 0))) / 3.6e6;  % [kWh]

% Net energy consumed
net_energy = energy_from_battery - energy_to_battery;

% SOC-based energy consumption (more accurate)
battery_capacity = 60;  % [kWh] - should match init_parameters
energy_consumed_soc = (battery_soc_initial - battery_soc_final) * battery_capacity / 100;

fprintf('Energy from Battery: %.3f kWh\n', energy_from_battery);
fprintf('Energy to Battery (regen): %.3f kWh\n', energy_to_battery);
fprintf('Net Energy Consumed: %.3f kWh\n', net_energy);
fprintf('Energy from SOC Change: %.3f kWh\n', energy_consumed_soc);
fprintf('\n');

%% 4. Overall System Efficiency

fprintf('=== Overall System Efficiency ===\n');

% Energy consumption per distance
if distance > 0
    energy_per_100km = (energy_consumed_soc / distance) * 100;  % [kWh/100km]
    fprintf('Energy Consumption: %.2f kWh/100km\n', energy_per_100km);
    fprintf('Equivalent MPGe: %.1f MPGe\n', 33.7 / energy_per_100km * 100);
    fprintf('Distance per kWh: %.2f km/kWh\n', distance / energy_consumed_soc);
else
    energy_per_100km = 0;
    fprintf('Distance traveled: 0 km (no efficiency calculation possible)\n');
end

% Average power consumption
avg_power = mean(abs(battery_power)) / 1000;  % [kW]
fprintf('Average Power Draw: %.2f kW\n', avg_power);

% Peak power
peak_power_discharge = max(battery_power) / 1000;  % [kW]
peak_power_charge = abs(min(battery_power)) / 1000;  % [kW]
fprintf('Peak Discharge Power: %.2f kW\n', peak_power_discharge);
fprintf('Peak Charge Power: %.2f kW\n', peak_power_charge);

fprintf('\n');

%% 5. Efficiency Map

fprintf('=== Efficiency Map ===\n');

% Create 2D efficiency map: Torque vs Speed
speed_bins_map = linspace(0, 8000, 20);
torque_bins_map = linspace(-300, 300, 20);

efficiency_map = zeros(length(torque_bins_map)-1, length(speed_bins_map)-1);

for i = 1:length(torque_bins_map)-1
    for j = 1:length(speed_bins_map)-1
        idx = (motor_torque >= torque_bins_map(i)) & ...
              (motor_torque < torque_bins_map(i+1)) & ...
              (motor_speed >= speed_bins_map(j)) & ...
              (motor_speed < speed_bins_map(j+1)) & ...
              active_idx;
        
        if any(idx)
            efficiency_map(i, j) = mean(motor_efficiency(idx)) * 100;
        else
            efficiency_map(i, j) = NaN;
        end
    end
end

fprintf('Efficiency map calculated (%dx%d grid)\n', ...
        length(torque_bins_map)-1, length(speed_bins_map)-1);
fprintf('\n');

%% 6. Save Results

% Create results structure
efficiency_results = struct();
efficiency_results.timestamp = datetime('now');
efficiency_results.motor_avg_efficiency = avg_motor_efficiency;
efficiency_results.motor_peak_efficiency = peak_efficiency;
efficiency_results.regen_efficiency = regen_efficiency;
efficiency_results.energy_regen = energy_regen;
efficiency_results.energy_consumed = energy_consumed_soc;
efficiency_results.energy_per_100km = energy_per_100km;
efficiency_results.distance = distance;
efficiency_results.avg_power = avg_power;
efficiency_results.efficiency_map = efficiency_map;
efficiency_results.speed_bins_map = speed_bins_map;
efficiency_results.torque_bins_map = torque_bins_map;

% Save to file
save('results/performance_metrics/efficiency_results.mat', 'efficiency_results');
fprintf('Efficiency results saved to: results/performance_metrics/efficiency_results.mat\n');

%% 7. Generate Efficiency Plots

% Plot efficiency vs speed
figure('Name', 'Motor Efficiency Analysis', 'Position', [100, 100, 1200, 800]);

subplot(2, 2, 1);
plot(speed_bins(1:end-1) + diff(speed_bins)/2, eff_vs_speed, 'b-o', 'LineWidth', 1.5);
grid on;
xlabel('Motor Speed [RPM]');
ylabel('Efficiency [%]');
title('Motor Efficiency vs Speed');
xlim([0, 8000]);
ylim([0, 100]);

% Plot efficiency map
subplot(2, 2, 2);
[X, Y] = meshgrid(speed_bins_map(1:end-1), torque_bins_map(1:end-1));
contourf(X, Y, efficiency_map, 20);
colorbar;
xlabel('Motor Speed [RPM]');
ylabel('Motor Torque [Nm]');
title('Motor Efficiency Map [%]');

% Plot power distribution
subplot(2, 2, 3);
histogram(motor_power/1000, 50, 'FaceColor', 'g');
hold on;
xline(0, 'r--', 'LineWidth', 2);
grid on;
xlabel('Power [kW]');
ylabel('Frequency');
title('Motor Power Distribution');

% Plot cumulative energy
subplot(2, 2, 4);
cumulative_energy = cumtrapz(time, max(battery_power, 0)) / 3.6e6;  % [kWh]
cumulative_regen = abs(cumtrapz(time, min(battery_power, 0))) / 3.6e6;  % [kWh]
plot(time, cumulative_energy, 'r', 'LineWidth', 1.5);
hold on;
plot(time, cumulative_regen, 'g', 'LineWidth', 1.5);
plot(time, cumulative_energy - cumulative_regen, 'b', 'LineWidth', 1.5);
grid on;
xlabel('Time [s]');
ylabel('Energy [kWh]');
title('Cumulative Energy Flow');
legend('Consumed', 'Recovered', 'Net', 'Location', 'best');

% Save figure
saveas(gcf, 'results/plots/efficiency_analysis.png');
fprintf('Efficiency plots saved to: results/plots/efficiency_analysis.png\n');

fprintf('\n=== Efficiency Calculation Complete ===\n');

%% Helper Function
function load_sample_data()
    % Load or create sample data for testing
    warning('Creating sample data structure for demonstration');
    
    global out;
    out = struct();
    out.tout = (0:0.01:100)';
    out.motor_power = 50000 * ones(size(out.tout));
    out.battery_power = 52000 * ones(size(out.tout));
    out.motor_torque = 200 * ones(size(out.tout));
    out.motor_speed = 3000 * ones(size(out.tout));
    out.vehicle_speed = 80 * ones(size(out.tout));
    out.position = linspace(0, 2000, length(out.tout))';
    out.battery_soc = linspace(100, 95, length(out.tout))';
end
