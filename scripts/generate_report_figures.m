% =========================================================================
% generate_report_figures.m
% Generates all publication-grade figures for the Final Report:
% - Light mode (pure white background)
% - Pitch black fonts (Color = 'k', [0 0 0]) for maximum readability
% - Font: CMU Serif (crisp, high-contrast, bold titles)
% - High-resolution export (300 DPI) using exportgraphics
% =========================================================================

clear; clc; close all

% Global typography and appearance defaults
font_name = 'CMU Serif';
set(0, 'DefaultAxesFontName', font_name);
set(0, 'DefaultTextFontName', font_name);
set(0, 'DefaultTextColor', [0 0 0]);
set(0, 'DefaultAxesXColor', [0 0 0]);
set(0, 'DefaultAxesYColor', [0 0 0]);
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultTextFontSize', 12);

% High-contrast, clean publication colors
color_blue   = [0.000, 0.350, 0.700];   % Deep Royal Blue
color_red    = [0.800, 0.150, 0.100];   % Crimson Red
color_green  = [0.150, 0.600, 0.150];   % Deep Green
color_purple = [0.450, 0.100, 0.550];   % Deep Purple
color_amber  = [0.850, 0.550, 0.000];   % Dark Amber/Yellow
color_gray   = [0.300, 0.300, 0.300];   % Dark Charcoal

s = tf('s');
c = 0.0662;  c2 = 0.2083;  am = 1.71;  a = 100;
Gp_red  = c / (s * (s + am));
Gp_full = (c * a) / (s * (s + am) * (s + a));

w = logspace(-1, 3, 2000);

%% =========================================================================
%% FIGURE 1: Open-Loop Bode at Primary Design Gain K = 41.3 (Reduced vs Full)
%% =========================================================================
K_des = 41.3;
Gol_red  = K_des * Gp_red;
Gol_full = K_des * Gp_full;

[mag_r, phase_r, ~] = bode(Gol_red, w);
[mag_f, phase_f, ~] = bode(Gol_full, w);
mag_r_db = 20*log10(squeeze(mag_r));
mag_f_db = 20*log10(squeeze(mag_f));
phase_r_deg = squeeze(phase_r);
phase_f_deg = squeeze(phase_f);

[~, Pm_r, ~, Wcp_r] = margin(Gol_red);
[Gm_f, Pm_f, Wcg_f, Wcp_f] = margin(Gol_full);

fig1 = figure('Name', 'Bode Design Gain Comparison', 'Position', [100, 100, 850, 620], 'Color', 'w', 'Visible', 'off');

% Subplot 1: Magnitude
subplot(2, 1, 1);
semilogx(w, mag_r_db, 'Color', color_blue, 'LineWidth', 2.2, 'DisplayName', 'Reduced 2nd-Order Model'); hold on;
semilogx(w, mag_f_db, '--', 'Color', color_red, 'LineWidth', 2.0, 'DisplayName', 'Full 3rd-Order Model');
yline(0, 'k:', 'LineWidth', 1.4, 'DisplayName', '0 dB line');
plot(Wcp_r, 0, 'o', 'Color', color_blue, 'MarkerFaceColor', color_blue, 'MarkerSize', 6.5, ...
     'DisplayName', sprintf('\\omega_{gc} = %.2f rad/s', Wcp_r));

grid on; box on;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'LineWidth', 1.1, ...
         'GridColor', [0.8 0.8 0.8], 'GridAlpha', 0.8, 'FontName', font_name, 'FontSize', 11.5);
ylabel('Magnitude (dB)', 'Color', 'k', 'FontName', font_name, 'FontSize', 12, 'FontWeight', 'bold');
title(sprintf('Open-Loop Frequency Response at Design Gain K = %.1f', K_des), ...
      'Color', 'k', 'FontName', font_name, 'FontSize', 13, 'FontWeight', 'bold');
xlim([0.1, 1000]); ylim([-95, 45]);
leg1 = legend('Location', 'northeast', 'FontName', font_name, 'FontSize', 10, 'TextColor', 'k', 'Box', 'on', 'Color', 'w');
set(leg1, 'EdgeColor', [0.6 0.6 0.6]);

% Subplot 2: Phase
subplot(2, 1, 2);
semilogx(w, phase_r_deg, 'Color', color_blue, 'LineWidth', 2.2, 'DisplayName', 'Reduced 2nd-Order Model'); hold on;
semilogx(w, phase_f_deg, '--', 'Color', color_red, 'LineWidth', 2.0, 'DisplayName', 'Full 3rd-Order Model');
yline(-180, 'k:', 'LineWidth', 1.4, 'DisplayName', '-180^\circ line');

