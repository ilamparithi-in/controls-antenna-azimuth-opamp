% =========================================================================
% compare_pd_vs_lead_bode.m
% Illustrating the high-frequency noise ceiling:
% Ideal PD controller gain shoots to infinity vs. Lead compensator leveling off.
% =========================================================================

clear; clc; close all

s = tf('s');

% 1. Controllers (Normalized to base gain K = 173)
Kp = 173;  Kd = 10.99;
C_pd = Kp + Kd * s;                      % Ideal PD controller

% Lead compensator designed for same crossover region (alpha = 0.2, T = 0.15)
alpha = 0.2;  T = 0.15;
C_lead = Kp * (T*s + 1) / (alpha*T*s + 1); % Lead compensator

% 2. High-frequency frequency vector (0.1 rad/s to 10,000 rad/s)
w = logspace(-1, 4, 1000);

[mag_pd, ~]   = bode(C_pd, w);
[mag_lead, ~] = bode(C_lead, w);

mag_pd_db   = 20 * log10(squeeze(mag_pd));
mag_lead_db = 20 * log10(squeeze(mag_lead));

% 3. Plot Magnitude Comparison
figure('Position', [200, 200, 800, 500]);
semilogx(w, mag_pd_db, 'r--', 'LineWidth', 2, 'DisplayName', 'Ideal PD (shoots to \infty)');
hold on; grid on;
semilogx(w, mag_lead_db, 'b-', 'LineWidth', 2, 'DisplayName', 'Lead Compensator (levels off)');

% High-frequency gain ceiling for Lead
yline(20*log10(Kp/alpha), 'k:', 'LineWidth', 1.5, ...
      'DisplayName', sprintf('Lead High-Freq Ceiling (%.1f dB)', 20*log10(Kp/alpha)));

xlabel('Frequency \omega (rad/s)', 'FontSize', 11);
ylabel('Controller Magnitude (dB)', 'FontSize', 11);
title('High-Frequency Gain: PD Controller vs. Lead Compensator', 'FontSize', 12);
legend('Location', 'northwest', 'FontSize', 10);
xlim([0.1, 10000]); ylim([40, 110]);

scriptDir = fileparts(mfilename('fullpath'));
figDir = fullfile(scriptDir, '..', 'figures');
if ~exist(figDir, 'dir'), mkdir(figDir); end
figPath = fullfile(figDir, 'pd_vs_lead_noise_ceiling.png');

saveas(gcf, figPath);
fprintf('Plot saved to %s\n', figPath);
