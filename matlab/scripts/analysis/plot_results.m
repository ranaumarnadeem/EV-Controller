%% Plot Simulation Results
% This script creates comprehensive plots of simulation results
% for the EV controller system
%
% Author: EV Controller Team - NUST SEECS
% Date: November 2025

%% Check if simulation data exists
if ~exist('out', 'var') && ~exist('logsout', 'var')
    warning('No simulation data found. Creating sample plots with dummy data.');
    create_sample_plots();
    return;
end

fprintf('Generating plots from simulation results...\n');

%% Extract Time-Series Data
try
    % Extract logged signals (modify based on actual signal names)
    time = out.tout;
    
    % Vehicle state
    vehicle_speed = out.vehicle_speed;
    vehicle_accel = out.vehicle_accel;
    position = out.position;
    
    % Motor state
    motor_torque = out.motor_torque;
    motor_speed = out.motor_speed;
    motor_power = out.motor_power;
    motor_current = out.motor_current;
    motor_temp = out.motor_temp;
    
    % Battery state
    battery_soc = out.battery_soc;
    battery_voltage = out.battery_voltage;
    battery_current = out.battery_current;
    battery_power = out.battery_power;
    
    % Control signals
    cc_active = out.cc_active;
    acc_active = out.acc_active;
    set_speed = out.set_speed;
    
    fprintf('Simulation data loaded successfully\n');
catch
    warning('Could not extract signals. Using sample data.');
    create_sample_plots();
    return;
end

%% Figure 1: Vehicle Performance Overview
figure('Name', 'Vehicle Performance Overview', 'Position', [100, 100, 1200, 800]);

% Speed plot
subplot(3, 2, 1);
plot(time, vehicle_speed, 'b', 'LineWidth', 1.5);
hold on;
plot(time, set_speed, 'r--', 'LineWidth', 1.2);
grid on;
xlabel('Time [s]');
ylabel('Speed [km/h]');
title('Vehicle Speed vs Set Speed');
legend('Actual Speed', 'Set Speed', 'Location', 'best');

% Acceleration plot
subplot(3, 2, 2);
plot(time, vehicle_accel, 'g', 'LineWidth', 1.5);
hold on;
yline(2.0, 'r--', 'Max Accel');
yline(-3.0, 'r--', 'Max Decel');
grid on;
xlabel('Time [s]');
ylabel('Acceleration [m/s²]');
title('Vehicle Acceleration');
legend('Acceleration', 'Limits', 'Location', 'best');

% Position plot
subplot(3, 2, 3);
plot(time, position/1000, 'k', 'LineWidth', 1.5);
grid on;
xlabel('Time [s]');
ylabel('Position [km]');
title('Vehicle Position');

% Motor torque
subplot(3, 2, 4);
plot(time, motor_torque, 'm', 'LineWidth', 1.5);
hold on;
yline(300, 'r--', 'Max Torque');
yline(-300, 'r--', 'Min Torque');
grid on;
xlabel('Time [s]');
ylabel('Torque [Nm]');
title('Motor Torque');
legend('Torque', 'Limits', 'Location', 'best');

