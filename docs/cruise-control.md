# Cruise Control System

**Developed by**: Rana Umar Nadeem

---

## Overview

The cruise control system is the outer control loop responsible for velocity tracking and torque demand generation. It maintains the desired vehicle speed by calculating the required motor torque based on vehicle dynamics and environmental conditions.

---

## System Architecture

### Control Loop Structure

The system implements a **closed-loop feedback control** architecture:

```
┌──────────────┐
│   Desired    │
│   Velocity   │
│   (75 m/s)   │
└──────┬───────┘
       │
       ▼
    ┌──────┐      ┌─────────┐     ┌─────────────┐     ┌──────────┐
    │  Σ   │─────→│   PID   │────→│ Vehicle     │────→│ Velocity │
    │      │      │Controller│     │  Dynamics   │     │  Output  │
    └──┬───┘      └─────────┘     └─────────────┘     └────┬─────┘
       ▲                                                     │
       │                       Feedback                      │
       └─────────────────────────────────────────────────────┘
```

---

## Component Details

### 1. Summing Junction (Comparator)

**Function**: Calculates the instantaneous error signal.

```
e(t) = v_desired - v_measured
```

**Purpose**: 
- Quantifies deviation between setpoint and actual speed
- Drives the control logic
- Provides real-time error feedback

---

### 2. PID Controller (Compensator)

**Function**: Generates control effort to minimize error.

**Control Action**:
```
u(t) = Kp·e(t) + Ki·∫e(t)dt + Kd·de(t)/dt
```

#### Proportional Term (Kp)
- **Purpose**: Immediate error correction
- **Effect**: Improves rise time
- **Action**: Proportional to current error magnitude

#### Integral Term (Ki)
- **Purpose**: Eliminates steady-state error
- **Effect**: Compensates for drag forces
- **Action**: Accumulates error over time
- **Critical**: Without Ki, velocity settles below setpoint due to k₂ drag

#### Derivative Term (Kd)
- **Purpose**: Predictive error correction
- **Effect**: Reduces overshoot and oscillations
- **Action**: Responds to rate of change of error
- **Benefit**: Improves transient stability

---

### 3. Vehicle Dynamics Model

The vehicle is modeled as a **First-Order Linear Time-Invariant (LTI) System**.

**Governing Differential Equation**:
```
m · dv/dt = k₁·u(t) - k₂·v(t)
```

Where:
- **m**: Vehicle mass
- **v**: Velocity
- **u**: Control input
- **k₁**: Forward path gain
- **k₂**: Drag coefficient

#### Forward Path Gain (k₁/m)

**Value**: 0.002 (2/1000)

**Function**: Force-to-Acceleration Conversion

**Purpose**: 
- Converts dimensionless PID output into acceleration
- Scales control signal for vehicle mass
- Units: m/s² per control unit

**Mathematical Representation**:
```
a_control = (k₁/m) · u_pid
```

#### Feedback Gain (k₂/m)

**Value**: 0.1 (100/1000)

**Function**: Damping Coefficient / Linear Drag

**Purpose**:
- Represents resistive forces (air resistance + friction)
- Provides natural stability
- Proportional to velocity

**Mathematical Representation**:
```
a_drag = -(k₂/m) · v
```

**System Time Constant**:
```
τ = m/k₂ = 1000/100 = 10 seconds
```

This means the system naturally reaches 63% of its steady-state value in 10 seconds without control.

#### Integrator (1/s)

**Function**: State Integration

**Purpose**:
- Integrates net acceleration to obtain velocity
- Converts acceleration domain to velocity domain

**Mathematical Operation**:
```
v(t) = ∫[a_control(t) - a_drag(t)] dt
```

---

### 4. Inverse Dynamics Block

#### MATLAB Function: `velocity_to_torque`

**Function**: Inverse Dynamics Solver

**Purpose**: 
- Calculates actuation demand (motor torque)
- Solves inverse kinematics
- Determines torque needed to maintain current state

**Physics Principle**:

Starting from Newton's Second Law:
```
F_net = m · a
```

For steady-state motion:
```
F_motor = F_drag + F_gravity + F_acceleration
```

Converting to torque:
```
T_d = (F_motor · R_eff) / i_g
```

Where:
- **T_d**: Motor torque demand
- **R_eff**: Effective wheel radius
- **i_g**: Gear ratio

**Complete Torque Equation**:
```
T_d = m · [a + (k₂/m)·v + g·sin(θ)] · R_eff / i_g
```

**Input Variables**:
- Current velocity (v)
- Current acceleration (a)  
- Road slope angle (θ)
- Vehicle parameters (m, R_eff, i_g, k₂)

**Output**:
- **Torque Demand (T_d)** in Newton-meters [Nm]

---

### 5. Scenario Block (Disturbance Injection)

**Function**: Environmental Parameter Input

**Purpose**:
- Injects external load variables
- Simulates real-world conditions
- Enables gravity compensation

**Primary Input**: 
- **Slope Angle (θ)** in degrees

**Effect on Torque**:
```
T_gravity = m · g · sin(θ) · R_eff / i_g
```

**Use Cases**:
- Uphill driving: θ > 0 → Increased torque demand
- Downhill driving: θ < 0 → Reduced torque demand (or regenerative braking)
- Flat road: θ = 0 → No gravitational component

---

## Signal Interface Specification

### Outputs to Motor Control System

