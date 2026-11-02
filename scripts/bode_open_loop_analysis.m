clear; clc; close all

s = tf('s');
Gp = 0.0662 / (s * (s + 1.71));   % Antenna plant

fprintf('K        w_gc (rad/s)   PM (deg)\n');
for K = [11.04, 25, 41.3, 100, 173]
    [~, Pm, ~, wgc] = margin(K * Gp);
    fprintf('%5.1f    %6.2f         %5.1f\n', K, wgc, Pm);
end

figure; margin(41.3 * Gp); grid on
title('Open-Loop Frequency Response (K = 41.3)')
