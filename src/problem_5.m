% Problem 5
clc; clear; close all;

d = [2, 9, 3, 2, 5, 9]; % d1 d2 d3 d4 d5 d6

m_val = 1200 * (1 + 0.02 * (d(4) - 5));    % Mass [kg]
k_val = 4e6  * (1 + 0.02 * (d(5) - 5));    % Stiffness [N/m]
z_val = 0.05 + 0.05 * (d(6) - 5);         % Damping ratio (coeff: 0.05)

if z_val <= 0
    z_val = 0.05;
    warning('Damping formula gave zeta <= 0; clamped to 0.05');
end

P0 = 10000; % Forcing amplitude [N]
f_default = 6; % Default forcing frequency [Hz]


omega_n = sqrt(k_val / m_val);
f_n     = omega_n / (2 * pi);
c_val   = 2 * z_val * sqrt(k_val * m_val);
r       = (2 * pi * f_default) / omega_n;

y_static = P0 / k_val;
DMF      = 1 / sqrt((1 - r^2)^2 + (2*z_val*r)^2);
y_ss     = y_static * DMF;

fprintf(' Fixed Parameters \n\n')
fprintf('  Mass                  (m)    = %.2f kg\n',    m_val)
fprintf('  Stiffness             (k)    = %.3e N/m\n',   k_val)
fprintf('  Damping ratio         (z)    = %.4f\n',       z_val)
fprintf('  Damping coefficient   (c)    = %.2f N*s/m\n', c_val)
fprintf('  Natural frequency     (fn)   = %.3f Hz\n',    f_n)
fprintf('  Forcing frequency     (f)    = %.1f Hz\n',    f_default)
fprintf('  Frequency ratio       (r)    = %.4f\n\n',     r)

fprintf(' Analytical Results \n\n', f_default) %#ok<CTPCT>
fprintf('  Static Deflection             = %.5f mm\n',   y_static * 1e3)
fprintf('  Dynamic Magnification Factor  = %.4f\n',      DMF)
fprintf('  Steady-State Amplitude        = %.5f mm\n\n', y_ss * 1e3)

% Solve once (tight tolerances) for printed table
omega_f  = 2 * pi * f_default;
EOM_base = @(t, x) [x(2); (P0*sin(omega_f*t) - c_val*x(2) - k_val*x(1)) / m_val];
opts = odeset('RelTol', 1e-8, 'AbsTol', 1e-10);
[t_base, sol_base] = ode45(EOM_base, [0 5], [0; 0], opts);

y_b = sol_base(:, 1);
ydot_b = sol_base(:, 2);

[y_max, i_max] = max(y_b);
peak_disp = max(abs(y_max), abs(min(y_b)));

fprintf('  Peak Displacement             = %.5f mm\n',  peak_disp * 1e3)
fprintf('  Time of Peak                  = %.4f s\n\n', t_base(i_max))

fprintf('%-10s %-22s %-18s\n', 'Time (s)', 'Displacement (mm)', 'Velocity (mm/s)')
fprintf('%s\n', repmat('-', 1, 52))
for ts = 0:0.5:5
    [~, idx] = min(abs(t_base - ts));
    fprintf('%-10.1f %-22.6f %-18.6f\n', t_base(idx), y_b(idx)*1e3, ydot_b(idx)*1e3)
end
fprintf('%s\n\n', repmat('-', 1, 52))


