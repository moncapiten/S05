dataPosition = '../../Data/';
filename1 = 'exp_mezzoperiodo_LM741';
%filename2 = 'simulation_exp_OP07';

data1 = readmatrix(strcat(dataPosition, filename1, '.txt'));
tt1 = data1(:, 1);
ch11 = data1(:, 2);
ch21 = data1(:, 3);

%{
data2 = readmatrix(strcat(dataPosition, filename2, '.txt'));
tt2 = data2(:, 1);
ch12 = data2(:, 2);
ch22 = data2(:, 3);
%}

t = tiledlayout(1, 1, "TileSpacing","tight", "Padding","tight");

%ax1 = nexttile;
plot(tt1, ch11, '.', Color = '#0027BD');
hold on
plot(tt1, ch21, '.', Color = '#FF0000');
hold off
grid on
grid minor

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


