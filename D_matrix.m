function D = D_matrix(in1)
%D_matrix
%    D = D_matrix(IN1)

%    This function was generated by the Symbolic Math Toolbox version 23.2.
%    14-Dec-2023 11:22:45

theta = in1(:,3);
t2 = cos(theta);
t3 = t2.^2;
D = [0.0;0.0;(-3.57e-2)./(t3.*(8.1e+1./1.0e+1)-3.57e+2./1.0e+1);(t2.*(6.3e+1./1.0e+3))./(t3.*8.1e+1-3.57e+2)];
end