% Vertical markers for phase margins
plot([Wcp_r, Wcp_r], [-180, -180 + Pm_r], 'Color', color_blue, 'LineWidth', 2.4, ...
     'DisplayName', sprintf('PM (Reduced) = %.1f^\\circ', Pm_r));
plot([Wcp_f, Wcp_f], [-180, -180 + Pm_f], '--', 'Color', color_red, 'LineWidth', 2.2, ...
     'DisplayName', sprintf('PM (Full) = %.1f^\\circ', Pm_f));
plot(Wcg_f, -180, 's', 'Color', [0.1 0.5 0.1], 'MarkerFaceColor', [0.1 0.5 0.1], 'MarkerSize', 6.5, ...
     'DisplayName', sprintf('\\omega_{pc} = %.2f rad/s (GM = %.1f dB)', Wcg_f, 20*log10(Gm_f)));

grid on; box on;
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'LineWidth', 1.1, ...
         'GridColor', [0.8 0.8 0.8], 'GridAlpha', 0.8, 'FontName', font_name, 'FontSize', 11.5);
xlabel('Frequency \omega (rad/s)', 'Color', 'k', 'FontName', font_name, 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Phase (deg)', 'Color', 'k', 'FontName', font_name, 'FontSize', 12, 'FontWeight', 'bold');
xlim([0.1, 1000]); ylim([-285, -45]);
leg2 = legend('Location', 'northeast', 'FontName', font_name, 'FontSize', 9.5, 'TextColor', 'k', 'Box', 'on', 'Color', 'w');
set(leg2, 'EdgeColor', [0.6 0.6 0.6]);

exportgraphics(fig1, 'bode_design_gain_comparison.png', 'Resolution', 300);
close(fig1);
disp('Saved: bode_design_gain_comparison.png');

%% =========================================================================
%% FIGURE 2: Open-Loop Bode for Varying K (Reduced Plant)
%% =========================================================================
gains = [11.04, 25, 41.3, 100, 173];
gain_colors = [color_gray; color_amber; color_green; color_blue; color_red];

fig2 = figure('Name', 'Bode Open Loop Varying K', 'Position', [150, 150, 850, 620], 'Color', 'w', 'Visible', 'off');

subplot(2, 1, 1); hold on; grid on; box on;
for i = 1:length(gains)
    [mag, ~, ~] = bode(gains(i) * Gp_red, w);
    semilogx(w, 20*log10(squeeze(mag)), 'Color', gain_colors(i,:), 'LineWidth', 2.0, ...
             'DisplayName', sprintf('K = %.1f', gains(i)));
end
yline(0, 'k:', 'LineWidth', 1.4, 'DisplayName', '0 dB line');
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'LineWidth', 1.1, ...
         'GridColor', [0.8 0.8 0.8], 'GridAlpha', 0.8, 'FontName', font_name, 'FontSize', 11.5);
ylabel('Magnitude (dB)', 'Color', 'k', 'FontName', font_name, 'FontSize', 12, 'FontWeight', 'bold');
title('Open-Loop Bode Response for Varying Proportional Gain K', ...
      'Color', 'k', 'FontName', font_name, 'FontSize', 13, 'FontWeight', 'bold');
xlim([0.1, 100]); ylim([-65, 45]);
leg3 = legend('Location', 'northeast', 'FontName', font_name, 'FontSize', 10, 'TextColor', 'k', 'Box', 'on', 'Color', 'w');
set(leg3, 'EdgeColor', [0.6 0.6 0.6]);

subplot(2, 1, 2); hold on; grid on; box on;
for i = 1:length(gains)
    [~, ph, ~] = bode(gains(i) * Gp_red, w);
    semilogx(w, squeeze(ph), 'Color', gain_colors(i,:), 'LineWidth', 2.0, ...
             'DisplayName', sprintf('K = %.1f', gains(i)));
end
yline(-180, 'k:', 'LineWidth', 1.4, 'DisplayName', '-180^\circ line');
set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'LineWidth', 1.1, ...
         'GridColor', [0.8 0.8 0.8], 'GridAlpha', 0.8, 'FontName', font_name, 'FontSize', 11.5);
