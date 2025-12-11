---
layout: default
title: Motor PID Control
---

# Motor PID Control

**Navigation:**
- [Home](index.md)
- [Cruise Control](cruise-control.md)
- [Motor PID Control](motor-pid.md)
- [Decoupling Mechanism](decoupling.md)

---

**Developed by**: Maryam Imran & Urva Ali

---

## Overview

The Motor PID Control system regulates the PMSM (Permanent Magnet Synchronous Motor) by providing precise voltage outputs to achieve the desired torque. It operates in the d-q reference frame, using two independent PID controllers for flux and torque control.

---

## System Purpose

The motor PID controller serves as the **inner control loop** that:

1. Receives **torque demand** from the cruise control system
2. Converts torque demand to **current references** (id*, iq*)
3. Regulates actual motor currents to match references
4. Outputs **clean voltages** (vd_lin, vq_lin) for the motor

---

## Reference Frame Transformation

### ABC Frame of Reference

**Characteristics**:
- 3 sinusoidal waveforms (phases A, B, C)
- Time-varying and complex
- Difficult for control logic
- 120° phase shift between phases

**Limitations**:
- Requires instantaneous calculations
- Non-intuitive control
- Difficult to separate flux and torque

### d-q Frame of Reference

**Characteristics**:
- 2 DC-like signals in rotating frame
- Rotates synchronously with rotor
- Behaves like DC from rotor's perspective
- Enables independent control

**Advantages**:
- Simplified control strategy
- Direct flux and torque regulation
- Standard for field-oriented control (FOC)
- Separates real and reactive power

**Transformation**:
```
ABC → αβ (Clarke) → dq (Park)
```

---

## d-q Frame Control Signals

### d-axis Current (id)

**Function**: Controls magnetic flux production in the stator

**For PMSM with Permanent Magnets**:
- Flux is fixed by permanent magnets
- **id* = 0** (reference is zero)
- No additional flux needed
- Minimizes resistive losses

**Control Objective**: Force id → 0

### q-axis Current (iq)

**Function**: Controls torque production

**Relationship**:
```
T = 1.5 · Zp · φ · iq + 1.5 · Zp · (Ld - Lq) · id · iq
```

For PMSM with id = 0:
```
T = 1.5 · Zp · φ · iq
```

**Control Objective**: Force iq → iq* (based on torque demand)

Where:
- **T**: Motor torque [Nm]
- **Zp**: Number of pole pairs
- **φ**: Permanent magnet flux linkage [Wb]
- **Ld, Lq**: d-axis and q-axis inductances [H]

---

## System Architecture

![Motor PID Control Flowchart](images/motor-pid-flowchart.png)


---

## Component Details

### 1. DEMUX Block

**Function**: Vector decomposition

**Input**: 
```
Idq = [id; iq]  (2×1 vector)
```

**Operation**: 
- Breaks current vector into scalar components
- Separates flux current (id) from torque current (iq)

**Outputs**:
- **id**: d-axis current (flux component)
- **iq**: q-axis current (torque component)

---

### 2. PID Controller 1 (id Control)

**Objective**: Maintain id = 0

**Control Loop**:
```
     ┌─────┐     ┌──────┐     ┌───────┐
id* ─→  Σ  ├────→│ PID1 │────→│ Plant │───┐
(0)  │  -  │     └──────┘     └───────┘   │
     └──┬──┘                               │
        ↑                                  │
        └──────────────────────────────────┘
                    id (measured)
```

**Reference Input (id*)**:
- Always **0** for PMSM with permanent magnets
- Flux is constant from PMs
- No field weakening needed (in basic operation)

**Measured Input (id)**:
- Calculated from motor phase currents (ia, ib, ic)
- Via Clarke and Park transformations

**Error Signal**:
```
e_d = id* - id = 0 - id = -id
```

**PID Action**:
```
vd_lin = Kp_d · e_d + Ki_d · ∫e_d dt + Kd_d · de_d/dt
```

**Output**: 
- **vd_lin**: d-axis linear voltage
- Forces id → 0
- Minimizes reactive current

---

### 3. PID Controller 2 (iq Control)

**Objective**: Track iq* from torque demand

**Control Loop**:
```
     ┌─────┐     ┌──────┐     ┌───────┐
iq* ─→  Σ  ├────→│ PID2 │────→│ Plant │───┐
     │  -  │     └──────┘     └───────┘   │
     └──┬──┘                               │
        ↑                                  │
        └──────────────────────────────────┘
                    iq (measured)
```

