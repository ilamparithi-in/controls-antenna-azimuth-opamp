% =========================================================================
% table7_controller_comparison.m
% 
% Report Reference:
% Section 8: "Nonlinear gain scheduling" (Section 8.2 - 8.3, Table 7)
% "Fixed and scheduled controllers, 1 V step (numerical simulation)"
%
% Compares 6 controller configurations on the antenna azimuth servo:
% 1. Fixed K = 41.3 (P only, nominal 15% overshoot design)
% 2. Fixed K = 150  (P only, fast but underdamped)
% 3. Scheduled P only (K from 11 to 150, no derivative damping)
% 4. Fixed PD on output (Kp = 173, Kd = 10.99)
% 5. Scheduled PD (Kp from 100 to 300, Kd = 14)
% 6. Scheduled PD (Kp from 60 to 300, Kd = 15, final design)
% =========================================================================

clear; clc; close all;

% 1. Plant and Circuit Parameters (Section 2.1 - 2.3)
am   = 1.71;                   % Motor pole (rad/s)
kpot = 0.318;                  % Potentiometer gain (V/rad)
c2   = 0.2083;                 % Plant constant Kg * Km
c    = kpot * c2;              % Loop constant c ≈ 0.0662
Vi   = 1.0;                    % 1 V step command amplitude
V0   = 0.318;                  % Knee voltage (V) = initial error for 1 V step

% 2. Simulation Setup (High Precision ODE45 Solver)
opts  = odeset('RelTol', 1e-8, 'AbsTol', 1e-10, 'MaxStep', 0.005);
tspan = [0, 6.0];

% Case 1: Fixed K = 41.3 (P only)
f1 = @(t,x) [x(2); -am*x(2) + c2*(41.3 * kpot*(Vi - x(1)))];
[t1, x1] = ode45(f1, tspan, [0; 0], opts);

% Case 2: Fixed K = 150 (P only)
f2 = @(t,x) [x(2); -am*x(2) + c2*(150 * kpot*(Vi - x(1)))];
[t2, x2] = ode45(f2, tspan, [0; 0], opts);

% Case 3: Scheduled P only (K from 11 to 150, Kd = 0)
Kfun3 = @(ve) 11 + (150 - 11) * min(abs(ve)/V0, 1);
f3 = @(t,x) [x(2); -am*x(2) + c2*(Kfun3(kpot*(Vi - x(1))) * kpot*(Vi - x(1)))];
[t3, x3] = ode45(f3, tspan, [0; 0], opts);

% Case 4: Fixed PD on output (Kp = 173, Kd = 10.99)
f4 = @(t,x) [x(2); -am*x(2) + c2*(173 * kpot*(Vi - x(1)) - 10.99*x(2))];
[t4, x4] = ode45(f4, tspan, [0; 0], opts);

% Case 5: Scheduled PD (Kp 100 to 300, Kd = 14)
Kfun5 = @(ve) 100 + (300 - 100) * min(abs(ve)/V0, 1);
f5 = @(t,x) [x(2); -am*x(2) + c2*(Kfun5(kpot*(Vi - x(1))) * kpot*(Vi - x(1)) - 14*x(2))];
[t5, x5] = ode45(f5, tspan, [0; 0], opts);

% Case 6: Scheduled PD (Kp 60 to 300, Kd = 15, chosen design)
Kfun6 = @(ve) 60 + (300 - 60) * min(abs(ve)/V0, 1);
f6 = @(t,x) [x(2); -am*x(2) + c2*(Kfun6(kpot*(Vi - x(1))) * kpot*(Vi - x(1)) - 15*x(2))];
[t6, x6] = ode45(f6, tspan, [0; 0], opts);

time_series = {t1, t2, t3, t4, t5, t6};
resp_series = {x1(:,1), x2(:,1), x3(:,1), x4(:,1), x5(:,1), x6(:,1)};

controllers = { ...
    'Fixed K = 41.3'; ...
    'Fixed K = 150'; ...
    'Scheduled P only, K 11 to 150'; ...
    'Fixed PD, Kp = 173, Kd = 10.99'; ...
    'Scheduled PD, Kp 100 to 300, Kd = 14'; ...
    'Scheduled PD, Kp 60 to 300, Kd = 15' ...
};

% 3. Calculate Performance Metrics
N = length(controllers);
mp_vals  = zeros(N, 1);
ts_vals  = zeros(N, 1);
t90_vals = zeros(N, 1);

for i = 1:N
    ti = time_series{i};
    yi = resp_series{i};
    
    % Peak Overshoot (%M_p)
    mp_vals(i) = max((max(yi) - Vi) / Vi * 100, 0);
    
    % 2% Settling Time (Ts)
    idx_settle = find(abs(yi - Vi) > 0.02 * Vi, 1, 'last');
    if isempty(idx_settle)
        ts_vals(i) = 0;
    else
        ts_vals(i) = ti(idx_settle);
    end
    
    % Time to 90% (Rise time milestone)
    idx_90 = find(yi >= 0.90 * Vi, 1, 'first');
    t90_vals(i) = ti(idx_90);
