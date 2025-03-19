dataPosition = '../../Data/';
filename1 = 'exp_mezzoperiodo_LM741';
%filename2 = 'simulation_exp_OP07';

data1 = readmatrix(strcat(dataPosition, filename1, '.txt'));
tt = data1(:, 1);
ch1 = data1(:, 2);
ch2 = data1(:, 3);
sig_ch1 = repelem(0.001, length(ch1));
sig_ch2 = repelem(0.001, length(ch2));

limits = [3000, 15000];

function y = downwardExp(params, x)
    y = params(1) * exp(-params(2) * x) + params(3);
end




offset = 0.2;
quantity = ["A = ", "1/tau = R/L = ", "offset = "];
p0 = [0.2, 300, offset];
dimensions = ["V", "s", "V"];

ttFit = tt(limits(1):limits(2));
ch2Fit = ch2(limits(1):limits(2));
sig_ch2Fit = sig_ch2(limits(1):limits(2));

[p, R, ~, cov_p] = nlinfit(ttFit, ch2Fit, @downwardExp, p0);


t = tiledlayout(2, 1, "TileSpacing","tight", "Padding","tight");

ax1 = nexttile;
errorbar(tt, ch1, sig_ch1, '.', Color = '#0027BD');
hold on;
errorbar(tt, ch2, sig_ch2, '.', Color = '#FF0000');
errorbar(ttFit, ch2Fit, sig_ch2Fit, '.', Color = '#00ff00');
%plot(ttFit, downwardExp(p0, ttFit), '--', Color = 'magenta')    %p0
plot(ttFit, downwardExp(p, ttFit), 'v', Color = 'magenta');
hold off;
grid on;
grid minor;

ax2 = nexttile;
plot(ttFit, repelem(0, length(ttFit)), '--', Color = 'black');
hold on;
errorbar(ttFit, R, sig_ch2Fit, '.', Color = '#FF0000');
hold off;
grid on;
grid minor;


linkaxes([ax1, ax2], 'x');
xlim([-8e-3 8e-3]);


set(ax1,'Xticklabel',[])
ylabel(ax1, 'Voltage [V]', 'Interpreter', 'latex', 'FontSize', 14);

xlabel(ax2, 'Time [s]', 'Interpreter', 'latex', 'FontSize', 14);
ylabel(ax2, 'Residuals [V]', 'Interpreter', 'latex', 'FontSize', 14);

legend(ax1, 'Input', 'Output', 'Fitted Data', 'Fitted model', 'Location', 'ne', 'Interpreter', 'latex', 'FontSize', 14);
legend(ax2, 'Fitted Model', 'Residuals', 'Interpreter', 'latex', 'FontSize', 14);

title(t, 'LM741 - time domain analysis', 'Interpreter', 'latex', 'FontSize', 18);



%p
%sqrt(diag(cov_p))

% chi2

%chi2 = sum((R).^2 ./ sig_ch2Fit.^2);
%dof = length(ttFit) - length(p);

chi2 = 0;
for i = 1:length(ttFit)
    chi2 = chi2 + (ch2Fit(i) - downwardExp(p, ttFit(i)))^2 / sig_ch2Fit(i)^2;
%    chi2 = chi2 +  R(i)^2 / sig_ch2Fit(i)^2;
end
dof = length(ttFit) - length(p);
chi2_red = chi2 / dof;

fprintf('chi2 = %.10f\n', chi2_red)

for i = 1:3
    fprintf(strcat(quantity(i), sprintf('%.10f +- %.10f\n', p(i), sqrt(cov_p(i, i))), dimensions(i), '\n'));
end

%{
ax2 = nexttile;
plot(tt2, ch12, '.', Color = '#0027BD');
hold on
%plot(tt2, ch22, '.', Color = '#FF0000');
hold off
grid on
grid minor
%}
title(t, 'LM741')


