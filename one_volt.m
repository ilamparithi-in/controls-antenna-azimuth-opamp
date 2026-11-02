Vi = 1;
out = sim('nl_gain_antenna');

y = out.y.Data;  t = out.y.Time;
figure; plot(t,y); grid on
xlabel('Time (s)'); ylabel('Y (V)'); title('1 V step response')

figure; plot(out.keff.Time, out.keff.Data); grid on
xlabel('Time (s)'); ylabel('K_{eff}'); title('Effective gain')

fprintf('OS = %.1f %%,  Ts = %.2f s\n', ...
   (max(y)-Vi)/Vi*100, t(find(abs(y/Vi-1)>0.02,1,'last')));