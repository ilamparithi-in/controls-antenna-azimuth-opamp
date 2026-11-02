% =========================================================================
% figure5_derivative_action_comparison.m
% 
% Report Reference:
% Section 7: "Limits of P control and the PD controller" (Sections 7.2 - 7.3)
% Figure 5: "Effect of derivative action (unit step)"
% Table 6: "Comparison of P, PD on the error and PD on the output (unit step)"
%
% Compares:
% 1. P-only (K = 41.3)
% 2. PD on the error (Kp = 173, Kd = 34.6) - contains closed-loop zero
% 3. PD on the output (Kp = 173, Kd = 10.99) - no zero, eliminates derivative kick
% =========================================================================

clear; clc; close all;

% 1. System Parameters (from Sections 2.1 - 2.3 and Section 7)
% K_pot = 0.318 V/rad, K_g = 0.1, K_m = 2.083
c  = 0.318 * 0.1 * 2.083;     % Loop constant c ≈ 0.0662
c2 = 0.1 * 2.083;             % Plant constant c2 = Kg * Km = 0.2083
am = 1.71;                    % Motor mechanical pole (rad/s)
s  = tf('s');

% 2. Closed-Loop Transfer Functions (Section 7.2 - 7.3)
% Case 1: Proportional-only (K = 41.3)
% T_p(s) = (c * K) / (s^2 + am*s + c*K)
K_p_val = 41.3;
T_p = feedback((c * K_p_val) / (s * (s + am)), 1);

% Case 2: PD acting on the error (Kp = 173, Kd = 34.6)
% T_pd_err(s) = c*(Kp + Kd*s) / [s^2 + (am + c*Kd)*s + c*Kp]
Kp_err = 173;  Kd_err = 34.6;
T_pd_err = (c * (Kp_err + Kd_err * s)) / (s^2 + (am + c * Kd_err) * s + c * Kp_err);

% Case 3: PD acting on the output (Kp = 173, Kd = 10.99)
% T_pd_out(s) = c*Kp / [s^2 + (am + c2*Kd)*s + c*Kp]
Kp_out = 173;  Kd_out = 10.99;
T_pd_out = (c * Kp_out) / (s^2 + (am + c2 * Kd_out) * s + c * Kp_out);

% 3. Simulation Time Vector
t = linspace(0, 6, 1200);
y_p      = step(T_p, t);
y_pd_err = step(T_pd_err, t);
y_pd_out = step(T_pd_out, t);

% Compute Numerical Performance Metrics
info_p   = stepinfo(T_p,      'SettlingTimeThreshold', 0.02);
info_err = stepinfo(T_pd_err, 'SettlingTimeThreshold', 0.02);
info_out = stepinfo(T_pd_out, 'SettlingTimeThreshold', 0.02);

% 4. Create Figure Window
fig = figure('Color', 'w', 'Position', [150, 150, 780, 450]);
ax  = axes('Parent', fig);
hold(ax, 'on');

% Unity Reference Line (y = 1.0)
plot(ax, [0, 6], [1.0, 1.0], 'k-', 'LineWidth', 0.9, 'HandleVisibility', 'off');

% Plot Step Responses
% Colors: Blue, Orange, Green matching the reference figure
c_blue   = [0.12, 0.47, 0.71];
c_orange = [1.00, 0.50, 0.05];
c_green  = [0.17, 0.63, 0.17];

plot(ax, t, y_p,      '-', 'LineWidth', 1.8, 'Color', c_blue, ...
     'DisplayName', sprintf('P only, K = 41.3 (%%M_p = %.1f%%)', info_p.Overshoot));
plot(ax, t, y_pd_err, '-', 'LineWidth', 1.8, 'Color', c_orange, ...
     'DisplayName', sprintf('PD on error, Kp=173, Kd=34.6 (%%M_p = %.1f%%)', info_err.Overshoot));
