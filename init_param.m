%% Parameters for simulation

clear;
clc

% Simulation Flags
GET_MATRIX = true;
PLOT_FILTER = true;

% Simulation time
sim_time = 20;          % [s]

% UKF and EKF sample time
dt_EKF = 0.001;         % [s]
dt_UKF = 0.001;         % [s]

% Sample time for simulink signals
out_rate = 0.001;       % [s]

%% Initial condition

% Ideal Initial condition
xc_0_i = 2;           % [m]
dxc_0_i = 0;          % [m/s]
theta_0_i = pi/6;     % [rad]
dtheta_0_i = 0;       % [rad/s]

% Std deviation initial conditions
std_dev_xc = 0.1;               % [m]
std_dev_theta = 0.1;            % [rad]
std_dev_dxc = 0.01;             % [m/s]
std_dev_dtheta = 0.001;         % [rad/s]

% Real initial condition
xc_0 = xc_0_i + std_dev_xc*randn(1,1) ;                % [m]
dxc_0 = dxc_0_i + std_dev_theta*randn(1,1);            % [m/s]
theta_0 = theta_0_i + std_dev_dxc*randn(1,1);          % [rad]
dtheta_0 = dtheta_0_i + std_dev_dtheta*randn(1,1);     % [rad/s]

%% Input parameters

input_amplitude = 5;    % [V]
input_frequency = 1;    % [Hz]

%% Input disturbe parameter

% Std deviation input disturbe
std_dev_d = 0.01;           % [V]

% Mean input disturbe
U_mean = 0;                 % [V]

% Sampling time for noise
Ts.u_noise = 0.01;

%% System dimension

% Rail length
dim.xmin = 0;               %[m]
dim.xmax = 10;              %[m]

% Kart dimension
dim.h = 1;                  %[m]
dim.b = 1.5;                %[m]

% Pendulum length
dim.L1 = 3;                 %[m]
dim.L2 = 3;                 %[m]
dim.Lp = 3;                 %[m]

% Standard deviation system dimension
std_dev_dim = 0.01;         %[m]

% Real System dimension
dim_real.L1 = dim.L1 + std_dev_dim*randn(1,1);                 %[m]
dim_real.L2 = dim.L2 + std_dev_dim*randn(1,1);                 %[m]
dim_real.Lp = dim.Lp + std_dev_dim*randn(1,1);                 %[m]

%% System inertial param

% Masses
Mp = 10;                %[kg]
Mc = 30;                %[kg]
M1 = 10;                 %[kg]
M2 = 10;                %[kg]

% Standard deviation inertial param
std_dev_m = 0.1;         %[kg]

% Real system inertial param
Mp_real = Mp + std_dev_m*randn(1,1);         %[kg]
Mc_real = Mc + std_dev_m*randn(1,1);         %[kg]
M1_real = M1 + std_dev_m*randn(1,1);         %[kg]
M2_real = M2 + std_dev_m*randn(1,1);         %[kg]

%% Other param
Kg = 4;         % [-] Planetary gearbox ratio
Km = 0.23;      % [Nm/A] DC motor constant
r = 0.1;        % [m] motor pinion radius   

% Ideal param for dynamic equations
param.M = Mp + Mc + M1 + M2;   
param.N = 4/3*(M2*dim.L2^2 + M1*dim.L1^2) + Mp*dim.Lp^2;
param.P = M2*dim.L2 + Mp*dim.Lp - M1*dim.L1;
param.W = Kg*Km/(2*r);
param.Rm = 0.1;                                 % [ohm] armature resistence
param.g = 9.81;                                 % [m/s^2]

% Real param for dynamic equations
param_real.M = Mp_real + Mc_real + M1_real + M2_real;   
param_real.N = 4/3*(M2_real*dim_real.L2^2 + M1_real*dim_real.L1^2) + Mp_real*dim_real.Lp^2;
param_real.P = M2_real*dim_real.L2 + Mp_real*dim_real.Lp - M1_real*dim_real.L1;
param_real.W = Kg*Km/(2*r);
param_real.Rm = param.Rm;                                 
param_real.g = param.g;                                 

%% Sensor's Params

% Sensors's standard deviations
std_dev.distance_sensor = 0.07;             % [m] Laser sensor
std_dev.a1_sensor = 0.09;                   % [rad] Deviazione standard sensore per misurazione angolo a1 (telecamera)
std_dev.angularspeed_sensor = 0.05*12.5;    % [rad/s] Hall effect sensor (max error * max speed)

% Sensor sampling times

Ts.distance_sensor = 0.03;          % [s]       33 Hz
Ts.a1_sensor = 0.04;                % [s]       
Ts.angularspeed_sensor = 1/100;     % [s]       Analog signal, max freq DAC Arduino 1.74 MHz

%% Evaluate matrix for EKF

if GET_MATRIX 
    Get_F_matrix
    Get_H_matrix
    Get_D_matrix
end

%% Parameters for Filtering

% Sensor Covariance
R =[std_dev.distance_sensor^2 0 0; 0 std_dev.a1_sensor^2 0; 0 0 std_dev.angularspeed_sensor^2];

% Input disturbe
Q = std_dev_d^2;

x_mean_0 = [xc_0_i; theta_0_i; dxc_0_i; dtheta_0_i];

P_0 = [std_dev_xc^2 0 0 0; 0 std_dev_theta^2 0 0; 0 0 std_dev_dxc^2 0; 0 0 0 std_dev_dtheta^2];

epsilon = 0.0001;

%% Mahalanobis treshold
m_treshold = 5;



