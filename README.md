# EV Controller Project

[![MATLAB](https://img.shields.io/badge/MATLAB-R2023b%2B-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![Simulink](https://img.shields.io/badge/Simulink-R2023b%2B-blue.svg)](https://www.mathworks.com/products/simulink.html)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Project Overview

This repository contains the MATLAB/Simulink implementation of an advanced Electric Vehicle (EV) Controller system. The project integrates three key control systems:

- **Motor Control**: Efficient electric motor management and torque control
- **Cruise Control**: Speed maintenance and driver comfort optimization
- **Adaptive Cruise Control (ACC)**: Intelligent distance maintenance with lead vehicle detection

The system is designed to optimize energy efficiency, enhance driving safety, and provide a seamless user experience in electric vehicles.

## Team Members

| Name | Student ID | Role |
|------|------------|------|
| Urva Ali | - | Control Systems Design |
| Maryam Imran | - | Motor Control Implementation |
| Hanna Imran | - | Cruise Control Development |
| Rana Umar Nadeem | - | ACC & Integration |
| Ali Sher | - | Testing & Validation |

**Institution**: National University of Sciences and Technology (NUST) - School of Electrical Engineering and Computer Science (SEECS)

## Repository Structure

```
ev-controller-project/
├── docs/                          # Documentation files
│   ├── project-proposal.pdf       # Initial project proposal
│   ├── requirements.md            # System requirements specification
│   ├── design-specifications.md   # Detailed design documentation
│   └── presentations/             # Project presentations
│
├── matlab/                        # MATLAB scripts and functions
│   ├── scripts/                   # Main execution scripts
│   │   ├── initialization/        # Parameter initialization scripts
│   │   │   ├── init_parameters.m
│   │   │   ├── init_vehicle_dynamics.m
│   │   │   └── init_motor_params.m
│   │   ├── analysis/              # Analysis and plotting scripts
│   │   │   ├── analyze_performance.m
│   │   │   ├── plot_results.m
│   │   │   └── calculate_efficiency.m
│   │   └── utilities/             # Utility functions
│   │       ├── unit_conversions.m
│   │       └── data_processing.m
│   ├── functions/                 # Custom MATLAB functions
│   │   ├── motor_control/         # Motor control algorithms
│   │   ├── acc_logic/             # ACC decision logic
│   │   └── vehicle_dynamics/      # Vehicle dynamics models
│   └── data/                      # Data files
│       ├── test_scenarios/        # Test case definitions
│       ├── calibration/           # Calibration data
│       └── results/               # Simulation results
│
├── simulink/                      # Simulink models
│   ├── models/                    # Main and subsystem models
│   │   ├── ev_controller_main.slx # Top-level system model
│   │   ├── subsystems/            # Individual subsystem models
│   │   │   ├── motor_controller.slx
│   │   │   ├── cruise_control.slx
│   │   │   ├── adaptive_cruise.slx
│   │   │   ├── vehicle_dynamics.slx
│   │   │   └── sensor_models.slx
│   │   └── libraries/             # Custom block libraries
│   │       ├── custom_blocks.mdl
│   │       └── reusable_components.mdl
│   └── reports/                   # Auto-generated reports
│       ├── model_reports/
│       └── code_metrics/
│
├── results/                       # Simulation outputs
│   ├── simulations/               # Raw simulation data
│   ├── plots/                     # Generated plots and figures
│   ├── performance_metrics/       # Performance analysis results
│   └── validation_reports/        # Validation test reports
│
├── config/                        # Configuration files
│   ├── model_settings/            # Simulink model configurations
│   ├── solver_configurations/     # Solver settings
│   └── code_generation/           # Code generation settings
│
├── .gitignore                     # Git ignore rules
├── README.md                      # This file
├── setup_project.m                # Project setup script
└── project.prj                    # MATLAB project file
```

## Prerequisites

### Required Software
- **MATLAB** R2023b or later
- **Simulink** R2023b or later

### Required MATLAB Toolboxes
- Simulink
- Simscape Electrical
- Control System Toolbox
- Automated Driving Toolbox
- Stateflow
- MATLAB Coder (optional, for code generation)
- Simulink Coder (optional, for code generation)

### Checking Installed Toolboxes
Run the following command in MATLAB to verify installed toolboxes:
```matlab
ver
```

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/ranaumarnadeem/EV-Controller.git
cd EV-Controller
```

### 2. Open MATLAB
Navigate to the project directory in MATLAB or launch MATLAB from the project root directory.

### 3. Run Setup Script
Execute the setup script to configure paths and environment:
```matlab
setup_project
```

This script will:
- Add all necessary folders to the MATLAB path
- Verify required toolboxes are installed
- Initialize workspace variables
- Check for any missing dependencies

### 4. Open MATLAB Project
Double-click on `project.prj` or run:
```matlab
openProject('project.prj')
```

## Getting Started

### Running Your First Simulation

1. **Initialize Parameters**
   ```matlab
   run('matlab/scripts/initialization/init_parameters.m')
   run('matlab/scripts/initialization/init_vehicle_dynamics.m')
   run('matlab/scripts/initialization/init_motor_params.m')
   ```

2. **Open Main Simulink Model**
   ```matlab
   open_system('simulink/models/ev_controller_main.slx')
   ```

3. **Run Simulation**
   - Click the "Run" button in Simulink, or
   - Use MATLAB command: `sim('ev_controller_main')`

4. **Analyze Results**
   ```matlab
   run('matlab/scripts/analysis/plot_results.m')
   run('matlab/scripts/analysis/analyze_performance.m')
   ```

### Example Workflow

```matlab
% Complete simulation workflow
setup_project;                                          % Setup environment
init_parameters;                                        % Initialize parameters
sim('simulink/models/ev_controller_main');             % Run simulation
analyze_performance;                                    % Analyze results
plot_results;                                           % Visualize results
```

## Project Goals

1. **Motor Control**: Implement efficient torque and speed control for electric motors
2. **Cruise Control**: Develop robust speed maintenance system
3. **Adaptive Cruise Control**: Design intelligent distance-keeping system with sensor fusion
4. **Energy Efficiency**: Optimize overall system for maximum range
5. **Safety**: Ensure fail-safe operation and emergency handling

## Development Guidelines

### Branching Strategy
- `main` - Stable, tested code
- `develop` - Integration branch
- `feature/*` - New features
- `bugfix/*` - Bug fixes

### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Example:
```
feat(motor-control): Add torque limiting function

Implement torque limiter to prevent motor damage
during aggressive acceleration scenarios.

Closes #15
```

## Contributing

1. Create a feature branch from `develop`
2. Make your changes
3. Test thoroughly
4. Submit a pull request
5. Wait for code review

## Testing

Run all test scenarios:
```matlab
% Run test suite (to be implemented)
run_all_tests;
```

## Documentation

- [Requirements Specification](docs/requirements.md)
- [Design Documentation](docs/design-specifications.md)
- [API Reference](docs/api-reference.md) (to be created)

## Performance Metrics

Key performance indicators tracked:
- Motor efficiency (%)
- Energy consumption (kWh/100km)
- ACC response time (ms)
- Speed control accuracy (%)
- System latency (ms)

## Troubleshooting

### Common Issues

**Issue**: "Toolbox not found" error
- **Solution**: Verify all required toolboxes are installed using `ver` command

**Issue**: Path errors when running scripts
- **Solution**: Run `setup_project.m` to reconfigure paths

**Issue**: Simulink model won't open
- **Solution**: Ensure you're using MATLAB R2023b or later

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- NUST-SEECS for project support and resources
- Faculty advisors for guidance and mentorship
- MathWorks documentation and examples

## Contact

For questions or collaboration opportunities, please contact:
- Project Lead: Rana Umar Nadeem - [GitHub](https://github.com/ranaumarnadeem)
- Institution: NUST-SEECS

---

**Last Updated**: November 2025
**Version**: 1.0.0