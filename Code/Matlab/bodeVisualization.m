dataPosition = '../../Data/';
filename = 'dataBode002';
%filename2 = 'dataBode003';

mediaposition = '../../Media/';
medianame = 'AmplitudeOffsetIn';

flagSave = false;

% data import and creation of variance array
rawData = readmatrix(strcat(dataPosition, filename, '.txt'));
%rawData2 = readmatrix(strcat(dataPosition, filename2, '.txt'));

ff = rawData(:, 1);
A = rawData(:, 2);
ph = rawData(:, 8);

%vi = rawData(:, 4);
%s_i = repelem(2.1e-3, length(ff));
%oi = rawData(:, 10);
%vo = rawData(:, 6);
%s_o = repelem(1.5e-2, length(ff));

%ff = rawData(:, 1);
%vi2 = rawData2(:, 4);
%oi2 = rawData2(:, 10);
%vo2 = rawData2(:, 6);

t = tiledlayout(2, 1, "TileSpacing","tight", "Padding","tight");

ax1 = nexttile;
loglog(ff, A, 'o', Color = '#0027BD');
hold on
%semilogx(ff, oi, 'o', Color = 'blue');
%semilogx(ff, vi2, 'v', Color = 'magenta');
%semilogx(ff, oi2, 'v', Color = 'red');

grid on
grid minor
title('Amlitude and Offset of input signal');
%legend('Amplitude in - 4.5k divider', 'Offset in - 4.5k divider', 'Amplitude in - 45k divider', 'Offset in - 45k divider', Location= 'ne')


hold off


ax2 = nexttile;
semilogx(ff, ph, 'o', Color= '#0027bd');
grid on;
grid minor;
yticks(ax2, [-pi, -0.75*pi, -pi/2, -pi/4, 0, pi/4, pi/2, 0.75*pi, pi]);
yticklabels(ax2, {'-pi', '-3/4\pi', '-\pi/2', '-\pi/4', '0', '\pi/4', '\pi/2', '3/4\pi', '\pi'});

linkaxes([ax1, ax2], 'x');

xlabel(ax2, 'frequency [Hz]');
ylabel(ax1, 'Vi Amplitude [V]')
ylabel(ax2, 'Phase [radians]')


if flagSave
    fig = gcf;
    orient(fig, 'landscape')
    print(fig, strcat(mediaposition, medianame, '.pdf'), '-dpdf')
end
