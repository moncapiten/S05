dataPosition = '../../Data/';
filename = 'dataBode001';

data = readmatrix(strcat(dataPosition, filename, '.txt'));
tt = data(:, 1);
ch1 = data(:, 2);
ch2 = data(:, 3);

t = tiledlayout(2, 1);

nexttile
plot(tt, ch1, 'o', Color = '#0027BD');
grid on
grid minor

nexttile
plot(tt, ch1, 'o', Color = '#0027BD');
grid on
grid minor

title(t, 'Data Visualization')
