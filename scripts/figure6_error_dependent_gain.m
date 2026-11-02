% =========================================================================
% figure6_error_dependent_gain.m
% 
% Report Reference:
% Section 8: "Nonlinear gain scheduling" (Section 8.1, Figure 6)
% Error-dependent gain function K(|ve|):
%   K(|ve|) = Knear + (Kfar - Knear) * min(|ve| / V0, 1)
% Parameters:
%   Knear = 60, Kfar = 300, V0 = 0.318 V (initial error of a 1 V step)
% =========================================================================

clear; clc; close all;

% 1. Gain Scheduling Parameters (Section 8.1)
Knear = 60;                    % Gain near target (smooth arrival, low overshoot)
Kfar  = 300;                   % Gain far from target (fast rise / quick response)
V0    = 0.318;                 % Knee voltage (V) = initial error for 1 V step

% 2. Error Voltage Vector |ve|
ve = linspace(0, 0.6, 1000);
K_ve = Knear + (Kfar - Knear) * min(ve / V0, 1);

% 3. Create Figure Window
fig = figure('Color', 'w', 'Position', [150, 150, 720, 390]);
ax  = axes('Parent', fig);
hold(ax, 'on');

% 4. Plot Knee Vertical Dotted Line
plot(ax, [V0, V0], [48, 312], ':', 'Color', [0.45, 0.45, 0.45], ...
     'LineWidth', 1.4, 'HandleVisibility', 'off');

% Text annotation for the knee
text(ax, V0 + 0.01, 72, 'knee V_0 = 0.318 V', ...
     'FontName', 'CMU Serif', 'FontSize', 10, 'Color', [0.15, 0.15, 0.15], ...
     'VerticalAlignment', 'bottom');

% 5. Plot Error-Dependent Gain Curve
plot(ax, ve, K_ve, '-', 'LineWidth', 2.2, 'Color', [0.12, 0.47, 0.71]);

% 6. Title and Axis Labels
title(ax, 'Error-dependent gain: K_{near} = 60, K_{far} = 300', ...
      'FontName', 'CMU Serif', 'FontSize', 13, 'FontWeight', 'normal', 'Color', [0.1, 0.1, 0.1]);
xlabel(ax, '|v_e| (V)  (error-amplifier output)', ...
       'FontName', 'CMU Serif', 'FontSize', 11, 'Color', [0.1, 0.1, 0.1]);
ylabel(ax, 'K(|v_e|)', ...
       'FontName', 'CMU Serif', 'FontSize', 11, 'Color', [0.1, 0.1, 0.1]);

% 7. Axis Limits and Ticks
xlim(ax, [-0.02, 0.62]);
ylim(ax, [48, 312]);
xticks(ax, 0.0:0.1:0.6);
yticks(ax, 50:50:300);
xtickformat(ax, '%.1f');

% 8. Styling: Box off, outward ticks, soft grid, CMU Serif font
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

% 9. Save High-Resolution Figure to figures/ directory
scriptDir = fileparts(mfilename('fullpath'));
figDir    = fullfile(scriptDir, '..', 'figures');
if ~exist(figDir, 'dir'), mkdir(figDir); end
figPath = fullfile(figDir, 'figure6_error_dependent_gain.png');

try
    exportgraphics(fig, figPath, 'Resolution', 300, 'BackgroundColor', 'white');
catch
    pause(0.5);
    exportgraphics(fig, figPath, 'Resolution', 300, 'BackgroundColor', 'white');
end
fprintf('Figure 6 saved successfully to %s\n', figPath);
