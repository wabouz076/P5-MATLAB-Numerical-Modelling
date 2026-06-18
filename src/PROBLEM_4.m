% Problem 4
clc; clear; close all;

% Setup Parameters
P1 = 10; P2 = 13; P3 = 17;
E = 200e6; % Young's Modulus [kN/m^2]
n = 50; % Discretization points per member

% Cross sectional areas per member type (m^2)
A_bot  = 870e-6; % Bottom chord members (M1, M2, M3)
A_top  = 750e-6; % Top chord members (M4, M5)
A_diag = 690e-6; % Diagonal members (M6-M11)

% Area vector
Areavec = [A_bot; A_bot; A_bot; A_top; A_top; A_diag; A_diag; A_diag; A_diag; A_diag; A_diag];

% Node Coordinates (m)
nodesxy = [0,0; 3,0; 6,0; 9,0; 1.5,3; 4.5,3; 7.5,3];

% nodes each member connects
members = [1,2; 2,3; 3,4; 5,6; 6,7; 1,5; 2,5; 2,6; 3,6; 3,7; 4,7];

% Calculate Member Lengths 
L = zeros(11,1);
for i = 1:11
    p1 = nodesxy(members(i,1), :);
    p2 = nodesxy(members(i,2), :);
    L(i) = sqrt(sum((p1 - p2).^2));
end
% Solve for Forces using your external function
results = truss_solver(P1, P2, P3);
F = results(4:14); % Extract member forces F1 to F11

% Strain Energy Calculation (Analytical vs Numerical)
U_exacttotal = 0;
U_numericaltotal = 0;
fprintf('--- Member Energy Analysis ---\n');
fprintf('Mem | Exact (kJ) | Numerical (kJ) | Error (%%)\n');

for i = 1:11
% Analytical Calculation
    U_exact = (F(i)^2 * L(i)) / (2 * E * Areavec(i));
% Numerical Integration
    dx = L(i) / (n - 1);
% The integrand g(x) = F^2 / (2EA)
    gx = ((F(i)^2) / (2 * E * Areavec(i))) * ones(1, n);
% Trapezoidal Rule calculation
    sum_interior = sum(gx(2:end-1));
    U_num = (dx / 2) * (gx(1) + 2 * sum_interior + gx(end));

% Error Check
    err = abs(U_exact - U_num) / U_exact * 100;
if isnan(err), err = 0; end
    fprintf('%2d  | %10.6f | %14.6f | %9.2e\n', i, U_exact, U_num, err);
    U_exacttotal = U_exacttotal + U_exact;
    U_numericaltotal = U_numericaltotal + U_num;
end

% Central Difference to find displacement
dP = 0.1; % using Recommended step size

% Energy at (P2 + dP)
res_plus = truss_solver(P1, P2 + dP, P3);
F_plus = res_plus(4:14);
U_positive = sum((F_plus.^2 .* L) ./ (2 * E * Areavec));

% Energy at (P2 - dP)
res_minus = truss_solver(P1, P2 - dP, P3);
F_Negative = res_minus(4:14);
U_negative = sum((F_Negative.^2 .* L) ./ (2 * E * Areavec));

% Central Difference Derivative
delta_N6 = (U_positive- U_negative) / (2 * dP);

% Equivalent Stiffness calculation
k_eq = (2 * U_exacttotal) / (delta_N6^2);


% final output and results
fprintf('\n--- Final Results ---\n');
fprintf('Total Exact Energy:     %.6f kJ\n', U_exacttotal);
fprintf('Total Numerical Energy: %.6f kJ\n', U_numericaltotal);
fprintf('Deflection at Node N6:  %.4f mm\n', delta_N6 * 1000); % mm conversion
fprintf('Equivalent Stiffness:   %.2f kN/m\n', k_eq);
