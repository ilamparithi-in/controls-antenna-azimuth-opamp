Vi = 1;
cases = {
  'Scheduled PD',        60, 300, 15;
  'Fixed PD',           173, 173, 10.99;
  'Scheduled, no deriv', 11, 150,  0;
};
figure; hold on; grid on
for k = 1:size(cases,1)
    Knear = cases{k,2}; Kfar = cases{k,3}; Kd = cases{k,4};
    out = sim('nl_gain_antenna');
    y = out.y.Data;  t = out.y.Time;
    plot(t, y, 'DisplayName', cases{k,1});
    fprintf('%-22s OS = %5.1f %%   Ts = %.2f s\n', cases{k,1}, (max(y)-1)*100, t(find(abs(y-1)>0.02,1,'last')));
end
legend show; xlabel('Time (s)'); ylabel('Y')
Knear = 60; Kfar = 300; Kd = 15;   % restore design values