plot(ax, t, y_pd_out, '-', 'LineWidth', 1.8, 'Color', c_green, ...
     'DisplayName', sprintf('PD on output, Kp=173, Kd=10.99 (%%M_p = %.1f%%)', info_out.Overshoot));

% 5. Figure Styling: CMU Serif, box off, outward ticks, soft grid
title(ax, 'Effect of derivative action (unit step)', ...
      'FontName', 'CMU Serif', 'FontSize', 13, 'FontWeight', 'normal', 'Color', [0.1, 0.1, 0.1]);
xlabel(ax, 'Time (s)', 'FontName', 'CMU Serif', 'FontSize', 11, 'Color', [0.1, 0.1, 0.1]);
ylabel(ax, 'Y / Vi',   'FontName', 'CMU Serif', 'FontSize', 11, 'Color', [0.1, 0.1, 0.1]);

xlim(ax, [0, 6]);
ylim(ax, [-0.055, 1.21]);
xticks(ax, 0:1:6);
yticks(ax, 0:0.2:1.2);
ytickformat(ax, '%.1f');

box(ax, 'off');
grid(ax, 'on');
set(ax, 'Color', 'w', ...
        'TickDir', 'out', ...
        'FontName', 'CMU Serif', ...
        'FontSize', 11, ...
        'XColor', [0.2, 0.2, 0.2], ...
        'YColor', [0.2, 0.2, 0.2], ...
        'GridColor', [0.88, 0.88, 0.88], ...
        'GridAlpha', 0.8, ...
        'LineWidth', 1.0);

% Legend
lgd = legend(ax, 'Location', 'southeast', 'FontName', 'CMU Serif', 'FontSize', 9.5);
set(lgd, 'EdgeColor', [0.85, 0.85, 0.85], 'Color', 'w', 'TextColor', [0.1, 0.1, 0.1]);

% 6. Save High-Resolution Figure to figures/ directory
scriptDir = fileparts(mfilename('fullpath'));
figDir    = fullfile(scriptDir, '..', 'figures');
if ~exist(figDir, 'dir'), mkdir(figDir); end
figPath = fullfile(figDir, 'figure5_derivative_action.png');

try
    exportgraphics(fig, figPath, 'Resolution', 300, 'BackgroundColor', 'white');
catch
    pause(0.5);
    exportgraphics(fig, figPath, 'Resolution', 300, 'BackgroundColor', 'white');
end
fprintf('Figure saved successfully to %s\n\n', figPath);

% =========================================================================
% 7. Table 6: Comparison of P, PD on Error and PD on Output (Unit Step)
% =========================================================================
controllers = {'P only'; 'PD on the error'; 'PD on the output'};
gains_str   = {'K = 41.3'; 'Kp = 173, Kd = 34.6'; 'Kp = 173, Kd = 10.99'};
mp_vals     = [info_p.Overshoot; info_err.Overshoot; info_out.Overshoot];
ts_vals     = [info_p.SettlingTime; info_err.SettlingTime; info_out.SettlingTime];
tp_vals     = [info_p.PeakTime; info_err.PeakTime; info_out.PeakTime];

fprintf('===============================================================================================\n');
fprintf('Table 6: Comparison of P, PD on the error and PD on the output (unit step)\n');
fprintf('===============================================================================================\n');
fprintf('%-22s %-26s %-16s %-20s %-12s\n', ...
        'Controller', 'Gains', '%M_p (Overshoot)', 'Settling time (2 %)', 'Peak time (Tp)');
fprintf('-----------------------------------------------------------------------------------------------\n');
for i = 1:3
    fprintf('%-22s %-26s %5.1f %% %14.2f s %14.2f s\n', ...
            controllers{i}, gains_str{i}, mp_vals(i), ts_vals(i), tp_vals(i));
end
fprintf('===============================================================================================\n');

% MATLAB Table Object for Programmatic Use
table6 = table(controllers, gains_str, mp_vals, ts_vals, tp_vals, ...
    'VariableNames', {'Controller', 'Gains', 'Mp_percent', 'Ts_seconds', 'Tp_seconds'});
