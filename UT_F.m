function [p_mean, propagated_cov] = UT_F(x_mean, sigma_x, dt, V, param)
%   UT_F Summary of this function goes here
%   Detailed explanation goes here

% Rename input variables
N = param.N;
M = param.M;
Rm = param.Rm;
g = param.g;
W = param.W;
P = param.P;

% Define parameters
alpha = 1;
% beta = 2;
k = 0;
n = size(x_mean,1);
lambda = alpha^2*(n + k);

% Compute weights
w0 = lambda/(lambda + n);
wc(1) = w0;
wc(2:2*n+1) = 1/(2*(n+lambda));

% Factorise covariance matrix
[U,S] = svd(sigma_x);
gamma = U*S^(1/2);

% Create sigma points
sigma_points = zeros(length(x_mean),2*n+1);
sigma_points(:,1) = x_mean;

for i = 1:size(gamma,2)
    sigma_points(:,i+1) = x_mean + sqrt(n+lambda)*gamma(:,i);
    sigma_points(:,n+i+1) = x_mean - sqrt(n+lambda)*gamma(:,i);
end

% Propagated sigma points eval.
prop_sigma_points = zeros(size(sigma_points));
for i = 1:size(gamma,2)

    % Rename sigma points componets
    xc = sigma_points(1,i);
    theta = sigma_points(2,i);
    dxc = sigma_points(3,i);
    dtheta = sigma_points(4,i);
    
    % F(sigma_points)
    prop_sigma_points(:,i) = sigma_points(1:4,i) + dt*...
        [sigma_points(2,i);...
        sigma_points(4,i);...
        (V*N*M - dxc*N*W^2 + cos(theta)*g*sin(theta)*Rm*P^2 + dtheta^2*sin(theta)*Rm*N*P)/(Rm*(N*M - cos(theta)^2*P^2));...
        -P/Rm*(g*sin(theta)*Rm*M + cos(theta)*dtheta^2*sin(theta)*Rm*P + cos(theta)*(V + U)*M - cos(theta)*dxc*W^2)/(N*M - cos(theta)^2*P^2)*dt + dtheta];
end

% Propagated mean
p_mean = prop_sigma_points*wc';

% Propagated cov
propagated_cov = zeros(size(sigma_x));
    for i = 1:size(sigma_points,2)
        propagated_cov = propagated_cov + wc(i)*(prop_sigma_points(:,i) - p_mean)*(prop_sigma_points(:,i) - p_mean)';
    end
end

