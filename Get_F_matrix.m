%% Evaluate the F matrix for EKF

clc

N = param.N;
M = param.M;
Rm = param.Rm;
g = param.g;
W = param.W;
P = param.P;


syms xc dxc theta dtheta V U;
q = [xc, dxc, theta, dtheta];

% First row
a = jacobian(dxc*dt_EKF + xc, q);

% Second row
b = jacobian(dtheta*dt_EKF + theta, q);

% Third row
c = jacobian(((V + U)*N*W - dxc*N*W^2 + cos(theta)*g*sin(theta)*Rm*P^2 + dtheta^2*sin(theta)*Rm*N*P)/(Rm*(N*M - cos(theta)^2*P^2))*dt_EKF + dxc,q);

% Forth row
d = jacobian(-P/Rm*(g*sin(theta)*Rm*M + cos(theta)*dtheta^2*sin(theta)*Rm*P + cos(theta)*(V + U)*W - cos(theta)*dxc*W^2)/(N*M - cos(theta)^2*P^2)*dt_EKF + dtheta, q);

F = [a; b; c; d];

matlabFunction(F,'file','F_matrix', 'Vars', {q,V,U});
    