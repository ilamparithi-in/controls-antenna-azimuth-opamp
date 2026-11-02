% =========================================================================
% figure3_proportional_step_responses.m
% 
% Report Reference:
% Section 4.4: "Time-domain performance" (Figure 3 & Table 3)
% Unit-step response of the proportional loop for several values of K.
% Demonstrates that peak overshoot (%M_p) and oscillation frequency increase with K,
% while the 2% settling time envelope remains invariant at Ts ≈ 4.68 s.
% =========================================================================

clear; clc; close all;

% 1. Plant and Loop Parameters (from Section 2.1 - 2.3)
% K_pot = 0.318 V/rad, K_g = 0.1, K_m = 2.083
c = 0.318 * 0.1 * 2.083;      % Loop constant c ≈ 0.0662
s = tf('s');
Ts_theoretical = 4 / 0.855;    % Ts = 4 / (zeta * wn) = 4 / 0.855 ≈ 4.68 s

% Gains to plot (as in Figure 3)
plot_gains = [11.04, 25, 41.3, 100, 200];
colors = {
    [0.12, 0.47, 0.71], ...   % Blue   (K = 11.04, critical damping)
    [1.00, 0.50, 0.05], ...   % Orange (K = 25, well damped)
    [0.17, 0.63, 0.17], ...   % Green  (K = 41.3, 15% overshoot design)
    [0.84, 0.15, 0.16], ...   % Red    (K = 100, fast/oscillatory)
    [0.58, 0.40, 0.74]        % Purple (K = 200, severely underdamped)
};

% Simulation time vector
t = linspace(0, 10, 1500);

% 2. Create Figure Window
fig = figure('Color', 'w', 'Position', [150, 150, 780, 450]);
ax = axes('Parent', fig);
hold(ax, 'on');

% 3. Reference and Settling Tolerance Bounds
% Unity step final value (y = 1)
plot(ax, [0, 10], [1.0, 1.0], 'k-', 'LineWidth', 0.9, 'HandleVisibility', 'off');

% ±2% settling error band [0.98, 1.02]
yline(ax, 1.02, ':', 'Color', [0.65, 0.65, 0.65], 'LineWidth', 0.8, 'HandleVisibility', 'off');
yline(ax, 0.98, ':', 'Color', [0.65, 0.65, 0.65], 'LineWidth', 0.8, 'HandleVisibility', 'off');

% 4. Plot Step Responses for each K
for idx = 1:length(plot_gains)
    K = plot_gains(idx);
    
    % Closed-loop transfer function: T(s) = (c*K) / (s^2 + 1.71*s + c*K)
    T_cl = feedback((c * K) / (s * (s + 1.71)), 1);
    y = step(T_cl, t);
    
    plot(ax, t, y, 'LineWidth', 1.8, 'Color', colors{idx}, ...
         'DisplayName', sprintf('K = %g', K));
end

% 5. Mark Settling Time (Ts ≈ 4.68 s)
xline(ax, Ts_theoretical, '--', 'Color', [0.35, 0.35, 0.35], 'LineWidth', 1.2, ...
      'DisplayName', sprintf('T_s \\approx %.2f s (2%% band)', Ts_theoretical), ...
      'Interpreter', 'tex');

% Annotation text marking settling time
text(ax, Ts_theoretical + 0.15, 0.25, ...
     sprintf('T_s \\approx %.2f s\n(invariant for all K)', Ts_theoretical), ...
     'FontName', 'CMU Serif', 'FontSize', 10, 'Color', [0.25, 0.25, 0.25], ...
     'VerticalAlignment', 'bottom', 'Interpreter', 'tex');

% 6. Styling: box off, outward ticks, soft grid, CMU Serif font
title(ax, 'Proportional control: unit-step response for several K', ...
      'FontName', 'CMU Serif', 'FontSize', 13, 'FontWeight', 'normal', 'Color', [0.1, 0.1, 0.1]);
xlabel(ax, 'Time (s)', 'FontName', 'CMU Serif', 'FontSize', 11, 'Color', [0.1, 0.1, 0.1]);
ylabel(ax, 'Y / Vi',   'FontName', 'CMU Serif', 'FontSize', 11, 'Color', [0.1, 0.1, 0.1]);