fig = uifigure('Name', 'Kinematics', 'Color', 'white', 'Position', [100 50 920 820]);
label_title = uilabel(fig, 'Position', [0 788 920 28], 'Text', 'Dynamic Kinematic Analysis','FontSize', 15, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

% Displacement
ax1 = uiaxes(fig, 'Position', [55 580 810 195]);
grid(ax1, 'on');
title(ax1, 'Displacement  y(t)');
ylabel(ax1, 'y  (mm)'); xlabel(ax1, 'Time (s)');

% Velocity 1st derivative of displacement
ax2 = uiaxes(fig, 'Position', [55 360 810 195]);
grid(ax2, 'on');
title(ax2, 'Velocity  dy/dt  ');
ylabel(ax2, 'dy/dt  (m/s)'); xlabel(ax2, 'Time (s)');

% Acceleration 2nd derivative of displacment
ax3 = uiaxes(fig, 'Position', [55 140 810 195]);
grid(ax3, 'on');
title(ax3, 'Acceleration  d2y/dt2  ');
ylabel(ax3, 'd2y/dt2  (m/s^2)'); xlabel(ax3, 'Time (s)');

% Sliders
uilabel(fig, 'Position', [55  115 150 22], 'Text', 'Damping Ratio:');
slider_z = uislider(fig, 'Position', [55 90 200 3], 'Limits', [0.01 0.30], 'Value', z_val);

uilabel(fig, 'Position', [360 115 160 22], 'Text', 'Stiffness (N/m):');
slider_k = uislider(fig, 'Position', [360 90 200 3], 'Limits', [1e6 8e6],   'Value', k_val);

uilabel(fig, 'Position', [665 115 180 22], 'Text', 'Force Frequency (Hz):');
slider_f = uislider(fig, 'Position', [665 90 200 3], 'Limits', [1 20],       'Value', f_default);

% Live callbacks
slider_z.ValueChangingFcn = @(~, ev) updateDashboard(label_title, ax1, ax2, ax3,ev.Value, slider_k.Value, slider_f.Value, m_val, P0);
slider_k.ValueChangingFcn = @(~, ev) updateDashboard(label_title, ax1, ax2, ax3,slider_z.Value, ev.Value, slider_f.Value, m_val, P0);
slider_f.ValueChangingFcn = @(~, ev) updateDashboard(label_title, ax1, ax2, ax3,slider_z.Value, slider_k.Value, ev.Value, m_val, P0);

% Initial render
updateDashboard(label_title, ax1, ax2, ax3, z_val, k_val, f_default, m_val, P0);


function updateDashboard(lbl, ax1, ax2, ax3, z_curr, k_curr, f_curr, m, P0)

    omega_f = 2 * pi * f_curr;
    c_curr  = 2 * z_curr * sqrt(k_curr * m);
    fn = sqrt(k_curr / m) / (2 * pi);

    % Steady-state amplitude for envelope lines on displacement plot
    r_curr = omega_f / (2 * pi * fn);
    DMF_curr = 1 / sqrt((1 - r_curr^2)^2 + (2*z_curr*r_curr)^2);
  

    % Solve EOM with tight tolerances
    EOM  = @(t, x) [x(2); (P0*sin(omega_f*t) - c_curr*x(2) - k_curr*x(1)) / m];
    opts = odeset('RelTol', 1e-8, 'AbsTol', 1e-10);
    [t_vec, sol] = ode45(EOM, [0 5], [0; 0], opts);

    disp_m = sol(:, 1);
    velocity_ms = sol(:, 2);
    % Acceleration from EOM - exact, avoids numerical differentiation error
    acceleration_ms2 = (P0*sin(omega_f*t_vec) - c_curr*velocity_ms - k_curr*disp_m) / m;
    disp_mm = disp_m * 1e3;

    % Plot 1: Displacement + steady-state envelope
   plot(ax1, t_vec, disp_mm, 'b', 'LineWidth', 1.2);
hold(ax1, 'on');
[pk_val, pk_idx] = max(abs(disp_mm));
plot(ax1, t_vec(pk_idx), disp_mm(pk_idx), 'rv','MarkerSize', 10, 'MarkerFaceColor', 'r');
text(ax1, t_vec(pk_idx)+0.1, disp_mm(pk_idx), sprintf('Peak = %.2f mm', pk_val), 'Color', 'r', 'FontSize', 8);
hold(ax1, 'off');
ylim(ax1, 'auto');

   % Plot 2: Velocity
    plot(ax2, t_vec, velocity_ms, 'Color', [0.1 0.6 0.1], 'LineWidth', 1.2);
hold(ax2, 'on'); 
[pk_val_v, pk_idx_v] = max(abs(velocity_ms)); 
plot(ax2, t_vec(pk_idx_v), velocity_ms(pk_idx_v), 'rv', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
text(ax2, t_vec(pk_idx_v)+0.1, velocity_ms(pk_idx_v), sprintf('Peak = %.2f m/s', pk_val_v), 'Color', 'r', 'FontSize', 8);
hold(ax2, 'off');
ylim(ax2, 'auto');

    % Plot 3: Acceleration
    plot(ax3, t_vec, acceleration_ms2, 'r', 'LineWidth', 1.2);
hold(ax3, 'on'); % Keep the line plotted while adding the marker
[pk_val_a, pk_idx_a] = max(abs(acceleration_ms2)); % Find acceleration peak
plot(ax3, t_vec(pk_idx_a), acceleration_ms2(pk_idx_a), 'rv', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
text(ax3, t_vec(pk_idx_a)+0.1, acceleration_ms2(pk_idx_a), sprintf('Peak = %.2f m/s^2', pk_val_a), 'Color', 'r', 'FontSize', 8);
hold(ax3, 'off');
ylim(ax3, 'auto');

    % Header bar
    peak_d = max(abs(disp_mm));
    peak_a = max(abs(acceleration_ms2));
    lbl.Text = sprintf('Peak Disp: %.2f mm  |  Peak Accel: %.2f m/s2  |  z = %.3f  |  f = %.1f Hz  (fn = %.1f Hz)  |  DMF = %.3f', peak_d, peak_a, z_curr, f_curr, fn, DMF_curr);

    if abs(f_curr - fn) / fn < 0.1
    lbl.FontColor = [0.85 0 0];
else
    lbl.FontColor = [0 0 0];
    end
    
end