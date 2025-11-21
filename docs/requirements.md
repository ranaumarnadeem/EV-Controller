# System Requirements Specification

## EV Controller Project
**Version**: 1.0  
**Date**: November 2025  
**Team**: Urva Ali, Maryam Imran, Hanna Imran, Rana Umar Nadeem, Ali Sher  
**Institution**: NUST-SEECS

---

## 1. Introduction

### 1.1 Purpose
This document specifies the functional and non-functional requirements for the Electric Vehicle (EV) Controller system. The system integrates motor control, cruise control, and adaptive cruise control to provide efficient, safe, and comfortable vehicle operation.

### 1.2 Scope
The EV Controller system shall:
- Control electric motor torque and speed
- Maintain desired vehicle speed (cruise control)
- Automatically adjust speed based on leading vehicle distance (adaptive cruise control)
- Optimize energy consumption
- Ensure safe operation under all driving conditions

### 1.3 Definitions and Acronyms
- **EV**: Electric Vehicle
- **ACC**: Adaptive Cruise Control
- **CC**: Cruise Control
- **SOC**: State of Charge
- **BLDC**: Brushless DC Motor
- **PWM**: Pulse Width Modulation
- **ECU**: Electronic Control Unit

---

## 2. Overall Description

### 2.1 Product Perspective
The EV Controller is a comprehensive control system that interfaces with:
- Electric motor drive system
- Vehicle sensors (speed, distance, throttle, brake)
- Battery management system
- User interface (dashboard controls)

### 2.2 User Classes and Characteristics
- **Driver**: Primary user who interacts with cruise control and ACC features
- **System Engineer**: Configures and calibrates control parameters
- **Maintenance Personnel**: Monitors system performance and diagnostics

### 2.3 Operating Environment
- MATLAB R2023b or later
- Simulink for model-based design
- Target platform: Embedded ECU (future deployment)

---

## 3. Functional Requirements

### 3.1 Motor Control System

#### 3.1.1 Torque Control
**ID**: FR-MC-001  
**Priority**: High  
**Description**: The system shall control motor torque based on driver input and system constraints.

**Requirements**:
- FR-MC-001.1: Torque command range: -100% to +100% (regenerative to full acceleration)
- FR-MC-001.2: Torque response time: < 50 ms
- FR-MC-001.3: Torque accuracy: ± 2% of commanded value
- FR-MC-001.4: Implement torque limiting based on battery SOC
- FR-MC-001.5: Implement thermal protection with torque derating

#### 3.1.2 Speed Control
**ID**: FR-MC-002  
**Priority**: High  
**Description**: The system shall regulate motor speed within specified limits.

**Requirements**:
- FR-MC-002.1: Speed range: 0 - 8000 RPM
- FR-MC-002.2: Speed regulation accuracy: ± 1%
- FR-MC-002.3: Implement overspeed protection at 8500 RPM

#### 3.1.3 Motor Protection
**ID**: FR-MC-003  
**Priority**: High  
**Description**: The system shall protect the motor from damage.

**Requirements**:
- FR-MC-003.1: Current limiting: Maximum 300A continuous, 400A peak (5s)
- FR-MC-003.2: Temperature monitoring with shutdown at 150°C
- FR-MC-003.3: Undervoltage protection: < 280V
- FR-MC-003.4: Overvoltage protection: > 420V

### 3.2 Cruise Control System

#### 3.2.1 Speed Set Function
**ID**: FR-CC-001  
**Priority**: High  
**Description**: The driver shall be able to set and maintain a desired speed.

**Requirements**:
- FR-CC-001.1: Speed set range: 30 km/h to 150 km/h
- FR-CC-001.2: Speed increment/decrement: 5 km/h per button press
- FR-CC-001.3: Speed holding accuracy: ± 2 km/h
- FR-CC-001.4: Activation conditions: Vehicle speed > 30 km/h, no brake applied

#### 3.2.2 Speed Adjustment
**ID**: FR-CC-002  
**Priority**: Medium  
**Description**: The system shall allow speed adjustment while cruise control is active.

**Requirements**:
- FR-CC-002.1: Resume function returns to last set speed
- FR-CC-002.2: Acceleration/deceleration rate: 1.5 m/s²
- FR-CC-002.3: Cancel function: Brake pedal or cancel button

#### 3.2.3 Cruise Control Safety
**ID**: FR-CC-003  
**Priority**: High  
**Description**: The system shall ensure safe cruise control operation.

**Requirements**:
- FR-CC-003.1: Automatic deactivation on brake pedal press
- FR-CC-003.2: Cannot activate if vehicle stability compromised
- FR-CC-003.3: Automatic deactivation if wheel slip detected
- FR-CC-003.4: Deactivation on steep gradients (> 15%)

### 3.3 Adaptive Cruise Control (ACC)

#### 3.3.1 Distance Sensing
**ID**: FR-ACC-001  
**Priority**: High  
**Description**: The system shall detect and track leading vehicles.