xlim(ax, [0, 10]);
ylim(ax, [-0.07, 1.55]);
xticks(ax, 0:2:10);
yticks(ax, 0:0.2:1.4);
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
lgd = legend(ax, 'Location', 'northeast', 'FontName', 'CMU Serif', 'FontSize', 9.5);
set(lgd, 'EdgeColor', [0.85, 0.85, 0.85], 'Color', 'w', 'TextColor', [0.1, 0.1, 0.1]);

% 7. Save High-Resolution Figure
scriptDir = fileparts(mfilename('fullpath'));
figDir = fullfile(scriptDir, '..', 'figures');
if ~exist(figDir, 'dir'), mkdir(figDir); end
figPath = fullfile(figDir, 'figure3_proportional_step_responses.png');

try
    exportgraphics(fig, figPath, 'Resolution', 300, 'BackgroundColor', 'white');
catch
    pause(0.5);
    exportgraphics(fig, figPath, 'Resolution', 300, 'BackgroundColor', 'white');
end
fprintf('Figure 3 saved successfully to %s\n\n', figPath);

% =========================================================================
% 8. Generate and Display Table 3: Predicted vs Simulated Performance
% =========================================================================
table_gains = [11.04, 25, 41.3, 50, 100, 200];
N = length(table_gains);

K_col       = zeros(N, 1);
wn_col      = zeros(N, 1);
zeta_col    = zeros(N, 1);
mp_form_col = zeros(N, 1);
mp_sim_col  = zeros(N, 1);
tp_col      = cell(N, 1);
ts_col      = zeros(N, 1);
tr_col      = zeros(N, 1);

fprintf('==============================================================================================\n');
fprintf('Table 3: Proportional control: predicted performance for several gains\n');
fprintf('==============================================================================================\n');
fprintf('%-8s %-12s %-8s %-14s %-14s %-10s %-10s %-10s\n', ...
        'K', 'wn (rad/s)', 'zeta', '%M_p formula', '%M_p simulated', 'Tp (s)', 'Ts (s)', 'Tr (s)');
fprintf('----------------------------------------------------------------------------------------------\n');

for i = 1:N
    K_val = table_gains(i);
    wn = sqrt(c * K_val);
    zeta = 1.71 / (2 * wn);
    
    if zeta < 0.999
        mp_formula = 100 * exp(-zeta * pi / sqrt(1 - zeta^2));
        tp_formula = pi / (wn * sqrt(1 - zeta^2));
        tp_str = sprintf('%6.2f', tp_formula);
    else
        mp_formula = 0.0;
        tp_str = '   -  ';
    end
    
    ts_formula = 4 / (zeta * wn);  % 4 / 0.855 ≈ 4.68 s
    tr_formula = 1.8 / wn;         % Standard rise time approximation 1.8 / wn
    
    % Simulated closed loop
    T_sys = feedback((c * K_val) / (s * (s + 1.71)), 1);
    info  = stepinfo(T_sys, 'SettlingTimeThreshold', 0.02);
    
    K_col(i)       = K_val;
    wn_col(i)      = wn;
    zeta_col(i)    = zeta;
    mp_form_col(i) = mp_formula;
    mp_sim_col(i)  = info.Overshoot;
    tp_col{i}      = tp_str;
    ts_col(i)      = ts_formula;
    tr_col(i)      = tr_formula;
    
    fprintf('%-8.2f %-12.3f %-8.3f %-14.1f %-14.1f %-10s %-10.2f %-10.2f\n', ...
            K_val, wn, zeta, mp_formula, info.Overshoot, tp_str, ts_formula, tr_formula);
end
fprintf('==============================================================================================\n');

% Also create a MATLAB table object for programmatic access
results_table = table(K_col, wn_col, zeta_col, mp_form_col, mp_sim_col, tp_col, ts_col, tr_col, ...
    'VariableNames', {'K', 'omega_n', 'zeta', 'Mp_formula', 'Mp_simulated', 'Tp', 'Ts', 'Tr'});
