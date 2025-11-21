%% Initialize Motor Parameters
% This script initializes detailed electric motor parameters
% Includes BLDC motor characteristics, control parameters, and thermal model
%
% Author: EV Controller Team - NUST SEECS
% Date: November 2025

fprintf('Initializing Motor Parameters...\n');

%% Ensure base parameters are loaded
if ~exist('vehicle', 'var')
    warning('Base parameters not found. Running init_parameters.m first...');
    run('init_parameters.m');
end

%% Motor Type and Specifications
motor_spec.type = 'PMSM';                   % Motor type: Permanent Magnet Synchronous Motor
motor_spec.rated_power = 100e3;             % Rated power [W] (100 kW)
motor_spec.peak_power = 120e3;              % Peak power [W] (120 kW)
motor_spec.rated_torque = 280;              % Rated torque [N·m]
motor_spec.peak_torque = 300;               % Peak torque [N·m]
motor_spec.base_speed = 3000;               % Base speed [RPM]
motor_spec.max_speed = 8000;                % Maximum speed [RPM]
motor_spec.pole_pairs = 4;                  % Number of pole pairs

%% Electrical Parameters
motor_elec.rated_voltage = 350;             % Rated voltage [V]
motor_elec.max_voltage = 420;               % Maximum voltage [V]
motor_elec.rated_current = 200;             % Rated current [A]
motor_elec.peak_current = 400;              % Peak current (5s) [A]
motor_elec.max_continuous_current = 300;    % Max continuous current [A]

% Winding Parameters
motor_elec.stator_resistance = 0.025;       % Stator resistance [Ohm]
motor_elec.d_axis_inductance = 0.5e-3;      % d-axis inductance [H]
motor_elec.q_axis_inductance = 0.8e-3;      % q-axis inductance [H]
motor_elec.flux_linkage = 0.15;             % Permanent magnet flux linkage [Wb]
motor_elec.back_emf_constant = 0.15;        % Back-EMF constant [V·s/rad]
motor_elec.torque_constant = 1.2;           % Torque constant [N·m/A]

%% Mechanical Parameters
motor_mech.rotor_inertia = 0.02;            % Rotor inertia [kg·m²]
motor_mech.viscous_damping = 0.001;         % Viscous damping coefficient [N·m·s/rad]
motor_mech.static_friction = 0.5;           % Static friction torque [N·m]
motor_mech.coulomb_friction = 0.3;          % Coulomb friction torque [N·m]
motor_mech.bearing_friction = 0.1;          % Bearing friction [N·m]

%% Torque-Speed Characteristics
% Base Torque (constant torque region: 0 - base_speed)
motor_curve.torque_base = motor_spec.rated_torque;  % [N·m]
motor_curve.speed_base = motor_spec.base_speed;      % [RPM]

% Constant Power Region (base_speed - max_speed)
motor_curve.power_constant = motor_spec.rated_power; % [W]

% Speed points for torque map [RPM]
motor_curve.speed_points = [0, 500, 1000, 1500, 2000, 2500, 3000, ...
                             3500, 4000, 5000, 6000, 7000, 8000];

% Maximum torque at each speed point [N·m]
motor_curve.torque_max = [300, 300, 300, 300, 300, 295, 290, ...
                          250, 220, 180, 150, 130, 115];

% Motor efficiency map (2D: speed vs torque)
motor_curve.efficiency_map = [
    % Columns: torque percentage [0, 25, 50, 75, 100]%
    % Rows: speed [RPM] as per speed_points
    0.50, 0.75, 0.85, 0.88, 0.90;  % 0 RPM
    0.55, 0.80, 0.88, 0.91, 0.92;  % 500 RPM
    0.60, 0.82, 0.90, 0.92, 0.93;  % 1000 RPM
    0.65, 0.84, 0.91, 0.93, 0.94;  % 1500 RPM
    0.68, 0.86, 0.92, 0.94, 0.95;  % 2000 RPM
    0.70, 0.87, 0.93, 0.95, 0.95;  % 2500 RPM
    0.72, 0.88, 0.93, 0.95, 0.96;  % 3000 RPM (base)
    0.70, 0.87, 0.92, 0.94, 0.95;  % 3500 RPM
    0.68, 0.86, 0.91, 0.93, 0.94;  % 4000 RPM
    0.64, 0.84, 0.90, 0.92, 0.93;  % 5000 RPM
    0.60, 0.82, 0.88, 0.90, 0.91;  % 6000 RPM
    0.55, 0.78, 0.85, 0.88, 0.89;  % 7000 RPM
    0.50, 0.75, 0.82, 0.85, 0.87;  % 8000 RPM
];

motor_curve.torque_percentage = [0, 25, 50, 75, 100];

%% Thermal Model Parameters
motor_thermal.thermal_resistance = 0.05;    % Thermal resistance [K/W]
motor_thermal.thermal_capacitance = 1000;   % Thermal capacitance [J/K]
motor_thermal.ambient_temp = 25;            % Ambient temperature [°C]
motor_thermal.rated_temp = 120;             % Rated operating temperature [°C]
motor_thermal.max_temp = 150;               % Maximum temperature [°C]
motor_thermal.warning_temp = 140;           % Warning temperature [°C]
motor_thermal.cooling_factor = 0.002;       % Cooling factor (speed-dependent)

% Temperature derating
motor_thermal.derating_start_temp = 130;    % Temperature to start derating [°C]
motor_thermal.derating_slope = 0.02;        % Torque derating per °C above start temp

%% Control Parameters

