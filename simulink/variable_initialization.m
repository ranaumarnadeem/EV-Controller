m = 1000;%mass
Reff = 0.3;%wheel radius
ig = 9;%gear ratio
g = 9.81;
A = 3.45;
Rho = 1.1839;
V1 = 27.78;   % operating (linearization) speed [m/s] (~100 km/h)
Zp = 3;%number of pole pairs
phi = 0.23;%flux linkage
%% Motor parameters (kept for later use)
Ld = 1e-4;
Lq = 1e-3;
Rs = 0.00475;
%%Cruise conntrol
eta_dt=1;
k2=100; %linesr drag coeff
a_f=100; %rolling friction
Kp= 1.0; % v to a proprtional gain
%%pmsm
av = 1 / 1.475;%"car reaches 100 km/hr in 4 seconds"
%%initial values
id=0;
Tref=10;

iq=Tref/(1.5*Zp*phi+(Ld-Lq)*id);