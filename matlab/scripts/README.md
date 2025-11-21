# MATLAB Scripts

This directory contains all MATLAB scripts for the EV Controller project, organized by function.

## Directory Structure

### `initialization/`
Scripts for initializing system parameters:
- **`init_parameters.m`** - General system parameters (vehicle, battery, control)
- **`init_vehicle_dynamics.m`** - Vehicle dynamics and physical parameters
- **`init_motor_params.m`** - Electric motor specifications and control parameters

Run these scripts in order before running simulations:
```matlab
run('init_parameters.m')
run('init_vehicle_dynamics.m')
run('init_motor_params.m')
```

### `analysis/`
Scripts for post-simulation analysis:
- **`analyze_performance.m`** - Calculate performance metrics
- **`plot_results.m`** - Generate plots from simulation results
- **`calculate_efficiency.m`** - Compute efficiency metrics and energy analysis

Usage:
```matlab
% After simulation completes
analyze_performance;
plot_results;
calculate_efficiency;
```

### `utilities/`
Helper functions and utilities:
- **`unit_conversions.m`** - Unit conversion functions
- **`data_processing.m`** - Data filtering, smoothing, and analysis functions

## Usage Guidelines

### Running Simulations

1. **Setup Environment**
   ```matlab
   setup_project  % From project root
   ```

2. **Initialize Parameters**
   ```matlab
   cd('matlab/scripts/initialization')
   init_parameters
   init_vehicle_dynamics
   init_motor_params
   ```

3. **Run Simulink Model**
   ```matlab
   cd('../../simulink/models')
   sim('ev_controller_main')
   ```

4. **Analyze Results**
   ```matlab
   cd('../../matlab/scripts/analysis')
   analyze_performance
   plot_results
   ```

### Adding New Scripts

When adding new scripts:
- Place in appropriate subdirectory
- Include header comments with description, author, and date
- Use consistent naming: lowercase with underscores
- Document input/output parameters
- Add to this README

### Coding Standards

- Use clear variable names
- Comment complex operations
- Include error checking
- Use consistent formatting
- Test thoroughly before committing

## Common Variables

Scripts use these common variable structures:
- `vehicle.*` - Vehicle parameters
- `motor.*` - Motor parameters
- `battery.*` - Battery parameters
- `cc.*` - Cruise control parameters
- `acc.*` - ACC parameters
- `out.*` - Simulation output data

## Dependencies

Required MATLAB Toolboxes:
- MATLAB R2023b or later
- Control System Toolbox
- Signal Processing Toolbox (for filtering)
- Statistics and Machine Learning Toolbox (optional, for advanced analysis)

---

For technical questions, refer to the design specifications in `docs/design-specifications.md`.