% Torque Control (Outer Loop)
motor_control.torque_Kp = 0.5;              % Proportional gain
motor_control.torque_Ki = 50;               % Integral gain
motor_control.torque_Kd = 0.01;             % Derivative gain
motor_control.torque_limit = motor_spec.peak_torque;  % Output limit [N·m]

% Current Control (Inner Loop) - d-axis
motor_control.id_Kp = 10;                   % Proportional gain
motor_control.id_Ki = 1000;                 % Integral gain
motor_control.id_limit = motor_elec.peak_current;  % Output limit [A]

% Current Control (Inner Loop) - q-axis
motor_control.iq_Kp = 10;                   % Proportional gain
motor_control.iq_Ki = 1000;                 % Integral gain
motor_control.iq_limit = motor_elec.peak_current;  % Output limit [A]

% Speed Control
motor_control.speed_Kp = 0.1;               % Proportional gain
motor_control.speed_Ki = 1.0;               % Integral gain
motor_control.speed_Kd = 0.001;             % Derivative gain

% Field Weakening Control
motor_control.field_weakening_enable = true;      % Enable field weakening
motor_control.field_weakening_start_speed = 3000; % Start speed [RPM]
motor_control.id_field_weakening_max = -100;      % Max d-axis current [A]

%% PWM and Switching Parameters
motor_pwm.switching_frequency = 10e3;       % PWM switching frequency [Hz]
motor_pwm.dead_time = 2e-6;                 % Dead time [s]
motor_pwm.modulation_type = 'SVPWM';        % Space Vector PWM
motor_pwm.duty_cycle_min = 0;               % Minimum duty cycle [%]
motor_pwm.duty_cycle_max = 95;              % Maximum duty cycle [%]

%% Protection Limits
motor_protect.overcurrent_limit = 450;      % Hardware overcurrent limit [A]
motor_protect.overvoltage_limit = 420;      % Overvoltage limit [V]
motor_protect.undervoltage_limit = 280;     % Undervoltage limit [V]
motor_protect.overspeed_limit = 8500;       % Overspeed limit [RPM]
motor_protect.overtemp_limit = 150;         % Overtemperature limit [°C]

% Response times
motor_protect.overcurrent_response = 10e-6; % Overcurrent response time [s]
motor_protect.overspeed_response = 50e-3;   % Overspeed response time [s]
motor_protect.overtemp_response = 1.0;      % Overtemp response time [s]

%% Regenerative Braking Parameters
motor_regen.enable = true;                  % Enable regenerative braking
motor_regen.max_regen_torque = -150;        % Maximum regen torque [N·m]
motor_regen.max_regen_power = -50e3;        % Maximum regen power [W]
motor_regen.efficiency = 0.70;              % Regen efficiency
motor_regen.min_speed_regen = 300;          % Minimum speed for regen [RPM]
motor_regen.blend_with_friction = true;     % Blend with friction brakes

%% Sample Times and Update Rates
motor_timing.current_loop_freq = 10e3;      % Current loop frequency [Hz]
motor_timing.torque_loop_freq = 1e3;        % Torque loop frequency [Hz]
motor_timing.speed_loop_freq = 100;         % Speed loop frequency [Hz]
motor_timing.thermal_update_freq = 10;      % Thermal model update [Hz]

motor_timing.current_loop_Ts = 1/motor_timing.current_loop_freq;
motor_timing.torque_loop_Ts = 1/motor_timing.torque_loop_freq;
motor_timing.speed_loop_Ts = 1/motor_timing.speed_loop_freq;
motor_timing.thermal_update_Ts = 1/motor_timing.thermal_update_freq;

%% Initial Conditions
motor_init.torque = 0;                      % Initial torque [N·m]
motor_init.speed = 0;                       % Initial speed [RPM]
motor_init.current_d = 0;                   % Initial d-axis current [A]
motor_init.current_q = 0;                   % Initial q-axis current [A]
motor_init.temperature = motor_thermal.ambient_temp;  % Initial temp [°C]
motor_init.rotor_angle = 0;                 % Initial rotor angle [rad]

%% Motor State Machine States
motor_state.INIT = 0;
motor_state.IDLE = 1;
motor_state.READY = 2;
motor_state.OPERATING = 3;
motor_state.FAULT = 4;
motor_state.SHUTDOWN = 5;

motor_init.state = motor_state.IDLE;        % Initial state

%% Lookup Table Data (for Simulink)
% Create 1D lookup table for max torque vs speed
motor_lut.speed_vector = motor_curve.speed_points;
motor_lut.torque_vector = motor_curve.torque_max;

% Create 2D efficiency map lookup table
[motor_lut.speed_mesh, motor_lut.torque_mesh] = meshgrid(...
    motor_curve.torque_percentage, motor_curve.speed_points);

%% Display Summary
fprintf('  + Motor electrical parameters loaded\n');
fprintf('  + Motor mechanical parameters loaded\n');
fprintf('  + Torque-speed characteristics configured\n');
fprintf('  + Control parameters initialized\n');
fprintf('  + Thermal model parameters set\n');
fprintf('  + Protection limits configured\n');
fprintf('\nMotor initialization complete!\n');
fprintf('Motor Type: %s\n', motor_spec.type);
fprintf('Rated Power: %.0f kW\n', motor_spec.rated_power/1000);
fprintf('Peak Torque: %.0f Nm\n', motor_spec.peak_torque);
fprintf('Max Speed: %.0f RPM\n', motor_spec.max_speed);
fprintf('Torque Constant: %.2f Nm/A\n\n', motor_elec.torque_constant);
