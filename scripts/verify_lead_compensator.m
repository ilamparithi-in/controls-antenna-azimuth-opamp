% =========================================================================
% verify_lead_compensator.m
% Verification of Lead Compensator design (K = 173, alpha = 0.283, T = 0.419)
% =========================================================================

clear; clc; close all

s = tf('s');
Gp = 0.0662 / (s * (s + 1.71));     % Antenna plant
K = 173;

% 1. Lead Compensator from Design Steps
alpha = 0.283;  T = 0.419;
Gc = (T*s + 1) / (alpha*T*s + 1);

% 2. Open-loop systems
Gol_uncomp = K * Gp;
Gol_lead   = Gc * Gol_uncomp;

% 3. Check Frequency Margins
[~, Pm_u, ~, wgc_u] = margin(Gol_uncomp);
[~, Pm_l, ~, wgc_l] = margin(Gol_lead);

fprintf('System            w_gc (rad/s)   PM (deg)   Target PM\n');
fprintf('-----------------------------------------------------\n');
fprintf('Uncompensated     %6.2f         %5.1f       --\n', wgc_u, Pm_u);
fprintf('Lead Compensated  %6.2f         %5.1f      55.0 deg\n\n', wgc_l, Pm_l);

% 4. Closed-loop step responses
T_uncomp = feedback(Gol_uncomp, 1);
T_lead   = feedback(Gol_lead, 1);

info_u = stepinfo(T_uncomp);
info_l = stepinfo(T_lead);

fprintf('System            Overshoot (%%)   Settling Ts (s)\n');
fprintf('-------------------------------------------------\n');
fprintf('Uncompensated     %6.1f %%         %5.2f s\n', info_u.Overshoot, info_u.SettlingTime);
fprintf('Lead Compensated  %6.1f %%         %5.2f s\n', info_l.Overshoot, info_l.SettlingTime);

% 5. Plots
fig = figure('Position', [150, 150, 850, 420], 'Visible', 'off');
t = 0:0.01:6;
[y_u, ~] = step(T_uncomp, t);
[y_l, ~] = step(T_lead, t);
plot(t, y_u, 'r--', 'LineWidth', 1.8); hold on; grid on;
plot(t, y_l, 'b-',  'LineWidth', 2.0);
legend('Uncompensated (K = 173)', 'Lead Compensated (Gc * K)', 'Location', 'southeast');
title('Closed-Loop Step Response: Uncompensated vs. Lead Compensated');
ylabel('Y / Vi (Normalised Position)'); xlabel('Time (s)');

scriptDir = fileparts(mfilename('fullpath'));
figDir = fullfile(scriptDir, '..', 'figures');
if ~exist(figDir, 'dir'), mkdir(figDir); end
figPath = fullfile(figDir, 'lead_compensator_step_response.png');

saveas(fig, figPath);
fprintf('Done saving step response plot to %s\n', figPath);
