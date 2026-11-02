clear; clc; close all
set(0,'DefaultFigureVisible','on')

am = 1.71;  kpot = 0.318;  c2 = 0.2083;
Knear = 60; Kfar = 300; Kd = 15; V0 = 0.318;
Kfun = @(ve) Knear + (Kfar-Knear)*min(abs(ve)/V0, 1);

amps = [0.1 0.3 1 3 10];
opts = odeset('RelTol',1e-8,'AbsTol',1e-10,'MaxStep',0.005);

fig1 = figure('Name','Amplitude family');
ax1  = axes(fig1); hold(ax1,'on'); grid(ax1,'on')
fprintf('Step(V)   OS(%%)   Ts(s)\n');

for Vi = amps
    ve = @(Y) kpot*(Vi - Y);
    f  = @(t,x) [ x(2); -am*x(2) + c2*( Kfun(ve(x(1)))*ve(x(1)) - Kd*x(2) ) ];
    [t,x] = ode45(f,[0 10],[0;0],opts);
    y  = x(:,1)/Vi;
    plot(ax1,t,y,'DisplayName',sprintf('%g V step',Vi));
    OS = (max(y)-1)*100;
    Ts = t(find(abs(y-1)>0.02,1,'last'));
    fprintf('%6.1f   %5.1f   %5.2f\n',Vi,OS,Ts);
end
xlabel(ax1,'Time (s)'); ylabel(ax1,'Y / Vi');
title(ax1,'Scheduled PD: response vs step amplitude');
legend(ax1,'show','Location','southeast')

% Effective gain during the 1 V step
Vi = 1;
ve = @(Y) kpot*(Vi - Y);
f  = @(t,x) [x(2); -am*x(2) + c2*( Kfun(ve(x(1)))*ve(x(1)) - Kd*x(2) )];
[t,x] = ode45(f,[0 10],[0;0],opts);
Keff = arrayfun(@(Y) Kfun(ve(Y)), x(:,1));

fig2 = figure('Name','Effective gain');
ax2  = axes(fig2);
plot(ax2,t,Keff,'LineWidth',1.5); grid(ax2,'on')
xlabel(ax2,'Time (s)'); ylabel(ax2,'K_{eff}');
title(ax2,'Effective gain during a 1 V step')

drawnow; disp('Script finished')