% Control mode
subplot(3, 2, 5);
hold on;
area(time, cc_active * 50, 'FaceColor', 'b', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
area(time, acc_active * 100, 'FaceColor', 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
grid on;
xlabel('Time [s]');
ylabel('Control Mode');
title('Active Control Modes');
legend('CC Active', 'ACC Active', 'Location', 'best');
ylim([0, 110]);

% Battery SOC
subplot(3, 2, 6);
plot(time, battery_soc, 'Color', [0.8, 0.4, 0], 'LineWidth', 1.5);
hold on;
yline(20, 'r--', 'Low SOC Warning');
grid on;
xlabel('Time [s]');
ylabel('SOC [%]');
title('Battery State of Charge');
legend('SOC', 'Warning Level', 'Location', 'best');

% Save figure
saveas(gcf, 'results/plots/vehicle_performance_overview.png');
fprintf('Saved: results/plots/vehicle_performance_overview.png\n');

%% Figure 2: Motor Performance Details
figure('Name', 'Motor Performance', 'Position', [150, 150, 1200, 800]);

% Motor speed
subplot(2, 2, 1);
plot(time, motor_speed, 'b', 'LineWidth', 1.5);
hold on;
yline(8000, 'r--', 'Max Speed');
grid on;
xlabel('Time [s]');
ylabel('Speed [RPM]');
title('Motor Speed');
legend('Speed', 'Max Speed', 'Location', 'best');

% Motor power
subplot(2, 2, 2);
plot(time, motor_power/1000, 'g', 'LineWidth', 1.5);
hold on;
yline(100, 'r--', 'Rated Power');
yline(-50, 'b--', 'Max Regen');
grid on;
xlabel('Time [s]');
ylabel('Power [kW]');
title('Motor Power');
legend('Power', 'Rated', 'Regen Limit', 'Location', 'best');

% Motor current
subplot(2, 2, 3);
plot(time, motor_current, 'r', 'LineWidth', 1.5);
hold on;
yline(300, 'r--', 'Continuous Limit');
yline(400, 'm--', 'Peak Limit');
grid on;
xlabel('Time [s]');
ylabel('Current [A]');
title('Motor Current');
legend('Current', 'Continuous', 'Peak', 'Location', 'best');

% Motor temperature
subplot(2, 2, 4);
plot(time, motor_temp, 'Color', [0.8, 0.2, 0], 'LineWidth', 1.5);
hold on;
yline(120, 'g--', 'Rated Temp');
yline(150, 'r--', 'Max Temp');
grid on;
xlabel('Time [s]');
ylabel('Temperature [°C]');
title('Motor Temperature');
legend('Temperature', 'Rated', 'Maximum', 'Location', 'best');

% Save figure
saveas(gcf, 'results/plots/motor_performance.png');
fprintf('Saved: results/plots/motor_performance.png\n');

%% Figure 3: Battery Performance
figure('Name', 'Battery Performance', 'Position', [200, 200, 1200, 600]);

% Battery voltage
subplot(2, 2, 1);
plot(time, battery_voltage, 'b', 'LineWidth', 1.5);
hold on;
yline(420, 'r--', 'Overvoltage');
yline(280, 'r--', 'Undervoltage');
grid on;
xlabel('Time [s]');
ylabel('Voltage [V]');
title('Battery Voltage');
legend('Voltage', 'Limits', 'Location', 'best');

% Battery current
subplot(2, 2, 2);
plot(time, battery_current, 'r', 'LineWidth', 1.5);
grid on;
xlabel('Time [s]');
ylabel('Current [A]');
title('Battery Current (+ discharge, - charge)');

% Battery power
subplot(2, 2, 3);
plot(time, battery_power/1000, 'g', 'LineWidth', 1.5);
hold on;
yline(0, 'k--');
grid on;
xlabel('Time [s]');
ylabel('Power [kW]');
title('Battery Power');

% Battery SOC
subplot(2, 2, 4);
plot(time, battery_soc, 'Color', [0.8, 0.4, 0], 'LineWidth', 1.5);
hold on;
yline(20, 'r--', 'Low SOC');
yline(80, 'g--', 'High SOC');
grid on;
xlabel('Time [s]');
ylabel('SOC [%]');
title('Battery State of Charge');
legend('SOC', 'Low', 'High', 'Location', 'best');

% Save figure
saveas(gcf, 'results/plots/battery_performance.png');
fprintf('Saved: results/plots/battery_performance.png\n');

%% Figure 4: Torque-Speed Operating Points
figure('Name', 'Motor Operating Points', 'Position', [250, 250, 800, 600]);

% Create torque-speed envelope
speed_envelope = [0, 3000, 8000];
torque_envelope = [300, 300, 115];

% Plot envelope
plot(speed_envelope, torque_envelope, 'r--', 'LineWidth', 2);
hold on;
plot(speed_envelope, -torque_envelope, 'r--', 'LineWidth', 2);

% Plot operating points
scatter(motor_speed, motor_torque, 10, time, 'filled', 'MarkerFaceAlpha', 0.5);
colorbar;
ylabel(colorbar, 'Time [s]');

grid on;
xlabel('Motor Speed [RPM]');
ylabel('Motor Torque [Nm]');
title('Motor Operating Points in Torque-Speed Plane');
legend('Max Torque Envelope', 'Location', 'best');
xlim([0, 8500]);
ylim([-350, 350]);

% Save figure
saveas(gcf, 'results/plots/motor_operating_points.png');
fprintf('Saved: results/plots/motor_operating_points.png\n');

%% Figure 5: Energy Analysis
figure('Name', 'Energy Analysis', 'Position', [300, 300, 1200, 600]);

% Cumulative energy consumption
cumulative_energy = cumtrapz(time, max(motor_power, 0)) / 3.6e6;  % kWh
subplot(1, 2, 1);
plot(time, cumulative_energy, 'b', 'LineWidth', 1.5);
grid on;
xlabel('Time [s]');
ylabel('Energy [kWh]');
title('Cumulative Energy Consumption');

% Power distribution histogram
subplot(1, 2, 2);
histogram(motor_power/1000, 50, 'FaceColor', 'g', 'EdgeColor', 'k');
hold on;
xline(0, 'r--', 'LineWidth', 2);
grid on;
xlabel('Power [kW]');
ylabel('Frequency');
title('Power Distribution');
legend('Power', 'Zero Power', 'Location', 'best');

% Save figure
saveas(gcf, 'results/plots/energy_analysis.png');
fprintf('Saved: results/plots/energy_analysis.png\n');

fprintf('\nAll plots generated successfully!\n');
fprintf('Plots saved to: results/plots/\n');

%% Helper Function for Sample Data
function create_sample_plots()
    fprintf('Creating sample plots with dummy data...\n');
    
    % Generate sample data
    time = (0:0.1:100)';
    vehicle_speed = 50 + 20*sin(2*pi*time/50);
    
    figure('Name', 'Sample Plot', 'Position', [100, 100, 800, 600]);
    plot(time, vehicle_speed, 'b', 'LineWidth', 1.5);
    grid on;
    xlabel('Time [s]');
    ylabel('Speed [km/h]');
    title('Sample Vehicle Speed (Dummy Data)');
    
    % Save
    saveas(gcf, 'results/plots/sample_plot.png');
    fprintf('Sample plot saved to: results/plots/sample_plot.png\n');
end
