% Cleaned & corrected script
m = 1992;
Reff = 0.2413;
ig = 9;
CR = 0.0004;
CW = 0.23;
g = 9.81;
A = 3.45;
Rho = 1.1839;
V1 = 27.78;   % operating (linearization) speed [m/s] (~100 km/h)
Zp = 3;
phi = 0.23;
Tmax = 420;
Tmin = 0;

%% Motor parameters (kept for later use)
Ld = 1e-4;
Lq = 1e-3;
Rs = 0.00475;
% phi already defined above

%% For Linearization (secant)
V = linspace(0, 60, 100);          % velocity vector [m/s]

% Aerodynamic drag force per unit mass (vectorized)
% F1: aerodynamic term ~ 0.5 * rho * Cd * A * V^2  divided by mass
F1 = (1/2) * CW * A * Rho .* (V .^ 2) / m;

% F2: secant/linearized version about V1: (1/2)*rho*Cd*A*V*V1/m
% elementwise multiply to keep vector shape
F2 = (1/2) * CW * A * Rho .* (V .* V1) / m;

figure;
plot(V, F1, 'LineWidth', 1.4)
hold on
plot(V, F2, '--', 'LineWidth', 1.4)
xlabel('Velocity V (m/s)')
ylabel('Aerodynamic force / mass (m/s^2)')
legend('F1: 0.5 rho C_d A V^2 / m', 'F2: secant about V_1 (0.5 rho C_d A V V_1 / m)', 'Location', 'NorthWest')
grid on
title('Aerodynamic terms (vectorized and linearized)')

%% calculation of coefficients used in linear model
% bf : gain from wheel torque / motor to acceleration (includes gearbox)
bf = ig * (1 / (m * Reff));   % units: (gear ratio * 1/(m*Reff))

% af : linearized aerodynamic damping coefficient at operating speed V1
% derived from F2 expression: af = (1/2)*CW*A*Rho*V1 / m
af = (1/2) * CW * A * Rho * V1 / m;

% other time-constants / coefficients (kept as you had, but check units/meaning)
aw = 1 / 7.375;    % time constant for cruise control (1/seconds)
av = 1 / 1.475;    % motor time constant (1/seconds) -- you wrote "car reaches 100 km/hr in 4 seconds", adjust if needed

%% simple TF for longitudinal dynamics:
% We assume a first-order plant:  acceleration = bf * (input) - af * V
% Transfer function from input torque-like command to velocity (approx):
% G(s) = bf / (s + af)
num = bf;
den = [1 af];
sys = tf(num, den);

% continuous -> state-space -> discrete
ssys = ss(sys);
Ts = 0.01;           % sampling time for discretization [s] (adjust as needed)
sysd = c2d(ssys, Ts);

% show systems
disp('Continuous transfer function G(s):')
sys
disp('Discrete state-space (sampled at Ts):')
sysd

%% Optional: simulate a step input (torque command) to check response
tSim = 0:Ts:10;                    % simulate 10 seconds
u = ones(size(tSim)) * 100;        % constant input magnitude (adjust)
y = lsim(ssys, u, tSim);

figure;
plot(tSim, y, 'LineWidth', 1.4)
xlabel('Time (s)')
ylabel('Velocity (m/s)  (response to step input)')
title('Step response (continuous model)')
grid on
%%initia values
id=0;
Tref=10;

iq=Tref/(1.5*Zp*phi+(Ld-Lq)*id);