**Requirements**:
- FR-ACC-001.1: Detection range: 5m to 150m
- FR-ACC-001.2: Detection accuracy: ± 0.5m
- FR-ACC-001.3: Lateral detection: ± 1.5m (within lane)
- FR-ACC-001.4: Update rate: 50 Hz minimum

#### 3.3.2 Following Distance Control
**ID**: FR-ACC-002  
**Priority**: High  
**Description**: The system shall maintain safe following distance.

**Requirements**:
- FR-ACC-002.1: Time gap settings: 1.0s, 1.5s, 2.0s, 2.5s
- FR-ACC-002.2: Default time gap: 2.0s
- FR-ACC-002.3: Minimum following distance: 5m at all speeds
- FR-ACC-002.4: Distance maintenance accuracy: ± 1m

#### 3.3.3 Speed Adaptation
**ID**: FR-ACC-003  
**Priority**: High  
**Description**: The system shall adjust speed based on leading vehicle.

**Requirements**:
- FR-ACC-003.1: Maximum deceleration: -3.0 m/s² (comfort limit)
- FR-ACC-003.2: Maximum acceleration: +2.0 m/s²
- FR-ACC-003.3: Smooth speed transitions with jerk limiting: < 5 m/s³
- FR-ACC-003.4: Return to set speed when path is clear

#### 3.3.4 ACC Safety Features
**ID**: FR-ACC-004  
**Priority**: High  
**Description**: The system shall include safety features for ACC operation.

**Requirements**:
- FR-ACC-004.1: Forward collision warning at < 1.0s time gap
- FR-ACC-004.2: Automatic emergency braking capability
- FR-ACC-004.3: Driver override always available
- FR-ACC-004.4: Visual and audible warnings for system limitations

### 3.4 Energy Management

#### 3.4.1 Efficiency Optimization
**ID**: FR-EM-001  
**Priority**: Medium  
**Description**: The system shall optimize energy consumption.

**Requirements**:
- FR-EM-001.1: Implement regenerative braking with up to 70% energy recovery
- FR-EM-001.2: Optimize motor operating point for efficiency
- FR-EM-001.3: Predictive energy management for ACC
- FR-EM-001.4: Eco mode: Limit acceleration to 1.0 m/s²

---

## 4. Non-Functional Requirements

### 4.1 Performance Requirements

**NFR-PERF-001**: System response time < 100 ms for all control loops  
**NFR-PERF-002**: Control loop frequency: Minimum 100 Hz  
**NFR-PERF-003**: Sensor data processing: < 10 ms latency  
**NFR-PERF-004**: Overall system efficiency: > 92%

### 4.2 Safety Requirements

**NFR-SAFE-001**: System shall comply with ISO 26262 (ASIL-B minimum)  
**NFR-SAFE-002**: Fail-safe mode on critical component failure  
**NFR-SAFE-003**: Redundant sensors for critical measurements  
**NFR-SAFE-004**: Continuous self-diagnostics with fault logging

### 4.3 Reliability Requirements

**NFR-REL-001**: Mean Time Between Failures (MTBF): > 50,000 hours  
**NFR-REL-002**: System availability: 99.9%  
**NFR-REL-003**: Graceful degradation on non-critical failures

### 4.4 Usability Requirements

**NFR-USE-001**: Intuitive user interface with clear feedback  
**NFR-USE-002**: Setup and activation time < 5 seconds  
**NFR-USE-003**: Clear visual indicators for active modes

### 4.5 Maintainability Requirements

**NFR-MAINT-001**: Modular design for easy component replacement  
**NFR-MAINT-002**: Comprehensive diagnostic capabilities  
**NFR-MAINT-003**: Detailed documentation and commenting

---

## 5. System Constraints

### 5.1 Design Constraints
- Must be implementable in MATLAB/Simulink
- Compatible with standard automotive ECU hardware
- Power consumption: < 5W for control unit

### 5.2 Regulatory Constraints
- Comply with automotive safety standards (ISO 26262)
- Meet electromagnetic compatibility (EMC) requirements
- Adhere to regional vehicle safety regulations

### 5.3 Hardware Constraints
- Operating temperature: -40°C to +85°C
- Supply voltage: 9V to 16V
- Physical size constraints for ECU packaging

---

## 6. Verification and Validation

### 6.1 Verification Methods
- Model-in-the-Loop (MIL) testing in Simulink
- Software-in-the-Loop (SIL) testing
- Unit testing for all functions
- Integration testing for subsystems

### 6.2 Validation Methods
- Hardware-in-the-Loop (HIL) testing (future)
- Field testing with prototype vehicle
- Performance benchmarking
- User acceptance testing

---

## 7. Appendices

### 7.1 Test Scenarios
To be defined in separate test specification document.

### 7.2 Interface Specifications
To be defined in design specification document.

### 7.3 References
- ISO 26262: Road vehicles - Functional safety
- SAE J2735: Dedicated Short Range Communications (DSRC)
- MATLAB/Simulink documentation

---

**Document Control**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Nov 2025 | EV Controller Team | Initial requirements specification |

**Approval**

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Project Lead | Rana Umar Nadeem | | |
| Technical Lead | | | |
| Faculty Advisor | | | |
