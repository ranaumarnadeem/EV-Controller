%% Initialize General System Parameters
% This script initializes general parameters for the EV Controller system
% Run this before opening or simulating any Simulink models
%
% Author: EV Controller Team - NUST SEECS
% Date: November 2025

%% Clear workspace (optional - comment out if needed)
% clc; clear; close all;

fprintf('Initializing EV Controller Parameters...\n');

%% Simulation Parameters
Ts = 1e-3;              % Simulation time step [s] (1 ms)
T_sim = 100;            % Total simulation time [s]
Ts_control = 10e-3;     % Control loop sample time [s] (10 ms)
Ts_fast = 100e-6;       % Fast loop sample time [s] (100 μs) for motor control

%% Vehicle Parameters
vehicle.mass = 1500;                    % Vehicle mass [kg]
vehicle.frontal_area = 2.3;             % Frontal area [m²]
vehicle.drag_coefficient = 0.28;        % Aerodynamic drag coefficient
vehicle.rolling_resistance = 0.01;      % Rolling resistance coefficient
vehicle.wheel_radius = 0.32;            % Wheel radius [m]
vehicle.air_density = 1.225;            % Air density [kg/m³]
vehicle.gravity = 9.81;                 % Gravitational acceleration [m/s²]
vehicle.max_speed = 180;                % Maximum vehicle speed [km/h]
vehicle.gear_ratio = 8.5;               % Final drive gear ratio

%% Motor Parameters (Basic - detailed params in init_motor_params.m)
motor.max_torque = 300;                 % Maximum motor torque [N·m]
motor.max_power = 100e3;                % Maximum motor power [W] (100 kW)
motor.max_speed = 8000;                 % Maximum motor speed [RPM]
motor.nominal_voltage = 350;            % Nominal battery voltage [V]

%% Battery Parameters
battery.capacity = 60;                  % Battery capacity [kWh]
battery.nominal_voltage = 350;          % Nominal voltage [V]
battery.min_voltage = 280;              % Minimum voltage [V]
battery.max_voltage = 420;              % Maximum voltage [V]
battery.initial_soc = 80;               % Initial state of charge [%]

%% Cruise Control Parameters
cc.min_speed = 30;                      % Minimum activation speed [km/h]
cc.max_speed = 150;                     % Maximum set speed [km/h]
cc.speed_increment = 5;                 % Speed adjustment increment [km/h]
cc.speed_tolerance = 2;                 % Speed control tolerance [km/h]

% PID Controller Gains
cc.Kp = 500;                            % Proportional gain [N·m/(m/s)]
cc.Ki = 50;                             % Integral gain [N·m/(m·s)]
cc.Kd = 100;                            % Derivative gain [N·m·s/m]
cc.integral_limit = 200;                % Integral anti-windup limit [N·m]
cc.output_limit = 300;                  % Controller output limit [N·m]

% Acceleration/Deceleration Rates
cc.accel_rate = 1.5;                    % Acceleration rate [m/s²]
cc.decel_rate = 1.5;                    % Deceleration rate [m/s²]

%% Adaptive Cruise Control Parameters
acc.min_distance = 5;                   % Minimum following distance [m]
acc.max_distance = 150;                 % Maximum detection range [m]
acc.time_gap_options = [1.0, 1.5, 2.0, 2.5];  % Available time gaps [s]
acc.default_time_gap = 2.0;             % Default time gap [s]
acc.lateral_tolerance = 1.5;            % Lateral detection tolerance [m]

% Control Limits
acc.max_accel = 2.0;                    % Maximum acceleration [m/s²]
acc.max_decel = -3.0;                   % Maximum deceleration [m/s²]
acc.max_jerk = 5.0;                     % Maximum jerk [m/s³]
acc.comfort_decel = -2.0;               % Comfortable deceleration [m/s²]

% Sensor Parameters
acc.radar_update_rate = 20;             % Radar update rate [Hz]
acc.radar_accuracy = 0.5;               % Distance measurement accuracy [m]
acc.velocity_accuracy = 0.2;            % Relative velocity accuracy [m/s]

% Safety Thresholds
acc.warning_time_gap = 1.0;             % Forward collision warning threshold [s]
acc.emergency_time_gap = 0.5;           % Emergency braking threshold [s]

%% Controller Sample Times
sample_time.motor_control = Ts_fast;    % Motor control loop [s]
sample_time.cruise_control = Ts_control;% Cruise control loop [s]
sample_time.acc_control = Ts_control;   % ACC control loop [s]
sample_time.sensor_fusion = 0.05;       % Sensor fusion rate [s] (20 Hz)
sample_time.diagnostics = 0.1;          % Diagnostics update [s]

%% Physical Limits and Constraints
limits.max_motor_torque = 300;          % Maximum motor torque [N·m]
limits.min_motor_torque = -300;         % Minimum motor torque (regen) [N·m]
limits.max_motor_current = 300;         % Maximum continuous current [A]
limits.peak_motor_current = 400;        % Peak current (5s) [A]
limits.max_motor_temp = 150;            % Maximum motor temperature [°C]
limits.max_battery_power = 120e3;       % Maximum battery power [W]
limits.regen_efficiency = 0.70;         % Regenerative braking efficiency

%% Initial Conditions
initial.vehicle_speed = 0;              % Initial vehicle speed [km/h]
initial.motor_speed = 0;                % Initial motor speed [RPM]
initial.motor_torque = 0;               % Initial motor torque [N·m]
initial.battery_soc = battery.initial_soc;  % Initial SOC [%]
initial.position = 0;                   % Initial position [m]

%% Mode Flags
mode.manual = 1;                        % Manual driving mode
mode.cruise_control = 2;                % Cruise control mode
mode.adaptive_cruise = 3;               % Adaptive cruise control mode
mode.emergency = 4;                     % Emergency mode

%% Conversion Constants
conv.kmh_to_ms = 1/3.6;                 % km/h to m/s conversion
conv.ms_to_kmh = 3.6;                   % m/s to km/h conversion
conv.rpm_to_rads = pi/30;               % RPM to rad/s conversion
conv.rads_to_rpm = 30/pi;               % rad/s to RPM conversion
conv.kw_to_w = 1000;                    % kW to W conversion

%% Signal Names Structure (for logging and visualization)
signals.vehicle_speed = 'Vehicle Speed [km/h]';
signals.motor_torque = 'Motor Torque [Nm]';
signals.battery_soc = 'Battery SOC [%]';
signals.acc_distance = 'Following Distance [m]';
signals.set_speed = 'Set Speed [km/h]';

%% Display Summary
fprintf('  + Vehicle parameters loaded\n');
fprintf('  + Motor parameters loaded\n');
fprintf('  + Battery parameters loaded\n');
fprintf('  + Cruise Control parameters loaded\n');
fprintf('  + ACC parameters loaded\n');
fprintf('  + Simulation parameters configured\n');
fprintf('\nParameter initialization complete!\n');
fprintf('Vehicle Mass: %.0f kg\n', vehicle.mass);
fprintf('Motor Max Torque: %.0f Nm\n', motor.max_torque);
fprintf('Battery Capacity: %.0f kWh\n', battery.capacity);
fprintf('Initial SOC: %.0f%%\n\n', battery.initial_soc);
