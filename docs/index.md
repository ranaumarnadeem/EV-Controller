---
layout: default
title: Home
---

# EV Controller System Documentation

**Navigation:**
- [Home](index.md)
- [Cruise Control](cruise-control.md)
- [Motor PID Control](motor-pid.md)
- [Decoupling Mechanism](decoupling.md)

---

Welcome to the comprehensive documentation for the **Electric Vehicle Controller Project** developed at NUST-SEECS.

## Project Overview

This project implements a complete electric vehicle control system using MATLAB/Simulink, focusing on:

- **Cruise Control System** - Velocity tracking and regulation
- **Motor PID Control** - Torque and flux control for PMSM
- **Decoupling Mechanism** - Field-oriented control for PMSM motors
- **System Integration** - Complete EV control architecture

## Team Members

| Name | Responsibility |
|------|----------------|
| **Rana Umar Nadeem** | Cruise Control Development |
| **Maryam Imran** | Torque Control Implementation |
| **Urva Ali** | Torque Control & Final Integration |
| **Hanna Imran** | Decoupler Design |
| **Ali Sher** | PMSM Motor Modeling & Control |

**Institution**: National University of Sciences and Technology (NUST) - School of Electrical Engineering and Computer Science (SEECS)

---

## System Architecture

The EV Controller system consists of three main subsystems working together:

![System Flowchart](images/system-flowchart.png)



---

## Documentation Sections

### 1. [Cruise Control System](cruise-control.md)
- Control loop architecture
- PID controller design
- Vehicle dynamics model
- Torque demand calculation
- Interface specifications

**Key Features:**
- Closed-loop velocity tracking
- First-order vehicle dynamics
- Gravity compensation
- Torque demand generation

### 2. [Motor PID Control](motor-pid.md)
- d-q reference frame transformation
- Dual PID controller structure
- Current control strategy
- Voltage generation

**Key Features:**
- Independent flux and torque control
- Clarke and Park transformations
- Current regulation (id and iq)
- Clean voltage outputs

### 3. [Decoupling Mechanism](decoupling.md)
- PMSM coupling effects
- Field-oriented control
- Decoupling mathematics
- Implementation details

**Key Features:**
- Cross-coupling compensation
- Back-EMF compensation
- Stable torque production
- Enhanced control precision

---

## Quick Start

### Prerequisites
- MATLAB R2023b or later
- Simulink
- Control System Toolbox

### Installation

1. Clone the repository:
```bash
git clone https://github.com/ranaumarnadeem/EV-Controller.git
cd EV-Controller
```

2. Initialize parameters in MATLAB:
```matlab
setup_project
PMSM_init
init_parameters
```

3. Open Simulink models:
```matlab
open_system('cruise_control.slx')
open_system('motor_pid.slx')
open_system('PMSM.slx')
```

### Running Simulations

```matlab
% Run cruise control simulation
sim('cruise_control')

% Run motor control simulation
sim('motor_pid')

% Run integrated system
sim('IntegratedpmsmmotorofEV')
```

---

## Key Parameters

### Vehicle Parameters
- **Mass (m)**: 1992 kg
- **Effective Radius (Reff)**: 0.2413 m
- **Gear Ratio (ig)**: 9
- **Drag Coefficient (CW)**: 0.23
- **Frontal Area (A)**: 3.45 m²

### Motor Parameters (PMSM)
- **Pole Pairs (Zp)**: 3
- **Flux Linkage (φ)**: 0.23 Wb
- **d-axis Inductance (Ld)**: 1e-4 H
- **q-axis Inductance (Lq)**: 1e-3 H
- **Stator Resistance (Rs)**: 0.00475 Ω
- **Max Torque (Tmax)**: 420 Nm

### Control Parameters
- **Sample Time (Ts)**: 0.01 s
- **Operating Speed**: 100 km/h (27.78 m/s)
- **PID Gains**:
  - Kp = 0.677
  - Ki = 3.220
  - Kd = 0

---

## Signal Interface

### Between Cruise Control and Motor PID

| Signal | Symbol | Units | Description |
|--------|--------|-------|-------------|
| Torque Demand | Td | Nm | Reference torque from cruise control |
| Velocity State | v | m/s | Current vehicle velocity |
| Slope Angle | θ | deg | Road grade for compensation |

### Between Motor PID and Decoupler

| Signal | Symbol | Units | Description |
|--------|--------|-------|-------------|
| d-axis Linear Voltage | vdl | V | Uncoupled d-axis voltage |
| q-axis Linear Voltage | vql | V | Uncoupled q-axis voltage |
| d-axis Current | id | A | Measured flux current |
| q-axis Current | iq | A | Measured torque current |
| Electrical Speed | ωs | rad/s | Rotor electrical speed |

### Between Decoupler and PMSM

| Signal | Symbol | Units | Description |
|--------|--------|-------|-------------|
| d-axis Voltage | vd | V | Coupled d-axis voltage |
| q-axis Voltage | vq | V | Coupled q-axis voltage |

---

## Control Strategy

### 1. Velocity Control (Outer Loop)
The cruise control implements a PID-based velocity tracking system:
- **Proportional**: Immediate response to velocity error
- **Integral**: Eliminates steady-state error from drag
- **Derivative**: Reduces overshoot and improves stability

### 2. Current Control (Inner Loop)
Motor PID provides fast current regulation:
- **id Control**: Maintains zero flux current (PM motor)
- **iq Control**: Generates required torque current

### 3. Decoupling (Compensation)
Compensates for PMSM cross-coupling effects:
- Removes d-q axis interactions
- Adds back-EMF compensation
- Ensures independent control

---

## Repository Structure

```
EV-Controller/
├── docs/                  # Documentation files
│   ├── index.md          # This file
│   ├── cruise-control.md # Cruise control documentation
│   ├── motor-pid.md      # Motor PID documentation
│   └── decoupling.md     # Decoupling documentation
├── matlab/
│   └── scripts/
│       └── initialization/
│           └── PMSM_init.m
├── simulink/
│   ├── cruise_control.slx
│   ├── motor_pid.slx
│   ├── PMSM.slx
│   └── IntegratedpmsmmotorofEV.slx
└── README.md
```

---

## References

1. **PMSM Control Theory**: Field-Oriented Control for AC Motors
2. **PID Control**: Classical Control Theory and Applications
3. **Vehicle Dynamics**: Longitudinal Motion Control
4. **Clarke & Park Transformations**: Three-Phase to d-q Conversion

---

## Contact

**Project Repository**: [github.com/ranaumarnadeem/EV-Controller](https://github.com/ranaumarnadeem/EV-Controller)

**Institution**: NUST-SEECS, Islamabad, Pakistan

---

**Last Updated**: December 2025