xlabel('Frequency \omega (rad/s)', 'Color', 'k', 'FontName', font_name, 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Phase (deg)', 'Color', 'k', 'FontName', font_name, 'FontSize', 12, 'FontWeight', 'bold');
xlim([0.1, 100]); ylim([-185, -85]);

exportgraphics(fig2, 'bode_open_loop_gains.png', 'Resolution', 300);
close(fig2);
disp('Saved: bode_open_loop_gains.png');

%% =========================================================================
%% FIGURE 3: High-Frequency Noise Ceiling (Ideal PD vs. Lead Compensator)
%% =========================================================================
Kp = 173;  Kd = 10.99;
C_pd = Kp + Kd * s;
alpha = 0.283;  T = 0.419;
Gc = (T*s + 1) / (alpha*T*s + 1);
C_lead = Kp * Gc;

w_noise = logspace(-1, 4, 1000);
[mag_pd, ~]   = bode(C_pd, w_noise);
[mag_lead, ~] = bode(C_lead, w_noise);

fig3 = figure('Name', 'PD vs Lead Noise Ceiling', 'Position', [200, 200, 820, 500], 'Color', 'w', 'Visible', 'off');
semilogx(w_noise, 20*log10(squeeze(mag_pd)), '--', 'Color', color_red, 'LineWidth', 2.2, ...
         'DisplayName', 'Ideal PD (Gain \rightarrow \infty at +20 dB/dec)'); hold on; grid on; box on;
semilogx(w_noise, 20*log10(squeeze(mag_lead)), 'Color', color_blue, 'LineWidth', 2.4, ...
         'DisplayName', 'Lead Compensator (Levels off at +11.0 dB)');
yline(20*log10(Kp/alpha), 'k:', 'LineWidth', 1.5, ...
      'DisplayName', sprintf('High-Frequency Gain Ceiling (%.1f dB)', 20*log10(Kp/alpha)));

set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'LineWidth', 1.1, ...
         'GridColor', [0.8 0.8 0.8], 'GridAlpha', 0.8, 'FontName', font_name, 'FontSize', 11.5);
xlabel('Frequency \omega (rad/s)', 'Color', 'k', 'FontName', font_name, 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Controller Magnitude (dB)', 'Color', 'k', 'FontName', font_name, 'FontSize', 12, 'FontWeight', 'bold');
title('High-Frequency Noise Gain: Ideal PD Controller vs. Lead Compensator', ...
      'Color', 'k', 'FontName', font_name, 'FontSize', 13, 'FontWeight', 'bold');
xlim([0.1, 10000]); ylim([35, 115]);
leg4 = legend('Location', 'northwest', 'FontName', font_name, 'FontSize', 10.5, 'TextColor', 'k', 'Box', 'on', 'Color', 'w');
set(leg4, 'EdgeColor', [0.6 0.6 0.6]);

exportgraphics(fig3, 'pd_vs_lead_noise_ceiling.png', 'Resolution', 300);
close(fig3);
disp('Saved: pd_vs_lead_noise_ceiling.png');

%% =========================================================================
%% FIGURE 4: Lead Compensator Step Response (Uncompensated K=173 vs Lead)
%% =========================================================================
t_step = 0:0.005:5;
T_uncomp_173 = feedback(173 * Gp_red, 1);
T_lead_comp  = feedback(173 * Gc * Gp_red, 1);

[y_u173, ~] = step(T_uncomp_173, t_step);
[y_lcomp, ~] = step(T_lead_comp, t_step);

fig4 = figure('Name', 'Lead Step Response Verification', 'Position', [250, 250, 820, 480], 'Color', 'w', 'Visible', 'off');
plot(t_step, y_u173, '--', 'Color', color_red, 'LineWidth', 2.0, ...
     'DisplayName', 'Uncompensated Plant (K = 173): OS = 44.0%, Ts = 4.17 s'); hold on; grid on; box on;
plot(t_step, y_lcomp, 'Color', color_blue, 'LineWidth', 2.4, ...
     'DisplayName', 'Lead Compensated (Gc \cdot K): OS = 15.1%, Ts = 1.10 s');
yline(1.0, 'k:', 'LineWidth', 1.4, 'DisplayName', 'Target Reference (1.0 V)');

set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'LineWidth', 1.1, ...
         'GridColor', [0.8 0.8 0.8], 'GridAlpha', 0.8, 'FontName', font_name, 'FontSize', 11.5);
