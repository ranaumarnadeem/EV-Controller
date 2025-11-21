%% Initialize Vehicle Dynamics Parameters
% This script initializes detailed parameters for vehicle dynamics modeling
% Includes longitudinal dynamics, powertrain, and environmental factors
%
% Author: EV Controller Team - NUST SEECS
% Date: November 2025

fprintf('Initializing Vehicle Dynamics Parameters...\n');

%% Ensure base parameters are loaded
if ~exist('vehicle', 'var')
    warning('Base vehicle parameters not found. Running init_parameters.m first...');
    run('init_parameters.m');
end

%% Vehicle Dynamics - Longitudinal Model
% Basic Parameters (extended from init_parameters.m)
veh_dyn.mass = 1500;                        % Total vehicle mass [kg]
veh_dyn.mass_distribution_front = 0.45;     % Front axle weight distribution
veh_dyn.mass_distribution_rear = 0.55;      % Rear axle weight distribution
veh_dyn.wheelbase = 2.7;                    % Wheelbase [m]
veh_dyn.track_width = 1.55;                 % Track width [m]
veh_dyn.cg_height = 0.5;                    % Center of gravity height [m]

%% Tire Parameters
tire.radius = 0.32;                         % Effective tire radius [m]
tire.rolling_radius = 0.315;                % Rolling radius [m]
tire.width = 0.205;                         % Tire width [m]
tire.aspect_ratio = 55;                     % Aspect ratio [%]
tire.rim_diameter = 16;                     % Rim diameter [inches]

% Tire Force Characteristics
tire.friction_coeff_dry = 0.9;              % Friction coefficient (dry)
tire.friction_coeff_wet = 0.7;              % Friction coefficient (wet)
tire.cornering_stiffness = 80000;           % Cornering stiffness [N/rad]
tire.max_friction_force = 10000;            % Maximum friction force [N]

% Rolling Resistance
tire.rolling_resistance_coeff = 0.01;       % Rolling resistance coefficient
tire.rolling_resistance_speed_coeff = 6.5e-6; % Speed-dependent coefficient [s/m]

%% Aerodynamic Parameters
aero.frontal_area = 2.3;                    % Frontal area [m²]
aero.drag_coefficient = 0.28;               % Drag coefficient (Cd)
aero.lift_coefficient = 0.1;                % Lift coefficient (Cl)
aero.air_density = 1.225;                   % Air density at sea level [kg/m³]
aero.reference_height = 0.8;                % Reference height [m]

%% Resistance Force Calculations
% Rolling Resistance Force: F_roll = Crr * m * g * (1 + Cv * v)
% Aerodynamic Drag Force: F_aero = 0.5 * rho * Cd * A * v²
% Grade Resistance Force: F_grade = m * g * sin(theta)

%% Drivetrain Parameters
drivetrain.final_drive_ratio = 8.5;         % Final drive gear ratio
drivetrain.efficiency = 0.95;               % Overall drivetrain efficiency
drivetrain.gearbox_efficiency = 0.97;       % Gearbox efficiency
drivetrain.differential_efficiency = 0.98;  % Differential efficiency
drivetrain.inertia_motor = 0.02;            % Motor rotor inertia [kg·m²]
drivetrain.inertia_wheels = 1.5;            % Wheel inertia [kg·m²]
drivetrain.inertia_total = 0.05;            % Total rotational inertia [kg·m²]

%% Brake System Parameters
brake.max_brake_torque = 3000;              % Maximum brake torque per wheel [N·m]
brake.brake_distribution_front = 0.65;      % Front brake force distribution
brake.brake_distribution_rear = 0.35;       % Rear brake force distribution
brake.response_time = 0.2;                  % Brake response time [s]
brake.max_decel = 8.0;                      % Maximum deceleration [m/s²]
brake.abs_enabled = true;                   % ABS system enabled

%% Road Grade Parameters
road.grade_angle = 0;                       % Road grade angle [degrees]
road.grade_percent = 0;                     % Road grade [%]
road.friction_coefficient = 0.85;           % Road friction coefficient
road.surface_type = 'asphalt';              % Surface type