**Reference Input (iq*)**:

Derived from torque demand:
```
iq* = T_d / (1.5 · Zp · φ)
```

Where:
- **T_d**: Torque demand from cruise control [Nm]
- **Zp**: Motor pole pairs (typically 3)
- **φ**: Flux linkage [Wb]

**Measured Input (iq)**:
- Current measured from motor
- Transformed to q-axis via Clarke & Park

**Error Signal**:
```
e_q = iq* - iq
```

**PID Action**:
```
vq_lin = Kp_q · e_q + Ki_q · ∫e_q dt + Kd_q · de_q/dt
```

**Output**:
- **vq_lin**: q-axis linear voltage
- Forces iq → iq*
- Produces required torque

---

### 4. MUX Block

**Function**: Vector reconstruction

**Inputs**:
- vd_lin (from PID1)
- vq_lin (from PID2)

**Operation**:
```
Vdq_lin = [vd_lin; vq_lin]
```

**Output**: 
- 2×1 voltage vector in d-q frame

**Important Note**:
These are **uncoupled voltages**. They ignore the cross-coupling between id and iq that exists in the real motor. The decoupler block will add the coupling terms.

---

## PID Controller Design

### Why PID Control?

**Proportional (P)**:
- Immediate error correction
- Fast response to changes
- Reduces steady-state error

**Integral (I)**:
- Eliminates steady-state error completely
- Accounts for resistive voltage drops
- Compensates for back-EMF

**Derivative (D)**:
- Improves transient response
- Reduces current overshoot
- In this application: **Kd = 0** (not used)

### PID Parameters

**For d-axis (id control)**:
```matlab
Kp_d = av = 0.677
Ki_d = (Rs/Ld) * av = 3.220
Kd_d = 0

where:
Rs = 0.00475 Ω   (stator resistance)
Ld = 1.0e-4 H    (d-axis inductance)
av = ωc = 0.677  (bandwidth parameter)
```

**For q-axis (iq control)**:
```matlab
Kp_q = av = 0.677
Ki_q = (Rs/Lq) * av = 3.220
Kd_q = 0

where:
Lq = 1.0e-3 H    (q-axis inductance)
```

### Bandwidth Parameter (ωc)

**Definition**: How fast the current responds

**Value**: av = 0.677 rad/s

**Effect**:
- Higher ωc → Faster response
- Lower ωc → Smoother, more stable
- Trade-off between speed and stability

---

## Why Coupling Terms Are Ignored

The PID controllers output **linear voltages** that would be correct if id and iq were completely independent. However, in a real PMSM:

**d-axis voltage equation**:
```
vd = Rs·id + Ld·(did/dt) - ωs·Lq·iq
                          ^^^^^^^^^^
                          Coupling term!
```

**q-axis voltage equation**:
```
vq = Rs·iq + Lq·(diq/dt) + ωs·Ld·id + ωs·φ
                          ^^^^^^^^^^^^^^^^^^
                          Coupling terms!
```

**The PID controllers provide**:
```
vd_lin = Rs·id + Ld·(did/dt)
vq_lin = Rs·iq + Lq·(diq/dt)
```

**Missing terms** (added by decoupler):
- `-ωs·Lq·iq` in d-axis
- `+ωs·Ld·id + ωs·φ` in q-axis

This is why the **decoupler block** is essential.

---

## Torque-to-Current Conversion

**Given**: Torque demand Td from cruise control

**Calculate**: Required q-axis current

**Formula**:
```
iq* = Td / (1.5 · Zp · φ + (Ld - Lq) · id)
```

For PMSM with id = 0:
```
iq* = Td / (1.5 · Zp · φ)
```

**Example**:
```
Td = 100 Nm
Zp = 3
φ = 0.23 Wb

iq* = 100 / (1.5 × 3 × 0.23)
    = 100 / 1.035
    = 96.6 A
```

---

## Signal Flow Summary

1. **Cruise control** provides **Torque Demand (Td)**
2. **Torque → Current conversion** calculates **iq***
3. **id* set to 0** (no field weakening)
4. **DEMUX** separates measured **[id, iq]** from motor
5. **PID1** forces **id → 0**, outputs **vd_lin**
6. **PID2** forces **iq → iq***, outputs **vq_lin**
7. **MUX** combines into **Vdq_lin vector**
8. **Decoupler** adds coupling terms → **Vdq_actual**
9. **PMSM** receives final voltages, produces torque

