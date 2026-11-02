% =========================================================================
% figure2_model_reduction.m
% 
% Report Citation:
% Section 2.3: "Reducing it to Second Order" (Figure 2)
% Comparison of Full 3rd-Order Model vs. Reduced 2nd-Order Model
% for Proportional Gains K = 41.3 and K = 100.
% =========================================================================

clear; clc; close all;

% 1. System Parameters (from Section 2.1 - 2.3)
% K_pot = 0.318 V/rad, K_g = 0.1, K_m = 2.083
c = 0.318 * 0.1 * 2.083;      % Loop constant c ≈ 0.0662
s = tf('s');

% 2. Simulation Settings
t = linspace(0, 8, 1000);
gains    = [41.3, 100];
y_limits = {[-0.055, 1.21], [-0.055, 1.41]};
y_ticks  = {0:0.2:1.2, 0:0.2:1.4};

% 3. Create Figure
fig = figure('Color', 'w', 'Position', [150, 150, 880, 370]);

for i = 1:2
    K = gains(i);
    
    % Reduced 2nd-order closed loop: Power amplifier replaced by its DC gain (= 1)
    % G_red(s) = (c * K) / (s * (s + 1.71))
    T_red = feedback((c * K) / (s * (s + 1.71)), 1);
    
    % Full 3rd-order closed loop: Includes fast power amplifier pole at -100 rad/s
    % G_full(s) = (c * K * 100) / (s * (s + 1.71) * (s + 100))
    T_full = feedback((c * K * 100) / (s * (s + 1.71) * (s + 100)), 1);
    
    % Step response: Output position voltage Y / Input command voltage Vi
    y_red  = step(T_red, t);
    y_full = step(T_full, t);
    
    % Plot curves
    ax = subplot(1, 2, i);
    plot(t, y_red,  '-',  'LineWidth', 2.0, 'Color', [0.12, 0.47, 0.71], ...
         'DisplayName', '2nd-order (reduced)');
    hold on;
    plot(t, y_full, '--', 'LineWidth', 2.0, 'Color', [1.00, 0.50, 0.05], ...
         'DisplayName', '3rd-order (full)');
    
    % Title & Labels
    title(sprintf('K = %g', K), 'FontName', 'CMU Serif', 'FontSize', 13, ...
          'FontWeight', 'normal', 'Color', [0.1, 0.1, 0.1]);
    xlabel('Time (s)', 'FontName', 'CMU Serif', 'FontSize', 11, 'Color', [0.1, 0.1, 0.1]);
    if i == 1
        ylabel('Y / Vi', 'FontName', 'CMU Serif', 'FontSize', 11, 'Color', [0.1, 0.1, 0.1]);
    end
    
    % Axis limits and ticks
    xlim([0, 8]);
    ylim(y_limits{i});
    xticks(0:1:8);
    yticks(y_ticks{i});
    ytickformat('%.1f');
    
    % Styling: Clean despine, outward ticks, soft light grid
    box off;
    grid on;
    set(ax, 'Color', 'w', ...
            'TickDir', 'out', ...
            'FontName', 'CMU Serif', ...
            'FontSize', 11, ...
            'XColor', [0.2, 0.2, 0.2], ...
            'YColor', [0.2, 0.2, 0.2], ...
            'GridColor', [0.88, 0.88, 0.88], ...
            'GridAlpha', 0.8, ...
            'LineWidth', 1.0);
    
    % Legend matching reference
    lgd = legend('Location', 'southeast', 'FontName', 'CMU Serif', 'FontSize', 9);
    set(lgd, 'EdgeColor', [0.85, 0.85, 0.85], 'Color', 'w', 'TextColor', [0.1, 0.1, 0.1]);
end

% 4. Save High-Quality Image
scriptDir = fileparts(mfilename('fullpath'));
figDir = fullfile(scriptDir, '..', 'figures');
if ~exist(figDir, 'dir'), mkdir(figDir); end
figPath = fullfile(figDir, 'figure2_model_reduction.png');

exportgraphics(fig, figPath, 'Resolution', 300, 'BackgroundColor', 'white');
fprintf('Figure 2 saved successfully to %s\n', figPath);
