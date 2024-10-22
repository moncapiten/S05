dataPosition = '../../Data/';
filename = 'dataBode001';
filename2 = 'dataBode003';

mediaposition = '../../Media/';
medianame = 'AmplitudeOffsetIn';

flagSave = false;

% data import and creation of variance array
rawData = readmatrix(strcat(dataPosition, filename, '.txt'));
rawData2 = readmatrix(strcat(dataPosition, filename2, '.txt'));

ff = rawData(:, 1);
vi = rawData(:, 4);
s_i = repelem(2.1e-3, length(ff));
oi = rawData(:, 10);
vo = rawData(:, 6);
s_o = repelem(1.5e-2, length(ff));

%ff = rawData(:, 1);
vi2 = rawData2(:, 4);
oi2 = rawData2(:, 10);
vo2 = rawData2(:, 6);



semilogx(ff, vi, 'o', Color = '#0027BD');
hold on
semilogx(ff, oi, 'o', Color = 'blue');
semilogx(ff, vi2, 'v', Color = 'magenta');
semilogx(ff, oi2, 'v', Color = 'red');

grid on
grid minor
title('Amlitude and Offset of input signal');
legend('Amplitude in - 4.5k divider', 'Offset in - 4.5k divider', 'Amplitude in - 45k divider', 'Offset in - 45k divider', Location= 'ne')
ylabel('Vi Amplitude [V]')
xlabel('frequency [Hz]')

hold off



if flagSave
    fig = gcf;
    orient(fig, 'landscape')
    print(fig, strcat(mediaposition, medianame, '.pdf'), '-dpdf')
end
