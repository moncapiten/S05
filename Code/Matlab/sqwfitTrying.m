clear all;

dataPosition = '../../Data/';
filename = 'data004';

mediaposition = '../../Media/';
medianame = strcat('tda-', filename);

flagSave = true;
% data import and creation of variance array
rawData = readmatrix(strcat(dataPosition, filename, '.txt'));

tt = rawData(:, 1);
vi = rawData(:, 2);
vo = rawData(:, 3);


ttup = [];
viup = [];
ttdn = [];
vodn = [];

for i = 1:length(tt)
    if (abs(vi(i)) > 1.5) 
        ttup = [ttup, tt(i)];
        viup = [viup, vi(i)];
    end
    if (vi(i) < -1) && (tt(i) > 0)
        ttdn = [ttdn, tt(i)];
        vodn = [vodn, vo(i)];
    end
end


function y = funcSquare(params, t)
    w = 2*pi*params(2);
    
    y = params(1) * (square( w * t, 0.01) );
end

function y = dampedOsc(params, t)
    w = 2*pi*params(2);

    y = params(1) * sin(w*t + params(3)) .* exp(-t/params(4));

end

A = 2;
f = 1;
ph = 0;

p0 = [A, f];

p0do = [A, 1100,-pi*0.5, 2e-3]




[beta, R, ~, betacov] = nlinfit(ttup, viup, @funcSquare, p0);
[gamm, G, ~, gammcov] = nlinfit(ttdn, vodn, @dampedOsc, p0do);










t = tiledlayout(2, 2, "TileSpacing","tight", "Padding","tight");


ax1 = nexttile();
plot(ttup, viup, 'o', Color= '#0027bd');
hold on
plot(ttup, funcSquare(p0, ttup), '--', Color= 'cyan');
plot(ttup, funcSquare(beta, ttup), '-', Color= 'yellow');
grid on
grid minor
hold off


ax2 = nexttile();
plot(ttdn, vodn, 'v', Color= 'red');
hold on
plot(ttdn, dampedOsc(p0do, ttdn), '--', Color= 'magenta');
plot(ttdn, dampedOsc(gamm, ttdn), '-', Color= 'green');
grid on
grid minor
hold off

ax3 = nexttile();
plot(ttup, repelem(0, length(ttup)), '--', Color= 'yellow');
hold on
plot(ttup, R, 'o', Color= '#0027bd');
%plot(ttdn, dampedOsc(gamm, ttdn), '-', Color= 'green');
grid on
grid minor
hold off

ax4 = nexttile();
plot(ttdn, repelem(0, length(ttdn)), '--', Color= 'green');
hold on
plot(ttdn, G, 'v', Color='red');
grid on
grid minor

hold off



title(t, strcat("Time Domain Analysis - ", filename));
title(ax1, "Input Data");
title(ax2, "Output Data");

ylabel(ax1, 'Vi [V]');
ylabel(ax2, 'Vo [V]');
xlabel(ax3, 'Time [s]');
ylabel(ax3, 'Residuals - input [V]');
xlabel(ax4, 'Time [s]');
ylabel(ax4, 'Residuals - output [V]');


legend(ax1, 'Data in', 'model - p0', 'model - fitted', 'Location', 'se');
legend(ax2, 'Data out', 'model - p0', 'model - fit', 'Location', 'se');


linkaxes([ax1 ax3], 'x');
linkaxes([ax2 ax4], 'x');


xlim(ax1, [-5e-5, 1.5e-4])

xlim(ax2, [0, 6e-3]);
ylim(ax2, [-2, 2]);

ylim(ax4, [-1e-1, 5e-2]);


hold off




% image saving
if flagSave
    fig = gcf;
    orient(fig, 'landscape')
    print(fig, strcat(mediaposition, medianame, '.pdf'), '-dpdf')
end
