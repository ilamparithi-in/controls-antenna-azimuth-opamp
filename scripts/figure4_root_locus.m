% =========================================================================
% figure4_root_locus.m
% 
% Report Reference:
% Section 4.7: "Root locus" (Figure 4)
% Root locus of the closed-loop system as controller gain K increases.
% Shows open-loop poles at s = 0 and s = -1.71, breakaway at K = 11.04 
% (s = -0.855), and vertical branch along Re(s) = -0.855 for K > 11.04.
% =========================================================================

clear; clc; close all;

% 1. Plant and Loop Parameters (from Section 2.1 - 2.3)
% K_pot = 0.318, K_g = 0.1, K_m = 2.083
c = 0.318 * 0.1 * 2.083;      % Loop constant c ≈ 0.0662
p1 = 0;                        % Open-loop pole 1
p2 = -1.71;                    % Open-loop pole 2
sigma_b = (p1 + p2) / 2;       % Centroid / Breakaway real coordinate = -0.855
K_breakaway = 11.04;           % Breakaway gain (zeta = 1)

% 2. Create Figure Window
fig = figure('Color', 'w', 'Position', [150, 150, 780, 470]);
ax = axes('Parent', fig);
hold(ax, 'on');

% 3. Plot Asymptote (vertical dotted line across full y-range)
plot(ax, [sigma_b, sigma_b], [-6.2, 6.2], ':', 'Color', [0.55, 0.55, 0.55], ...
     'LineWidth', 1.0, 'HandleVisibility', 'off');

% 4. Root Locus Branches
% Real axis branch: between the two open-loop poles [p2, p1]
plot(ax, [p2, p1], [0, 0], 'b-', 'LineWidth', 2.2, 'HandleVisibility', 'off');

% Vertical branch for K >= 11.04 up to K = 500
K_vec = linspace(11.04, 500, 1000);
omega_d = sqrt(c * K_vec - (p2/2)^2);

% Upper and lower vertical branches along Re(s) = -0.855
plot(ax, sigma_b * ones(size(omega_d)),  omega_d, 'b-', 'LineWidth', 2.2, 'HandleVisibility', 'off');
plot(ax, sigma_b * ones(size(omega_d)), -omega_d, 'b-', 'LineWidth', 2.2, 'HandleVisibility', 'off');

% 5. Key Operating Points / Specific Gains K
specific_gains = [25, 41.3, 100, 200];
labels         = {'K=25', 'K=41.3', 'K=100', 'K=200'};

for i = 1:length(specific_gains)
    K_val = specific_gains(i);
    wd = sqrt(c * K_val - (p2/2)^2);
    
    % Plot upper and lower closed-loop pole locations (black dots)
    plot(ax, sigma_b,  wd, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 4.5, 'HandleVisibility', 'off');
    plot(ax, sigma_b, -wd, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 4.5, 'HandleVisibility', 'off');
    
    % Gain text annotation (placed slightly to the right of upper poles)
    text(ax, sigma_b + 0.06, wd + 0.18, labels{i}, ...
         'FontName', 'CMU Serif', 'FontSize', 9.5, 'Color', [0.1, 0.1, 0.1], ...
         'VerticalAlignment', 'middle');
end

% 6. Special Points with Legend Entries
% Open-loop poles (K = 0) at s = 0 and s = -1.71
h_ol = plot(ax, [p2, p1], [0, 0], 'rx', 'MarkerSize', 11, 'LineWidth', 2.4, ...
            'DisplayName', 'open-loop poles (K = 0)', 'Clipping', 'off');

% Breakaway point (K = 11.04) at s = -0.855
h_br = plot(ax, sigma_b, 0, 's', 'MarkerSize', 8, ...
            'MarkerFaceColor', [0.0, 0.55, 0.0], 'MarkerEdgeColor', [0.0, 0.55, 0.0], ...
            'DisplayName', sprintf('breakaway, K = %.2f', K_breakaway));

% 7. Styling: box off, outward ticks, soft grid, CMU Serif font
title(ax, 'Root locus of the closed loop versus gain K', ...
      'FontName', 'CMU Serif', 'FontSize', 13, 'FontWeight', 'normal', 'Color', [0.1, 0.1, 0.1]);
xlabel(ax, 'Real axis',      'FontName', 'CMU Serif', 'FontSize', 11, 'Color', [0.1, 0.1, 0.1]);
ylabel(ax, 'Imaginary axis', 'FontName', 'CMU Serif', 'FontSize', 11, 'Color', [0.1, 0.1, 0.1]);

xlim(ax, [-2.0, 0.0]);
ylim(ax, [-6.2, 6.2]);
xticks(ax, -2.0:0.5:0.0);
yticks(ax, -6:2:6);
xtickformat(ax, '%.1f');

box(ax, 'off');
grid(ax, 'on');
set(ax, 'Color', 'w', ...
        'YAxisLocation', 'right', ...
        'TickDir', 'out', ...
        'FontName', 'CMU Serif', ...
        'FontSize', 11, ...
        'XColor', [0.2, 0.2, 0.2], ...
        'YColor', [0.2, 0.2, 0.2], ...
        'GridColor', [0.88, 0.88, 0.88], ...
        'GridAlpha', 0.8, ...
        'LineWidth', 1.0);

% Legend in bottom-left corner
lgd = legend(ax, [h_ol, h_br], 'Location', 'southwest', ...
             'FontName', 'CMU Serif', 'FontSize', 9.5);
set(lgd, 'EdgeColor', [0.85, 0.85, 0.85], 'Color', 'w', 'TextColor', [0.1, 0.1, 0.1]);

% 8. Save High-Resolution Figure
scriptDir = fileparts(mfilename('fullpath'));
figDir = fullfile(scriptDir, '..', 'figures');
if ~exist(figDir, 'dir'), mkdir(figDir); end
figPath = fullfile(figDir, 'figure4_root_locus.png');

try
    exportgraphics(fig, figPath, 'Resolution', 300, 'BackgroundColor', 'white');
catch
    pause(0.5);
    exportgraphics(fig, figPath, 'Resolution', 300, 'BackgroundColor', 'white');
end
fprintf('Figure 4 saved successfully to %s\n', figPath);