%% Environmental Conditions
environment.temperature = 25;                % Ambient temperature [°C]
environment.wind_speed = 0;                 % Wind speed [m/s]
environment.wind_direction = 0;             % Wind direction [degrees]
environment.altitude = 0;                   % Altitude [m]
environment.pressure = 101.325;             % Atmospheric pressure [kPa]

% Temperature effects on air density
environment.air_density = aero.air_density * ...
    (273.15 / (273.15 + environment.temperature)) * ...
    (environment.pressure / 101.325);

%% Vehicle State Variables (Initial Conditions)
state.velocity = 0;                         % Vehicle velocity [m/s]
state.acceleration = 0;                     % Vehicle acceleration [m/s²]
state.position = 0;                         % Vehicle position [m]
state.yaw_rate = 0;                         % Yaw rate [rad/s]
state.wheel_speed_fl = 0;                   % Front-left wheel speed [rad/s]
state.wheel_speed_fr = 0;                   % Front-right wheel speed [rad/s]
state.wheel_speed_rl = 0;                   % Rear-left wheel speed [rad/s]
state.wheel_speed_rr = 0;                   % Rear-right wheel speed [rad/s]

%% Load Distribution (Dynamic)
load_dist.static_front = veh_dyn.mass * vehicle.gravity * ...
    veh_dyn.mass_distribution_front;        % Static front axle load [N]
load_dist.static_rear = veh_dyn.mass * vehicle.gravity * ...
    veh_dyn.mass_distribution_rear;         % Static rear axle load [N]

%% Longitudinal Dynamics Model
% Differential equation: m * dv/dt = F_traction - F_drag - F_roll - F_grade
% where:
% F_traction = (Motor_Torque * gear_ratio * efficiency) / wheel_radius
% F_drag = 0.5 * rho * Cd * A * v²
% F_roll = Crr * m * g * cos(grade)
% F_grade = m * g * sin(grade)

%% Transfer Functions
% Vehicle as a first-order system with time constant
veh_tf.time_constant = veh_dyn.mass / ...
    (tire.rolling_resistance_coeff * veh_dyn.mass * vehicle.gravity);
veh_tf.dc_gain = 1 / (tire.rolling_resistance_coeff * veh_dyn.mass * vehicle.gravity);

%% Simulation Parameters for Vehicle Dynamics
veh_sim.integration_method = 'ode4';        % Integration method
veh_sim.fixed_step = 1e-3;                  % Fixed step size [s]
veh_sim.max_step = 1e-2;                    % Maximum step size [s]
veh_sim.initial_velocity = 0;               % Initial velocity [m/s]
veh_sim.initial_position = 0;               % Initial position [m]

%% Speed Limiter
speed_limit.max_vehicle_speed = 180;        % Maximum vehicle speed [km/h]
speed_limit.max_reverse_speed = 20;         % Maximum reverse speed [km/h]
speed_limit.enable = true;                  % Enable speed limiting

%% Safety Margins
safety.max_lateral_accel = 8.0;             % Maximum lateral acceleration [m/s²]
safety.max_longitudinal_accel = 5.0;        % Maximum longitudinal acceleration [m/s²]
safety.min_safe_distance = 2.0;             % Minimum safe distance [m]
safety.reaction_time = 0.7;                 % Driver reaction time [s]

%% Performance Metrics (for logging)
performance.accel_0_100 = 0;                % 0-100 km/h time [s] (calculated)
performance.max_grade = 0;                  % Maximum climbable grade [%] (calculated)
performance.range = 0;                      % Vehicle range [km] (calculated)

%% Display Summary
fprintf('  + Vehicle dynamics parameters loaded\n');
fprintf('  + Tire model parameters configured\n');
fprintf('  + Aerodynamic parameters set\n');
fprintf('  + Drivetrain parameters initialized\n');
fprintf('  + Environmental conditions set\n');
fprintf('\nVehicle Dynamics initialization complete!\n');
fprintf('Vehicle Mass: %.0f kg\n', veh_dyn.mass);
fprintf('Final Drive Ratio: %.1f:1\n', drivetrain.final_drive_ratio);
fprintf('Drag Coefficient: %.2f\n', aero.drag_coefficient);
fprintf('Rolling Resistance: %.4f\n\n', tire.rolling_resistance_coeff);
