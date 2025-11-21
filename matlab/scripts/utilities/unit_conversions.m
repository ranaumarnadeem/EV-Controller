%% Unit Conversion Utilities
% Collection of unit conversion functions for the EV Controller project
%
% Author: EV Controller Team - NUST SEECS
% Date: November 2025

%% Speed Conversions

function ms = kmh_to_ms(kmh)
    % Convert km/h to m/s
    ms = kmh / 3.6;
end

function kmh = ms_to_kmh(ms)
    % Convert m/s to km/h
    kmh = ms * 3.6;
end

function mph = kmh_to_mph(kmh)
    % Convert km/h to mph
    mph = kmh * 0.621371;
end

function kmh = mph_to_kmh(mph)
    % Convert mph to km/h
    kmh = mph / 0.621371;
end

%% Angular Speed Conversions

function rads = rpm_to_rads(rpm)
    % Convert RPM to rad/s
    rads = rpm * (pi / 30);
end

function rpm = rads_to_rpm(rads)
    % Convert rad/s to RPM
    rpm = rads * (30 / pi);
end

%% Power Conversions

function w = kw_to_w(kw)
    % Convert kW to W
    w = kw * 1000;
end

function kw = w_to_kw(w)
    % Convert W to kW
    kw = w / 1000;
end

function hp = kw_to_hp(kw)
    % Convert kW to horsepower
    hp = kw * 1.34102;
end

function kw = hp_to_kw(hp)
    % Convert horsepower to kW
    kw = hp / 1.34102;
end

%% Energy Conversions

function kwh = j_to_kwh(j)
    % Convert Joules to kWh
    kwh = j / 3.6e6;
end

function j = kwh_to_j(kwh)
    % Convert kWh to Joules
    j = kwh * 3.6e6;
end

function wh = j_to_wh(j)
    % Convert Joules to Wh
    wh = j / 3600;
end

%% Torque Conversions

function nm = lbft_to_nm(lbft)
    % Convert lb-ft to N·m
    nm = lbft * 1.35582;
end

function lbft = nm_to_lbft(nm)
    % Convert N·m to lb-ft
    lbft = nm / 1.35582;
end

%% Temperature Conversions

function c = f_to_c(f)
    % Convert Fahrenheit to Celsius
    c = (f - 32) * 5/9;
end

function f = c_to_f(c)
    % Convert Celsius to Fahrenheit
    f = c * 9/5 + 32;
end

function k = c_to_k(c)
    % Convert Celsius to Kelvin
    k = c + 273.15;
end

function c = k_to_c(k)
    % Convert Kelvin to Celsius
    c = k - 273.15;
end

%% Distance Conversions

function m = km_to_m(km)
    % Convert kilometers to meters
    m = km * 1000;
end

function km = m_to_km(m)
    % Convert meters to kilometers
    km = m / 1000;
end

function mi = km_to_mi(km)
    % Convert kilometers to miles
    mi = km * 0.621371;
end

function km = mi_to_km(mi)
    % Convert miles to kilometers
    km = mi / 0.621371;
end

%% Force Conversions

function n = kgf_to_n(kgf)
    % Convert kilogram-force to Newtons
    n = kgf * 9.80665;
end

function kgf = n_to_kgf(n)
    % Convert Newtons to kilogram-force
    kgf = n / 9.80665;
end

%% Pressure Conversions

function bar = pa_to_bar(pa)
    % Convert Pascals to bar
    bar = pa / 1e5;
end

function pa = bar_to_pa(bar)
    % Convert bar to Pascals
    pa = bar * 1e5;
end

function psi = pa_to_psi(pa)
    % Convert Pascals to PSI
    psi = pa / 6894.76;
end

function pa = psi_to_pa(psi)
    % Convert PSI to Pascals
    pa = psi * 6894.76;
end
