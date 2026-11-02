figure; hold on; grid on
fprintf('Step(V)   OS(%%)   Ts(s)\n');
for v = [0.1 0.3 1 3 10]
    Vi = v;
    out = sim('nl_gain_antenna');
    y = out.y.Data/v;  t = out.y.Time;
    plot(t, y, 'DisplayName', sprintf('%g V', v));
    fprintf('%6.1f   %5.1f   %5.2f\n', v, (max(y)-1)*100, t(find(abs(y-1)>0.02,1,'last')));
end
legend show; xlabel('Time (s)'); ylabel('Y / Vi')
title('Scheduled PD: response vs step amplitude')
Vi = 1;   % restore