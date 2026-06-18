% Problem 3 
clc; clear; close all;

load('synthetic_truss_293259.mat');

P1 = 10;      % Applied load at Node 2 [kN]  
P3 = 17;      % Applied load at Node 7 [kN]  
E  = 200e9;   % Young's Modulus [Pa]

% Nominal area for member 8 = 690 mm^2
AREAnominal = double(areas.A_diag_mm2) * 1e-6; % [m^2]


% Convert microstrain to absolute strain
epsilonmeasured = epsilon_measured_microstrain * 1e-6;

% Strain vs P2 
PREVIOUSstrain = polyfit(P2_kN, epsilonmeasured, 1);
coe_meas   = PREVIOUSstrain(1); % [strain / kN]
dist_meas   = PREVIOUSstrain(2); % intercept

% Model Force vs P2 
PREVforce  = polyfit(P2_kN, F_model_kN, 1);
Force_slope  = PREVforce(1); % (dimensionless ratio)

%  A = (dF/dP2) / (E * de/dP2)
% Units: (kN/kN) / (Pa * strain/kN) 
AREAcalibrated = (Force_slope * 1000) / (E * coe_meas); % [m^2]

% Theoretical strain using nominal area
epsilon_model = (F_model_kN * 1000) ./ (E * AREAnominal); % [strain]

% Calibration output
fprintf(' Calibration Results \n\n')
fprintf('  Fitted Strain Eq: e = %.4e * P2 + %.4e\n\n', coe_meas, dist_meas)
fprintf('  Nominal Area: %.4f mm^2\n',   AREAnominal    * 1e6)
fprintf('  Calibrated Area: %.4f mm^2\n\n', AREAcalibrated * 1e6)

% Calibration plot
figure('Name', 'Strain Calibration', 'Color', 'w');
hold on; grid on;
scatter(P2_kN, epsilon_measured_microstrain, 15, 'k', 'filled','MarkerFaceAlpha', 0.5, 'DisplayName', 'Measured Data (Noisy)');
P2_plot = linspace(min(P2_kN), max(P2_kN), 100);
fitted_micro = (coe_meas * P2_plot + dist_meas) * 1e6;
theoretical_micro = (polyval(PREVforce, P2_plot) * 1000) ./ (E * AREAnominal) * 1e6;
plot(P2_plot, fitted_micro,      'g-',  'LineWidth', 2, 'DisplayName', 'Regression Fit');
plot(P2_plot, theoretical_micro, 'b--', 'LineWidth', 2, 'DisplayName', 'Nominal Model');
xlabel('Applied Load P2 (kN)', 'FontWeight', 'bold');
ylabel('Strain (\mu\epsilon)',  'FontWeight', 'bold');
title(sprintf('Strain Calibration — Member %d', member_index), 'FontSize', 12);
legend('Location', 'northwest');
hold off;


allowable_stress = 120; % [MPa]
tol = 1e-5;  % Convergence tolerance [MPa]
max_iter = 50;

% Starting bracket: just above the data range
PreviousP = max(P2_kN); % k-1 point [kN]
CurrentP = max(P2_kN) + 1; % k point [kN]

fprintf(' Secant Method \n\n')
fprintf('  Fixed Loads:  P1 = %d kN,  P3 = %d kN\n',   P1, P3)
fprintf('  Allowable Stress = %.2f MPa\n\n', allowable_stress)
fprintf('%-10s | %-12s | %-14s | %-14s | %-12s\n','Iteration', 'P2 (kN)', 'F_member (kN)', 'Stress (MPa)', 'Error (MPa)')
fprintf('%s\n', repmat('-', 1, 68))

for iter = 1:max_iter

    % Evaluate stress at previous point
    PreviousF = truss_solver(P1, PreviousP, P3);
    stressprev = abs(PreviousF(member_index) * 1000) / AREAcalibrated / 1e6;

    % Evaluate stress at current pointesws 
    currentF = truss_solver(P1, CurrentP, P3);
    stress_curr = abs(currentF(member_index) * 1000) / AREAcalibrated / 1e6;

    % Residuals: f(P) = stress(P) - allowable
    Previousf = stressprev - allowable_stress;
    Currentf = stress_curr - allowable_stress;

    fprintf('%-10d | %-12.4f | %-14.4f | %-14.4f | %-12.4f\n',iter, CurrentP, currentF(member_index), stress_curr, Currentf)

    % Convergence check
    if abs(Currentf) < tol
        fprintf('\n  Converged in %d iterations.\n\n', iter)
        break
    end

    % Zero slope guard
    if (Currentf - Previousf) == 0
        error('Secant method failed: zero slope detected at iteration %d.', iter)
    end

    % Secant update
    Pnext = CurrentP - Currentf * (CurrentP - PreviousP) / (Currentf - Previousf);

    % Shift for next iteration
    PreviousP = CurrentP;
    CurrentP = Pnext;
end

% final results display
fprintf(' Final Summary \n\n')
fprintf('  Nominal Area: %.4f mm^2\n',   AREAnominal    * 1e6)
fprintf('  Calibrated Area: %.4f mm^2\n',   AREAcalibrated * 1e6)
fprintf('  Critical Safe Load P2* = %.4f kN\n\n', CurrentP)
fprintf('  Operational limit: P2 must not exceed %.2f kN to remain below %.0f MPa.\n\n',CurrentP, allowable_stress)