end

% 4. Display Table 7 in Command Window
fprintf('========================================================================================\n');
fprintf('Table 7: Fixed and scheduled controllers, 1 V step (numerical simulation)\n');
fprintf('========================================================================================\n');
fprintf('%-38s %-16s %-18s %-14s\n', ...
        'Controller', '%M_p (Overshoot)', 'Settling (2 %)', 'Time to 90 %');
fprintf('----------------------------------------------------------------------------------------\n');
for i = 1:N
    fprintf('%-38s %6.1f %% %14.2f s %12.2f s\n', ...
            controllers{i}, mp_vals(i), ts_vals(i), t90_vals(i));
end
fprintf('========================================================================================\n');

% MATLAB Table Object for Programmatic Use
table7 = table(controllers, mp_vals, ts_vals, t90_vals, ...
    'VariableNames', {'Controller', 'Mp_percent', 'Ts_seconds', 'T90_seconds'});

% 5. Create Step Response Comparison Figure
fig = figure('Color', 'w', 'Position', [150, 150, 840, 480]);
ax  = axes('Parent', fig);
hold(ax, 'on');

% Unity Reference Line
plot(ax, [0, 6], [1.0, 1.0], 'k-', 'LineWidth', 0.9, 'HandleVisibility', 'off');

% Color Palette and Line Styles
styles = {
    [0.12, 0.47, 0.71], '--'; ...   % Blue dashed (P only, K = 41.3)
    [0.84, 0.15, 0.16], '--'; ...   % Red dashed (P only, K = 150)
    [0.58, 0.40, 0.74], '-.'; ...   % Purple dash-dot (Scheduled P only)
    [0.17, 0.63, 0.17], '-';  ...   % Green solid (Fixed PD)
    [1.00, 0.50, 0.05], '-';  ...   % Orange solid (Scheduled PD, Kd=14)
    [0.00, 0.00, 0.00], '-'   ...   % Black solid (Scheduled PD, Kd=15, final design)
};

for i = 1:N
    plot(ax, time_series{i}, resp_series{i}, ...
         'LineStyle', styles{i, 2}, ...
         'LineWidth', 1.8, ...
         'Color', styles{i, 1}, ...
         'DisplayName', sprintf('%s (%%M_p = %.1f%%)', controllers{i}, mp_vals(i)));
end

% 6. Styling: CMU Serif, box off, outward ticks, soft grid
title(ax, 'Comparison of Fixed and Scheduled Controllers (1 V Step Response)', ...
      'FontName', 'CMU Serif', 'FontSize', 12.5, 'FontWeight', 'normal', 'Color', [0.1, 0.1, 0.1]);
xlabel(ax, 'Time (s)', 'FontName', 'CMU Serif', 'FontSize', 11, 'Color', [0.1, 0.1, 0.1]);
ylabel(ax, 'Y / Vi',   'FontName', 'CMU Serif', 'FontSize', 11, 'Color', [0.1, 0.1, 0.1]);

xlim(ax, [0, 6]);
ylim(ax, [0, 1.5]);
xticks(ax, 0:1:6);
yticks(ax, 0:0.2:1.4);
ytickformat(ax, '%.1f');

box(ax, 'off');
grid(ax, 'on');
set(ax, 'Color', 'w', ...
        'TickDir', 'out', ...
        'FontName', 'CMU Serif', ...
        'FontSize', 10.5, ...
        'XColor', [0.2, 0.2, 0.2], ...
        'YColor', [0.2, 0.2, 0.2], ...
        'GridColor', [0.88, 0.88, 0.88], ...
        'GridAlpha', 0.8, ...
        'LineWidth', 1.0);

% Legend
lgd = legend(ax, 'Location', 'northeast', 'FontName', 'CMU Serif', 'FontSize', 9);
set(lgd, 'EdgeColor', [0.85, 0.85, 0.85], 'Color', 'w', 'TextColor', [0.1, 0.1, 0.1]);

% 7. Save High-Resolution Figure to figures/ directory
scriptDir = fileparts(mfilename('fullpath'));
figDir    = fullfile(scriptDir, '..', 'figures');
if ~exist(figDir, 'dir'), mkdir(figDir); end
figPath = fullfile(figDir, 'table7_controller_comparison.png');

try
    exportgraphics(fig, figPath, 'Resolution', 300, 'BackgroundColor', 'white');
catch
    pause(0.5);
    exportgraphics(fig, figPath, 'Resolution', 300, 'BackgroundColor', 'white');
end
fprintf('Figure saved successfully to %s\n', figPath);