xlabel('Time (s)', 'Color', 'k', 'FontName', font_name, 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Antenna Shaft Position Y (V)', 'Color', 'k', 'FontName', font_name, 'FontSize', 12, 'FontWeight', 'bold');
title('Closed-Loop Unit Step Response: Uncompensated vs. Lead Compensated', ...
      'Color', 'k', 'FontName', font_name, 'FontSize', 13, 'FontWeight', 'bold');
xlim([0, 5]); ylim([0, 1.55]);
leg5 = legend('Location', 'northeast', 'FontName', font_name, 'FontSize', 10.5, 'TextColor', 'k', 'Box', 'on', 'Color', 'w');
set(leg5, 'EdgeColor', [0.6 0.6 0.6]);

exportgraphics(fig4, 'lead_compensator_step_response.png', 'Resolution', 300);
close(fig4);
disp('Saved: lead_compensator_step_response.png');

%% =========================================================================
%% FIGURE 5: Controlled Comparison of All Controllers (1 V Step)
%% =========================================================================
T_p_41 = feedback(41.3 * Gp_red, 1);
T_pd_err = c * (173 + 34.6*s) / (s^2 + (am + c*34.6)*s + c*173);
T_pd_out = c * 173 / (s^2 + (am + c2*10.99)*s + c*173);

[y_p41, ~]    = step(T_p_41, t_step);
[y_pderr, ~]  = step(T_pd_err, t_step);
[y_pdout, ~]  = step(T_pd_out, t_step);

% Scheduled PD (nonlinear ODE)
Knear = 60;  Kfar = 300;  Kd_sch = 15;  V0 = 0.318;  kpot = 0.318;
Kfun = @(ve) Knear + (Kfar - Knear) * min(abs(ve)/V0, 1);
ve_fn = @(Y) kpot * (1 - Y);
f_ode = @(t_in, x) [x(2); -am*x(2) + c2*( Kfun(ve_fn(x(1)))*ve_fn(x(1)) - Kd_sch*x(2) )];
opts = odeset('RelTol', 1e-8, 'AbsTol', 1e-10, 'MaxStep', 0.005);
[~, x_sch] = ode45(f_ode, t_step, [0; 0], opts);
y_sch = x_sch(:, 1);

fig5 = figure('Name', 'All Controllers Comparison', 'Position', [100, 100, 950, 680], 'Color', 'w', 'Visible', 'off');
plot(t_step, y_p41,   'Color', color_gray,   'LineWidth', 2.0, 'DisplayName', '1. P only (K = 41.3): OS = 15.0%, Ts = 4.75 s'); hold on; grid on; box on;
plot(t_step, y_pderr, '--', 'Color', color_amber, 'LineWidth', 2.0, 'DisplayName', '2. PD on Error (Kp=173, Kd=34.6): OS = 13.9%, Ts = 1.53 s');
plot(t_step, y_pdout, 'Color', color_green,  'LineWidth', 2.2, 'DisplayName', '3. PD on Output (Kp=173, Kd=10.99): OS = 10.0%, Ts = 1.75 s');
plot(t_step, y_sch,   '-.', 'Color', color_purple, 'LineWidth', 2.2, 'DisplayName', '4. Scheduled PD (60 \to 300, Kd=15): OS = 4.4%, Ts = 2.21 s');
plot(t_step, y_lcomp, 'Color', color_blue,   'LineWidth', 2.4, 'DisplayName', '5. Lead Compensator (K=173, \alpha=0.28): OS = 15.1%, Ts = 1.10 s');
yline(1.0, 'k:', 'LineWidth', 1.4, 'DisplayName', 'Reference (1.0 V)');

set(gca, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'LineWidth', 1.1, ...
         'GridColor', [0.8 0.8 0.8], 'GridAlpha', 0.8, 'FontName', font_name, 'FontSize', 11.5);
xlabel('Time (s)', 'Color', 'k', 'FontName', font_name, 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Antenna Position Y (V)', 'Color', 'k', 'FontName', font_name, 'FontSize', 12, 'FontWeight', 'bold');
title('Controlled Comparison of Feedback Controllers (1 V Step Response)', ...
      'Color', 'k', 'FontName', font_name, 'FontSize', 13, 'FontWeight', 'bold');
xlim([0, 5]); ylim([0, 1.70]);
leg6 = legend('Location', 'northeast', 'FontName', font_name, 'FontSize', 10.0, 'TextColor', 'k', 'Box', 'on', 'Color', 'w');
set(leg6, 'EdgeColor', [0.6 0.6 0.6]);

exportgraphics(fig5, 'all_controllers_comparison.png', 'Resolution', 300);
close(fig5);
disp('Saved: all_controllers_comparison.png');

fprintf('\nAll 5 figures successfully exported at 300 DPI with solid black text!\n');
