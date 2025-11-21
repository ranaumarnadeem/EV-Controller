# Design Specifications

## EV Controller Project
**Version**: 1.0  
**Date**: November 2025  
**Team**: Urva Ali, Maryam Imran, Hanna Imran, Rana Umar Nadeem, Ali Sher  
**Institution**: NUST-SEECS

---

## 1. System Architecture

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   EV Controller System                   │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌───────────────┐  ┌───────────────┐  ┌────────────┐ │
│  │ Motor Control │  │ Cruise Control│  │    ACC     │ │
│  │   Subsystem   │  │   Subsystem   │  │ Subsystem  │ │
│  └───────┬───────┘  └───────┬───────┘  └─────┬──────┘ │
│          │                  │                 │         │
│          └──────────────────┴─────────────────┘         │
│                          │                               │
│                ┌─────────▼──────────┐                   │
│                │ Integration Layer  │                   │
│                │  & Arbitration     │                   │
│                └─────────┬──────────┘                   │
│                          │                               │
└──────────────────────────┼───────────────────────────────┘
                           │
              ┌────────────▼────────────┐
              │   Vehicle Interface     │
              │  (Sensors & Actuators)  │
              └─────────────────────────┘
```

### 1.2 Component Overview

#### 1.2.1 Motor Control Subsystem
- **Purpose**: Manage electric motor torque and speed
- **Inputs**: Torque command, vehicle state, battery status
- **Outputs**: Motor control signals (PWM)
- **Key Algorithms**: Field-oriented control, torque vectoring

#### 1.2.2 Cruise Control Subsystem
- **Purpose**: Maintain constant vehicle speed
- **Inputs**: Set speed, current speed, driver commands
- **Outputs**: Torque request
- **Key Algorithms**: PID control, feed-forward compensation

#### 1.2.3 Adaptive Cruise Control Subsystem
- **Purpose**: Maintain safe following distance
- **Inputs**: Radar/camera data, vehicle speed, set gap
- **Outputs**: Speed/torque request
- **Key Algorithms**: Model predictive control, sensor fusion

---

## 2. Detailed Subsystem Design

### 2.1 Motor Control Subsystem

#### 2.1.1 Control Architecture
```
Driver Command → Torque → Current → Field → Motor
                Limiter   Control   Orient.  Drive
                                    Control
                   ↑         ↑        ↑
                   └─────────┴────────┘
                   Feedback (Speed, Current, Position)
```

#### 2.1.2 Torque Control Loop
- **Control Type**: Cascaded control with outer torque loop, inner current loop
- **Controller**: PI controller with anti-windup
- **Sample Time**: 100 μs (10 kHz)
- **Bandwidth**: 500 Hz

**Transfer Function**:
```
C(s) = Kp + Ki/s
Kp = 0.5  (Proportional gain)
Ki = 50   (Integral gain)
```

#### 2.1.3 Speed Estimation
- **Method**: Observer-based estimation from motor position
- **Filter**: 2nd order Butterworth, 50 Hz cutoff
- **Accuracy**: ±1 RPM

#### 2.1.4 Current Control
- **Type**: Field-oriented control (FOC)
- **Reference Frame**: d-q rotating frame
- **Current Sampling**: 10 kHz
- **Protection**: Hardware overcurrent limit at 400A

#### 2.1.5 State Machine

```
┌──────────┐
│   INIT   │
└────┬─────┘
     │
     ▼
┌──────────┐    Error    ┌──────────┐
│   IDLE   │────────────→│  FAULT   │
└────┬─────┘             └──────────┘
     │                         ▲
     │ Enable                  │
     ▼                         │ Fault
┌──────────┐                  │
│  READY   │──────────────────┘
└────┬─────┘
     │
     │ Torque Cmd
     ▼
┌──────────┐
│OPERATING │
└──────────┘
```

### 2.2 Cruise Control Subsystem

#### 2.2.1 Control Architecture
```
Set Speed ──→ Error ──→ PID ──→ Torque ──→ Vehicle
              ▲  Calc     │      Request    Dynamics
              │            │                     │
              └────────────┴─────────────────────┘
                    Actual Speed (Feedback)
