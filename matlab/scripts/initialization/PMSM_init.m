m=1992;
Reff=0.2413;
ig=9;
CR=0.0004;
CW=0.23;
g=9.81;
A=3.45;
Rho=1.1839;
V1=27.78;
Zp=3;
phi=0.23;
Tmax=420;
Tmin=0;
%% Motor parameters
Ld=1e-4;
Lq=1e-3;
Rs=0.00475;
phi=0.23;

%% For Linearization (secant)
V=linspace(0, 60, 100);
F1 = ((1/2)CW*A*Rho(V.^2))/m;
F2 = ((1/2)CW*A*Rho(V)*V1)/m;
plot(V,F1)
hold on
plot(V,F2)

%% calculation
bf=ig*(1/(m*Reff));
af=(1/2)CW((A*Rho)/m)*V1;
aw=(1/(7.375)); %time constant for cruise control.
av=(1/(1.475)); %time constant for motor.The car reaches 100 kmhr in 4 seconds

%% calculation
w=1;
D=1;

%% transfer function to state space
Ts = 1;
sys = tf(bf,[1 af]);
sysss = ss(sys);
sysd = c2d(sysss,Ts);