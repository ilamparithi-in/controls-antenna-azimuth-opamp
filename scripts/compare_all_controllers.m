% =========================================================================
% compare_all_controllers.m
% Complete comparison of all 5 controller configurations:
% 1. Proportional (P-only, K = 41.3)
% 2. PD with Derivative on Error (Kp = 173, Kd = 34.6)
% 3. PD with Derivative on Output (Kp = 173, Kd = 10.99)
% 4. Scheduled PD (Knear = 60, Kfar = 300, Kd = 15)
% 5. Lead Compensator (K = 173, alpha = 0.283, T = 0.419)
% =========================================================================

clear; clc; close all

s = tf('s');
c = 0.0662;  c2 = 0.2083;  am = 1.71;  kpot = 0.318;
t = 0:0.005:6;

%% 1. Linear Closed-Loop Transfer Functions
% Case 1: P-only (K = 41.3)
T_p = feedback(41.3 * c / (s*(s + am)), 1);

% Case 2: PD on Error (Kp = 173, Kd = 34.6)
T_pd_err = c * (173 + 34.6*s) / (s^2 + (am + c*34.6)*s + c*173);

% Case 3: PD on Output (Kp = 173, Kd = 10.99)
T_pd_out = c * 173 / (s^2 + (am + c2*10.99)*s + c*173);

% Case 5: Lead Compensator (K = 173, alpha = 0.283, T = 0.419)
alpha = 0.283;  T = 0.419;
Gc = (T*s + 1) / (alpha*T*s + 1);
T_lead = feedback(173 * Gc * (c / (s*(s + am))), 1);

%% 2. Step Responses
[y_p, ~]      = step(T_p, t);
[y_pd_err, ~] = step(T_pd_err, t);
[y_pd_out, ~] = step(T_pd_out, t);
[y_lead, ~]   = step(T_lead, t);

%% 3. Scheduled PD (Nonlinear ODE Simulation from report Section 8)
Knear = 60;  Kfar = 300;  Kd_sch = 15;  V0 = 0.318;
Kfun = @(ve) Knear + (Kfar - Knear) * min(abs(ve)/V0, 1);
ve = @(Y) kpot * (1 - Y);
f  = @(t_in, x) [x(2); -am*x(2) + c2*( Kfun(ve(x(1)))*ve(x(1)) - Kd_sch*x(2) )];
opts = odeset('RelTol', 1e-8, 'AbsTol', 1e-10, 'MaxStep', 0.005);
[~, x_sch] = ode45(f, t, [0; 0], opts);
y_sch = x_sch(:, 1);

%% 4. Performance Metrics Calculation
responses = {y_p, y_pd_err, y_pd_out, y_sch, y_lead};
names = {'1. P only (K=41.3)', ...
         '2. PD on Error', ...
         '3. PD on Output', ...
         '4. Scheduled PD', ...
         '5. Lead Compensator'};

fprintf('=========================================================================\n');
fprintf('  CONTROLLER PERFORMANCE COMPARISON TABLE (1 V STEP RESPONSE)\n');
fprintf('=========================================================================\n');
fprintf('%-24s %-12s %-14s %-12s\n', 'Controller', 'Overshoot(%)', 'Settling Ts(s)', 'Peak Time(s)');
fprintf('-------------------------------------------------------------------------\n');

for i = 1:5
    y = responses{i};
    os = max(0, (max(y) - 1) * 100);
    idx_settled = find(abs(y - 1) > 0.02, 1, 'last');
    if isempty(idx_settled)
        ts = 0;
    else
        ts = t(idx_settled);
    end
    [~, idx_pk] = max(y);
    tp = t(idx_pk);
    fprintf('%-24s %6.1f %%       %5.2f s        %5.2f s\n', names{i}, os, ts, tp);
end
fprintf('=========================================================================\n\n');

%% 5. Plot Comparison
fig = figure('Position', [100, 100, 950, 550], 'Visible', 'off');
plot(t, y_p,      'Color', [0.5 0.5 0.5], 'LineWidth', 1.6, 'DisplayName', '1. P only (K = 41.3)'); hold on; grid on;
plot(t, y_pd_err, 'r--',                  'LineWidth', 1.8, 'DisplayName', '2. PD on Error (Kp=173, Kd=34.6)');
plot(t, y_pd_out, 'g-',                   'LineWidth', 2.0, 'DisplayName', '3. PD on Output (Kp=173, Kd=10.99)');
plot(t, y_sch,    'm-.',                  'LineWidth', 2.0, 'DisplayName', '4. Scheduled PD (60 \to 300, Kd=15)');
plot(t, y_lead,   'b-',                   'LineWidth', 2.2, 'DisplayName', '5. Lead Compensator (K=173, \alpha=0.28)');

yline(1.0, 'k:', 'LineWidth', 1.2, 'DisplayName', 'Reference (1 V)');
xlabel('Time (s)', 'FontSize', 11);
ylabel('Antenna Position Y (V)', 'FontSize', 11);
title('Comparison of All 5 Feedback Controllers (Antenna Azimuth Position Servo)', 'FontSize', 12);
legend('Location', 'southeast', 'FontSize', 10);
xlim([0, 5]); ylim([0, 1.25]);

scriptDir = fileparts(mfilename('fullpath'));
figDir = fullfile(scriptDir, '..', 'figures');
if ~exist(figDir, 'dir'), mkdir(figDir); end
figPath = fullfile(figDir, 'all_controllers_comparison.png');

saveas(fig, figPath);
fprintf('Comparison plot saved to %s\n', figPath);