```

#### 2.2.2 PID Controller Design
- **Proportional Gain (Kp)**: 500 N·m/(m/s)
- **Integral Gain (Ki)**: 50 N·m/(m·s)
- **Derivative Gain (Kd)**: 100 N·m·s/m
- **Integral Limits**: ±200 N·m (anti-windup)
- **Output Limits**: ±300 N·m

**Discrete Implementation**:
```matlab
% PID Controller
e(k) = SetSpeed - ActualSpeed;
P(k) = Kp * e(k);
I(k) = I(k-1) + Ki * e(k) * Ts;
D(k) = Kd * (e(k) - e(k-1)) / Ts;
Output(k) = P(k) + I(k) + D(k);
```

#### 2.2.3 Feedforward Compensation
- **Purpose**: Compensate for known disturbances (grade, air resistance)
- **Grade Compensation**: Torque_ff = m * g * sin(θ) * r
- **Air Resistance**: Torque_ff = 0.5 * ρ * Cd * A * v² * r

#### 2.2.4 Activation Logic
```
Conditions for Activation:
1. Vehicle speed > 30 km/h
2. Brake pedal not pressed
3. No active faults
4. Driver button pressed
5. Gear in Drive
6. No wheel slip detected
```

### 2.3 Adaptive Cruise Control Subsystem

#### 2.3.1 System Architecture
```
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│    Sensor    │─────→│    Sensor    │─────→│   Decision   │
│   Interface  │      │    Fusion    │      │    Logic     │
└──────────────┘      └──────────────┘      └──────┬───────┘
                                                    │
                                                    ▼
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│   Vehicle    │←─────│   Control    │←─────│  Trajectory  │
│  Actuators   │      │  Allocation  │      │   Planning   │
└──────────────┘      └──────────────┘      └──────────────┘
```

#### 2.3.2 Sensor Fusion
- **Sensors**: Radar (primary), Camera (secondary)
- **Algorithm**: Extended Kalman Filter (EKF)
- **State Vector**: [distance, relative_velocity, relative_acceleration]
- **Update Rate**: 20 Hz

**State Equations**:
```
x(k+1) = A*x(k) + B*u(k) + w(k)
y(k) = C*x(k) + v(k)

where:
A = [1  Ts  0 ]
    [0  1   Ts]
    [0  0   1 ]

C = [1  0  0]
```

#### 2.3.3 Time Gap Control
**Control Law**: Model Predictive Control (MPC)

**Objective Function**:
```
J = Σ[(d_actual - d_desired)² + λ₁*a² + λ₂*Δa²]

where:
d_desired = v_ego * t_gap + d_min
t_gap = driver-selected time gap (1.0-2.5s)
d_min = minimum safe distance (5m)
λ₁ = acceleration weight (0.1)
λ₂ = jerk weight (1.0)
```

**Constraints**:
```
-3.0 m/s² ≤ a ≤ 2.0 m/s²  (acceleration limits)
-5.0 m/s³ ≤ jerk ≤ 5.0 m/s³  (jerk limits)
d ≥ d_min  (safety distance)
v ≤ v_set  (set speed limit)
```

#### 2.3.4 Object Detection & Tracking
- **Detection Range**: 5m - 150m
- **Field of View**: ±20° lateral
- **Target Classification**: Vehicle, stationary object, unknown
- **Track Management**: 
  - New track confirmation: 3 consecutive detections
  - Track deletion: 5 missed detections

#### 2.3.5 ACC State Machine

```
        ┌──────────────┐
        │  CC_ACTIVE   │ (No leading vehicle)
        └──────┬───────┘
               │
    Vehicle    │    Clear
    Detected   │    Path
               ▼
        ┌──────────────┐
        │ ACC_FOLLOWING│ (Following mode)
        └──────┬───────┘
               │
        Unsafe │    Safe
        Gap    │    Again
               ▼
        ┌──────────────┐
        │   WARNING    │ (FCW active)
        └──────┬───────┘
               │
        Critical│   Gap
        Gap     │   Increases
               ▼
        ┌──────────────┐
        │ EMERGENCY_   │ (AEB active)
        │   BRAKE      │
        └──────────────┘
```

### 2.4 Integration and Arbitration

#### 2.4.1 Mode Selection Logic
```
Priority Order (Highest to Lowest):
1. Emergency/Fault Mode
2. Driver Override (Brake/Accelerator)
3. ACC Following Mode
4. Cruise Control Mode
5. Manual Mode
```

#### 2.4.2 Torque Arbitration
```matlab
function torque_final = arbitrate_torque(torque_requests, modes)
    % Input: torque_requests from different subsystems
    % Output: final torque command
    
    if fault_detected
        torque_final = 0; % Safe state
    elseif driver_override
        torque_final = driver_torque;
    elseif acc_active && lead_vehicle_detected
        torque_final = min(acc_torque, cc_torque);
    elseif cc_active
        torque_final = cc_torque;
    else
        torque_final = manual_torque;
    end
    
    % Apply limits
    torque_final = limit(torque_final, -300, 300);
