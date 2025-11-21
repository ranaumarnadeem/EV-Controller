# Simulink Models

This directory contains all Simulink models for the EV Controller system.

## Directory Structure

### `models/`
Main Simulink models and subsystems

#### Top-Level Model
- **`ev_controller_main.slx`** - Main system model (to be created)
  - Integrates all subsystems
  - Top-level control logic
  - Interfaces with vehicle dynamics

#### `subsystems/`
Individual subsystem models:
- **`motor_controller.slx`** - Motor control subsystem
- **`cruise_control.slx`** - Cruise control subsystem
- **`adaptive_cruise.slx`** - Adaptive cruise control subsystem
- **`vehicle_dynamics.slx`** - Vehicle dynamics model
- **`sensor_models.slx`** - Sensor simulation models

#### `libraries/`
Reusable component libraries:
- **`custom_blocks.mdl`** - Custom Simulink blocks
- **`reusable_components.mdl`** - Common components

### `reports/`
Auto-generated model documentation

#### `model_reports/`
- Model Advisor reports
- Dependency analysis
- Interface specifications

#### `code_metrics/`
- Complexity metrics
- Code generation reports
- Performance analysis

## Model Development Guidelines

### Before You Start

1. **Initialize Parameters**
   ```matlab
   setup_project
   init_parameters
   init_vehicle_dynamics
   init_motor_params
   ```

2. **Load Project**
   ```matlab
   openProject('project.prj')
   ```

### Creating New Models

When creating subsystem models:

1. Use descriptive block names
2. Add annotations for complex logic
3. Use consistent signal naming
4. Set appropriate sample times
5. Enable logging for key signals
6. Document ports and interfaces

### Naming Conventions

- **Models**: `lowercase_with_underscores.slx`
- **Subsystems**: `CamelCase`
- **Signals**: `snake_case` or `camelCase`
- **Parameters**: Match MATLAB workspace variables

### Signal Naming

Use consistent prefixes:
- `cmd_*` - Command signals
- `meas_*` - Measured signals
- `est_*` - Estimated signals
- `ref_*` - Reference signals

### Sample Times

- Motor control: 100 μs (10 kHz)
- Cruise/ACC control: 10 ms (100 Hz)
- Sensor fusion: 50 ms (20 Hz)
- Diagnostics: 100 ms (10 Hz)

## Running Simulations

### Quick Start
```matlab
% Open model
open_system('simulink/models/ev_controller_main.slx')

% Run simulation
sim('ev_controller_main')

% Analyze results
analyze_performance
plot_results
```

### Advanced Configuration

1. **Solver Settings**
   - Type: Variable-step
   - Solver: ode45
   - Max step: 1e-3 s

2. **Data Logging**
   - Enable signal logging for analysis
   - Configure Simulink Data Inspector
   - Save simulation output to workspace

3. **Code Generation** (optional)
   - Configure for target hardware
   - Enable optimization
   - Run Model Advisor

## Model Organization

### Subsystem Structure
```
ev_controller_main.slx
├── Inputs (Driver commands, sensors)
├── Motor Controller
│   ├── Torque Control
│   ├── Current Control
│   └── Protection
├── Cruise Control
│   ├── Speed Control
│   └── Mode Logic
├── Adaptive Cruise
│   ├── Sensor Fusion
│   ├── MPC Controller
│   └── Safety Monitor
├── Vehicle Dynamics
│   ├── Longitudinal Dynamics
│   └── Powertrain
├── Integration Layer
│   ├── Mode Manager
│   └── Arbitration
└── Outputs (Visualization, logging)
```

## Testing

### Unit Testing
- Test each subsystem independently
- Use Test Harness for isolated testing
- Verify against requirements

### Integration Testing
- Test subsystem interactions
- Verify mode transitions
- Test arbitration logic

### Scenarios
Test scenarios in `matlab/data/test_scenarios/`:
- Urban driving cycle
- Highway cruise
- ACC following scenarios
- Emergency situations

## Model Quality

### Best Practices
- Run Model Advisor regularly
- Check for algebraic loops
- Verify signal dimensions
- Use Bus objects for complex interfaces
- Enable runtime checks during development

### Performance
- Optimize for simulation speed
- Use appropriate data types
- Minimize global signals
- Use efficient blocks

## Version Control

- Save models in ASCII format for better diff
- Use model comparison tools
- Document significant changes
- Tag release versions

## Troubleshooting

### Common Issues

**Issue**: Model won't simulate
- Check parameter initialization
- Verify all required variables exist
- Check solver settings

**Issue**: Slow simulation
- Reduce logging frequency
- Increase max step size
- Use fixed-step solver if possible

**Issue**: Unexpected results
- Check initial conditions
- Verify signal units
- Check sample time settings

---

For detailed design information, see `docs/design-specifications.md`.
