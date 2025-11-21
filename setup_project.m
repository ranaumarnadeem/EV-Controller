%% EV Controller Project Setup Script
% This script configures the MATLAB environment for the EV Controller project
% Run this script after cloning the repository to set up all necessary paths
% and verify required toolboxes are installed.
%
% Author: EV Controller Team - NUST SEECS
% Date: November 2025

%% Clear workspace
clc;
clear;
close all;

fprintf('====================================================\n');
fprintf('  EV Controller Project - Environment Setup\n');
fprintf('====================================================\n\n');

%% Get project root directory
projectRoot = fileparts(mfilename('fullpath'));
cd(projectRoot);

fprintf('Project Root: %s\n\n', projectRoot);

%% Add project folders to MATLAB path
fprintf('Adding project folders to MATLAB path...\n');

% Define folders to add to path
folders = {
    'matlab/scripts/initialization';
    'matlab/scripts/analysis';
    'matlab/scripts/utilities';
    'matlab/functions/motor_control';
    'matlab/functions/acc_logic';
    'matlab/functions/vehicle_dynamics';
    'matlab/data/test_scenarios';
    'matlab/data/calibration';
    'matlab/data/results';
    'simulink/models';
    'simulink/models/subsystems';
    'simulink/models/libraries';
    'config/model_settings';
    'config/solver_configurations';
    'config/code_generation';
};

% Add each folder to path
for i = 1:length(folders)
    folderPath = fullfile(projectRoot, folders{i});
    if exist(folderPath, 'dir')
        addpath(folderPath);
        fprintf('  + Added: %s\n', folders{i});
    else
        warning('Folder not found: %s', folders{i});
    end
end

% Save path for future sessions (optional - commented out by default)
% savepath;

fprintf('\n');

%% Verify Required Toolboxes
fprintf('Checking required MATLAB toolboxes...\n');

requiredToolboxes = {
    'Simulink';
    'Simscape Electrical';
    'Control System Toolbox';
    'Automated Driving Toolbox';
    'Stateflow';
};

optionalToolboxes = {
    'MATLAB Coder';
    'Simulink Coder';
    'Simulink Coverage';
};

% Get installed toolboxes
installedToolboxes = ver;
installedNames = {installedToolboxes.Name};

% Check required toolboxes
allRequiredInstalled = true;
for i = 1:length(requiredToolboxes)
    if any(contains(installedNames, requiredToolboxes{i}))
        fprintf('  [OK] %s\n', requiredToolboxes{i});
    else
        fprintf('  [MISSING] %s - REQUIRED\n', requiredToolboxes{i});
        allRequiredInstalled = false;
    end
end

fprintf('\n');

% Check optional toolboxes
fprintf('Checking optional MATLAB toolboxes...\n');
for i = 1:length(optionalToolboxes)
    if any(contains(installedNames, optionalToolboxes{i}))
        fprintf('  [OK] %s\n', optionalToolboxes{i});
    else
        fprintf('  [NOT INSTALLED] %s - Optional\n', optionalToolboxes{i});
    end
end

fprintf('\n');

%% Verify Project Structure
fprintf('Verifying project directory structure...\n');

requiredDirs = {
    'docs';
    'matlab';
    'simulink';
    'results';
    'config';
};

structureOK = true;
for i = 1:length(requiredDirs)
    dirPath = fullfile(projectRoot, requiredDirs{i});
    if exist(dirPath, 'dir')
        fprintf('  [OK] %s/\n', requiredDirs{i});
    else
        fprintf('  [MISSING] %s/ - Creating...\n', requiredDirs{i});
        mkdir(dirPath);
        structureOK = false;
    end
end

fprintf('\n');

%% Initialize Workspace Variables (Optional)
fprintf('Initializing workspace variables...\n');

% Define global project variables
global EV_PROJECT_ROOT;
EV_PROJECT_ROOT = projectRoot;

% Set default figure properties for consistent plotting
set(0, 'DefaultFigureWindowStyle', 'docked');
set(0, 'DefaultLineLineWidth', 1.5);
set(0, 'DefaultAxesFontSize', 11);
set(0, 'DefaultAxesFontName', 'Arial');

fprintf('  + Workspace variables initialized\n');
fprintf('  + Figure defaults configured\n\n');

%% Display Setup Summary
fprintf('====================================================\n');
fprintf('  Setup Summary\n');
fprintf('====================================================\n');

if allRequiredInstalled
    fprintf('[SUCCESS] All required toolboxes are installed.\n');
else
    fprintf('[WARNING] Some required toolboxes are missing!\n');
    fprintf('          Please install missing toolboxes to use all features.\n');
end

if structureOK
    fprintf('[SUCCESS] Project directory structure verified.\n');
else
    fprintf('[INFO] Some directories were created.\n');
end

fprintf('\n');
fprintf('Project setup complete!\n\n');

%% Display Next Steps
fprintf('====================================================\n');
fprintf('  Next Steps\n');
fprintf('====================================================\n');
fprintf('1. Initialize parameters:\n');
fprintf('   >> run(''matlab/scripts/initialization/init_parameters.m'')\n\n');
fprintf('2. Open the main Simulink model:\n');
fprintf('   >> open_system(''simulink/models/ev_controller_main.slx'')\n\n');
fprintf('3. Open MATLAB project file:\n');
fprintf('   >> openProject(''project.prj'')\n\n');
fprintf('====================================================\n');

%% Check MATLAB Version
matlabVersion = version('-release');
fprintf('\nMATLAB Version: R%s\n', matlabVersion);

% Verify minimum version (R2023b = 23b)
minVersion = '2023b';
if str2double(matlabVersion(1:4)) < 2023
    warning('This project is designed for MATLAB R2023b or later. Some features may not work correctly.');
elseif strcmp(matlabVersion, '2023a')
    warning('This project is designed for MATLAB R2023b or later. You are using R2023a.');
else
    fprintf('MATLAB version check: OK\n');
end

fprintf('\n====================================================\n\n');