---

## Control Performance

### Current Regulation Bandwidth

**Typical settling time**: 10-20 ms

**Response characteristics**:
- Fast tracking of iq* changes
- Minimal overshoot (~5%)
- Zero steady-state error (Ki action)

### Torque Production Accuracy

With proper decoupling:
- **Torque error**: < 2% of commanded value
- **Response time**: < 50 ms for 90% of step change

---

## Simulink Implementation

### Required Blocks

1. **Constant**: id* = 0
2. **Gain**: Torque-to-current conversion (1 / (1.5·Zp·φ))
3. **Demux**: Split Idq into [id, iq]
4. **Sum**: Error calculation (2×, one for each axis)
5. **PID Controller**: 2× PID blocks
6. **Mux**: Combine [vd_lin, vq_lin]

### Signal Connections

```
Td ──[1/(1.5*Zp*φ)]──→ iq*
                         │
                         ▼
Idq ──[DEMUX]──→ id ──[Σ]──[PID1]──→ vd_lin
                 iq ──[Σ]──[PID2]──→ vq_lin
                      ↑         ↑
                      0        iq*

[vd_lin, vq_lin] ──[MUX]──→ Vdq_lin ──→ To Decoupler
```

---

## Tuning Guidelines

### Step 1: Test d-axis controller
- Set iq* = 0 (no torque)
- Apply step in id* (though normally 0)
- Tune Kp_d, Ki_d for fast settling

### Step 2: Test q-axis controller
- Set iq* to small constant (10-20 A)
- Ensure id = 0 is maintained
- Tune Kp_q, Ki_q for fast torque response

### Step 3: Test coupled response
- Apply step changes in torque demand
- Check both id and iq behavior
- Verify minimal cross-coupling

---

## Integration Points

### Input from Cruise Control

| Signal | Units | Range | Update Rate |
|--------|-------|-------|-------------|
| Torque Demand (Td) | Nm | 0-420 | 100 Hz |

### Input from Motor/Sensors

| Signal | Units | Range | Measurement |
|--------|-------|-------|-------------|
| Motor currents (ia, ib, ic) | A | -400 to +400 | Hall sensors |
| Rotor position (θ) | rad | 0 to 2π | Encoder |

### Output to Decoupler

| Signal | Units | Range | Characteristics |
|--------|-------|-------|-----------------|
| vd_lin | V | 0-400 | Linear d-voltage |
| vq_lin | V | 0-400 | Linear q-voltage |
| id | A | -50 to +50 | Measured flux current |
| iq | A | -400 to +400 | Measured torque current |

---

## Advantages of d-q Control

1. **Simplicity**: DC-like control instead of AC
2. **Decoupling**: Independent flux and torque control
3. **Efficiency**: Minimize reactive currents (id = 0)
4. **Fast Response**: Direct torque control
5. **Robustness**: PID handles parameter variations

---

## Challenges Addressed

### Problem: 3-phase currents are sinusoidal
**Solution**: Transform to d-q rotating frame (appears DC)

### Problem: id and iq affect each other
**Solution**: Use decoupler to compensate cross-coupling

### Problem: Back-EMF varies with speed
**Solution**: Integral term compensates, decoupler adds ωs·φ term

### Problem: Torque ripple
**Solution**: Fast current regulation smooths torque production

---

## Performance Metrics

| Metric | Target | Typical |
|--------|--------|---------|
| Current settling time | < 20 ms | 15 ms |
| Torque accuracy | ±2% | ±1.5% |
| id regulation | < 5 A | < 2 A |
| iq tracking error | < 3% | < 2% |
| Update rate | 10 kHz | 10 kHz |

---

## Future Enhancements

- **Field Weakening**: Allow id < 0 for high-speed operation
- **MTPA (Maximum Torque Per Ampere)**: Optimize id/iq ratio
- **Adaptive Tuning**: Adjust PID gains with operating point
- **Feedforward Control**: Predict coupling terms
- **Sensorless Control**: Estimate position without encoder

---

## References

1. **Field-Oriented Control**: Blaschke, F. (1972). "The Principle of Field Orientation"
2. **PMSM Control**: Krishnan, R. (2009). *Permanent Magnet Synchronous and Brushless DC Motor Drives*
3. **d-q Transformation**: Park, R. H. (1929). "Two-Reaction Theory of Synchronous Machines"

---

**Developed by**: Maryam Imran & Urva Ali, NUST-SEECS  
**Last Updated**: December 2025
