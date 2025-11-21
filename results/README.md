# Simulation Results

This directory stores simulation outputs, plots, and performance metrics.

## Directory Structure

### `simulations/`
Raw simulation data and results:
- Saved workspace variables
- Time-series data
- State logs
- Signal recordings

Typical files:
- `*.mat` - MATLAB data files with simulation results
- `simulation_<timestamp>.mat` - Timestamped simulation runs

### `plots/`
Generated figures and visualizations:
- Performance plots
- Comparison charts
- Efficiency maps
- State trajectories

Typical files:
- `*.png`, `*.fig` - Plot files
- `*.pdf` - Publication-ready figures

### `performance_metrics/`
Calculated performance metrics:
- Efficiency calculations
- Energy consumption data
- Performance reports
- Benchmark results

Typical files:
- `performance_report.mat` - Comprehensive metrics
- `efficiency_results.mat` - Efficiency analysis
- `*.txt`, `*.csv` - Exported data

### `validation_reports/`
Test validation documentation:
- Test case results
- Requirement verification
- Acceptance criteria status
- Regression test logs

## Usage

### Saving Results

Results are automatically saved when running analysis scripts:

```matlab
% Run simulation
sim('ev_controller_main')

% Analyze and save results
analyze_performance  % Saves to performance_metrics/
plot_results         % Saves to plots/
calculate_efficiency % Saves efficiency data
```

### Manual Saving

To manually save simulation results:

```matlab
% Save workspace to results folder
timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
filename = sprintf('results/simulations/sim_%s.mat', timestamp);
save(filename, 'out', 'vehicle', 'motor', 'battery');
```

### Loading Results

To load and analyze previous results:

```matlab
% Load saved simulation
load('results/simulations/sim_2025-11-21_14-30-00.mat')

% Re-run analysis
analyze_performance
plot_results
```

## File Organization

### Naming Convention

Use descriptive names with timestamps:
- Simulations: `sim_<scenario>_<timestamp>.mat`
- Plots: `<plot_type>_<description>.png`
- Reports: `<metric>_report_<timestamp>.mat`

Examples:
- `sim_highway_cruise_2025-11-21.mat`
- `efficiency_map_full_range.png`
- `performance_report_2025-11-21.mat`

### Subdirectories by Scenario

Organize results by test scenario:
```
simulations/
├── urban_driving/
├── highway_cruise/
├── acc_following/
└── emergency_scenarios/
```

## Data Management

### Version Control

**DO NOT** commit large data files to git:
- The `.gitignore` is configured to ignore most result files
- Only commit representative examples or summary data
- Use external storage for large datasets

### Archiving

Periodically archive old results:
1. Compress old simulation data
2. Move to archive folder
3. Keep summary reports
4. Document what was archived

### Cleanup

Clean up unnecessary files:
```matlab
% Delete old simulation files (optional)
delete('results/simulations/*_old.mat')

% Keep only recent results
% (Implement your own cleanup strategy)
```

## Analysis Workflow

### Standard Analysis

1. **Run Simulation**
   ```matlab
   sim('ev_controller_main')
   ```

2. **Generate Reports**
   ```matlab
   analyze_performance
   ```

3. **Create Visualizations**
   ```matlab
   plot_results
   ```

4. **Calculate Efficiency**
   ```matlab
   calculate_efficiency
   ```

### Comparative Analysis

Compare multiple simulation runs:
```matlab
% Load multiple simulations
sim1 = load('results/simulations/sim_scenario1.mat');
sim2 = load('results/simulations/sim_scenario2.mat');

% Compare performance
compare_performance(sim1, sim2)
```

## Visualization

### Available Plots

The `plot_results.m` script generates:
- Vehicle speed vs time
- Motor torque and power
- Battery SOC
- Control mode indicators
- Efficiency maps
- Energy consumption

### Custom Plots

Create custom plots:
```matlab
figure;
plot(out.tout, out.vehicle_speed);
xlabel('Time [s]');
ylabel('Speed [km/h]');
title('Vehicle Speed Profile');
grid on;

% Save
saveas(gcf, 'results/plots/custom_speed_plot.png');
```

## Performance Metrics

### Key Metrics Calculated

- Energy consumption [kWh/100km]
- Motor efficiency [%]
- Regenerative braking efficiency [%]
- 0-100 km/h acceleration time [s]
- Maximum speed [km/h]
- Range [km]

### Accessing Metrics

Load performance report:
```matlab
load('results/performance_metrics/performance_report.mat')
disp(performance_report)
```

## Export Options

### Export to CSV

```matlab
% Export time series data
export_to_csv('results/speed_data.csv', time, ...
              'Speed', vehicle_speed, ...
              'Torque', motor_torque);
```

### Export Figures

```matlab
% Export high-resolution figure
figure(1);
print('results/plots/figure1', '-dpng', '-r300');
```

## Troubleshooting

### Issue: Cannot save files
- Check write permissions
- Ensure directory exists
- Check available disk space

### Issue: Large file sizes
- Reduce logging frequency
- Save only necessary signals
- Compress old data

### Issue: Out of memory
- Clear workspace periodically
- Process data in chunks
- Use appropriate data types

---

For analysis script details, see `matlab/scripts/analysis/README.md`.