| Signal Name | Symbol | Units | Range | Description |
|-------------|--------|-------|-------|-------------|
| **Torque Demand** | T_d | Nm | 0-420 | Required motor torque |
| **Velocity State** | v | m/s | 0-60 | Current vehicle speed |
| **Slope Angle** | θ | deg | -15 to +15 | Road grade angle |

---

## Control Performance Characteristics

### Step Response Properties

**Target Velocity**: 75 m/s (~270 km/h)

Expected behavior with properly tuned PID:

| Characteristic | Target Value |
|----------------|--------------|
| Rise Time | < 15 seconds |
| Settling Time | < 30 seconds |
| Overshoot | < 5% |
| Steady-State Error | 0 (eliminated by Ki) |

---

## Mathematical Model Summary

### Plant Transfer Function

From control input to velocity:
```
G(s) = k₁/(m·s + k₂)
```

Simplified:
```
G(s) = 0.002/(s + 0.1)
```

### Closed-Loop Transfer Function

With PID controller:
```
        Kp·s² + Ki·s + Kd·s³
H(s) = ────────────────────────────
       s³ + (0.1 + Kd)·s² + Kp·s + Ki
```

---

## Implementation Details

### Simulation Parameters

```matlab
% Operating point
V1 = 27.78;        % Linearization speed [m/s] (~100 km/h)

% Vehicle parameters
m = 1992;          % Mass [kg]
Reff = 0.2413;     % Effective radius [m]
ig = 9;            % Gear ratio
CR = 0.0004;       % Rolling resistance
CW = 0.23;         % Drag coefficient
A = 3.45;          % Frontal area [m²]
Rho = 1.1839;      % Air density [kg/m³]

% Control gains
bf = ig * (1 / (m * Reff));        % Forward gain
af = (1/2) * CW * A * Rho * V1 / m; % Drag damping coefficient

% Time constants
aw = 1 / 7.375;    % Cruise control time constant
av = 1 / 1.475;    % Motor time constant

% Sampling
Ts = 0.01;         % Sampling time [s]
```

### Linearization Approach

The aerodynamic drag force is linearized about operating point V₁:

**Actual (Nonlinear)**:
```
F_drag = (1/2) · ρ · Cd · A · v²
```

**Linearized (Secant)**:
```
F_drag ≈ (1/2) · ρ · Cd · A · v · V₁
```

This allows for linear control design while maintaining accuracy near the operating point.

---

## Simulink Implementation

### Block Diagram Components

1. **Constant Block**: Desired velocity setpoint (75 m/s)
2. **Sum Block**: Error calculation (e = v_desired - v_actual)
3. **PID Controller Block**: Tuned compensator
4. **Gain Block (k₁/m)**: Forward path scaling
5. **Sum Block**: Acceleration calculation (control - drag)
6. **Integrator**: Velocity state computation
7. **Gain Block (k₂/m)**: Drag feedback
8. **MATLAB Function**: Inverse dynamics (velocity_to_torque)
9. **Scenario Block**: Slope input

---

## Tuning Guidelines

### PID Tuning Process

1. **Start with P-only control**:
   - Set Ki = 0, Kd = 0
   - Increase Kp until system responds quickly
   - Expect steady-state error

2. **Add Integral action**:
   - Gradually increase Ki
   - Eliminates steady-state error
   - Watch for oscillations

3. **Add Derivative action**:
   - Increase Kd to reduce overshoot
   - Improves transient response
   - Don't over-tune (noise sensitivity)

### Recommended Starting Values

```matlab
Kp = 0.5;   % Moderate proportional gain
Ki = 0.05;  % Low integral gain
Kd = 0.1;   % Small derivative gain
```

---

## Testing Scenarios

### 1. Step Input Test
- Set desired velocity to 75 m/s
- Flat road (θ = 0)
- Evaluate rise time, overshoot, settling time

### 2. Disturbance Rejection
- Maintain 75 m/s
- Introduce slope: θ = 5° uphill
- Check if controller compensates

### 3. Velocity Change
- Start at 50 m/s
- Change setpoint to 80 m/s mid-simulation
- Evaluate tracking performance

---

## Integration with Motor Control

The cruise control output (Torque Demand) serves as the **reference input** for the motor PID controller:

```
Cruise Control (T_d) → Motor PID (i_q*) → Decoupler (v_q) → PMSM
```

**Handoff Specifications**:
- Signal type: Continuous analog
- Update rate: 100 Hz
- Units: Newton-meters (Nm)
- Range: 0 to 420 Nm

---

## Advantages of This Design

1. **Modularity**: Independent from motor control details
2. **Robustness**: PID compensates for drag and disturbances
3. **Simplicity**: Linear model enables straightforward tuning
4. **Realistic**: Includes gravity compensation for slopes
5. **Feedforward Capable**: Can add predictive control for acceleration requests

---

## Future Enhancements

- Adaptive gain scheduling for different speeds
- Model Predictive Control (MPC) for constraints
- Kalman filtering for noisy velocity measurements
- Energy-optimal velocity profiles
- Integration with ACC (Adaptive Cruise Control)

---

## References

1. **Vehicle Dynamics**: Gillespie, T. D. (1992). *Fundamentals of Vehicle Dynamics*
2. **PID Control**: Åström, K. J., & Hägglund, T. (1995). *PID Controllers: Theory, Design, and Tuning*
3. **Cruise Control Design**: Bevly, D. M. (2006). *Robust Vehicle Control Systems*

---

**Developed by**: Rana Umar Nadeem, NUST-SEECS  
**Last Updated**: December 2025