end
```

---

## 3. Interface Specifications

### 3.1 Input Interfaces

| Signal Name | Type | Range | Unit | Sample Rate | Source |
|-------------|------|-------|------|-------------|--------|
| Throttle_Pedal | Analog | 0-100 | % | 100 Hz | Pedal Sensor |
| Brake_Pedal | Digital | 0/1 | - | 100 Hz | Brake Switch |
| Vehicle_Speed | Analog | 0-200 | km/h | 100 Hz | Wheel Sensors |
| Radar_Distance | Analog | 0-150 | m | 20 Hz | Radar |
| Radar_RelVel | Analog | -50-50 | m/s | 20 Hz | Radar |
| Battery_SOC | Analog | 0-100 | % | 1 Hz | BMS |
| Motor_Temp | Analog | -40-150 | °C | 10 Hz | Temp Sensor |
| CC_Button | Digital | 0/1 | - | Event | Button |
| ACC_Button | Digital | 0/1 | - | Event | Button |

### 3.2 Output Interfaces

| Signal Name | Type | Range | Unit | Update Rate | Destination |
|-------------|------|-------|------|-------------|-------------|
| Motor_Torque_Cmd | Analog | -300-300 | N·m | 10 kHz | Motor Controller |
| PWM_DutyCycle | PWM | 0-100 | % | 10 kHz | Inverter |
| CC_Status | Digital | 0/1 | - | 10 Hz | Dashboard |
| ACC_Status | Digital | 0/1 | - | 10 Hz | Dashboard |
| Warning_FCW | Digital | 0/1 | - | 20 Hz | Dashboard/HMI |
| Set_Speed | Analog | 30-150 | km/h | 10 Hz | Dashboard |

---

## 4. Performance Specifications

### 4.1 Response Times
- Motor torque response: < 50 ms
- Cruise control activation: < 200 ms
- ACC target acquisition: < 100 ms
- Emergency braking trigger: < 150 ms

### 4.2 Accuracy Specifications
- Speed control: ±2 km/h
- Distance measurement: ±0.5 m
- Torque command: ±2%
- Time gap maintenance: ±0.1 s

### 4.3 Stability Margins
- Gain Margin: > 6 dB
- Phase Margin: > 45°
- Resonance Peak: < 3 dB

---

## 5. Safety Design

### 5.1 Fault Detection and Handling

| Fault Type | Detection Method | Response | Recovery |
|------------|-----------------|----------|----------|
| Sensor Failure | Plausibility check | Switch to backup | Auto if sensor OK |
| Communication Loss | Timeout (100ms) | Safe state | Manual reset |
| Motor Overcurrent | Hardware limit | Torque reduction | Auto cooldown |
| Brake Failure | Monitoring | Disable CC/ACC | Manual reset |
| ECU Fault | Watchdog | Emergency stop | Manual reset |

### 5.2 Redundancy
- Dual speed sensors (wheel + motor)
- Independent brake system
- Watchdog timer for ECU
- Backup power supply

---

## 6. Simulink Model Structure

### 6.1 Model Hierarchy
```
ev_controller_main.slx
├── Motor_Controller.slx
│   ├── Torque_Control
│   ├── Current_Control
│   └── Protection_Logic
├── Cruise_Control.slx
│   ├── PID_Controller
│   ├── Activation_Logic
│   └── Speed_Limiter
├── Adaptive_Cruise.slx
│   ├── Sensor_Fusion
│   ├── MPC_Controller
│   ├── Object_Tracking
│   └── Safety_Monitor
├── Vehicle_Dynamics.slx
│   ├── Longitudinal_Dynamics
│   ├── Powertrain
│   └── Environment
└── Integration_Layer.slx
    ├── Mode_Manager
    ├── Torque_Arbitration
    └── Diagnostics
```

### 6.2 Solver Configuration
- **Type**: Variable-step
- **Solver**: ode45 (Dormand-Prince)
- **Max Step Size**: 1e-3 s
- **Relative Tolerance**: 1e-4
- **Absolute Tolerance**: 1e-6

---

## 7. Testing Strategy

### 7.1 Unit Testing
- Test each subsystem independently
- Verify against requirements
- Coverage target: 100% of functional requirements

### 7.2 Integration Testing
- Test subsystem interactions
- Verify mode transitions
- Test arbitration logic

### 7.3 System Testing
- End-to-end scenarios
- Performance validation
- Safety verification

### 7.4 Test Scenarios
1. **Urban Driving**: Frequent stops, low speeds
2. **Highway Cruising**: Constant high speed
3. **ACC Following**: Various gaps and lead vehicle speeds
4. **Emergency Situations**: Sudden braking, cut-ins
5. **Grade Changes**: Uphill/downhill performance
6. **Fault Injection**: Sensor failures, communication loss

---

## 8. Code Generation

### 8.1 Target Configuration
- **Target**: Generic real-time system
- **Code Format**: C/C++
- **Optimization**: Speed
- **Fixed-point**: Enable for performance

### 8.2 Code Standards
- MISRA C:2012 compliance
- Polyspace verification
- Maximum cyclomatic complexity: 15
- Maximum function size: 200 lines

---

## 9. Appendices

### 9.1 Parameter Tables
See `matlab/scripts/initialization/` for detailed parameter definitions.

### 9.2 Block Diagrams
Detailed block diagrams available in `docs/presentations/`.

### 9.3 References
- J. Larminie, J. Lowry, "Electric Vehicle Technology Explained"
- R. Rajamani, "Vehicle Dynamics and Control"
- ISO 26262 Functional Safety Standard

---

**Document Control**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Nov 2025 | EV Controller Team | Initial design specification |

**Approval**

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Design Lead | | | |
| Technical Review | | | |
| Faculty Advisor | | | |
